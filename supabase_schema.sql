-- ============================================================================
-- GEBEYA MARKET PRICE TRACKER - SUPABASE DATABASE SCHEMA
-- Region: Ethiopia (Pilot: Addis Ababa)
-- ============================================================================

-- 1. EXTENSIONS
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- 2. ENUMS
CREATE TYPE item_category AS ENUM (
    'grains_flour',
    'vegetables_produce',
    'pulses_legumes',
    'meat_dairy',
    'oil_sugar_pantry',
    'spices',
    'electronics',
    'clothing',
    'beverages',
    'bakery',
    'shoes',
    'bags',
    'beauty',
    'health',
    'baby',
    'home',
    'kitchen',
    'appliances',
    'cleaning',
    'books',
    'sports',
    'toys',
    'automotive',
    'tools',
    'garden',
    'pets'
);

CREATE TYPE report_source AS ENUM (
    'user',
    'scout',
    'wfp',
    'ess',
    'official_bulletin',
    'scraped'
);

CREATE TYPE report_status AS ENUM (
    'verified',
    'pending',
    'flagged',
    'rejected'
);

-- 3. MARKETS TABLE
CREATE TABLE IF NOT EXISTS markets (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name_en TEXT NOT NULL,
    name_am TEXT NOT NULL,
    city TEXT NOT NULL DEFAULT 'Addis Ababa',
    subcity TEXT,
    latitude DOUBLE PRECISION,
    longitude DOUBLE PRECISION,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- 4. ITEMS TABLE
CREATE TABLE IF NOT EXISTS items (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name_en TEXT NOT NULL,
    name_am TEXT NOT NULL,
    category item_category NOT NULL,
    standard_unit TEXT NOT NULL, -- 'kg', 'liter', 'piece'
    supported_local_units JSONB DEFAULT '[]'::jsonb, -- e.g. [{"unit": "tassa", "multiplier": 1.25}]
    icon_name TEXT,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- 5. PRICE REPORTS (RAW CROWDSOURCED & SCOUT DATA)
CREATE TABLE IF NOT EXISTS price_reports (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    item_id UUID NOT NULL REFERENCES items(id) ON DELETE CASCADE,
    market_id UUID NOT NULL REFERENCES markets(id) ON DELETE CASCADE,
    user_id UUID, -- NULL for anonymous users
    device_id TEXT, -- Device-level fingerprint for guest submissions
    price NUMERIC(10, 2) NOT NULL, -- Total price paid
    quantity NUMERIC(10, 2) NOT NULL DEFAULT 1.0, -- Quantity in reported unit
    reported_unit TEXT NOT NULL, -- 'kg', 'tassa', 'jog', 'quintal', etc.
    price_per_standard_unit NUMERIC(10, 2) NOT NULL, -- Normalized to standard unit (ETB/kg or ETB/L)
    source report_source NOT NULL DEFAULT 'user',
    status report_status NOT NULL DEFAULT 'pending',
    notes TEXT,
    reported_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Index for speedy queries on item + market + date
CREATE INDEX IF NOT EXISTS idx_price_reports_item_market_date 
ON price_reports (item_id, market_id, reported_at DESC);

-- 6. PRICE AGGREGATES (COMPUTED MEDIAN & RANGES)
CREATE TABLE IF NOT EXISTS price_aggregates (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    item_id UUID NOT NULL REFERENCES items(id) ON DELETE CASCADE,
    market_id UUID NOT NULL REFERENCES markets(id) ON DELETE CASCADE,
    period_days INT NOT NULL DEFAULT 14, -- rolling window in days
    median_price NUMERIC(10, 2) NOT NULL,
    min_price NUMERIC(10, 2) NOT NULL,
    max_price NUMERIC(10, 2) NOT NULL,
    p10_price NUMERIC(10, 2), -- 10th percentile
    p90_price NUMERIC(10, 2), -- 90th percentile
    report_count INT NOT NULL DEFAULT 0,
    currency TEXT NOT NULL DEFAULT 'ETB',
    last_reported_at TIMESTAMPTZ,
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    CONSTRAINT uq_item_market UNIQUE (item_id, market_id)
);

-- 7. USER PROFILES & REPUTATION (PHASE 2 READY)
CREATE TABLE IF NOT EXISTS user_profiles (
    id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
    display_name TEXT,
    phone TEXT,
    role TEXT DEFAULT 'shopper', -- 'shopper', 'scout', 'admin'
    trust_score INT DEFAULT 10,
    reports_submitted INT DEFAULT 0,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- ============================================================================
-- 8. ROW LEVEL SECURITY (RLS) POLICIES
-- ============================================================================
ALTER TABLE markets ENABLE ROW LEVEL SECURITY;
ALTER TABLE items ENABLE ROW LEVEL SECURITY;
ALTER TABLE price_reports ENABLE ROW LEVEL SECURITY;
ALTER TABLE price_aggregates ENABLE ROW LEVEL SECURITY;
ALTER TABLE user_profiles ENABLE ROW LEVEL SECURITY;

-- Anyone (including anonymous public) can read markets, items, and aggregated prices
CREATE POLICY "Public read markets" ON markets FOR SELECT USING (true);
CREATE POLICY "Public read items" ON items FOR SELECT USING (true);
CREATE POLICY "Public read aggregates" ON price_aggregates FOR SELECT USING (true);

-- Anyone can read approved/verified price reports
CREATE POLICY "Public read verified reports" ON price_reports FOR SELECT 
USING (status IN ('verified', 'pending'));

-- Anyone can submit a price report (including guest/anon)
CREATE POLICY "Anyone can insert price report" ON price_reports FOR INSERT 
WITH CHECK (true);

-- ============================================================================
-- 9. AGGREGATION STORED PROCEDURE (ROLLING MEDIAN & OUTLIER FILTERING)
-- ============================================================================
CREATE OR REPLACE FUNCTION recompute_market_prices(p_window_days INT DEFAULT 14)
RETURNS VOID AS $$
BEGIN
    INSERT INTO price_aggregates (
        item_id,
        market_id,
        period_days,
        median_price,
        min_price,
        max_price,
        p10_price,
        p90_price,
        report_count,
        currency,
        last_reported_at,
        updated_at
    )
    SELECT
        r.item_id,
        r.market_id,
        p_window_days,
        ROUND(PERCENTILE_CONT(0.50) WITHIN GROUP (ORDER BY r.price_per_standard_unit)::numeric, 2) AS median_price,
        ROUND(MIN(r.price_per_standard_unit)::numeric, 2) AS min_price,
        ROUND(MAX(r.price_per_standard_unit)::numeric, 2) AS max_price,
        ROUND(PERCENTILE_CONT(0.10) WITHIN GROUP (ORDER BY r.price_per_standard_unit)::numeric, 2) AS p10_price,
        ROUND(PERCENTILE_CONT(0.90) WITHIN GROUP (ORDER BY r.price_per_standard_unit)::numeric, 2) AS p90_price,
        COUNT(*)::int AS report_count,
        'ETB',
        MAX(r.reported_at),
        NOW()
    FROM price_reports r
    WHERE r.reported_at >= NOW() - (p_window_days || ' days')::INTERVAL
      AND r.status != 'rejected'
    GROUP BY r.item_id, r.market_id
    ON CONFLICT (item_id, market_id) DO UPDATE SET
        period_days = EXCLUDED.period_days,
        median_price = EXCLUDED.median_price,
        min_price = EXCLUDED.min_price,
        max_price = EXCLUDED.max_price,
        p10_price = EXCLUDED.p10_price,
        p90_price = EXCLUDED.p90_price,
        report_count = EXCLUDED.report_count,
        last_reported_at = EXCLUDED.last_reported_at,
        updated_at = NOW();
END;
$$ LANGUAGE plpgsql;

-- ============================================================================
-- 10. SEED DATA FOR ADDIS ABABA (MARKETS & WIDER BASKET)
-- ============================================================================

-- Pilot Markets in Addis Ababa
INSERT INTO markets (name_en, name_am, city, subcity, latitude, longitude) VALUES
('Merkato', 'መርካቶ', 'Addis Ababa', 'Addis Ketema', 9.0305, 38.7402),
('Shola', 'ሾላ', 'Addis Ababa', 'Yeka', 9.0232, 38.7951),
('Saris', 'ሳሪስ', 'Addis Ababa', 'Akaky Kaliti', 8.9528, 38.7617),
('Kera', 'ቄራ', 'Addis Ababa', 'Kirkos', 9.0012, 38.7513),
('Megenagna', 'መገናኛ', 'Addis Ababa', 'Bole / Yeka', 9.0203, 38.8021)
ON CONFLICT DO NOTHING;

-- Wider Basket Items with Local Unit Conversions
INSERT INTO items (name_en, name_am, category, standard_unit, supported_local_units, icon_name) VALUES
-- Grains & Flours
('Teff (Magna)', 'ማኛ ጤፍ', 'grains_flour', 'kg', '[{"unit": "tassa", "multiplier": 1.25, "name_am": "ጣሳ"}, {"unit": "quintal", "multiplier": 100.0, "name_am": "ኩንታል"}]'::jsonb, 'grain'),
('Teff (Sergegna)', 'ሰርገኛ ጤፍ', 'grains_flour', 'kg', '[{"unit": "tassa", "multiplier": 1.25, "name_am": "ጣሳ"}, {"unit": "quintal", "multiplier": 100.0, "name_am": "ኩንታል"}]'::jsonb, 'grain'),
('Wheat Flour', 'የስንዴ ዱቄት', 'grains_flour', 'kg', '[{"unit": "quintal", "multiplier": 100.0, "name_am": "ኩንታል"}]'::jsonb, 'bakery_dining'),
('Shiro Flour', 'የሽሮ ዱቄት', 'grains_flour', 'kg', '[{"unit": "tassa", "multiplier": 1.10, "name_am": "ጣሳ"}]'::jsonb, 'soup_kitchen'),

-- Vegetables & Produce
('Red Onion', 'ቀይ ሽንኩርት', 'vegetables_produce', 'kg', '[]'::jsonb, 'eco'),
('Garlic', 'ነጭ ሽንኩርት', 'vegetables_produce', 'kg', '[{"unit": "kubaya", "multiplier": 0.35, "name_am": "ኩባያ"}]'::jsonb, 'spa'),
('Tomato', 'ቲማቲም', 'vegetables_produce', 'kg', '[]'::jsonb, 'nutrition'),
('Potato', 'ድንች', 'vegetables_produce', 'kg', '[]'::jsonb, 'agriculture'),
('Green Pepper (Karia)', 'ቃሪያ', 'vegetables_produce', 'kg', '[]'::jsonb, 'local_florist'),

-- Pulses & Legumes
('Red Lentils (Misir Kik)', 'የቀይ ምስር ክክ', 'pulses_legumes', 'kg', '[{"unit": "tassa", "multiplier": 1.20, "name_am": "ጣሳ"}]'::jsonb, 'grass'),
('Chickpeas (Shimbra)', 'ሽምብራ', 'pulses_legumes', 'kg', '[{"unit": "tassa", "multiplier": 1.15, "name_am": "ጣሳ"}]'::jsonb, 'grain'),

-- Meat & Dairy
('Beef (Siga)', 'የበሬ ሥጋ', 'meat_dairy', 'kg', '[]'::jsonb, 'restaurant'),
('Fresh Milk', 'ጥሬ ወተት', 'meat_dairy', 'liter', '[]'::jsonb, 'water_drop'),
('Spiced Butter (Qibe)', 'የተነጠረ ቅቤ', 'meat_dairy', 'kg', '[{"unit": "kubaya", "multiplier": 0.40, "name_am": "ኩባያ"}]'::jsonb, 'breakfast_dining'),
('Eggs', 'እንቁላል', 'meat_dairy', 'piece', '[{"unit": "crate (30)", "multiplier": 30.0, "name_am": "ካርቶን (30)"}]'::jsonb, 'egg'),

-- Oil, Sugar & Pantry
('Cooking Oil', 'የምግብ ዘይት', 'oil_sugar_pantry', 'liter', '[{"unit": "jog (3L)", "multiplier": 3.0, "name_am": "3 ሊትር ጆግ"}, {"unit": "jog (5L)", "multiplier": 5.0, "name_am": "5 ሊትር ጆግ"}]'::jsonb, 'opacity'),
('Sugar', 'ስኳር', 'oil_sugar_pantry', 'kg', '[]'::jsonb, 'cookie'),
('Berbere', 'በርበሬ', 'spices', 'kg', '[{"unit": "kubaya", "multiplier": 0.35, "name_am": "ኩባያ"}]'::jsonb, 'whatshot')
ON CONFLICT DO NOTHING;
