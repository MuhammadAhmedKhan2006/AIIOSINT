-- ================================================
-- AIIOSINT COMPLETE DATABASE SCHEMA
-- ================================================
-- Run this entire file in your Supabase SQL Editor
-- Go to: https://app.supabase.com/project/YOUR_PROJECT/sql
-- ================================================

-- Enable UUID extension (required for generating UUIDs)
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- ================================================
-- TABLE 1: USERS (extends auth.users)
-- ================================================
-- This table stores additional user profile information
-- The id references Supabase auth.users automatically
-- ================================================

CREATE TABLE public.users (
    -- Primary Key (links to auth.users)
    id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
    
    -- User Profile Fields (from signup form)
    codename TEXT NOT NULL,
    country TEXT,
    phone TEXT,
    city TEXT,
    postal_code TEXT,
    reason TEXT,
    avatar_url TEXT,
    
    -- Credits & Account Status
    credits INTEGER DEFAULT 2500,
    security_level INTEGER DEFAULT 1,
    total_scans INTEGER DEFAULT 0,
    
    -- Timestamps
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

COMMENT ON TABLE public.users IS 'Extended user profile information linked to auth.users';
COMMENT ON COLUMN public.users.codename IS 'User chosen alias/nickname';
COMMENT ON COLUMN public.users.credits IS 'Available credits for API usage';
COMMENT ON COLUMN public.users.total_scans IS 'Total number of scans performed';
COMMENT ON COLUMN public.users.security_level IS 'User account tier (1-5)';

-- ================================================
-- TABLE 2: SEARCH HISTORY
-- ================================================
-- Stores every search/scan performed by users
-- ================================================

CREATE TABLE public.search_history (
    -- Primary Key
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    
    -- Foreign Key to users
    user_id UUID REFERENCES public.users(id) ON DELETE CASCADE NOT NULL,
    
    -- Search Details
    module_type TEXT NOT NULL CHECK (module_type IN (
        'dns_lookup',
        'breach_search',
        'subdomain_recon',
        'port_scanner',
        'ip_geolocation',
        'domain_threat_intel',
        'ssl_certs',
        'social_recon',
        'tech_profiler',
        'exif_extractor',
        'phone_lookup',
        'dork_generator'
    )),
    
    query_input TEXT NOT NULL,
    
    -- Results stored as JSON
    result_summary JSONB,  -- Quick stats: { count: 10, status: "success" }
    full_result JSONB,     -- Complete API response
    
    -- Status
    status TEXT DEFAULT 'completed' CHECK (status IN ('completed', 'failed', 'in_progress')),
    
    -- Credits tracking
    credits_used INTEGER DEFAULT 1,
    
    -- Timestamp
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

COMMENT ON TABLE public.search_history IS 'Records of all searches performed by users';
COMMENT ON COLUMN public.search_history.module_type IS 'Which OSINT module was used';
COMMENT ON COLUMN public.search_history.query_input IS 'The target searched (domain, email, IP, username)';
COMMENT ON COLUMN public.search_history.result_summary IS 'Lightweight summary for quick display';
COMMENT ON COLUMN public.search_history.full_result IS 'Complete API response data';

-- ================================================
-- TABLE 3: CREDIT TRANSACTIONS
-- ================================================
-- Tracks all credit additions and deductions
-- ================================================

CREATE TABLE public.credit_transactions (
    -- Primary Key
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    
    -- Foreign Key to users
    user_id UUID REFERENCES public.users(id) ON DELETE CASCADE NOT NULL,
    
    -- Transaction Details
    amount INTEGER NOT NULL,
    transaction_type TEXT NOT NULL CHECK (transaction_type IN ('purchase', 'usage', 'bonus', 'refund')),
    
    -- Optional Reference
    module_type TEXT,
    search_id UUID REFERENCES public.search_history(id) ON DELETE SET NULL,
    
    -- Description
    description TEXT,
    
    -- Timestamp
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

COMMENT ON TABLE public.credit_transactions IS 'Complete audit log of all credit movements';
COMMENT ON COLUMN public.credit_transactions.amount IS 'Positive for additions, negative for usage';
COMMENT ON COLUMN public.credit_transactions.transaction_type IS 'Type of transaction';

-- ================================================
-- TABLE 4: SAVED REPORTS
-- ================================================
-- Stores user-saved export files
-- ================================================

CREATE TABLE public.saved_reports (
    -- Primary Key
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    
    -- Foreign Keys
    user_id UUID REFERENCES public.users(id) ON DELETE CASCADE NOT NULL,
    search_id UUID REFERENCES public.search_history(id) ON DELETE CASCADE,
    
    -- Report Details
    report_name TEXT NOT NULL,
    report_type TEXT NOT NULL CHECK (report_type IN ('csv', 'json', 'txt', 'pdf')),
    report_data JSONB NOT NULL,
    
    -- Metadata
    is_favorite BOOLEAN DEFAULT false,
    
    -- Timestamp
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

COMMENT ON TABLE public.saved_reports IS 'User-saved exported reports';
COMMENT ON COLUMN public.saved_reports.report_type IS 'Format of exported report';
COMMENT ON COLUMN public.saved_reports.is_favorite IS 'User marked as favorite';

-- ================================================
-- INDEXES FOR PERFORMANCE
-- ================================================

-- Search History Indexes
CREATE INDEX idx_search_history_user_id ON public.search_history(user_id);
CREATE INDEX idx_search_history_module ON public.search_history(module_type);
CREATE INDEX idx_search_history_created ON public.search_history(created_at DESC);
CREATE INDEX idx_search_history_status ON public.search_history(status);

-- Credit Transactions Indexes
CREATE INDEX idx_credit_transactions_user ON public.credit_transactions(user_id);
CREATE INDEX idx_credit_transactions_type ON public.credit_transactions(transaction_type);
CREATE INDEX idx_credit_transactions_created ON public.credit_transactions(created_at DESC);

-- Saved Reports Indexes
CREATE INDEX idx_saved_reports_user ON public.saved_reports(user_id);
CREATE INDEX idx_saved_reports_favorite ON public.saved_reports(is_favorite) WHERE is_favorite = true;

-- ================================================
-- ROW LEVEL SECURITY (RLS) POLICIES
-- ================================================
-- These ensure users can only access their own data
-- ================================================

-- Enable RLS on all tables
ALTER TABLE public.users ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.search_history ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.credit_transactions ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.saved_reports ENABLE ROW LEVEL SECURITY;

-- ================================================
-- USERS TABLE POLICIES
-- ================================================

CREATE POLICY "Users can view own profile"
    ON public.users
    FOR SELECT
    USING (auth.uid() = id);

CREATE POLICY "Users can update own profile"
    ON public.users
    FOR UPDATE
    USING (auth.uid() = id);

-- ================================================
-- SEARCH HISTORY POLICIES
-- ================================================

CREATE POLICY "Users can view own search history"
    ON public.search_history
    FOR SELECT
    USING (auth.uid() = user_id);

CREATE POLICY "Users can insert own search history"
    ON public.search_history
    FOR INSERT
    WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update own search history"
    ON public.search_history
    FOR UPDATE
    USING (auth.uid() = user_id);

CREATE POLICY "Users can delete own search history"
    ON public.search_history
    FOR DELETE
    USING (auth.uid() = user_id);

-- ================================================
-- CREDIT TRANSACTIONS POLICIES
-- ================================================

CREATE POLICY "Users can view own transactions"
    ON public.credit_transactions
    FOR SELECT
    USING (auth.uid() = user_id);

CREATE POLICY "Users can insert own transactions"
    ON public.credit_transactions
    FOR INSERT
    WITH CHECK (auth.uid() = user_id);

-- ================================================
-- SAVED REPORTS POLICIES
-- ================================================

CREATE POLICY "Users can view own reports"
    ON public.saved_reports
    FOR SELECT
    USING (auth.uid() = user_id);

CREATE POLICY "Users can insert own reports"
    ON public.saved_reports
    FOR INSERT
    WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update own reports"
    ON public.saved_reports
    FOR UPDATE
    USING (auth.uid() = user_id);

CREATE POLICY "Users can delete own reports"
    ON public.saved_reports
    FOR DELETE
    USING (auth.uid() = user_id);

-- ================================================
-- FUNCTION 1: Auto-create user profile after signup
-- ================================================
-- This runs automatically when a new user signs up
-- It creates a matching profile in public.users table
-- ================================================

CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
BEGIN
    INSERT INTO public.users (
        id,
        codename,
        country,
        phone,
        city,
        postal_code,
        reason,
        created_at
    )
    VALUES (
        NEW.id,
        COALESCE(NEW.raw_user_meta_data->>'codename', 'Agent-' || substring(NEW.id::text, 1, 8)),
        NEW.raw_user_meta_data->>'country',
        NEW.raw_user_meta_data->>'phone',
        NEW.raw_user_meta_data->>'city',
        NEW.raw_user_meta_data->>'postal_code',
        NEW.raw_user_meta_data->>'reason',
        NOW()
    );
    RETURN NEW;
END;
$$;

COMMENT ON FUNCTION public.handle_new_user IS 'Automatically creates user profile when auth.users record is created';

-- Create trigger to auto-run on user signup
DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;
CREATE TRIGGER on_auth_user_created
    AFTER INSERT ON auth.users
    FOR EACH ROW
    EXECUTE FUNCTION public.handle_new_user();

-- ================================================
-- FUNCTION 2: Deduct credits from user account
-- ================================================
-- Call this after each successful search
-- Example: SELECT deduct_credits(auth.uid(), 1, 'dns_lookup', search_id);
-- ================================================

CREATE OR REPLACE FUNCTION public.deduct_credits(
    p_user_id UUID,
    p_amount INTEGER,
    p_module_type TEXT,
    p_search_id UUID DEFAULT NULL
)
RETURNS VOID
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
BEGIN
    -- Update user credits and total scans
    UPDATE public.users
    SET 
        credits = credits - p_amount,
        total_scans = total_scans + 1,
        updated_at = NOW()
    WHERE id = p_user_id;
    
    -- Record the transaction
    INSERT INTO public.credit_transactions (
        user_id,
        amount,
        transaction_type,
        module_type,
        search_id,
        description
    )
    VALUES (
        p_user_id,
        -p_amount,
        'usage',
        p_module_type,
        p_search_id,
        'Credit deducted for ' || p_module_type || ' search'
    );
END;
$$;

COMMENT ON FUNCTION public.deduct_credits IS 'Deducts credits from user and logs transaction';

-- ================================================
-- FUNCTION 3: Add credits to user account
-- ================================================
-- Call this when user purchases credits
-- Example: SELECT add_credits(auth.uid(), 1000, 'Credit purchase');
-- ================================================

CREATE OR REPLACE FUNCTION public.add_credits(
    p_user_id UUID,
    p_amount INTEGER,
    p_description TEXT DEFAULT 'Credit purchase'
)
RETURNS VOID
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
BEGIN
    -- Update user credits
    UPDATE public.users
    SET 
        credits = credits + p_amount,
        updated_at = NOW()
    WHERE id = p_user_id;
    
    -- Record the transaction
    INSERT INTO public.credit_transactions (
        user_id,
        amount,
        transaction_type,
        description
    )
    VALUES (
        p_user_id,
        p_amount,
        'purchase',
        p_description
    );
END;
$$;

COMMENT ON FUNCTION public.add_credits IS 'Adds credits to user account and logs transaction';

-- ================================================
-- FUNCTION 4: Get user statistics
-- ================================================
-- Returns breakdown of searches by module type
-- Example: SELECT * FROM get_user_stats(auth.uid());
-- ================================================

CREATE OR REPLACE FUNCTION public.get_user_stats(p_user_id UUID)
RETURNS TABLE (
    dns_lookups BIGINT,
    subdomain_scans BIGINT,
    breach_searches BIGINT,
    port_scans BIGINT,
    ip_geolocations BIGINT,
    ssl_cert_checks BIGINT,
    social_recons BIGINT,
    phone_lookups BIGINT,
    total_searches BIGINT,
    total_credits_used BIGINT,
    failed_searches BIGINT
)
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
BEGIN
    RETURN QUERY
    SELECT
        COUNT(*) FILTER (WHERE module_type = 'dns_lookup') AS dns_lookups,
        COUNT(*) FILTER (WHERE module_type = 'subdomain_recon') AS subdomain_scans,
        COUNT(*) FILTER (WHERE module_type = 'breach_search') AS breach_searches,
        COUNT(*) FILTER (WHERE module_type = 'port_scanner') AS port_scans,
        COUNT(*) FILTER (WHERE module_type = 'ip_geolocation') AS ip_geolocations,
        COUNT(*) FILTER (WHERE module_type = 'ssl_certs') AS ssl_cert_checks,
        COUNT(*) FILTER (WHERE module_type = 'social_recon') AS social_recons,
        COUNT(*) FILTER (WHERE module_type = 'phone_lookup') AS phone_lookups,
        COUNT(*) AS total_searches,
        COALESCE(SUM(credits_used), 0) AS total_credits_used,
        COUNT(*) FILTER (WHERE status = 'failed') AS failed_searches
    FROM public.search_history
    WHERE user_id = p_user_id;
END;
$$;

COMMENT ON FUNCTION public.get_user_stats IS 'Returns comprehensive user statistics for profile page';

-- ================================================
-- FUNCTION 5: Get recent search history
-- ================================================
-- Returns last N searches for dashboard
-- Example: SELECT * FROM get_recent_searches(auth.uid(), 10);
-- ================================================

CREATE OR REPLACE FUNCTION public.get_recent_searches(
    p_user_id UUID,
    p_limit INTEGER DEFAULT 10
)
RETURNS TABLE (
    id UUID,
    module_type TEXT,
    query_input TEXT,
    status TEXT,
    created_at TIMESTAMP WITH TIME ZONE
)
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
BEGIN
    RETURN QUERY
    SELECT
        sh.id,
        sh.module_type,
        sh.query_input,
        sh.status,
        sh.created_at
    FROM public.search_history sh
    WHERE sh.user_id = p_user_id
    ORDER BY sh.created_at DESC
    LIMIT p_limit;
END;
$$;

COMMENT ON FUNCTION public.get_recent_searches IS 'Returns recent search history for dashboard display';

-- ================================================
-- FUNCTION 6: Check if user has enough credits
-- ================================================
-- Returns TRUE if user can perform search
-- Example: SELECT can_perform_search(auth.uid(), 5);
-- ================================================

CREATE OR REPLACE FUNCTION public.can_perform_search(
    p_user_id UUID,
    p_credits_required INTEGER DEFAULT 1
)
RETURNS BOOLEAN
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
    v_current_credits INTEGER;
BEGIN
    SELECT credits INTO v_current_credits
    FROM public.users
    WHERE id = p_user_id;
    
    RETURN v_current_credits >= p_credits_required;
END;
$$;

COMMENT ON FUNCTION public.can_perform_search IS 'Checks if user has sufficient credits';

-- ================================================
-- INITIAL DATA (Optional)
-- ================================================
-- Uncomment to create a test/demo account
-- ================================================

-- Create a demo user (only works if you have auth.users record with this ID)
-- INSERT INTO public.users (id, codename, country, city, credits)
-- VALUES (
--     'demo-user-uuid-here',
--     'Demo Agent',
--     'United States',
--     'New York',
--     5000
-- );

-- ================================================
-- GRANT PERMISSIONS (Important!)
-- ================================================
-- Allow authenticated users to access their own data
-- ================================================

-- Grant usage on schema
GRANT USAGE ON SCHEMA public TO authenticated;
GRANT USAGE ON SCHEMA public TO anon;

-- Grant table access
GRANT SELECT, INSERT, UPDATE, DELETE ON public.users TO authenticated;
GRANT SELECT, INSERT, UPDATE, DELETE ON public.search_history TO authenticated;
GRANT SELECT, INSERT ON public.credit_transactions TO authenticated;
GRANT SELECT, INSERT, UPDATE, DELETE ON public.saved_reports TO authenticated;

-- Grant function execution
GRANT EXECUTE ON FUNCTION public.deduct_credits TO authenticated;
GRANT EXECUTE ON FUNCTION public.add_credits TO authenticated;
GRANT EXECUTE ON FUNCTION public.get_user_stats TO authenticated;
GRANT EXECUTE ON FUNCTION public.get_recent_searches TO authenticated;
GRANT EXECUTE ON FUNCTION public.can_perform_search TO authenticated;

-- ================================================
-- VERIFICATION QUERIES
-- ================================================
-- Run these to verify your schema was created correctly
-- ================================================

-- Check all tables were created
SELECT table_name
FROM information_schema.tables
WHERE table_schema = 'public'
AND table_name IN ('users', 'search_history', 'credit_transactions', 'saved_reports');

-- Check all functions exist
SELECT routine_name
FROM information_schema.routines
WHERE routine_schema = 'public'
AND routine_type = 'FUNCTION'
AND routine_name IN (
    'handle_new_user',
    'deduct_credits',
    'add_credits',
    'get_user_stats',
    'get_recent_searches',
    'can_perform_search'
);

-- Check RLS is enabled
SELECT tablename, rowsecurity
FROM pg_tables
WHERE schemaname = 'public'
AND tablename IN ('users', 'search_history', 'credit_transactions', 'saved_reports');

-- ================================================
-- SCHEMA CREATION COMPLETE
-- ================================================
-- Next Steps:
-- 1. Copy your Supabase keys to .env file
-- 2. Test signup/login with Supabase Auth
-- 3. Verify user profile is auto-created
-- ================================================
