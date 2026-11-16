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
    gallery TEXT[] DEFAULT ARRAY[]::TEXT[],
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

-- 3.7 Admin Users & Executive Security Table
CREATE TABLE IF NOT EXISTS public.admin_users (
    id TEXT PRIMARY KEY DEFAULT gen_random_uuid()::TEXT,
    username TEXT UNIQUE NOT NULL,
    email TEXT,
    password_hash TEXT NOT NULL,
    role TEXT NOT NULL DEFAULT 'SuperAdmin',
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
ALTER TABLE public.admin_users ENABLE ROW LEVEL SECURITY;

-- Admin Users
DROP POLICY IF EXISTS "Allow All Access Admin Users" ON public.admin_users;
CREATE POLICY "Allow All Access Admin Users" ON public.admin_users FOR ALL USING (true) WITH CHECK (true);

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

-- 8.1 Official TIA'M South Korea Dermo-Cosmetics Flagship Products (tiamglobal.com)
INSERT INTO public.products (
    id, title, title_bn, brand, category, origin, flag, price, old_price,
    wholesale_price, moq, batch, expiry, skin_type, shades, short_desc,
    description_bn, ingredients, usage, img, gallery, is_best_seller, is_new_arrival,
    stock, rating, reviews_count
) VALUES
(
    'tiam_p1_vita_b3_source',
    'TIA''M Vita B3 Source (10% Niacinamide + 2% Arbutin)',
    'টিআই''এম ভিটা বি৩ সোর্স সিরাম (১০% নিয়াসিনামাইড ও ২% আরবুটিন)',
    'TIA''M',
    'Serums',
    'South Korea',
    '🇰🇷',
    1650.00,
    1950.00,
    1180.00,
    10,
    'TM-VB3-2026-01',
    '2028-06',
    'All Skin Types, Dark Spots & Hyperpigmentation',
    ARRAY['40ml Dropper']::TEXT[],
    'High-potency dual brightening serum formulated with 10% Niacinamide and 2% Arbutin to fade post-acne marks, melasma, and hyperpigmentation while balancing excess sebum.',
    '১০% নিয়াসিনামাইড এবং ২% আরবুটিন সমৃদ্ধ শক্তিশালী ব্রাইটনিং সিরাম। এটি মেছতা, ব্রণের জেদি দাগ দূর করতে এবং অতিরিক্ত তেল নিয়ন্ত্রণ করে ত্বককে উজ্জ্বল করে।',
    'Water, Niacinamide (10%), Butylene Glycol, Arbutin (2%), Allantoin, Dipotassium Glycyrrhizate, Sodium Hyaluronate, Hydroxyethylcellulose, 1,2-Hexanediol.',
    'Apply 2-3 drops evenly over cleansed and toned skin morning and evening. Follow with daytime sunscreen.',
    'https://images.unsplash.com/photo-1620916566398-39f1143ab7be?auto=format&fit=crop&w=800&q=80',
    ARRAY[
        'https://images.unsplash.com/photo-1608248597359-26d11b228f41?auto=format&fit=crop&w=800&q=80',
        'https://images.unsplash.com/photo-1556228720-195a672e8a03?auto=format&fit=crop&w=800&q=80',
        'https://images.unsplash.com/photo-1616683693504-3ea7e9ad6fec?auto=format&fit=crop&w=800&q=80',
        'https://images.unsplash.com/photo-1598440947619-2c35fc9aa908?auto=format&fit=crop&w=800&q=80'
    ]::TEXT[],
    TRUE,
    FALSE,
    45,
    4.9,
    218
),
(
    'tiam_p2_pore_minimizing_21',
    'TIA''M Pore Minimizing 21 Serum (20% Niacinamide + 1% Zinc PCA)',
    'টিআই''এম পোর মিনিমাইজিং ২১ সিরাম (২০% নিয়াসিনামাইড + জিংক পিসিএ)',
    'TIA''M',
    'Serums',
    'South Korea',
    '🇰🇷',
    1750.00,
    2100.00,
    1250.00,
    10,
    'TM-PM21-2026-02',
    '2028-05',
    'Oily, Enlarged Pores & Rough Texture',
    ARRAY['40ml Dropper']::TEXT[],
    'Engineered with 20% high-concentration Niacinamide, 1% Zinc PCA, and Willow Bark extract to tighten enlarged pores, regulate oil secretion, and smooth rough skin.',
    'উচ্চমাত্রার ২০% নিয়াসিনামাইড এবং ১% জিংক পিসিএ সমৃদ্ধ সিরাম যা বড় হয়ে যাওয়া লোমকূপ সঙ্কুচিত করে, অতিরিক্ত সিবাম উৎপাদন রোধ করে এবং খসখসে ভাব দূর করে মসৃণ করে।',
    'Water, Niacinamide (20%), Butylene Glycol, 1,2-Hexanediol, Zinc PCA (1%), Salix Alba (Willow) Bark Water, Sodium Hyaluronate, Allantoin, Xanthan Gum.',
    'Dispense 2-3 drops after toner, gently patting into areas with enlarged pores or excess shine. Use SPF during daytime.',
    'https://images.unsplash.com/photo-1608248597359-26d11b228f41?auto=format&fit=crop&w=800&q=80',
    ARRAY[
        'https://images.unsplash.com/photo-1556228720-195a672e8a03?auto=format&fit=crop&w=800&q=80',
        'https://images.unsplash.com/photo-1616683693504-3ea7e9ad6fec?auto=format&fit=crop&w=800&q=80',
        'https://images.unsplash.com/photo-1598440947619-2c35fc9aa908?auto=format&fit=crop&w=800&q=80',
        'https://images.unsplash.com/photo-1522337360788-8b13dee7a37e?auto=format&fit=crop&w=800&q=80'
    ]::TEXT[],
    TRUE,
    FALSE,
    38,
    4.9,
    176
),
(
    'tiam_p3_vita_a_bakuchiol',
    'TIA''M Vita A Bakuchiol Youth Serum (Retinol Alternative)',
    'টিআই''এম ভিটা এ বাকুচিওল ইউথ সিরাম (অ্যান্টি-এজিং সিরাম)',
    'TIA''M',
    'Serums',
    'South Korea',
    '🇰🇷',
    1850.00,
    2250.00,
    1320.00,
    10,
    'TM-VAB-2026-03',
    '2028-08',
    'Aging, Fine Lines & Loss of Elasticity',
    ARRAY['40ml Pump Bottle']::TEXT[],
    'Gentle yet powerful anti-aging youth serum formulated with Vitamin A (Retinyl Palmitate), plant-based Bakuchiol, and Hydrolyzed Collagen to firm and plump without irritation.',
    'ভিটামিন এ (রেটিনাইল পালমিটেট), প্রাকৃতিক বাকুচিওল এবং কোলাজেন সমৃদ্ধ তারুণ্যোজ্জ্বল সিরাম যা বলিরেখা ও ফাইন লাইনস কমায় এবং ত্বককে টানটান ও উজ্জ্বল রাখে।',
    'Water, Butylene Glycol, Glycerin, Helianthus Annuus (Sunflower) Seed Oil, Bakuchiol, Retinyl Palmitate, Hydrolyzed Collagen, Adenosine, Tocopherol.',
    'Apply evenly onto face and neck during evening routine. Always apply sunscreen the following morning.',
    'https://images.unsplash.com/photo-1556228720-195a672e8a03?auto=format&fit=crop&w=800&q=80',
    ARRAY[
        'https://images.unsplash.com/photo-1620916566398-39f1143ab7be?auto=format&fit=crop&w=800&q=80',
        'https://images.unsplash.com/photo-1616683693504-3ea7e9ad6fec?auto=format&fit=crop&w=800&q=80',
        'https://images.unsplash.com/photo-1598440947619-2c35fc9aa908?auto=format&fit=crop&w=800&q=80',
        'https://images.unsplash.com/photo-1522337360788-8b13dee7a37e?auto=format&fit=crop&w=800&q=80'
    ]::TEXT[],
    FALSE,
    TRUE,
    50,
    4.8,
    94
),
(
    'tiam_p4_snail_azulene_essence',
    'TIA''M Snail & Azulene Water Essence (87% Snail Mucin)',
    'টিআই''এম স্নেল অ্যান্ড আজুলিন ওয়াটার এসেন্স (স্কিন বেরিয়ার রিপেয়ার)',
    'TIA''M',
    'Toner & Essence',
    'South Korea',
    '🇰🇷',
    1750.00,
    2050.00,
    1250.00,
    10,
    'TM-SAE-2026-04',
    '2028-09',
    'Dry, Sensitive & Damaged Barrier Skin',
    ARRAY['180ml Jumbo Bottle']::TEXT[],
    'Intensively hydrating restorative water essence packed with 87% Snail Secretion Filtrate and soothing Guaiazulene to heal damaged skin, relieve redness, and calm irritation.',
    '৮৭% স্নেল মিউসিন এবং ক্যামোমাইল থেকে প্রাপ্ত আজুলিন সমৃদ্ধ ওয়াটার এসেন্স। এটি ক্ষতিগ্রস্ত স্কিন বেরিয়ার নিরাময় করে, লালচে ভাব দূর করে এবং ত্বকে দীর্ঘস্থায়ী আর্দ্রতা জোগায়।',
    'Snail Secretion Filtrate (87%), Butylene Glycol, Glycerin, Sodium Guaiazulene Sulfonate, Betaine, Allantoin, Panthenol, Sodium Hyaluronate.',
    'Pour moderate amount into palms or cotton pad and gently pat across entire face after cleansing until completely absorbed.',
    'https://images.unsplash.com/photo-1616683693504-3ea7e9ad6fec?auto=format&fit=crop&w=800&q=80',
    ARRAY[
        'https://images.unsplash.com/photo-1620916566398-39f1143ab7be?auto=format&fit=crop&w=800&q=80',
        'https://images.unsplash.com/photo-1608248597359-26d11b228f41?auto=format&fit=crop&w=800&q=80',
        'https://images.unsplash.com/photo-1556228720-195a672e8a03?auto=format&fit=crop&w=800&q=80',
        'https://images.unsplash.com/photo-1598440947619-2c35fc9aa908?auto=format&fit=crop&w=800&q=80'
    ]::TEXT[],
    TRUE,
    FALSE,
    52,
    4.9,
    153
),
(
    'tiam_p5_snail_azulene_cleanser',
    'TIA''M Snail & Azulene Low pH Cleanser (pH 5.5 Balanced)',
    'টিআই''এম স্নেল অ্যান্ড আজুলিন লো পিএইচ ক্লিনজার (মৃদু ফেসিয়াল ওয়াশ)',
    'TIA''M',
    'Cleansers',
    'South Korea',
    '🇰🇷',
    1550.00,
    1800.00,
    1100.00,
    10,
    'TM-SAC-2026-05',
    '2028-07',
    'Sensitive, Acne-Prone & Dehydrated Skin',
    ARRAY['200ml Family Pump']::TEXT[],
    'Mild gel cleanser formulated at skin-natural pH 5.5 with Snail Mucin and Guaiazulene to wash away daily dirt, sebum, and fine dust without stripping moisture.',
    'ত্বকের প্রাকৃতিক পিএইচ ৫.৫ সমতাযুক্ত মৃদু জেল ক্লিনজার। স্নেল মিউসিন এবং আজুলিন থাকায় ত্বক শুষ্ক না করে গভীর থেকে পরিষ্কার করে এবং প্রশান্তি দেয়।',
    'Water, Snail Secretion Filtrate, Cocamidopropyl Betaine, Sodium Lauroyl Methyl Isethionate, Sodium Guaiazulene Sulfonate, Panthenol, Citric Acid.',
    'Lather small amount with water, gently massage in circular motions across damp face, and rinse thoroughly with lukewarm water.',
    'https://images.unsplash.com/photo-1598440947619-2c35fc9aa908?auto=format&fit=crop&w=800&q=80',
    ARRAY[
        'https://images.unsplash.com/photo-1620916566398-39f1143ab7be?auto=format&fit=crop&w=800&q=80',
        'https://images.unsplash.com/photo-1608248597359-26d11b228f41?auto=format&fit=crop&w=800&q=80',
        'https://images.unsplash.com/photo-1556228720-195a672e8a03?auto=format&fit=crop&w=800&q=80',
        'https://images.unsplash.com/photo-1616683693504-3ea7e9ad6fec?auto=format&fit=crop&w=800&q=80'
    ]::TEXT[],
    FALSE,
    FALSE,
    40,
    4.8,
    112
),
(
    'tiam_p6_snail_azulene_mask',
    'TIA''M Snail & Azulene Sleeping Mask (Overnight Recovery)',
    'টিআই''এম স্নেল অ্যান্ড আজুলিন স্লিপিং মাস্ক (নাইট রিপেয়ার মাস্ক)',
    'TIA''M',
    'Creams & Masks',
    'South Korea',
    '🇰🇷',
    1750.00,
    2050.00,
    1250.00,
    10,
    'TM-SASM-2026-06',
    '2028-10',
    'Dry, Fatigued & Stressed Barrier Skin',
    ARRAY['80ml Glass Jar']::TEXT[],
    'Soothing overnight treatment packed with 85% Snail Filtrate and Azulene that locks in deep hydration, repairs skin overnight, and reveals radiant glow by morning.',
    '৮৫% স্নেল ফিল্ট্রেট ও আজুলিন সমৃদ্ধ ওভারনাইট মাস্ক। ঘুমের মধ্যে ত্বকের ক্লান্তি ও ক্ষতি মেরামত করে সকালের মধ্যে ত্বককে কোমল, প্রাণবন্ত ও গ্লোয়িং করে তোলে।',
    'Snail Secretion Filtrate (85%), Glycerin, Butylene Glycol, Sodium Guaiazulene Sulfonate, Betaine, Allantoin, Panthenol, Carbomer.',
    'As last step of nighttime routine, apply moderate layer over entire face avoiding eye and lip areas. Wash off with lukewarm water next morning.',
    'https://images.unsplash.com/photo-1522337360788-8b13dee7a37e?auto=format&fit=crop&w=800&q=80',
    ARRAY[
        'https://images.unsplash.com/photo-1620916566398-39f1143ab7be?auto=format&fit=crop&w=800&q=80',
        'https://images.unsplash.com/photo-1608248597359-26d11b228f41?auto=format&fit=crop&w=800&q=80',
        'https://images.unsplash.com/photo-1556228720-195a672e8a03?auto=format&fit=crop&w=800&q=80',
        'https://images.unsplash.com/photo-1616683693504-3ea7e9ad6fec?auto=format&fit=crop&w=800&q=80'
    ]::TEXT[],
    FALSE,
    TRUE,
    30,
    4.9,
    88
),
(
    'tiam_p7_ac_fighting_spot_cream',
    'TIA''M AC Fighting Spot Rx Cream (10% Niacinamide + Zinc)',
    'টিআই''এম এসি ফাইটিং স্পট আরএক্স ক্রিম (একনে ও ব্রণের সমাধান)',
    'TIA''M',
    'Treatments & Creams',
    'South Korea',
    '🇰🇷',
    1550.00,
    1850.00,
    1100.00,
    10,
    'TM-ACSP-2026-07',
    '2028-06',
    'Acne-Prone, Active Blemishes & Pimple Spots',
    ARRAY['30ml Precision Tube']::TEXT[],
    'Fast-acting blemish rescue cream featuring 10% Niacinamide, Zinc Oxide, Centella Asiatica, and natural micro-spicules to target acne bacteria and accelerate recovery.',
    '১০% নিয়াসিনামাইড, জিঙ্ক এবং সেন্টেলা সমৃদ্ধ দ্রুত কার্যকরী পিম্পল স্পট ক্রিম। এটি ব্রণের প্রদাহ কমায়, ব্যাকটেরিয়া দূর করে এবং দাগ পড়া রোধ করে।',
    'Water, Niacinamide (10%), Zinc Oxide (7%), Glycerin, Centella Asiatica Extract, Melaleuca Alternifolia (Tea Tree) Leaf Oil, Hydrolyzed Sponge, Asiaticoside.',
    'Dab a small pea-sized amount directly onto active pimples or breakout areas after moisturizer. Gently press until absorbed.',
    'https://images.unsplash.com/photo-1556228720-195a672e8a03?auto=format&fit=crop&w=800&q=80',
    ARRAY[
        'https://images.unsplash.com/photo-1620916566398-39f1143ab7be?auto=format&fit=crop&w=800&q=80',
        'https://images.unsplash.com/photo-1608248597359-26d11b228f41?auto=format&fit=crop&w=800&q=80',
        'https://images.unsplash.com/photo-1616683693504-3ea7e9ad6fec?auto=format&fit=crop&w=800&q=80',
        'https://images.unsplash.com/photo-1598440947619-2c35fc9aa908?auto=format&fit=crop&w=800&q=80'
    ]::TEXT[],
    TRUE,
    FALSE,
    55,
    4.9,
    230
),
(
    'tiam_p8_ac_fighting_aqua_cream',
    'TIA''M AC Fighting Oil-Free Aqua Cream (Gel Moisturizer)',
    'টিআই''এম এসি ফাইটিং অয়েল-ফ্রি অ্যাকোয়া ক্রিম (হালকা ময়েশ্চারাইজার)',
    'TIA''M',
    'Creams & Moisturizers',
    'South Korea',
    '🇰🇷',
    1650.00,
    1950.00,
    1180.00,
    10,
    'TM-ACOF-2026-08',
    '2028-08',
    'Oily, Congested & Combination Skin',
    ARRAY['50ml Jar']::TEXT[],
    '100% oil-free lightweight cooling aqua cream delivering oil-balancing hydration with Panthenol, Betaine, and Niacinamide without clogging pores or greasy shine.',
    '১০০% তেলমুক্ত ওয়াটার-জেল ময়েশ্চারাইজার যা পোরস বন্ধ না করে ত্বকে প্রশান্তিদায়ক আর্দ্রতা জোগায় এবং অতিরিক্ত তৈলাক্ত ভাব নিয়ন্ত্রণ করে।',
    'Water, Butylene Glycol, Glycerin, 1,2-Hexanediol, Niacinamide, Panthenol, Betaine, Allantoin, Arginine, Carbomer, Melaleuca Alternifolia (Tea Tree) Extract.',
    'Smooth an appropriate amount over face as final step of morning and evening skincare routine.',
    'https://images.unsplash.com/photo-1608248597359-26d11b228f41?auto=format&fit=crop&w=800&q=80',
    ARRAY[
        'https://images.unsplash.com/photo-1620916566398-39f1143ab7be?auto=format&fit=crop&w=800&q=80',
        'https://images.unsplash.com/photo-1556228720-195a672e8a03?auto=format&fit=crop&w=800&q=80',
        'https://images.unsplash.com/photo-1616683693504-3ea7e9ad6fec?auto=format&fit=crop&w=800&q=80',
        'https://images.unsplash.com/photo-1522337360788-8b13dee7a37e?auto=format&fit=crop&w=800&q=80'
    ]::TEXT[],
    FALSE,
    FALSE,
    42,
    4.8,
    104
),
(
    'tiam_p9_vita_b3_mist_toner',
    'TIA''M Vita B3 Mist Toner (Brightening & Glow Booster)',
    'টিআই''এম ভিটা বি৩ মিস্ট টোনার (উজ্জ্বলতাকারী মিস্ট টোনার)',
    'TIA''M',
    'Toner & Essence',
    'South Korea',
    '🇰🇷',
    1650.00,
    1900.00,
    1180.00,
    10,
    'TM-VBM-2026-09',
    '2028-09',
    'Dull, Dehydrated & Uneven Tone Skin',
    ARRAY['200ml Fine Spray Mist']::TEXT[],
    'Ultra-fine vitamin hydrating mist toner packed with 3% Niacinamide, Tranexamic Acid, and Vitamin C to revitalize tired complexion and boost radiance anytime, anywhere.',
    '৩% নিয়াসিনামাইড, ট্রানেক্সামিক অ্যাসিড ও ভিটামিন সি সমৃদ্ধ হালকা মিস্ট টোনার। এটি সারাদিন ত্বককে হাইড্রেটেড রাখে এবং তাৎক্ষণিক ব্রাইট গ্লো দেয়।',
    'Water, Niacinamide (3%), 1,2-Hexanediol, Butylene Glycol, Tranexamic Acid, Ascorbyl Glucoside, Panthenol, Allantoin, Sodium Hyaluronate.',
    'Close eyes and spray evenly across face from 20cm distance after cleansing or whenever skin feels dry throughout the day.',
    'https://images.unsplash.com/photo-1616683693504-3ea7e9ad6fec?auto=format&fit=crop&w=800&q=80',
    ARRAY[
        'https://images.unsplash.com/photo-1620916566398-39f1143ab7be?auto=format&fit=crop&w=800&q=80',
        'https://images.unsplash.com/photo-1608248597359-26d11b228f41?auto=format&fit=crop&w=800&q=80',
        'https://images.unsplash.com/photo-1556228720-195a672e8a03?auto=format&fit=crop&w=800&q=80',
        'https://images.unsplash.com/photo-1598440947619-2c35fc9aa908?auto=format&fit=crop&w=800&q=80'
    ]::TEXT[],
    FALSE,
    TRUE,
    35,
    4.8,
    79
),
(
    'tiam_p10_b3_niacin_sunscreen',
    'TIA''M B3 Niacin Sunscreen SPF 50+ PA++++ (UV Shield)',
    'টিআই''এম বি৩ নিয়াসিন সানস্ক্রিন এসপিএফ ৫০+ পিএ++++ (সুরক্ষা ও গ্লো)',
    'TIA''M',
    'Sun Care',
    'South Korea',
    '🇰🇷',
    1750.00,
    2050.00,
    1250.00,
    10,
    'TM-B3S-2026-10',
    '2028-11',
    'All Skin Types, No White Cast, Non-Greasy',
    ARRAY['50ml Daily Tube']::TEXT[],
    'Broad-spectrum high protection daily sunscreen infused with Niacinamide and Centella to shield against UVA/UVB rays while brightening dark spots with zero white cast.',
    'এসপিএফ ৫০+ এবং পিএ++++ যুক্ত উচ্চমানের ডেইলি সানস্ক্রিন। নিয়াসিনামাইড ও সেন্টেলা সমৃদ্ধ এই সানস্ক্রিন সূর্যের ক্ষতিকর অতিবেগুনি রশ্মি থেকে সুরক্ষা দেয় কোনো সাদা দাগ ছাড়াই।',
    'Water, Dibutyl Adipate, Niacinamide (2%), Ethylhexyl Triazone, Diethylamino Hydroxybenzoyl Hexyl Benzoate, Centella Asiatica Extract, Tocopherol, Adenosine.',
    'Apply generously as the final step of morning routine 15 minutes before sun exposure. Reapply every 2-3 hours during outdoor activities.',
    'https://images.unsplash.com/photo-1598440947619-2c35fc9aa908?auto=format&fit=crop&w=800&q=80',
    ARRAY[
        'https://images.unsplash.com/photo-1620916566398-39f1143ab7be?auto=format&fit=crop&w=800&q=80',
        'https://images.unsplash.com/photo-1608248597359-26d11b228f41?auto=format&fit=crop&w=800&q=80',
        'https://images.unsplash.com/photo-1556228720-195a672e8a03?auto=format&fit=crop&w=800&q=80',
        'https://images.unsplash.com/photo-1616683693504-3ea7e9ad6fec?auto=format&fit=crop&w=800&q=80'
    ]::TEXT[],
    TRUE,
    TRUE,
    60,
    4.9,
    198
),
(
    'tiam_p11_glow_333_capsule_cream',
    'TIA''M Glow 333 Capsule Cream (NMN + Vitamin C Radiance)',
    'টিআই''এম গ্লো ৩৩৩ ক্যাপসুল ক্রিম (ভিটামিন সি ও এনএমএন সমৃদ্ধ)',
    'TIA''M',
    'Creams & Moisturizers',
    'South Korea',
    '🇰🇷',
    2150.00,
    2550.00,
    1520.00,
    8,
    'TM-G333-2026-11',
    '2028-12',
    'Dull, Uneven Skin & Anti-Oxidant Glow',
    ARRAY['50ml Luxury Jar']::TEXT[],
    'Luxury radiance booster cream containing dual-capsule technology with NMN (Nicotinamide Mononucleotide), pure Vitamin C, and 3% Niacinamide for glass-skin illumination.',
    'এনএমএন এবং খাঁটি ভিটামিন সি ক্যাপসুল প্রযুক্তির বিলাসবহুল ক্রিম যা ত্বককে পুনরুজ্জীবিত করে, ভেতর থেকে প্রাকৃতিক আভা ছড়ায় এবং কোরিয়ান গ্লাস স্কিন লুক এনে দেয়।',
    'Water, Glycerin, Niacinamide (3%), Nicotinamide Mononucleotide (NMN), Ascorbic Acid (Pure Vitamin C Capsules), Butyrospermum Parkii (Shea) Butter, Ceramide NP.',
    'Massage a moderate scoop over face until capsules gently burst and absorb into skin. Ideal for morning and night radiance.',
    'https://images.unsplash.com/photo-1522337360788-8b13dee7a37e?auto=format&fit=crop&w=800&q=80',
    ARRAY[
        'https://images.unsplash.com/photo-1620916566398-39f1143ab7be?auto=format&fit=crop&w=800&q=80',
        'https://images.unsplash.com/photo-1608248597359-26d11b228f41?auto=format&fit=crop&w=800&q=80',
        'https://images.unsplash.com/photo-1556228720-195a672e8a03?auto=format&fit=crop&w=800&q=80',
        'https://images.unsplash.com/photo-1616683693504-3ea7e9ad6fec?auto=format&fit=crop&w=800&q=80'
    ]::TEXT[],
    FALSE,
    TRUE,
    25,
    5.0,
    64
),
(
    'tiam_p12_alpha_5_mela_care_cream',
    'TIA''M Alpha-5 Mela Care Cream (5-Pathway Melasma Defense)',
    'টিআই''এম আলফা-৫ মেলা কেয়ার ক্রিম (মেছতা ও গাঢ় দাগ দূরীকরণ)',
    'TIA''M',
    'Treatments & Creams',
    'South Korea',
    '🇰🇷',
    2250.00,
    2650.00,
    1580.00,
    8,
    'TM-A5M-2026-12',
    '2028-12',
    'Melasma, Stubborn Pigmentation & Sun Spots',
    ARRAY['50ml Treatment Tube']::TEXT[],
    'Specialized dermo-cosmetic cream formulating 5 clinical brightening actives (Alpha-Arbutin, Tranexamic Acid, Niacinamide, Glutathione, and Vitamin C) to suppress deep melanin.',
    'মেছতা এবং দীর্ঘস্থায়ী পিগমেন্টেশন চিকিৎসার জন্য ৫টি শক্তিশালী উপাদানের (আলফা-আরবুটিন, ট্রানেক্সামিক অ্যাসিড, গ্লুটাথিয়ন) বিশেষজ্ঞ ক্রিম।',
    'Water, Alpha-Arbutin, Tranexamic Acid, Niacinamide, Glutathione, Ethyl Ascorbyl Ether, Centella Asiatica Extract, Sodium Hyaluronate, Madecassoside.',
    'Apply across face focusing on areas with melasma, sun spots, or stubborn freckles twice daily after serums.',
    'https://images.unsplash.com/photo-1620916566398-39f1143ab7be?auto=format&fit=crop&w=800&q=80',
    ARRAY[
        'https://images.unsplash.com/photo-1608248597359-26d11b228f41?auto=format&fit=crop&w=800&q=80',
        'https://images.unsplash.com/photo-1556228720-195a672e8a03?auto=format&fit=crop&w=800&q=80',
        'https://images.unsplash.com/photo-1616683693504-3ea7e9ad6fec?auto=format&fit=crop&w=800&q=80',
        'https://images.unsplash.com/photo-1598440947619-2c35fc9aa908?auto=format&fit=crop&w=800&q=80'
    ]::TEXT[],
    TRUE,
    TRUE,
    28,
    4.9,
    142
)
ON CONFLICT (id) DO UPDATE SET
    title = EXCLUDED.title,
    title_bn = EXCLUDED.title_bn,
    brand = EXCLUDED.brand,
    category = EXCLUDED.category,
    price = EXCLUDED.price,
    old_price = EXCLUDED.old_price,
    wholesale_price = EXCLUDED.wholesale_price,
    moq = EXCLUDED.moq,
    img = EXCLUDED.img,
    gallery = EXCLUDED.gallery,
    short_desc = EXCLUDED.short_desc,
    description_bn = EXCLUDED.description_bn,
    ingredients = EXCLUDED.ingredients,
    usage = EXCLUDED.usage,
    stock = EXCLUDED.stock;

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

-- 8.6 System Administrators
INSERT INTO public.admin_users (username, email, password_hash, role)
VALUES
('admin', 'admin@ruposhi.com', 'admin123', 'SuperAdmin'),
('ruposhi', 'ceo@ruposhi.com', 'admin2026', 'Executive')
ON CONFLICT (username) DO NOTHING;

-- ==============================================================================
-- END OF COMPLETE SCHEMA SCRIPT
-- ==============================================================================
