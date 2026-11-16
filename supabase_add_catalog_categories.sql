-- Existing databases: run and commit this script BEFORE supabase_seed_catalog.sql.
ALTER TYPE item_category ADD VALUE IF NOT EXISTS 'electronics';
ALTER TYPE item_category ADD VALUE IF NOT EXISTS 'clothing';
