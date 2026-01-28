/**
 * Supabase Helper Functions for AIIOSINT
 * Contains reusable functions for database operations
 * Note: Assumes supabaseClient is already initialized globally
 */

/**
 * Save search to history and deduct credits
 * @param {string} moduleType - Module type (e.g., 'dns_lookup', 'port_scanner')
 * @param {string} queryInput - The target searched (domain, IP, email, etc.)
 * @param {object} results - The results from the API
 * @param {number} creditsUsed - Number of credits to deduct (default: 1)
 * @returns {Promise<boolean>} - Success status
 */
async function saveSearchHistory(moduleType, queryInput, results, creditsUsed = 1) {
    try {
        // Get current user session
        const { data: { session }, error: sessionError } = await supabaseClient.auth.getSession();
        
        if (sessionError || !session) {
            console.log('No active session - search not saved');
            return false;
        }

        // Check if user has enough credits
        const { data: canSearch, error: creditCheckError } = await supabaseClient
            .rpc('can_perform_search', { 
                p_user_id: session.user.id, 
                p_credits_required: creditsUsed 
            });

        if (creditCheckError) {
            console.error('Error checking credits:', creditCheckError);
            return false;
        }

        if (!canSearch) {
            alert('Insufficient credits! Please contact support to add more credits.');
            return false;
        }

        // Prepare result summary (lightweight version for quick display)
        const resultSummary = {
            count: Array.isArray(results) ? results.length : (results ? 1 : 0),
            timestamp: new Date().toISOString(),
            status: results ? 'success' : 'no_data'
        };

        // Add vulnerability count if applicable
        if (results) {
            if (results.vulnerabilities) resultSummary.vulnerabilities = results.vulnerabilities.length;
            if (results.risks) resultSummary.risks = results.risks.length;
            if (results.breaches) resultSummary.breaches = results.breaches.length;
        }

        // Save to search_history table
        const { data: searchData, error: searchError } = await supabaseClient
            .from('search_history')
            .insert({
                user_id: session.user.id,
                module_type: moduleType,
                query_input: queryInput,
                result_summary: resultSummary,
                full_result: results,
                status: 'completed',
                credits_used: creditsUsed
            })
            .select()
            .single();

        if (searchError) {
            console.error('Error saving search history:', searchError);
            return false;
        }

        // Deduct credits
        const { error: deductError } = await supabaseClient
            .rpc('deduct_credits', {
                p_user_id: session.user.id,
                p_amount: creditsUsed,
                p_module_type: moduleType,
                p_search_id: searchData.id
            });

        if (deductError) {
            console.error('Error deducting credits:', deductError);
            return false;
        }

        console.log(`✅ Search saved: ${moduleType} - ${queryInput}`);
        return true;

    } catch (error) {
        console.error('Error in saveSearchHistory:', error);
        return false;
    }
}

/**
 * Get user's current credit balance
 * @returns {Promise<number>} - Current credits or 0 if error
 */
async function getCurrentCredits() {
    try {
        const { data: { session }, error: sessionError } = await supabaseClient.auth.getSession();
        
        if (sessionError || !session) {
            return 0;
        }

        const { data, error } = await supabaseClient
            .from('users')
            .select('credits')
            .eq('id', session.user.id)
            .single();

        if (error) {
            console.error('Error fetching credits:', error);
            return 0;
        }

        return data?.credits || 0;
    } catch (error) {
        console.error('Error in getCurrentCredits:', error);
        return 0;
    }
}

/**
 * Get dashboard statistics
 * @returns {Promise<object>} - Dashboard stats object
 */
async function getDashboardStats() {
    try {
        const { data: { session }, error: sessionError } = await supabaseClient.auth.getSession();
        
        if (sessionError || !session) {
            return null;
        }

        const { data, error } = await supabaseClient
            .rpc('get_dashboard_stats', { p_user_id: session.user.id });

        if (error) {
            console.error('Error fetching dashboard stats:', error);
            return null;
        }

        return data && data.length > 0 ? data[0] : null;
    } catch (error) {
        console.error('Error in getDashboardStats:', error);
        return null;
    }
}

/**
 * Get user statistics for profile page
 * @returns {Promise<object>} - User stats object
 */
async function getUserStats() {
    try {
        const { data: { session }, error: sessionError } = await supabaseClient.auth.getSession();
        
        if (sessionError || !session) {
            return null;
        }

        const { data, error } = await supabaseClient
            .rpc('get_user_stats', { p_user_id: session.user.id });

        if (error) {
            console.error('Error fetching user stats:', error);
            return null;
        }

        return data && data.length > 0 ? data[0] : null;
    } catch (error) {
        console.error('Error in getUserStats:', error);
        return null;
    }
}

/**
 * Display credits in UI (call this on page load)
 * @param {string} elementId - ID of element to display credits in
 */
async function displayCredits(elementId = 'user-credits') {
    const credits = await getCurrentCredits();
    const element = document.getElementById(elementId);
    if (element) {
        element.textContent = credits.toLocaleString();
    }
    return credits;
}
