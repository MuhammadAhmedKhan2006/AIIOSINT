// AllOSINT Configuration
// This file contains API endpoints and configuration
// In production, these should be loaded from environment variables

const CONFIG = {
    // Supabase Configuration
    SUPABASE_URL: 'https://bueyuchjtypfctvtpvrp.supabase.co',
    SUPABASE_ANON_KEY: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImJ1ZXl1Y2hqdHlwZmN0dnRwdnJwIiwicm9sZSI6ImFub24iLCJpYXQiOjE3Njk1NjA5NjcsImV4cCI6MjA4NTEzNjk2N30.pI1G7g17J9fd0BVgHpecAQ0I_LI4KFw1Rgnb3FuuMIw',

    // API Endpoints
    CLOUDFLARE_DOH_API: 'https://cloudflare-dns.com/dns-query',
    CERTSPOTTER_API: 'https://api.certspotter.com/v1',
    CRTSH_API: 'https://crt.sh',
    WHOIS_API: 'https://www.whois.com/whois',
    IPAPI_URL: 'https://ipapi.co',
    DNS_LOOKUP_API: 'https://dns.google/resolve',

    // Application Settings
    APP_VERSION: '2.4.0',
    APP_NAME: 'AllOSINT',
    MAX_CREDITS: 5000,
    DEFAULT_CREDITS: 2500,

    // Feature Flags
    ENABLE_BREACH_SEARCH: true,
    ENABLE_PORT_SCANNER: true,
    ENABLE_SUBDOMAIN_RECON: true,

    // Rate Limiting
    MAX_REQUESTS_PER_MINUTE: 60,
    REQUEST_TIMEOUT: 30000, // 30 seconds

    // UI Settings
    CONSOLE_MAX_LINES: 100,
    NOTIFICATION_TIMEOUT: 5000,
};

// Export for use in other files
if (typeof module !== 'undefined' && module.exports) {
    module.exports = CONFIG;
}
