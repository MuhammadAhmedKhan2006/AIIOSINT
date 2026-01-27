// AllOSINT Configuration
// This file contains API endpoints and configuration
// In production, these should be loaded from environment variables

const CONFIG = {
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
