-- ==============================================================================
-- RUPOSHI INTERNATIONAL - COMPLETE PRODUCTION DATABASE & STORAGE SCHEMA
-- Target Environment: Supabase (PostgreSQL 15+)
-- Project URL: https://eisxuqlnznaixjgkjndc.supabase.co
-- ==============================================================================

-- 1. EXTENSIONS
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "pgcrypto";

-- ==============================================================================
-- 2. DROP EXISTING CONFLICTING TABLES
-- (Safely removes old/incompatible tables so new columns like 'title' exist cleanly)
-- ==============================================================================
DROP TABLE IF EXISTS public.products CASCADE;
DROP TABLE IF EXISTS public.orders CASCADE;
DROP TABLE IF EXISTS public.b2b_partners CASCADE;
DROP TABLE IF EXISTS public.coupons CASCADE;
DROP TABLE IF EXISTS public.warehouse_batches CASCADE;
DROP TABLE IF EXISTS public.customers CASCADE;

-- ==============================================================================
-- 3. TABLES DDL
-- ==============================================================================

-- 3.1 Products Catalog Table
CREATE TABLE public.products (
    id TEXT PRIMARY KEY,
    title TEXT NOT NULL,
    title_bn TEXT,
    brand TEXT NOT NULL,
    category TEXT NOT NULL,
    origin TEXT NOT NULL,
    flag TEXT,
    price NUMERIC(12, 2) NOT NULL CHECK (price >= 0),
    old_price NUMERIC(12, 2),
    wholesale_price NUMERIC(12, 2) NOT NULL CHECK (wholesale_price >= 0),
    moq INTEGER NOT NULL DEFAULT 10 CHECK (moq > 0),
    batch TEXT,
    expiry TEXT,
    skin_type TEXT,
    shades TEXT[] DEFAULT ARRAY[]::TEXT[],
    short_desc TEXT,
    description_bn TEXT,
    ingredients TEXT,
    usage TEXT,
    img TEXT NOT NULL,
    is_best_seller BOOLEAN DEFAULT FALSE,
    is_new_arrival BOOLEAN DEFAULT FALSE,
    stock INTEGER NOT NULL DEFAULT 50 CHECK (stock >= 0),
    rating NUMERIC(3, 1) DEFAULT 5.0 CHECK (rating >= 0 AND rating <= 5.0),
    reviews_count INTEGER DEFAULT 0 CHECK (reviews_count >= 0),
    created_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc'::text, now()),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc'::text, now())
);

-- 3.2 Orders Table
CREATE TABLE public.orders (
    order_id TEXT PRIMARY KEY,
    customer_name TEXT NOT NULL,
    customer_phone TEXT NOT NULL,
    delivery_address TEXT NOT NULL,
    city TEXT NOT NULL DEFAULT 'Dhaka',
    payment_method TEXT NOT NULL DEFAULT 'COD',
    subtotal NUMERIC(12, 2) NOT NULL DEFAULT 0.00 CHECK (subtotal >= 0),
    delivery_fee NUMERIC(12, 2) NOT NULL DEFAULT 0.00 CHECK (delivery_fee >= 0),
    grand_total NUMERIC(12, 2) NOT NULL DEFAULT 0.00 CHECK (grand_total >= 0),
    items JSONB NOT NULL DEFAULT '[]'::JSONB,
    status TEXT NOT NULL DEFAULT 'Pending',
    courier TEXT DEFAULT 'SteadFast',
    tracking_code TEXT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc'::text, now()),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc'::text, now())
);

-- 3.3 B2B Wholesale Partners Table
CREATE TABLE public.b2b_partners (
    id TEXT PRIMARY KEY,
    business_name TEXT NOT NULL,
    contact_person TEXT NOT NULL,
    phone TEXT NOT NULL,
    email TEXT,
    trade_license TEXT,
    district TEXT NOT NULL,
    tier TEXT NOT NULL DEFAULT 'Bronze',
    status TEXT NOT NULL DEFAULT 'Pending',
    total_orders INTEGER NOT NULL DEFAULT 0 CHECK (total_orders >= 0),
    total_spend NUMERIC(14, 2) NOT NULL DEFAULT 0.00 CHECK (total_spend >= 0),
    created_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc'::text, now())
);

-- 3.4 Promotional Coupons Table
CREATE TABLE public.coupons (
    code TEXT PRIMARY KEY,
    discount_percent NUMERIC(5, 2) NOT NULL CHECK (discount_percent > 0 AND discount_percent <= 100),
    min_spend NUMERIC(12, 2) NOT NULL DEFAULT 0.00 CHECK (min_spend >= 0),
    is_active BOOLEAN NOT NULL DEFAULT TRUE,
    usage_count INTEGER NOT NULL DEFAULT 0 CHECK (usage_count >= 0),
    expiry_date DATE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc'::text, now())
);

-- 3.5 Warehouse & BSTI Customs Batches Table
CREATE TABLE public.warehouse_batches (
    batch_no TEXT PRIMARY KEY,
    product_name TEXT NOT NULL,
    origin_country TEXT NOT NULL,
    bsti_cert_no TEXT,
    customs_entry_no TEXT,
    air_awb TEXT,
    current_temp TEXT DEFAULT '21°C',
    status TEXT NOT NULL DEFAULT 'Released',
    created_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc'::text, now())
);

-- 3.6 Customer CRM Directory Table
CREATE TABLE public.customers (
    phone TEXT PRIMARY KEY,
    name TEXT NOT NULL,
    district TEXT DEFAULT 'Dhaka',
    total_orders INTEGER NOT NULL DEFAULT 1 CHECK (total_orders >= 0),
    total_spent NUMERIC(14, 2) NOT NULL DEFAULT 0.00 CHECK (total_spent >= 0),
    last_order_date TIMESTAMPTZ NOT NULL DEFAULT timezone('utc'::text, now()),
    is_vip BOOLEAN NOT NULL DEFAULT FALSE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc'::text, now())
);

-- ==============================================================================
-- 4. PERFORMANCE INDEXES
-- ==============================================================================
CREATE INDEX IF NOT EXISTS idx_products_category ON public.products (category);
CREATE INDEX IF NOT EXISTS idx_products_brand ON public.products (brand);
CREATE INDEX IF NOT EXISTS idx_products_is_best_seller ON public.products (is_best_seller);
CREATE INDEX IF NOT EXISTS idx_products_is_new_arrival ON public.products (is_new_arrival);

CREATE INDEX IF NOT EXISTS idx_orders_customer_phone ON public.orders (customer_phone);
CREATE INDEX IF NOT EXISTS idx_orders_status ON public.orders (status);
CREATE INDEX IF NOT EXISTS idx_orders_created_at ON public.orders (created_at DESC);

CREATE INDEX IF NOT EXISTS idx_b2b_partners_phone ON public.b2b_partners (phone);
CREATE INDEX IF NOT EXISTS idx_b2b_partners_status ON public.b2b_partners (status);

CREATE INDEX IF NOT EXISTS idx_coupons_active ON public.coupons (is_active);

-- ==============================================================================
-- 5. AUTOMATED TRIGGERS & FUNCTIONS
-- ==============================================================================

CREATE OR REPLACE FUNCTION public.handle_updated_at()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = timezone('utc'::text, now());
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS trg_products_updated_at ON public.products;
CREATE TRIGGER trg_products_updated_at
BEFORE UPDATE ON public.products
FOR EACH ROW EXECUTE FUNCTION public.handle_updated_at();

DROP TRIGGER IF EXISTS trg_orders_updated_at ON public.orders;
CREATE TRIGGER trg_orders_updated_at
BEFORE UPDATE ON public.orders
FOR EACH ROW EXECUTE FUNCTION public.handle_updated_at();

-- Auto-sync customer CRM record on order placement
CREATE OR REPLACE FUNCTION public.handle_order_placed_sync_customer()
RETURNS TRIGGER AS $$
BEGIN
    INSERT INTO public.customers (phone, name, district, total_orders, total_spent, last_order_date, is_vip)
    VALUES (
        NEW.customer_phone,
        NEW.customer_name,
        NEW.city,
        1,
        NEW.grand_total,
        NEW.created_at,
        (NEW.grand_total >= 10000)
    )
    ON CONFLICT (phone) DO UPDATE SET
        name = EXCLUDED.name,
        total_orders = public.customers.total_orders + 1,
        total_spent = public.customers.total_spent + EXCLUDED.total_spent,
        last_order_date = EXCLUDED.last_order_date,
        is_vip = CASE WHEN (public.customers.total_spent + EXCLUDED.total_spent) >= 15000 THEN TRUE ELSE public.customers.is_vip END;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS trg_order_placed_customer_sync ON public.orders;
CREATE TRIGGER trg_order_placed_customer_sync
AFTER INSERT ON public.orders
FOR EACH ROW EXECUTE FUNCTION public.handle_order_placed_sync_customer();

-- ==============================================================================
-- 6. ROW LEVEL SECURITY (RLS) POLICIES
-- ==============================================================================

ALTER TABLE public.products ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.orders ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.b2b_partners ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.coupons ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.warehouse_batches ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.customers ENABLE ROW LEVEL SECURITY;

-- Products
DROP POLICY IF EXISTS "Public Read Products" ON public.products;
CREATE POLICY "Public Read Products" ON public.products FOR SELECT USING (true);

DROP POLICY IF EXISTS "Allow All Modify Products" ON public.products;
CREATE POLICY "Allow All Modify Products" ON public.products FOR ALL USING (true) WITH CHECK (true);

-- Orders
DROP POLICY IF EXISTS "Public Insert Orders" ON public.orders;
CREATE POLICY "Public Insert Orders" ON public.orders FOR INSERT WITH CHECK (true);

DROP POLICY IF EXISTS "Allow All Select Orders" ON public.orders;
CREATE POLICY "Allow All Select Orders" ON public.orders FOR SELECT USING (true);

DROP POLICY IF EXISTS "Allow All Update Orders" ON public.orders;
CREATE POLICY "Allow All Update Orders" ON public.orders FOR UPDATE USING (true) WITH CHECK (true);

DROP POLICY IF EXISTS "Allow All Delete Orders" ON public.orders;
CREATE POLICY "Allow All Delete Orders" ON public.orders FOR DELETE USING (true);

-- B2B Partners
DROP POLICY IF EXISTS "Public Register B2B Partners" ON public.b2b_partners;
CREATE POLICY "Public Register B2B Partners" ON public.b2b_partners FOR INSERT WITH CHECK (true);

DROP POLICY IF EXISTS "Allow All Access B2B Partners" ON public.b2b_partners;
CREATE POLICY "Allow All Access B2B Partners" ON public.b2b_partners FOR ALL USING (true) WITH CHECK (true);

-- Coupons
DROP POLICY IF EXISTS "Public Read Coupons" ON public.coupons;
CREATE POLICY "Public Read Coupons" ON public.coupons FOR SELECT USING (true);

DROP POLICY IF EXISTS "Allow All Modify Coupons" ON public.coupons;
CREATE POLICY "Allow All Modify Coupons" ON public.coupons FOR ALL USING (true) WITH CHECK (true);

-- Warehouse Batches
DROP POLICY IF EXISTS "Public Read Warehouse Batches" ON public.warehouse_batches;
CREATE POLICY "Public Read Warehouse Batches" ON public.warehouse_batches FOR SELECT USING (true);

DROP POLICY IF EXISTS "Allow All Modify Warehouse Batches" ON public.warehouse_batches;
CREATE POLICY "Allow All Modify Warehouse Batches" ON public.warehouse_batches FOR ALL USING (true) WITH CHECK (true);

-- Customers CRM
DROP POLICY IF EXISTS "Allow All Access Customers" ON public.customers;
CREATE POLICY "Allow All Access Customers" ON public.customers FOR ALL USING (true) WITH CHECK (true);

-- ==============================================================================
-- 7. SUPABASE STORAGE BUCKET: product-images (<= 100 KB Compressed Uploads)
-- ==============================================================================

DO $$
BEGIN
    INSERT INTO storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
    VALUES (
        'product-images',
        'product-images',
        TRUE,
        5242880,
        ARRAY['image/jpeg', 'image/png', 'image/webp', 'image/jpg', 'image/gif']
    )
    ON CONFLICT (id) DO UPDATE SET
        public = TRUE;
EXCEPTION WHEN OTHERS THEN
    RAISE NOTICE 'Storage bucket insertion notice: %', SQLERRM;
END $$;

DO $$
BEGIN
    DROP POLICY IF EXISTS "Public Access Product Images" ON storage.objects;
    CREATE POLICY "Public Access Product Images"
    ON storage.objects FOR SELECT
    USING (bucket_id = 'product-images');

    DROP POLICY IF EXISTS "Allow Upload Product Images" ON storage.objects;
    CREATE POLICY "Allow Upload Product Images"
    ON storage.objects FOR INSERT
    WITH CHECK (bucket_id = 'product-images');

    DROP POLICY IF EXISTS "Allow Update Product Images" ON storage.objects;
    CREATE POLICY "Allow Update Product Images"
    ON storage.objects FOR UPDATE
    USING (bucket_id = 'product-images')
    WITH CHECK (bucket_id = 'product-images');

    DROP POLICY IF EXISTS "Allow Delete Product Images" ON storage.objects;
    CREATE POLICY "Allow Delete Product Images"
    ON storage.objects FOR DELETE
    USING (bucket_id = 'product-images');
EXCEPTION WHEN OTHERS THEN
    RAISE NOTICE 'Storage policy notice: %', SQLERRM;
END $$;

-- ==============================================================================
-- 8. INITIAL PRODUCTION SEED DATA
-- ==============================================================================

-- 8.1 Official Cosmetics Products
INSERT INTO public.products (
    id, title, title_bn, brand, category, origin, flag, price, old_price,
    wholesale_price, moq, batch, expiry, skin_type, shades, short_desc,
    description_bn, ingredients, usage, img, is_best_seller, is_new_arrival,
    stock, rating, reviews_count
) VALUES
(
    'p1',
    'Heartleaf 77% Soothing Toner',
    'হার্টলিফ ৭৭% সুদিং টোনার',
    'Anua',
    'Skincare',
    'South Korea',
    '🇰🇷',
    2150.00,
    2450.00,
    1450.00,
    10,
    'AN-2026-03K',
    '12/2027',
    'Sensitive & Acne-Prone Skin',
    ARRAY[]::TEXT[],
    'Soothes irritated skin and balances moisture with 77% Houttuynia Cordata extract.',
    'সংবেদনশীল ত্বকের লালচে ভাব ও ব্রণ কমাতে অত্যন্ত কার্যকর দক্ষিণ কোরিয়ান টোনার।',
    'Houttuynia Cordata Extract (77%), Purified Water, Gluconolactone, Betaine, Centella Asiatica.',
    'After cleansing, apply gently across face and pat until absorbed.',
    'https://images.unsplash.com/photo-1556228720-195a672e8a03?w=800&q=80',
    TRUE,
    FALSE,
    42,
    4.9,
    148
),
(
    'p2',
    'Skin Perfecting 2% BHA Liquid Exfoliant',
    'স্কিন পারফেক্টিং ২% বিএইচএ এক্সফোলিয়েন্ট',
    'Paula''s Choice',
    'Skincare',
    'USA',
    '🇺🇸',
    3450.00,
    3900.00,
    2350.00,
    6,
    'PC-USA-9921',
    '08/2027',
    'Oily & Combination Skin',
    ARRAY[]::TEXT[],
    'Gentle leave-on exfoliant that clears pores, smooths wrinkles, and evens skin tone.',
    'ব্ল্যাকহেডস ও পোরস গভীরভাবে পরিষ্কার করে ত্বকের টেক্সচার মসৃণ করে।',
    'Salicylic Acid 2%, Camellia Oleifera (Green Tea) Leaf Extract, Methylpropanediol.',
    'Apply once or twice daily after cleansing and toning with a cotton pad.',
    'https://images.unsplash.com/photo-1620916566398-39f1143ab7be?w=800&q=80',
    TRUE,
    FALSE,
    28,
    5.0,
    312
),
(
    'p3',
    'Lip Sleeping Mask (Berry 20g)',
    'লিপ স্লিপিং মাস্ক (বেরি ২০ গ্রাম)',
    'Laneige',
    'Lip Care',
    'South Korea',
    '🇰🇷',
    1850.00,
    2100.00,
    1250.00,
    12,
    'LN-LIP-4410',
    '03/2028',
    'All Skin Types',
    ARRAY['Berry', 'Grapefruit', 'Apple Lime', 'Vanilla'],
    'Overnight leave-on lip mask that delivers intense moisture and antioxidants.',
    'রাতারাতি ঠোঁটের শুষ্কতা দূর করে নরম ও কোমল করে তোলে।',
    'Berry Fruit Complex, Vitamin C, Coconut Oil, Shea Butter, Murumuru Seed Butter.',
    'Apply generously to lips before sleeping; wipe clean gently next morning.',
    'https://images.unsplash.com/photo-1586495777744-4413f21062fa?w=800&q=80',
    TRUE,
    FALSE,
    65,
    4.8,
    240
),
(
    'p4',
    'Advanced Snail 96 Mucin Power Essence',
    'অ্যাডভান্সড স্নেল ৯৬ মিউসিন এসেন্স',
    'COSRX',
    'Skincare',
    'South Korea',
    '🇰🇷',
    1750.00,
    1950.00,
    1150.00,
    10,
    'CX-SNL-8812',
    '11/2027',
    'Dry, Dull & Aging Skin',
    ARRAY[]::TEXT[],
    'Lightweight essence enriched with 96.3% snail secretion filtrate for intense repair.',
    'ত্বকের ক্ষতি পূরণ ও প্রাকৃতিক গ্লো ফিরিয়ে আনতে সমৃদ্ধ স্নেল এসেন্স।',
    'Snail Secretion Filtrate 96.3%, Betaine, Sodium Hyaluronate, Allantoin, Panthenol.',
    'Pump an adequate amount and gently massage over whole face until absorbed.',
    'https://images.unsplash.com/photo-1608248597359-26966f363c46?w=800&q=80',
    FALSE,
    TRUE,
    38,
    4.9,
    186
),
(
    'p5',
    'Niacinamide 10% + Zinc 1%',
    'নিয়াসিনামাইড ১০% + জিঙ্ক ১%',
    'The Ordinary',
    'Serums',
    'Canada',
    '🇨🇦',
    1350.00,
    1550.00,
    880.00,
    15,
    'TO-NZ-1011',
    '06/2027',
    'Blemish-Prone Skin',
    ARRAY[]::TEXT[],
    'High-strength vitamin and mineral blemish formula that visibly targets blemishes.',
    'ব্রণের দাগ হালকা করতে এবং অতিরিক্ত তেল উৎপাদন নিয়ন্ত্রণে কার্যকর।',
    'Niacinamide (Vitamin B3) 10%, Zinc PCA 1%, Tamarindus Indica Seed Gum.',
    'Apply to entire face morning and evening before heavier creams.',
    'https://images.unsplash.com/photo-1617897903246-719242758050?w=800&q=80',
    FALSE,
    TRUE,
    55,
    4.7,
    520
),
(
    'p6',
    'Hydrating Cleanser with Ceramides',
    'হাইড্রেটিং ক্লিনজার উইথ সিরামাইডস',
    'CeraVe',
    'Cleansers',
    'USA',
    '🇺🇸',
    1950.00,
    2200.00,
    1320.00,
    10,
    'CV-HYD-5501',
    '09/2027',
    'Normal to Dry Skin',
    ARRAY[]::TEXT[],
    'Non-foaming lotion cleanser that cleanses and hydrates while maintaining skin barrier.',
    'ত্বকের স্বাভাবিক আর্দ্রতা বজায় রেখে আলতোভাবে পরিষ্কার করে।',
    'Ceramides 1, 3, 6-II, Hyaluronic Acid, Glycerin, MVE Delivery Technology.',
    'Wet skin with lukewarm water. Massage cleanser into skin in gentle circular motion.',
    'https://images.unsplash.com/photo-1556228722-d0b5de70b774?w=800&q=80',
    FALSE,
    FALSE,
    44,
    4.8,
    98
),
(
    'p7',
    'Anthelios UVMune 400 Invisible Fluid SPF50+',
    'অ্যান্থেলিয়স ইউভিমিউন ৪০০ সানস্ক্রিন',
    'La Roche-Posay',
    'Sun Care',
    'France',
    '🇫🇷',
    2850.00,
    3200.00,
    1950.00,
    8,
    'LRP-UV-7734',
    '01/2028',
    'All Skin Types',
    ARRAY[]::TEXT[],
    'Ultimate broad spectrum UV protection preventing cellular damage from ultra-long UVA rays.',
    'সবচেয়ে ক্ষতিকর আল্ট্রা-লং ইউভিএ রশ্মি থেকে ত্বককে সর্বোচ্চ সুরক্ষা দেয়।',
    'Mexoryl 400, Netlock Technology, Glycerin, Thermal Spring Water.',
    'Shake well before use. Apply liberally 15 minutes before sun exposure.',
    'https://images.unsplash.com/photo-1598440947619-2c35fc9aa908?w=800&q=80',
    TRUE,
    FALSE,
    30,
    5.0,
    164
),
(
    'p8',
    'Relief Sun : Rice + Probiotics SPF50+ PA++++',
    'রিলিফ সান : রাইস + প্রোবায়োটিকস সানস্ক্রিন',
    'Beauty of Joseon',
    'Sun Care',
    'South Korea',
    '🇰🇷',
    1750.00,
    1980.00,
    1150.00,
    12,
    'BOJ-SUN-2026',
    '10/2027',
    'Sensitive & Normal Skin',
    ARRAY[]::TEXT[],
    'Organic sunscreen with lightweight creamy texture that leaves zero white cast.',
    'ভাতের নির্যাস ও প্রোবায়োটিক সমৃদ্ধ যা ত্বককে ময়েশ্চারাইজ করে ও উজ্জ্বল রাখে।',
    'Rice Extract 30%, Fermented Grain Complex, Niacinamide, Camellia Sinensis.',
    'Evenly spread a generous amount over face and neck as the final skincare step.',
    'https://images.unsplash.com/photo-1522337360788-8b13dee7a37e?w=800&q=80',
    TRUE,
    TRUE,
    52,
    4.9,
    410
);

-- 8.2 Active Coupons
INSERT INTO public.coupons (code, discount_percent, min_spend, is_active, usage_count, expiry_date)
VALUES
('RUPOSHI10', 10.00, 1500.00, TRUE, 142, '2026-12-31'),
('GLOW20', 20.00, 3500.00, TRUE, 58, '2026-11-30'),
('EID2026', 15.00, 2500.00, TRUE, 89, '2026-12-31');

-- 8.3 B2B Verified Partners
INSERT INTO public.b2b_partners (id, business_name, contact_person, phone, email, trade_license, district, tier, status, total_orders, total_spend)
VALUES
('b2b-01', 'Dhanmondi Beauty Lounge', 'Afroza Khan', '+8801711223344', 'dhanmondi.beauty@gmail.com', 'TRAD/DN/2024/0992', 'Dhaka', 'Platinum', 'Active', 24, 485000.00),
('b2b-02', 'Banani Skin Studio & Spa', 'Dr. Sabrina Haque', '+8801819556677', 'banani.skin@spa.bd', 'TRAD/DN/2023/8810', 'Dhaka', 'Gold', 'Active', 18, 312000.00),
('b2b-03', 'Chittagong Glamour Parlour', 'Nusrat Jahan', '+8801914778899', 'ctg.glamour@yahoo.com', 'TRAD/CTG/2025/1102', 'Chittagong', 'Silver', 'Active', 9, 142000.00),
('b2b-04', 'Sylhet Aesthetic Hub', 'Kamrul Hasan', '+8801612334455', 'sylhet.aesthetics@gmail.com', 'TRAD/SYL/2026/0411', 'Sylhet', 'Bronze', 'Pending', 1, 28000.00);

-- 8.4 Warehouse BSTI Customs Batches
INSERT INTO public.warehouse_batches (batch_no, product_name, origin_country, bsti_cert_no, customs_entry_no, air_awb, current_temp, status)
VALUES
('AN-2026-03K', 'Heartleaf 77% Soothing Toner', 'South Korea', 'BSTI/COS/2026/1842', 'C-109288/DAC', 'KE-652-9901-4412', '20.5°C', 'Released'),
('PC-USA-9921', 'Skin Perfecting 2% BHA Liquid', 'USA', 'BSTI/COS/2026/0921', 'C-087123/DAC', 'QR-157-8812-7731', '21.0°C', 'Released'),
('LN-LIP-4410', 'Lip Sleeping Mask 20g', 'South Korea', 'BSTI/COS/2026/1140', 'C-112044/DAC', 'TG-310-4491-0021', '19.8°C', 'Released'),
('BOJ-SUN-2026', 'Relief Sun : Rice + Probiotics', 'South Korea', 'BSTI/COS/2026/3011', 'C-134991/DAC', 'KE-652-3321-7714', '21.2°C', 'Released');

-- 8.5 Customer CRM Records
INSERT INTO public.customers (phone, name, district, total_orders, total_spent, last_order_date, is_vip)
VALUES
('+8801711223344', 'Afroza Khan', 'Dhaka', 24, 485000.00, NOW() - INTERVAL '2 days', TRUE),
('+8801819556677', 'Dr. Sabrina Haque', 'Dhaka', 18, 312000.00, NOW() - INTERVAL '5 days', TRUE),
('+8801912345678', 'Sadia Islam', 'Dhaka', 3, 7250.00, NOW() - INTERVAL '1 day', FALSE),
('+8801812345679', 'Tahmina Rahman', 'Chittagong', 2, 4900.00, NOW() - INTERVAL '4 days', FALSE);

-- ==============================================================================
-- END OF COMPLETE SCHEMA SCRIPT
-- ==============================================================================
