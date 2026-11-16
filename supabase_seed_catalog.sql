-- Run after supabase_schema.sql (new database), or after committing
-- supabase_add_catalog_categories.sql (existing database).
-- Catalog entries only; prices are supplied through market reports.
INSERT INTO items (name_en, name_am, category, standard_unit)
SELECT catalog.name_en, catalog.name_am, catalog.category::item_category, 'piece'
FROM (VALUES
  -- Electronics with model-specific listing prices: run supabase_electronics_models.sql.
  ('Cotton T-shirt', 'የጥጥ ቲሸርት', 'clothing'),
  ('Denim Jeans', 'ጂንስ ሱሪ', 'clothing'),
  ('Lightweight Jacket', 'ቀላል ጃኬት', 'clothing'),
  ('Cotton Dress', 'የጥጥ ቀሚስ', 'clothing')
) AS catalog(name_en, name_am, category)
WHERE NOT EXISTS (
  SELECT 1 FROM items existing
  WHERE existing.name_en = catalog.name_en
    AND existing.category::text = catalog.category
);
