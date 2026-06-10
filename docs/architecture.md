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

# 7. Recipe Subsystem
The current implementation includes a full recipe subsystem on the Web Admin Panel, plus recipe browsing on mobile.

Web responsibilities:
- Recipe CRUD with title, markdown description, prep time, video URL, and ingredient links
- Recipe ingredient mapping through `recipe_products`
- Soft delete support for recipes with a `deleted_at` timestamp
- Markdown editing and preview support in the admin UI
- Video parsing for YouTube, Vimeo, Instagram, TikTok and fallback URLs

Mobile responsibilities:
- Recipe list and detail screens
- Embedded video playback for YouTube/Vimeo
- Markdown recipe rendering in the mobile UI
- Related recipe suggestions shown on package details

---

# 8. Security & Data Integrity
Recipes are org-scoped and protected by Supabase RLS.

The system uses a helper function, `auth_user_org_id()`, to resolve the current user's organization safely.
A security-definer RPC helper, `soft_delete_recipe`, is used for soft deletes so recipe soft-deletion remains both secure and reliable.

Design goals:
- Keep recipe state tenant-aware via `org_id`
- Enforce update/delete operations through user session-aware auth
- Use RPC only where RLS + session context needs deterministic behavior


---

# 9. Inventory Workflow

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

# 10. Search Workflow

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

# 11. Printing Workflow

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

# 12. Analytics Workflow

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

# 13. Security Model

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

# 14. Scalability Strategy

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
