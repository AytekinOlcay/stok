# Freezer Inventory System — Product Specification

## 1. Overview

Freezer Inventory System is a QR-based inventory tracking application designed for home freezer usage but architected to scale to small food storage businesses or grocery stores.

The system tracks individual food packages stored in freezer shelves. Each package has its own QR code and metadata such as quantity, storage date, and recommended consumption date.

The application consists of:

* Mobile App (Flutter) → operational usage
* Web Admin Panel (Next.js) → management & analytics
* Backend (Supabase) → database, auth, business logic

---

# 2. Core Concepts

The system manages inventory at **package level**, not product level.

Example:

Product:
Minced Meat

Packages:

* 500g minced meat
* 750g minced meat
* 1kg minced meat

Each package has:

* its own QR code
* its own storage date
* its own shelf
* its own recommended consumption date

---

# 3. Domain Model

Main entities:

User
Shelf
Product
Package
InventoryLog

Relationships:

User → performs actions
Shelf → contains packages
Product → defines food type
Package → physical item in freezer
InventoryLog → tracks actions

Diagram (logical):

User
└── InventoryLog

Product
└── Package

Shelf
└── Package

Package
└── InventoryLog

---

# 4. Product Model

Represents food type.

Example:
Chicken
Minced Meat
Beef
Chickpeas

Fields:

id (uuid)

name

category

default_unit
(g, kg, piece)

recommended_freezer_storage_days

created_at

Example:

Minced meat

recommended_freezer_storage_days = 180

When adding a package:

recommended_consume_before = added_at + recommended_storage_days

User can override manually.

---

# 5. Package Model (Inventory)

Represents a physical container stored in the freezer.

Fields:

id (uuid)

product_id (fk)

shelf_id (fk)

quantity

unit

qr_code

added_at

recommended_consume_before

expiration_date (optional)

notes (optional)

created_by (user_id)

Example:

Product: Minced Meat
Quantity: 500
Unit: g
Shelf: 3
Added: 2026-04-16
Recommended consume before: 2026-10-16

---

# 6. Shelf Model

Represents freezer shelves.

Fields:

id

name

position

qr_code

created_at

Default configuration:

7 shelves.

Admin panel must allow shelf count changes.

---

# 7. Inventory Logs

Every operation must be logged.

Log types:

package_added
package_removed
quantity_adjusted
shelf_changed

Fields:

id

package_id

product_id

action_type

quantity

unit

user_id

created_at

Log retention:

Minimum 1 year.

---

# 8. Global Product Stock

The system must calculate total stock of a product.

Example:

Packages:

500g minced meat
750g minced meat
1000g minced meat

Total:

2.25kg

Implementation:

Aggregate packages grouped by product_id.

---

# 9. Search Feature (Mobile)

User can search by product name.

Results include:

Shelf number
Quantity
Recommended consumption date
Expiration date

Example:

Search: "minced meat"

Shelf 2
500g minced meat (TETT 16.10.2026)

Shelf 4
1kg minced meat (TETT 01.12.2026)

Purpose:

Freezer containers may be opaque or iced over.

---

# 10. Recipe Model
Recipes represent user-created meal plans or freezer usage instructions.

Fields:

id uuid
org_id uuid
title text
description text
prep_time_min integer
video_url text
video_source video_source_type
video_embed_url text
video_thumbnail text
created_by uuid
updated_by uuid
created_at timestamptz
updated_at timestamptz
deleted_at timestamptz

Recipes are scoped by organization and protected by RLS via `auth_user_org_id()`.

# 11. Recipe Product Links
Each recipe may link to multiple products through `recipe_products`.

Fields:

id uuid
recipe_id uuid
product_id uuid
quantity numeric
unit text
sort_order integer

This enables recipe detail pages to show ingredient amounts and units.

# 12. Web Admin Recipes
Web admin supports recipe CRUD, markdown descriptions, ingredient quantity/unit entry, video URL parsing, and soft delete behavior.

Recipe UI expectations:
- Create and edit recipe metadata
- Attach product ingredient rows with quantity and unit
- Preview markdown descriptions
- Persist video metadata such as embed URL and thumbnail

# 13. Mobile Recipes
The mobile app now includes recipe browsing and detail flows.

Mobile capabilities:
- Recipe list view with thumbnails, prep time, and ingredient count
- Recipe detail view with embedded video playback and markdown content
- Related recipes shown on package detail pages for the same product

---

# 14. QR Code Strategy

Two QR types exist.

## Shelf QR

Format:

SHELF:{shelf_id}

Example:

SHELF:3

Scanning shelf QR shows all packages on that shelf.

---

## Package QR

Format:

PKG:{package_id}

Example:

PKG:7f21b8b3-6c4a

Scanning package QR shows:

Product name
Quantity
Shelf location
Recommended consume date
Total product stock

---

# 11. Thermal Printer Label Format

Labels should be small and freezer-friendly.

Recommended size:

50mm x 30mm

Label layout:

+-------------------------+
| QR CODE                 |
|                         |
| Minced Meat             |
| 500 g                   |
| Added: 16.04.2026       |
+-------------------------+

Fields:

QR Code
Product Name
Quantity
Added Date (optional)

Generated as:

PDF or PNG.

Later printed via Bluetooth thermal printer.

---

# 12. Supabase Production Database Schema

Tables:

users (managed by Supabase Auth)

products

shelves

packages

inventory_logs

---

## products

id uuid pk

name text

category text

default_unit text

recommended_freezer_storage_days int

created_at timestamp

---

## shelves

id uuid pk

name text

position int

qr_code text

created_at timestamp

---

## packages

id uuid pk

product_id uuid fk

shelf_id uuid fk

quantity numeric

unit text

qr_code text

added_at timestamp

recommended_consume_before timestamp

expiration_date timestamp

notes text

created_by uuid

created_at timestamp

---

## inventory_logs

id uuid pk

package_id uuid

product_id uuid

action_type text

quantity numeric

unit text

user_id uuid

created_at timestamp

---

# 13. Flutter Mobile Architecture

Architecture:

Feature-based architecture.

Structure:

mobile/lib/

core/

services/

models/

utils/

features/

auth/

products/

inventory/

shelves/

scanner/

search/

stats/

shared/

widgets/

navigation/

Key components:

QR Scanner

Inventory actions

Product search

Shelf viewer

Statistics dashboard

State management:

GetX

---

# 14. Next.js Admin Panel Structure

Purpose:

Management & analytics.

Routes:

/dashboard

/products

/shelves

/logs

/stats

Structure:

web/

app/

dashboard/

products/

shelves/

logs/

stats/

components/

ui/

tables/

forms/

charts/

lib/

supabase.ts

queries.ts

Stack:

Next.js App Router
TailwindCSS
shadcn/ui

---

# 15. Analytics

Analytics generated from inventory logs.

Examples:

Monthly consumption

Top consumed products

Average freezer storage duration

Example output:

This month you consumed:

4kg chicken
2kg beef
500g chickpeas

---

# 16. Future Scalability

System must support future use cases:

Small grocery stores

Restaurant storage

Butchery inventory

Warehouse cold storage

Design principles:

Use package-level tracking.

Avoid aggregated product stock storage.

Compute totals dynamically.
