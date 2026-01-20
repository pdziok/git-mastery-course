#!/bin/bash

# Git Workshop Test Repository Setup Script
# ==========================================
# This script creates a Git repository with realistic history
# for practicing all course concepts.

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_DIR="${SCRIPT_DIR}/sandbox"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}╔══════════════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║       Git Workshop - Test Repository Setup               ║${NC}"
echo -e "${BLUE}╚══════════════════════════════════════════════════════════╝${NC}"
echo ""

# Clean up if exists
if [ -d "$REPO_DIR" ]; then
    echo -e "${YELLOW}Removing existing sandbox directory...${NC}"
    rm -rf "$REPO_DIR"
fi

# Create directory
mkdir -p "$REPO_DIR"
cd "$REPO_DIR"

echo -e "${GREEN}Creating test repository in: ${REPO_DIR}${NC}"
echo ""

# Initialize repo
git init

# Configure for workshop (local config only)
git config user.name "Workshop User"
git config user.email "workshop@example.com"

# ============================================================
# PHASE 1: Initial project setup
# ============================================================
echo -e "${BLUE}Phase 1: Creating initial project structure...${NC}"

mkdir -p src tests docs

cat > README.md << 'EOF'
# E-Commerce Platform

A sample e-commerce application for learning Git.

## Features
- User authentication
- Product catalog
- Shopping cart
- Order processing

## Setup
1. Clone the repository
2. Run `npm install`
3. Run `npm start`
EOF

cat > src/app.js << 'EOF'
// Main Application Entry Point
const express = require('express');
const app = express();

app.get('/', (req, res) => {
    res.send('Welcome to E-Commerce Platform');
});

module.exports = app;
EOF

cat > src/config.js << 'EOF'
// Application Configuration
module.exports = {
    port: 3000,
    database: 'mongodb://localhost/ecommerce',
    secret: 'development-secret'
};
EOF

cat > package.json << 'EOF'
{
    "name": "ecommerce-platform",
    "version": "1.0.0",
    "description": "Sample e-commerce application",
    "main": "src/app.js",
    "scripts": {
        "start": "node src/app.js",
        "test": "jest"
    }
}
EOF

cat > .gitignore << 'EOF'
node_modules/
.env
.env.local
*.log
.DS_Store
coverage/
dist/
EOF

git add .
git commit -m "chore: initial project setup

- Add basic Express application structure
- Add configuration module
- Add package.json with scripts
- Add .gitignore for common patterns"

# ============================================================
# PHASE 2: Add authentication feature
# ============================================================
echo -e "${BLUE}Phase 2: Adding authentication feature...${NC}"

cat > src/auth.js << 'EOF'
// Authentication Module
const bcrypt = require('bcrypt');
const jwt = require('jsonwebtoken');
const config = require('./config');

async function hashPassword(password) {
    return bcrypt.hash(password, 10);
}

async function verifyPassword(password, hash) {
    return bcrypt.compare(password, hash);
}

function generateToken(userId) {
    return jwt.sign({ userId }, config.secret, { expiresIn: '1h' });
}

function verifyToken(token) {
    return jwt.verify(token, config.secret);
}

module.exports = {
    hashPassword,
    verifyPassword,
    generateToken,
    verifyToken
};
EOF

cat > tests/auth.test.js << 'EOF'
// Authentication Tests
const auth = require('../src/auth');

describe('Authentication', () => {
    test('should hash password', async () => {
        const hash = await auth.hashPassword('secret123');
        expect(hash).toBeDefined();
        expect(hash).not.toBe('secret123');
    });

    test('should verify correct password', async () => {
        const hash = await auth.hashPassword('secret123');
        const result = await auth.verifyPassword('secret123', hash);
        expect(result).toBe(true);
    });
});
EOF

git add .
git commit -m "feat(auth): add authentication module

- Add password hashing with bcrypt
- Add JWT token generation and verification
- Add unit tests for auth functions"

# ============================================================
# PHASE 3: Add product catalog
# ============================================================
echo -e "${BLUE}Phase 3: Adding product catalog...${NC}"

cat > src/products.js << 'EOF'
// Product Catalog Module
const products = [];

function addProduct(product) {
    const newProduct = {
        id: products.length + 1,
        ...product,
        createdAt: new Date()
    };
    products.push(newProduct);
    return newProduct;
}

function getProduct(id) {
    return products.find(p => p.id === id);
}

function getAllProducts() {
    return [...products];
}

function updateProduct(id, updates) {
    const index = products.findIndex(p => p.id === id);
    if (index === -1) return null;
    products[index] = { ...products[index], ...updates };
    return products[index];
}

module.exports = {
    addProduct,
    getProduct,
    getAllProducts,
    updateProduct
};
EOF

git add .
git commit -m "feat(products): add product catalog module

- Add CRUD operations for products
- Store products in memory (to be replaced with DB)"

# ============================================================
# PHASE 4: Create branches for exercises
# ============================================================
echo -e "${BLUE}Phase 4: Creating branches for exercises...${NC}"

# Create feature-cart branch (for merge/rebase exercises)
git checkout -b feature-cart

cat > src/cart.js << 'EOF'
// Shopping Cart Module
const carts = new Map();

function getCart(userId) {
    if (!carts.has(userId)) {
        carts.set(userId, { items: [], total: 0 });
    }
    return carts.get(userId);
}

function addToCart(userId, productId, quantity) {
    const cart = getCart(userId);
    const existingItem = cart.items.find(i => i.productId === productId);

    if (existingItem) {
        existingItem.quantity += quantity;
    } else {
        cart.items.push({ productId, quantity });
    }

    return cart;
}

function removeFromCart(userId, productId) {
    const cart = getCart(userId);
    cart.items = cart.items.filter(i => i.productId !== productId);
    return cart;
}

module.exports = {
    getCart,
    addToCart,
    removeFromCart
};
EOF

git add .
git commit -m "feat(cart): add shopping cart module

- Add cart management per user
- Add add/remove item functions"

echo "// Calculate cart total" >> src/cart.js
cat >> src/cart.js << 'EOF'

function calculateTotal(userId, products) {
    const cart = getCart(userId);
    let total = 0;

    for (const item of cart.items) {
        const product = products.find(p => p.id === item.productId);
        if (product) {
            total += product.price * item.quantity;
        }
    }

    cart.total = total;
    return total;
}

module.exports.calculateTotal = calculateTotal;
EOF

git add .
git commit -m "feat(cart): add total calculation"

# Back to main and make different changes (for conflict exercises)
git checkout main

cat > src/utils.js << 'EOF'
// Utility Functions
function formatPrice(cents) {
    return '$' + (cents / 100).toFixed(2);
}

function generateId() {
    return Math.random().toString(36).substring(2, 15);
}

function validateEmail(email) {
    const re = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
    return re.test(email);
}

module.exports = {
    formatPrice,
    generateId,
    validateEmail
};
EOF

git add .
git commit -m "feat(utils): add utility functions"

# Create a branch with intentional conflict
git checkout -b feature-validation

# Modify the same file that will be modified on main
cat >> src/utils.js << 'EOF'

function validatePassword(password) {
    // Validation branch version
    return password.length >= 8;
}

module.exports.validatePassword = validatePassword;
EOF

git add .
git commit -m "feat(utils): add password validation (minimum length)"

# Back to main and make conflicting change
git checkout main

cat >> src/utils.js << 'EOF'

function validatePassword(password) {
    // Main branch version - stricter
    const hasLetter = /[a-zA-Z]/.test(password);
    const hasNumber = /[0-9]/.test(password);
    return password.length >= 10 && hasLetter && hasNumber;
}

module.exports.validatePassword = validatePassword;
EOF

git add .
git commit -m "feat(utils): add password validation (strict rules)"

# Create branches for cherry-pick exercise
git checkout -b feature-orders

cat > src/orders.js << 'EOF'
// Order Processing Module
const orders = [];

function createOrder(userId, cart) {
    const order = {
        id: orders.length + 1,
        userId,
        items: [...cart.items],
        total: cart.total,
        status: 'pending',
        createdAt: new Date()
    };
    orders.push(order);
    return order;
}

function getOrder(id) {
    return orders.find(o => o.id === id);
}

module.exports = {
    createOrder,
    getOrder
};
EOF

git add .
git commit -m "feat(orders): add order creation"

# Add a bugfix commit (good for cherry-pick)
cat >> src/orders.js << 'EOF'

function getUserOrders(userId) {
    return orders.filter(o => o.userId === userId);
}

module.exports.getUserOrders = getUserOrders;
EOF

git add .
git commit -m "fix(orders): add function to get user orders

This was missing and causing issues in the dashboard."

# Add more commits
cat >> src/orders.js << 'EOF'

function updateOrderStatus(orderId, status) {
    const order = getOrder(orderId);
    if (order) {
        order.status = status;
        order.updatedAt = new Date();
    }
    return order;
}

module.exports.updateOrderStatus = updateOrderStatus;
EOF

git add .
git commit -m "feat(orders): add order status updates"

# Back to main
git checkout main

# ============================================================
# PHASE 5: Create messy branch for rebase -i exercise
# ============================================================
echo -e "${BLUE}Phase 5: Creating branch with messy commits (for interactive rebase)...${NC}"

git checkout -b feature-notifications

echo "// Notifications module" > src/notifications.js
git add .
git commit -m "WIP"

echo "// TODO: implement this" >> src/notifications.js
git add .
git commit -m "wip more stuff"

cat > src/notifications.js << 'EOF'
// Notifications Module
function sendEmail(to, subject, body) {
    console.log(`Sending email to ${to}: ${subject}`);
    // TODO: implement actual email sending
}
EOF

git add .
git commit -m "almost done"

cat >> src/notifications.js << 'EOF'

function sendSMS(phone, message) {
    console.log(`Sending SMS to ${phone}: ${message}`);
    // TODO: implement actual SMS sending
}
EOF

git add .
git commit -m "add sms"

cat >> src/notifications.js << 'EOF'

module.exports = {
    sendEmail,
    sendSMS
};
EOF

git add .
git commit -m "fix exports oops"

# ============================================================
# PHASE 6: Create stash scenario
# ============================================================
echo -e "${BLUE}Phase 6: Setting up stash exercise scenario...${NC}"

git checkout main

# Create uncommitted work (user can stash this)
echo "// Work in progress - not ready to commit" >> src/app.js

# ============================================================
# PHASE 7: Final setup
# ============================================================
echo -e "${BLUE}Phase 7: Final setup...${NC}"

# Show status
git status

echo ""
echo -e "${GREEN}╔══════════════════════════════════════════════════════════╗${NC}"
echo -e "${GREEN}║           Test Repository Created Successfully!          ║${NC}"
echo -e "${GREEN}╚══════════════════════════════════════════════════════════╝${NC}"
echo ""
echo -e "Repository location: ${YELLOW}${REPO_DIR}${NC}"
echo ""
echo -e "${BLUE}Available branches:${NC}"
git branch -a
echo ""
echo -e "${BLUE}Commit history:${NC}"
git log --oneline --graph --all
echo ""
echo -e "${YELLOW}Exercises you can practice:${NC}"
echo ""
echo "1. MERGE EXERCISE:"
echo "   git checkout main"
echo "   git merge feature-cart"
echo ""
echo "2. CONFLICT EXERCISE:"
echo "   git checkout main"
echo "   git merge feature-validation  (will conflict!)"
echo ""
echo "3. REBASE EXERCISE:"
echo "   git checkout feature-cart"
echo "   git rebase main"
echo ""
echo "4. INTERACTIVE REBASE (clean up messy commits):"
echo "   git checkout feature-notifications"
echo "   git rebase -i main"
echo ""
echo "5. CHERRY-PICK EXERCISE:"
echo "   git checkout main"
echo "   git log feature-orders --oneline  (find the bugfix commit)"
echo "   git cherry-pick <hash-of-bugfix>"
echo ""
echo "6. STASH EXERCISE:"
echo "   # There's uncommitted work in src/app.js"
echo "   git stash"
echo "   git stash pop"
echo ""
echo -e "${GREEN}Happy learning!${NC}"
