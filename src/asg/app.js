/**
 * Service 3 — EC2/ASG Inventory Service (Node.js / Express)
 * -----------------------------------------------------------
 * Deployed on: EC2 Auto Scaling Group, VPC3, port 8080
 * Role: Manages product inventory data
 *
 * Routes:
 *   GET /              → health check (ALB health probe)
 *   GET /health        → health check
 *   GET /inventory     → full inventory list
 *   GET /stock/:id     → stock for a single product
 *   PUT /stock/:id     → update stock quantity
 */

const express = require("express");

const app  = express();
const PORT = process.env.PORT || 8080;

app.use(express.json());

// ── In-memory inventory (use DynamoDB/RDS in production) ───────────────────
const inventory = {
  P001: { productId: "P001", productName: "Laptop",     stock: 42,  warehouse: "WH-EAST", reorderThreshold: 10 },
  P002: { productId: "P002", productName: "Headphones", stock: 120, warehouse: "WH-EAST", reorderThreshold: 20 },
  P003: { productId: "P003", productName: "Desk Chair", stock: 18,  warehouse: "WH-WEST", reorderThreshold: 5  },
  P004: { productId: "P004", productName: "Monitor",    stock: 35,  warehouse: "WH-EAST", reorderThreshold: 8  },
  P005: { productId: "P005", productName: "Keyboard",   stock: 200, warehouse: "WH-WEST", reorderThreshold: 30 },
};

// ── Routes ─────────────────────────────────────────────────────────────────

/** Health check — ALB target group health probe on GET / */
app.get(["/", "/health"], (req, res) => {
  res.json({
    service:   "service3-ec2-asg-inventory",
    status:    "healthy",
    timestamp: new Date().toISOString(),
    version:   "1.0.0",
    hostname:  process.env.HOSTNAME || require("os").hostname(),
  });
});

/** Return full inventory */
app.get("/inventory", (req, res) => {
  const items = Object.values(inventory).map((item) => ({
    ...item,
    status: stockStatus(item.stock, item.reorderThreshold),
    lastUpdated: new Date().toISOString(),
  }));

  res.json({
    inventory: items,
    count:     items.length,
    source:    "service3-ec2-asg",
    timestamp: new Date().toISOString(),
  });
});

/** Return stock for a single product */
app.get("/stock/:productId", (req, res) => {
  const item = inventory[req.params.productId.toUpperCase()];

  if (!item) {
    return res.status(404).json({
      error:     `Product ${req.params.productId} not found in inventory`,
      source:    "service3-ec2-asg",
    });
  }

  res.json({
    ...item,
    status:      stockStatus(item.stock, item.reorderThreshold),
    lastUpdated: new Date().toISOString(),
    source:      "service3-ec2-asg",
  });
});

/**
 * PUT /stock/:productId
 * Body: { quantity: 10, operation: "add" | "subtract" | "set" }
 */
app.put("/stock/:productId", (req, res) => {
  const { productId } = req.params;
  const { quantity, operation = "set" } = req.body;
  const item = inventory[productId.toUpperCase()];

  if (!item) {
    return res.status(404).json({ error: `Product ${productId} not found` });
  }

  const qty = parseInt(quantity, 10);
  if (isNaN(qty) || qty < 0) {
    return res.status(400).json({ error: "quantity must be a non-negative integer" });
  }

  const prevStock = item.stock;
  switch (operation) {
    case "add":      item.stock += qty; break;
    case "subtract": item.stock = Math.max(0, item.stock - qty); break;
    case "set":      item.stock = qty; break;
    default:
      return res.status(400).json({ error: "operation must be add | subtract | set" });
  }

  res.json({
    productId:   item.productId,
    productName: item.productName,
    prevStock,
    newStock:    item.stock,
    operation,
    quantity:    qty,
    status:      stockStatus(item.stock, item.reorderThreshold),
    updatedAt:   new Date().toISOString(),
    source:      "service3-ec2-asg",
  });
});

// ── Helpers ────────────────────────────────────────────────────────────────
function stockStatus(stock, threshold) {
  if (stock === 0)           return "OUT_OF_STOCK";
  if (stock <= threshold)    return "LOW_STOCK";
  return "IN_STOCK";
}

// ── Start ──────────────────────────────────────────────────────────────────
app.listen(PORT, "0.0.0.0", () => {
  console.log(`[Service 3 - EC2/ASG Inventory] Listening on port ${PORT}`);
});
