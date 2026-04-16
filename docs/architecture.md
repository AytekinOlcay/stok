# Freezer Inventory System — System Architecture

## 1. System Overview

Freezer Inventory System is a QR-based inventory tracking application designed for household freezer usage but built with scalable architecture to support small food businesses in the future.

The system consists of three main layers:

Client Layer
Backend Layer
Database Layer

Main components:

Mobile Application (Flutter)
Web Admin Panel (Next.js)
Backend Services (Supabase)
Database (PostgreSQL via Supabase)

Primary goals:

* Simple and fast inventory interaction via QR scanning
* Package-level inventory tracking
* Minimal operational complexity
* Scalable data model

---

# 2. C4 Architecture Model

## Level 1 — System Context

Actors:

User (Household Member)

Systems:

Freezer Inventory System

External Systems:

Bluetooth Thermal Printer (future)

Interaction flow:

User → Mobile App → Supabase → Database

Admin usage:

User → Web Admin → Supabase → Database

---

# 3. Level 2 — Container Diagram

Containers inside the system:

Mobile App (Flutter)

Responsibilities:

QR scanning
Inventory operations
Search
Viewing shelf contents
Viewing statistics

Communicates with:

Supabase API

---

Web Admin Panel (Next.js)

Responsibilities:

Product management
Shelf management
Viewing logs
Viewing statistics

Communicates with:

Supabase API

---

Supabase Backend

Responsibilities:

Authentication
Database access
Row Level Security
Edge Functions

Provides:

REST API
Realtime subscriptions

---

Database (PostgreSQL)

Stores:

Products
Shelves
Packages
Inventory Logs

---

# 4. Level 3 — Component Architecture

## Mobile Application Components

Core Modules:

QR Scanner

Reads QR codes and determines type:
Shelf or Package.

Inventory Service

Handles:

Add package
Remove package
Move package

Search Service

Handles product search queries.

Statistics Service

Fetches consumption analytics.

Printer Service

Generates printable labels.

---

## Web Admin Components

Dashboard

Displays system overview.

Product Management

Create/edit products.

Shelf Management

Create/edit shelves.

Logs Viewer

Displays inventory operations.

Statistics Dashboard

Consumption charts.

---

# 5. Data Flow

## Adding a Package

User scans shelf QR.

Mobile app identifies shelf.

User selects product.

User enters:

Quantity
Unit
Optional expiration date.

Mobile sends request:

create_package()

Supabase stores:

Package record
Inventory log.

Response returned to mobile.

Mobile generates QR label.

User prints label.

---

## Removing a Package

User scans package QR.

Mobile retrieves package info.

User selects:

Consume / Remove.

Mobile sends:

remove_package()

Database:

Updates inventory log.

Package may be deleted or marked consumed.

---

# 6. QR Workflow

Two QR formats exist.

Shelf QR:

SHELF:{shelf_id}

Example:

SHELF:3

Scanning opens shelf view.

---

Package QR:

PKG:{package_id}

Example:

PKG:98fdc4d2

Scanning opens package details.

---

QR resolution process:

Scan QR → Parse prefix → Determine entity → Fetch record from Supabase.

---

# 7. Inventory Workflow

Primary operations:

Add Package

User scans shelf.

User selects product.

User enters quantity.

System creates package record.

---

Remove Package

User scans package.

User confirms consumption.

System logs removal.

---

Move Package

User scans package.

User scans new shelf.

System updates shelf_id.

---

Adjust Quantity

User scans package.

User updates quantity.

System logs adjustment.

---

# 8. Search Workflow

User searches product name.

Mobile app queries:

products + packages.

Results grouped by shelf.

Example result:

Shelf 2

500g minced meat
TETT: 16.10.2026

Shelf 4

1kg minced meat
TETT: 01.12.2026

---

# 9. Printing Workflow

Label generation occurs on mobile.

Steps:

Package created.

Mobile generates QR code.

Mobile generates label layout.

Output:

PDF
PNG

Later:

Sent via Bluetooth to thermal printer.

---

# 10. Analytics Workflow

Analytics generated from inventory logs.

Example queries:

Monthly consumption per product.

Average storage duration.

Top consumed products.

Example output:

This month you consumed:

4kg chicken
2kg beef
500g chickpeas

---

# 11. Security Model

Authentication handled by Supabase Auth.

Users limited via Row Level Security.

Rules:

Users only access their own data.

Future:

Multi-household support.

Possible structure:

households

household_members

---

# 12. Scalability Strategy

System designed for future growth.

Key design choices:

Package-level inventory.

Stateless API usage.

Supabase managed infrastructure.

Potential future scaling:

Multi-tenant support.

Business inventory tracking.

Restaurant storage management.

Cold warehouse inventory.

---

# 13. Future Extensions

Potential features:

Barcode scanning

Expiration notifications

Smart consumption predictions

AI inventory recommendations

Shopping list generation
