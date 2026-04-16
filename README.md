# Freezer Inventory System

QR-based freezer inventory tracking — built for home use, architected to scale.

## Stack

| Layer | Technology |
|-------|-----------|
| Mobile | Flutter + GetX |
| Web Admin | Next.js 15 + Tailwind + shadcn/ui |
| Backend | Supabase (Postgres, Auth, Storage, Edge Functions) |

## Repository Structure

```
freezer-app/
├── mobile/          # Flutter app (feature-based architecture)
├── web/             # Next.js admin panel
├── supabase/
│   ├── migrations/  # SQL migrations
│   ├── functions/   # Deno edge functions
│   └── seed.sql
└── docs/
```

## Getting Started

### Prerequisites

- Flutter ≥ 3.0
- Node.js ≥ 18
- Supabase CLI (`npm i -g supabase`)

### Local Supabase

```bash
supabase start          # starts local Postgres + API
supabase db reset       # applies migrations + seed
```

### Mobile

```bash
cd mobile
flutter pub get
flutter run --dart-define=SUPABASE_URL=http://localhost:54321 \
            --dart-define=SUPABASE_ANON_KEY=<your-anon-key>
```

### Web Admin

```bash
cd web
cp .env.local.example .env.local   # fill in your keys
npm install
npm run dev
```

## Docs

- [Architecture](docs/architecture.md)
- [Product Spec](docs/product-spec.md)
