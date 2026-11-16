-- Apply after the electronics category migration has committed.
-- Keep historical generic items/report associations unchanged.
ALTER TABLE items ADD COLUMN IF NOT EXISTS listing_price NUMERIC(10, 2);
ALTER TABLE items ADD COLUMN IF NOT EXISTS listing_source TEXT;
ALTER TABLE items ADD COLUMN IF NOT EXISTS listing_note TEXT;
INSERT INTO items (name_en, name_am, category, standard_unit, listing_price, listing_source, listing_note)
SELECT 'Samsung Galaxy A16 (4 GB / 128 GB)', 'Samsung Galaxy A16 (4 GB / 128 GB)', 'electronics', 'piece', 29500, 'https://jiji.com.et/bole/mobile-phones/new-samsung-galaxy-a16-128-gb-black-a9xkPRtqncl3l9yrCf051oD.html', 'Jiji · Bole · Listed as new · Checked 2026-11-16. Seller asking price; availability and condition require confirmation.'
WHERE NOT EXISTS (SELECT 1 FROM items WHERE name_en = 'Samsung Galaxy A16 (4 GB / 128 GB)' AND category = 'electronics');
INSERT INTO items (name_en, name_am, category, standard_unit, listing_price, listing_source, listing_note)
SELECT 'Lenovo ThinkPad T480 (Core i5 8th Gen / 8 GB / 256 GB SSD)', 'Lenovo ThinkPad T480 (Core i5 8th Gen / 8 GB / 256 GB SSD)', 'electronics', 'piece', 56000, 'https://jiji.com.et/am/yeka/computers-and-laptops/new-laptop-lenovo-thinkpad-t480-8gb-intel-core-i5-ssd-256gb-bo6h8dqI6HTutnsNxZK3OeZT.html', 'Jiji · Yeka · Listed as new · Checked 2026-11-16. Seller asking price; availability and condition require confirmation.'
WHERE NOT EXISTS (SELECT 1 FROM items WHERE name_en = 'Lenovo ThinkPad T480 (Core i5 8th Gen / 8 GB / 256 GB SSD)' AND category = 'electronics');
INSERT INTO items (name_en, name_am, category, standard_unit, listing_price, listing_source, listing_note)
SELECT 'Anker Soundcore R50i True Wireless Earbuds', 'Anker Soundcore R50i True Wireless Earbuds', 'electronics', 'piece', 4600, 'https://jiji.com.et/bole/headphones/soundcore-by-anker-r50i-true-wireless-earbuds-brand-new-itmsu4YmhVxLQnuEaCdY8QLl.html', 'Jiji · Bole · Listed as new · Checked 2026-11-16. Seller asking price; availability and condition require confirmation.'
WHERE NOT EXISTS (SELECT 1 FROM items WHERE name_en = 'Anker Soundcore R50i True Wireless Earbuds' AND category = 'electronics');
INSERT INTO items (name_en, name_am, category, standard_unit, listing_price, listing_source, listing_note)
SELECT 'Samsung EP-T2510 USB-C Charger (25 W)', 'Samsung EP-T2510 USB-C Charger (25 W)', 'electronics', 'piece', 1700, 'https://jiji.com.et/kirkos/cell-phones-tablets-accessories/samsung-25w-super-fast-usb-c-charger-mt5nWziKNuSqGXjoGX9KhPFG.html', 'Jiji · Kirkos · Listed as new · Checked 2026-11-16. Seller asking price; availability and condition require confirmation.'
WHERE NOT EXISTS (SELECT 1 FROM items WHERE name_en = 'Samsung EP-T2510 USB-C Charger (25 W)' AND category = 'electronics');