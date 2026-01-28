-- ================================================
-- ADDITIONAL FUNCTION FOR DASHBOARD STATISTICS
-- ================================================
-- Run this in your Supabase SQL Editor AFTER schema.sql
-- This adds a helper function to get dashboard-specific stats
-- ================================================

-- ================================================
-- FUNCTION: Get Dashboard Statistics
-- ================================================
-- Returns real-time stats for dashboard display
-- Example: SELECT * FROM get_dashboard_stats(auth.uid());
-- ================================================

CREATE OR REPLACE FUNCTION public.get_dashboard_stats(p_user_id UUID)
RETURNS TABLE (
    total_scans BIGINT,
    scans_today BIGINT,
    scans_this_week BIGINT,
    vulnerabilities_found BIGINT,
    current_credits INTEGER,
    total_credits_spent BIGINT,
    success_rate NUMERIC(5,2),
    most_used_module TEXT
)
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
    v_credits INTEGER;
BEGIN
    -- Get current credits
    SELECT credits INTO v_credits
    FROM public.users
    WHERE id = p_user_id;
    
    RETURN QUERY
    SELECT
        -- Total scans
        COUNT(*)::BIGINT AS total_scans,
        
        -- Scans today
        COUNT(*) FILTER (WHERE created_at >= CURRENT_DATE)::BIGINT AS scans_today,
        
        -- Scans this week
        COUNT(*) FILTER (WHERE created_at >= date_trunc('week', CURRENT_DATE))::BIGINT AS scans_this_week,
        
        -- Count vulnerabilities from results (searches that found issues)
        COUNT(*) FILTER (
            WHERE 
                status = 'completed' 
                AND (
                    result_summary->>'vulnerabilities' IS NOT NULL
                    OR result_summary->>'risks' IS NOT NULL
                    OR result_summary->>'breaches' IS NOT NULL
                )
        )::BIGINT AS vulnerabilities_found,
        
        -- Current credits
        v_credits AS current_credits,
        
        -- Total credits spent
        COALESCE(SUM(credits_used), 0)::BIGINT AS total_credits_spent,
        
        -- Success rate (completed / total * 100)
        CASE 
            WHEN COUNT(*) > 0 THEN 
                ROUND((COUNT(*) FILTER (WHERE status = 'completed')::NUMERIC / COUNT(*)::NUMERIC) * 100, 2)
            ELSE 0
        END AS success_rate,
        
        -- Most used module
        (
            SELECT module_type
            FROM public.search_history
            WHERE user_id = p_user_id
            GROUP BY module_type
            ORDER BY COUNT(*) DESC
            LIMIT 1
        ) AS most_used_module
        
    FROM public.search_history
    WHERE user_id = p_user_id;
END;
$$;

COMMENT ON FUNCTION public.get_dashboard_stats IS 'Returns comprehensive statistics for dashboard display';

-- Grant execution permission
GRANT EXECUTE ON FUNCTION public.get_dashboard_stats TO authenticated;

-- ================================================
-- VERIFICATION
-- ================================================
-- Test the function (replace with your actual user ID after signup)
-- SELECT * FROM get_dashboard_stats(auth.uid());
-- ================================================
