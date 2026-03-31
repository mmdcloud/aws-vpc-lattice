/**
 * Service 1 — ECS Orchestrator (Node.js / Express)
 * -------------------------------------------------------
 * Deployed on: ECS Fargate, VPC1, port 8080
 * Role: API gateway / orchestrator — fans out to Service 2
 *       (Lambda) and Service 3 (EC2/ASG) via VPC Lattice.
 *
 * Environment variables (set via ECS task definition or
 * terraform.tfvars injected at deploy time):
 *   SERVICE2_LATTICE_URL  — VPC Lattice DNS for the Lambda service
 *   SERVICE3_LATTICE_URL  — VPC Lattice DNS for the EC2/ASG service
 *   AWS_REGION            — e.g. us-east-1 (auto-set in ECS)
 *
 * Inter-service calls are signed with SigV4 because the Lattice
 * service network uses auth_type = "AWS_IAM".
 */

const express = require("express");
const aws4    = require("aws4");
const axios   = require("axios");
const https   = require("https");
const http    = require("http");
const { URL } = require("url");

const app  = express();
const PORT = process.env.PORT || 8080;

// ── Lattice service URLs (injected via ECS task env vars) ──────────────────
const SERVICE2_URL = process.env.SERVICE2_LATTICE_URL || "http://service2-placeholder.vpc-lattice-svcs.us-east-1.on.aws";
const SERVICE3_URL = process.env.SERVICE3_LATTICE_URL || "http://service3-placeholder.vpc-lattice-svcs.us-east-1.on.aws";
const AWS_REGION   = process.env.AWS_REGION || "us-east-1";

app.use(express.json());

// ── SigV4 helper ───────────────────────────────────────────────────────────
/**
 * Makes an IAM-signed HTTP request to a VPC Lattice service.
 *
 * @param {string} method  - HTTP method (GET, POST, …)
 * @param {string} url     - Full URL including path
 * @param {object} body    - Request body (will be JSON-serialised)
 */
async function latticeRequest(method, url, body = null) {
  const parsed   = new URL(url);
  const bodyStr  = body ? JSON.stringify(body) : "";
  const isHttps  = parsed.protocol === "https:";

  const opts = {
    host:    parsed.hostname,
    path:    parsed.pathname + parsed.search,
    method:  method.toUpperCase(),
    service: "vpc-lattice-svcs",
    region:  AWS_REGION,
    headers: {
      "Content-Type": "application/json",
      ...(bodyStr && { "Content-Length": Buffer.byteLength(bodyStr).toString() }),
    },
    ...(bodyStr && { body: bodyStr }),
  };

  // aws4 signs in-place; it reads credentials from the ECS task role env vars
  aws4.sign(opts);

  const response = await axios({
    method:  opts.method,
    url:     url,
    headers: opts.headers,
    data:    bodyStr || undefined,
    httpsAgent: isHttps ? new https.Agent({ rejectUnauthorized: true }) : undefined,
    httpAgent:  !isHttps ? new http.Agent() : undefined,
    timeout: 10000,
  });

  return response.data;
}

// ── Sample data ────────────────────────────────────────────────────────────
const PRODUCTS = [
  { id: "P001", name: "Laptop",     price: 999.99,  category: "Electronics" },
  { id: "P002", name: "Headphones", price: 149.99,  category: "Electronics" },
  { id: "P003", name: "Desk Chair", price: 299.99,  category: "Furniture"   },
  { id: "P004", name: "Monitor",    price: 499.99,  category: "Electronics" },
  { id: "P005", name: "Keyboard",   price:  89.99,  category: "Electronics" },
];

// ── Routes ─────────────────────────────────────────────────────────────────

/** Health check — used by ALB target group */
app.get("/", (req, res) => {
  res.json({
    service:   "service1-ecs-orchestrator",
    status:    "healthy",
    timestamp: new Date().toISOString(),
    version:   "1.0.0",
  });
});

/** List all products (local data) */
app.get("/products", (req, res) => {
  res.json({ products: PRODUCTS, count: PRODUCTS.length });
});

/**
 * POST /order
 * Body: { productId: "P001", quantity: 2, customerId: "C123" }
 *
 * Calls Service 2 (Lambda) via VPC Lattice to process the order.
 */
app.post("/order", async (req, res) => {
  const { productId, quantity, customerId } = req.body;

  if (!productId || !quantity || !customerId) {
    return res.status(400).json({ error: "productId, quantity and customerId are required" });
  }

  const product = PRODUCTS.find((p) => p.id === productId);
  if (!product) {
    return res.status(404).json({ error: `Product ${productId} not found` });
  }

  try {
    // ── Call Service 2 (Lambda) via VPC Lattice ──
    const orderPayload = {
      productId,
      productName: product.name,
      quantity,
      unitPrice:   product.price,
      customerId,
      totalAmount: product.price * quantity,
    };

    const orderResult = await latticeRequest("POST", `${SERVICE2_URL}/order`, orderPayload);

    res.json({
      message:      "Order placed successfully",
      product,
      orderDetails: orderResult,
      processedBy:  "service2-lambda",
    });
  } catch (err) {
    console.error("Error calling Service 2 (Lambda):", err.message);
    res.status(502).json({ error: "Failed to process order", details: err.message });
  }
});

/**
 * GET /inventory/:productId?
 *
 * Calls Service 3 (EC2/ASG) via VPC Lattice to get inventory data.
 * Optionally filter by productId.
 */
app.get("/inventory/:productId?", async (req, res) => {
  const { productId } = req.params;

  try {
    const path = productId ? `/stock/${productId}` : "/inventory";
    const inventoryData = await latticeRequest("GET", `${SERVICE3_URL}${path}`);

    res.json({
      ...inventoryData,
      fetchedBy: "service1-ecs",
      source:    "service3-ec2-asg",
    });
  } catch (err) {
    console.error("Error calling Service 3 (EC2/ASG):", err.message);
    res.status(502).json({ error: "Failed to fetch inventory", details: err.message });
  }
});

/**
 * GET /dashboard
 *
 * Aggregates data from both Service 2 and Service 3 in parallel
 * to build a unified dashboard response.
 */
app.get("/dashboard", async (req, res) => {
  const [inventoryResult, ordersResult] = await Promise.allSettled([
    latticeRequest("GET", `${SERVICE3_URL}/inventory`),
    latticeRequest("GET", `${SERVICE2_URL}/orders`),
  ]);

  res.json({
    service:   "service1-ecs-orchestrator",
    timestamp: new Date().toISOString(),
    products:  { count: PRODUCTS.length, items: PRODUCTS },
    inventory: inventoryResult.status === "fulfilled"
      ? { status: "ok", data: inventoryResult.value }
      : { status: "error", reason: inventoryResult.reason?.message },
    orders: ordersResult.status === "fulfilled"
      ? { status: "ok", data: ordersResult.value }
      : { status: "error", reason: ordersResult.reason?.message },
  });
});

/** Liveness / readiness probe */
app.get("/health", (req, res) => res.json({ status: "ok" }));

// ── Start ──────────────────────────────────────────────────────────────────
app.listen(PORT, "0.0.0.0", () => {
  console.log(`[Service 1 - ECS Orchestrator] Listening on port ${PORT}`);
  console.log(`  → Service 2 (Lambda) : ${SERVICE2_URL}`);
  console.log(`  → Service 3 (EC2/ASG): ${SERVICE3_URL}`);
});
