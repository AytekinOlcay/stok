-- ============================================================
-- Türkçe isimler: raflar, ürünler, kategoriler
-- ============================================================

-- Rafları güncelle
update shelves set name = 'Raf 1' where position = 1;
update shelves set name = 'Raf 2' where position = 2;
update shelves set name = 'Raf 3' where position = 3;
update shelves set name = 'Raf 4' where position = 4;
update shelves set name = 'Raf 5' where position = 5;
update shelves set name = 'Raf 6' where position = 6;
update shelves set name = 'Raf 7' where position = 7;

-- Ürün isimlerini güncelle (seed'den gelen İngilizce kayıtlar)
update products set name = 'Tavuk',    category = 'Et'        where name = 'Chicken';
update products set name = 'Kıyma',    category = 'Et'        where name = 'Minced Meat';
update products set name = 'Dana Eti', category = 'Et'        where name = 'Beef';
update products set name = 'Nohut',    category = 'Baklagil'  where name = 'Chickpeas';
update products set name = 'Somon',    category = 'Balık'     where name = 'Salmon';
update products set name = 'Brokoli',  category = 'Sebze'     where name = 'Broccoli';
update products set name = 'Ekmek',    category = 'Fırın'     where name = 'Bread';

-- Yalnızca kategori alanını güncelle (İngilizce kalmış olabilecekler için)
update products set category = 'Et'       where category = 'Meat';
update products set category = 'Balık'    where category = 'Fish';
update products set category = 'Sebze'    where category = 'Vegetable';
update products set category = 'Fırın'    where category = 'Bakery';
update products set category = 'Baklagil' where category = 'Legumes';
