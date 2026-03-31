"""
Service 2 — Lambda Order Processor (Python 3.12)
-------------------------------------------------
Deployed on: AWS Lambda, VPC2
Handler:     lambda.lambda_handler   (matches main.tf)
Role:        Process orders forwarded by Service 1 (ECS) via VPC Lattice

VPC Lattice invokes the Lambda with an event shaped like:
{
  "version": "1.0",
  "path": "/order",
  "method": "POST",
  "headers": { ... },
  "queryStringParameters": {},
  "body": "<JSON string>",
  "isBase64Encoded": false
}

The function also exposes GET /orders  (list recent orders)
and GET /           (health check).

Note: If this Lambda needs to call other Lattice services itself,
use the lattice_request() helper below — it signs requests with
SigV4 using boto3's built-in credential chain.
"""

import json
import uuid
import os
import logging
from datetime import datetime, timezone

# boto3 is available in the Lambda runtime; no layer needed.
import boto3
from botocore.auth import SigV4Auth
from botocore.awsrequest import AWSRequest
from botocore.credentials import RefreshableCredentials
import urllib.request
import urllib.parse

logger = logging.getLogger()
logger.setLevel(logging.INFO)

AWS_REGION = os.environ.get("AWS_REGION", "us-east-1")

# In-memory order store (resets per Lambda cold-start — use DynamoDB in production)
_orders: list[dict] = []

# ── SigV4 helper (for Lambda → Lattice calls if needed) ───────────────────

def lattice_request(method: str, url: str, body: dict | None = None) -> dict:
    """
    Makes an IAM-signed HTTP request to a VPC Lattice service.
    Lambda's execution role credentials are picked up automatically.
    """
    session = boto3.Session()
    creds   = session.get_credentials().get_frozen_credentials()

    body_bytes = json.dumps(body).encode() if body else b""
    headers = {
        "Content-Type": "application/json",
        "Content-Length": str(len(body_bytes)),
    }

    aws_request = AWSRequest(method=method.upper(), url=url, data=body_bytes, headers=headers)
    SigV4Auth(creds, "vpc-lattice-svcs", AWS_REGION).add_auth(aws_request)
    signed_headers = dict(aws_request.headers)

    req = urllib.request.Request(url, data=body_bytes or None, headers=signed_headers, method=method.upper())
    with urllib.request.urlopen(req, timeout=10) as resp:
        return json.loads(resp.read())


# ── Route dispatcher ───────────────────────────────────────────────────────

def lambda_handler(event: dict, context) -> dict:
    """Main Lambda entry point — routes VPC Lattice HTTP events."""
    logger.info("Event: %s", json.dumps(event))

    method = event.get("method", "GET").upper()
    path   = event.get("path", "/").rstrip("/") or "/"
    body   = {}

    raw_body = event.get("body", "")
    if raw_body:
        try:
            body = json.loads(raw_body)
        except json.JSONDecodeError:
            return _response(400, {"error": "Invalid JSON body"})

    # ── Routing ──────────────────────────────────────────────────────────
    if path == "/" and method == "GET":
        return _health_check()

    if path == "/health" and method == "GET":
        return _health_check()

    if path == "/order" and method == "POST":
        return _process_order(body)

    if path == "/orders" and method == "GET":
        return _list_orders()

    return _response(404, {"error": f"Route {method} {path} not found"})


# ── Handlers ───────────────────────────────────────────────────────────────

def _health_check() -> dict:
    return _response(200, {
        "service":   "service2-lambda-order-processor",
        "status":    "healthy",
        "timestamp": _now(),
        "version":   "1.0.0",
        "orders_in_memory": len(_orders),
    })


def _process_order(body: dict) -> dict:
    required = {"productId", "productName", "quantity", "unitPrice", "customerId", "totalAmount"}
    missing  = required - body.keys()
    if missing:
        return _response(400, {"error": f"Missing fields: {', '.join(sorted(missing))}"})

    quantity    = int(body["quantity"])
    unit_price  = float(body["unitPrice"])
    total       = round(quantity * unit_price, 2)

    order = {
        "orderId":     str(uuid.uuid4())[:8].upper(),
        "productId":   body["productId"],
        "productName": body["productName"],
        "customerId":  body["customerId"],
        "quantity":    quantity,
        "unitPrice":   unit_price,
        "totalAmount": total,
        "status":      "CONFIRMED",
        "createdAt":   _now(),
        "estimatedDelivery": "3-5 business days",
    }

    _orders.append(order)
    logger.info("Order created: %s", order["orderId"])

    return _response(201, {
        "message":     "Order processed successfully",
        "order":       order,
        "processedBy": "service2-lambda",
    })


def _list_orders() -> dict:
    return _response(200, {
        "orders":      _orders,
        "count":       len(_orders),
        "processedBy": "service2-lambda",
        "timestamp":   _now(),
    })


# ── Helpers ────────────────────────────────────────────────────────────────

def _response(status_code: int, body: dict) -> dict:
    """Returns a VPC Lattice-compatible HTTP response."""
    return {
        "statusCode": status_code,
        "headers":    {"Content-Type": "application/json"},
        "body":       json.dumps(body),
    }


def _now() -> str:
    return datetime.now(timezone.utc).isoformat()
