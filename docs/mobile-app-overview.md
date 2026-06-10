# Freezer Inventory — Mobile App Overview

## Tech Stack

| | |
|---|---|
| Framework | Flutter (Dart), Material 3 |
| State / DI / Navigation | GetX (`^4.6.6`) |
| Backend | Supabase (`supabase_flutter ^2.8.4`) |
| QR okuma | `mobile_scanner ^7.0.1` |
| QR oluşturma | `qr_flutter ^4.1.0` |
| PDF / etiket | `pdf ^3.11.1`, `printing ^5.13.2` |
| Tarih formatlama | `intl ^0.20.2` |
| Tema | Material 3, `ColorScheme.fromSeed(seedColor: Colors.blue)` |

## Uygulama Başlangıcı

`main.dart` → `Supabase.initialize()` → `FreezerApp` (GetMaterialApp)

Supabase URL ve Anon Key `--dart-define` ile dışarıdan verilir:
```
flutter run \
  --dart-define=SUPABASE_URL=https://xxx.supabase.co \
  --dart-define=SUPABASE_ANON_KEY=eyJ...
```

---

## Ekran & Navigasyon Haritası

```
/ (Home)
├── /qr-scanner         QR Tarayıcı
├── /shelves            Raf Listesi
│   └── /shelf/:id      Raf Detayı
│       └── /package/:id  Paket Detayı
├── /search             Envanter Arama / Listesi
├── /recipes            Tarifler
├── /products           Ürün Kataloğu
└── /statistics         Tüketim İstatistikleri
```

---

## Ekranlar

### 1. Home — `/`

**Dosya:** `features/home/views/home_view.dart`

Ana menü ekranı. Ortada dikey sıralı 5 büyük buton bulunur:
- **Scan QR** → `/qr-scanner`
- **Shelves** → `/shelves`
- **Search** → `/search`
- **Products** → `/products`
- **Statistics** → `/statistics`

Butonlar `ElevatedButton.icon`, genişlik 220px, ikon + yazı.  
AppBar başlığı: "Freezer Inventory"

---

### 2. QR Scanner — `/qr-scanner`

**Dosya:** `features/qr_scanner/views/qr_scanner_view.dart`  
**Controller:** `qr_scanner_controller.dart`

Tam ekran kamera görünümü (`MobileScanner`).  
Ortada beyaz çerçeveli hedef kutusu (240×240px).  
Alt kısımda yönlendirme metni.

**QR format (JSON):**
```json
{ "type": "shelf", "id": "<uuid>" }
{ "type": "package", "id": "<uuid>" }
```

Tarama başarılı olunca:
- `type == "shelf"` → `/shelf/:id` (replace)
- `type == "package"` → `/package/:id` (replace)
- Tanınmayan/hatalı → snackbar

---

### 3. Raf Listesi — `/shelves`

**Dosya:** `features/shelves_list/views/shelves_list_view.dart`  
**Controller:** `shelves_list_controller.dart`

Veritabanındaki tüm rafları listeler, `position` sütununa göre sıralı.  
Her öğe: sol tarafta `CircleAvatar` (pozisyon numarası), raf adı, sağda `chevron_right`.  
Tıklanınca `/shelf/:id` sayfasına yönlendirir.  
AppBar'da refresh butonu var.

---

### 4. Raf Detayı — `/shelf/:id`

**Dosya:** `features/shelf/views/shelf_view.dart`  
**Controller:** `shelf_controller.dart`

**AppBar:**
- Başlık: raf adı (reactive)
- Sağ ikon: QR kodu göster (o rafın QR'ını dialog'da gösterir)

**FAB:** `+` → `AddPackageSheet` bottom sheet'ini açar

**Liste:** O raftaki paketler, her kart:
- Başlık: `Ürün Adı — Miktar Birim`
- Alt başlık: `TETT: gg.aa.yyyy`
- Sağda: kırmızı çöp kutusu ikonu → onay dialog → paketi siler
- Tıklanınca: `/package/:id`

---

### 5. Paket Detayı — `/package/:id`

**Dosya:** `features/package/views/package_view.dart`  
**Controller:** `package_controller.dart`

**AppBar sağ:** QR ikonu → `showQrDialog` (ürün adı, eklenme tarihi, TETT bilgileriyle)

**İçerik (ListView, 3 section kart):**

| Section | Alanlar |
|---|---|
| Temel bilgi | Ürün, Miktar+Birim, Raf |
| Tarihler | Eklenme tarihi, Consume Before (TETT), Expiration (varsa) |
| Toplam stok | Tüm raflardaki aynı üründen toplam miktar |
| Notlar | (varsa) |

**Alt kısım — Tüketim (`_ConsumeSection`):**
- Miktar giriş alanı (sayısal, max = mevcut miktar)
- **"Use"** butonu (kısmi tüketim)
- **"Use All"** outlined butonu (tamamını tüket)

Kısmi tüketimde: miktar güncellenir, stok yeniden hesaplanır.  
Tam tüketimde: paket silinir, sayfa kapanır.

**Ek özellik:** Bu ekranda aynı ürünü kullanan tariflerden en fazla 3 tane listelenir.

**RPC:** `consume_package(p_package_id, p_amount)` — atomic

---

### 6. Envanter / Arama — `/search`

**Dosya:** `features/search/views/search_view.dart`  
**Controller:** `search_controller.dart`

Açılışta tüm paketleri 20'li sayfalar halinde listeler (infinite scroll).

**Arama:** Üstte `TextField`, debounce 400ms, ürün adına göre filtreler.

**Her paket kartı** (`_PackageCard`):
- Sağ üst: miktar+birim badge (renkli)
- Ürün adı (büyük, bold)
- Kategori (label ikonu ile)
- Raf konumu
- Eklenme tarihi
- TETT tarihi (renk uyarısı: <14 gün kırmızı, <30 gün turuncu)
- Son kullanma tarihi (varsa, kırmızı)
- Notlar (varsa, gri)

Tıklanınca: `/package/:id`

**Pagination:** Scroll sona 250px yaklaşınca sonraki 20 kayıt otomatik yüklenir. Alt kısımda spinner gösterilir.

---

### 7. Tarifler — `/recipes`

**Dosya:** `features/recipes/views/recipes_view.dart`  
**Controller:** `recipes_controller.dart`

Web adminde oluşturulan tariflerin listesini gösterir. Her tarif kartı şunları içerir:
- Başlık
- Hazırlık süresi
- Malzeme sayısı
- Video küçük resmi (varsa)

Tıklanınca detay sayfasına gider.

---

### 8. Tarif Detayı — `/recipe/:id`

**Dosya:** `features/recipes/views/recipe_detail_view.dart`  
**Controller:** `recipe_detail_controller.dart`

Tarif detay ekranı şunları gösterir:
- Başlık ve prep time
- Video embed (YouTube / Vimeo) veya harici bağlantı
- Markdown formatlı tarif açıklaması
- Malzemeler; miktar ve birim bilgileri
- Paket detayından ilgili tarifler önerisi

---

### 9. Ürün Kataloğu — `/products`

**Dosya:** `features/products/views/products_view.dart`  
**Controller:** `products_controller.dart`

Sistemde kayıtlı tüm ürün tiplerini listeler (paket değil, şablon ürünler).

**Liste:** Her kart:
- `CircleAvatar`: ürün adının baş harfi
- Başlık: ürün adı
- Alt: `Kategori · birim · X days`

**FAB:** `+` → `AddProductSheet` bottom sheet

**`AddProductSheet`** alanları:
- Ürün adı (zorunlu)
- Kategori (text field)
- Varsayılan birim (dropdown: g, kg, ml, L, piece)
- Önerilen dondurucu raf ömrü (gün)

---

### 10. İstatistikler — `/statistics`

**Dosya:** `features/statistics/views/statistics_view.dart`  
**Controller:** `statistics_controller.dart`

Tüm zamanlar toplam tüketim listesi.  
Her kart: ürün adı + sağda toplam tüketilen miktar+birim.  
Veri yoksa bilgi mesajı gösterilir.  
AppBar'da refresh butonu.

---

## Paylaşılan Bileşenler

### `showQrDialog`

**Dosya:** `widgets/qr_display_dialog.dart`

`AlertDialog` içinde QR kodu gösterir (220×220px `QrImageView`).  
QR verisi: `{"type":"shelf"|"package", "id":"<uuid>"}`  
Opsiyonel bilgi satırları: productName, addedAt, consumeBefore.  
Altında "Close" butonu.

---

## Bottom Sheet'ler

| Sheet | Nereden Açılır | Alanlar |
|---|---|---|
| `AddPackageSheet` | Shelf Detayı FAB | Ürün seçici (DB'den), miktar, birim, son kullanma tarihi (opsiyonel), notlar |
| `AddProductSheet` | Products FAB | Ad, kategori, birim, raf ömrü (gün) |

---

## Veri Modeli (Supabase Tabloları)

```
shelves       id, name, position
products      id, name, category, default_unit, recommended_freezer_storage_days
packages      id, product_id, shelf_id, quantity, unit, qr_code,
              added_at, recommended_consume_before, expiration_date, notes
inventory_logs id, package_id, product_id, action, quantity, unit, note, created_at
```

**RPC'ler:**
- `consume_package(p_package_id, p_amount)` — atomic tüketim (kısmi güncelleme, tam silme)
- `get_product_total_stock(p_product_id)` — ürünün tüm raflardaki toplam miktarı

---

## Klasör Yapısı

```
mobile/lib/
├── main.dart
├── app/
│   ├── app.dart                   # GetMaterialApp, tema
│   └── routes/
│       ├── app_routes.dart        # Route sabitleri
│       └── app_pages.dart         # Route → View + Binding eşleşmesi
├── core/
│   └── services/
│       └── supabase_service.dart
├── widgets/
│   └── qr_display_dialog.dart     # Paylaşılan QR dialog
└── features/
    ├── home/
    ├── qr_scanner/
    ├── shelves_list/
    ├── shelf/
    ├── package/
    ├── add_package/
    ├── search/
    ├── products/
    └── statistics/
```

Her feature klasörü: `views/`, `controllers/`, `bindings/`

---

## Mevcut Tema

```dart
ThemeData(
  colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
  useMaterial3: true,
)
```

Tüm renkler `seedColor: Colors.blue` tabanlı Material 3 renk şemasından türetiliyor.  
Light mode only, dark mode henüz eklenmemiş.  
Özel font tanımlanmamış (sistem fontu).
