# 📜 History Page - Development Task

## 🎯 Objective
Create a **Search History** page that displays all past OSINT scans performed by the logged-in user, with filtering, search, and detailed view capabilities.

---

## 🎨 Design Theme & UI Guidelines

### Color Scheme (Match Existing Design)
```css
Primary Color: #21c45d (Green)
Background Dark: #020617
Surface Dark: #0f172a
Text White: #ffffff
Text Gray: #94a3b8
Border: rgba(255, 255, 255, 0.1)
```

### Typography
- **Headings:** `Space Grotesk` (font-display)
- **Code/Mono:** `JetBrains Mono` (font-mono)
- **Body:** `Space Grotesk`

### UI Components Style
- Dark glassmorphism cards with `border-white/10`
- Rounded corners: `rounded-lg`
- Hover effects with `transition-all duration-300`
- Icons: Material Symbols Outlined
- Green accent (`#21c45d`) for primary actions
- Consistent with dashboard.html and profile.html

---

## 📊 Database Structure (Already Set Up)

### Table: `search_history`

| Column | Type | Description |
|--------|------|-------------|
| `id` | UUID | Primary key |
| `user_id` | UUID | Foreign key to users table |
| `module_type` | TEXT | Type of scan (see Module Types below) |
| `query_input` | TEXT | What user searched for (domain, IP, email) |
| `result_summary` | JSONB | Summary of results |
| `full_result` | JSONB | Complete scan results |
| `status` | TEXT | 'completed', 'failed', 'pending' |
| `credits_used` | INTEGER | Credits deducted (usually 1) |
| `created_at` | TIMESTAMP | When scan was performed |

### Module Types
```javascript
const MODULE_TYPES = {
    'dns_lookup': 'DNS Lookup',
    'port_scanner': 'Port Scanner',
    'ip_geolocation': 'IP Geolocation',
    'subdomain_recon': 'Subdomain Recon',
    'domain_threat_intel': 'Domain Threat Intel',
    'ssl_certs': 'SSL Certificates',
    'breach_search': 'Breach Search',
    'social_recon': 'Social Recon',
    'phone_lookup': 'Phone Lookup',
    'tech_profiler': 'Tech Stack Profiler',
    'exif_extractor': 'EXIF Extractor',
    'dork_generator': 'Dork Generator'
};
```

---

## 🔧 Required Scripts (Already Available)

Add these to `<head>`:
```html
<script src="https://cdn.tailwindcss.com"></script>
<script src="https://cdn.jsdelivr.net/npm/@supabase/supabase-js@2"></script>
<script src="config.js"></script>
```

Initialize Supabase:
```javascript
const { createClient } = supabase;
const supabaseClient = createClient(CONFIG.SUPABASE_URL, CONFIG.SUPABASE_ANON_KEY);
```

---

## 💻 Core Functionality

### 1. Fetch User's Search History

```javascript
async function loadSearchHistory() {
    try {
        // Get current user
        const { data: { user }, error: authError } = await supabaseClient.auth.getUser();
        if (authError || !user) {
            window.location.href = 'login.html';
            return;
        }

        // Fetch all search history (RLS automatically filters by user_id)
        const { data: searches, error } = await supabaseClient
            .from('search_history')
            .select('*')
            .order('created_at', { ascending: false })
            .limit(100); // Load latest 100

        if (error) throw error;

        displaySearchHistory(searches);
    } catch (error) {
        console.error('Error loading history:', error);
    }
}
```

### 2. Filter by Module Type

```javascript
async function filterByModule(moduleType) {
    const { data: searches, error } = await supabaseClient
        .from('search_history')
        .select('*')
        .eq('module_type', moduleType)
        .order('created_at', { ascending: false });
    
    displaySearchHistory(searches);
}
```

### 3. Filter by Date Range

```javascript
async function filterByDateRange(startDate, endDate) {
    const { data: searches, error } = await supabaseClient
        .from('search_history')
        .select('*')
        .gte('created_at', startDate)
        .lte('created_at', endDate)
        .order('created_at', { ascending: false });
    
    displaySearchHistory(searches);
}
```

### 4. Search by Query Input

```javascript
async function searchHistory(searchTerm) {
    const { data: searches, error } = await supabaseClient
        .from('search_history')
        .select('*')
        .ilike('query_input', `%${searchTerm}%`)
        .order('created_at', { ascending: false });
    
    displaySearchHistory(searches);
}
```

---

## 🎨 Page Layout Structure

### Navbar (Copy from dashboard.html)
```html
<nav class="border-b border-white/10 bg-background-dark/80 backdrop-blur-md sticky top-0 z-50">
    <div class="max-w-7xl mx-auto px-6 py-4 flex items-center justify-between">
        <a href="dashboard.html" class="text-primary hover:text-white transition-colors">
            ← Back to Dashboard
        </a>
        <h1 class="text-xl font-bold text-white">Search History</h1>
        <button onclick="logout()" class="text-red-400 hover:text-red-300">Logout</button>
    </div>
</nav>
```

### Main Container
```html
<div class="max-w-7xl mx-auto px-6 py-8">
    <!-- Stats Cards Row -->
    <div class="grid grid-cols-1 md:grid-cols-4 gap-6 mb-8">
        <!-- Total Scans Card -->
        <!-- This Week Card -->
        <!-- Most Used Module Card -->
        <!-- Credits Used Card -->
    </div>

    <!-- Filters Section -->
    <div class="bg-surface-dark border border-white/10 rounded-lg p-6 mb-6">
        <!-- Module Filter Dropdown -->
        <!-- Date Range Picker -->
        <!-- Search Input -->
        <!-- Clear Filters Button -->
    </div>

    <!-- History Cards Grid -->
    <div id="history-container" class="grid grid-cols-1 gap-4">
        <!-- History cards will be inserted here -->
    </div>
</div>
```

---

## 📋 History Card Design

Each search result should display as a card:

```html
<div class="bg-surface-dark border border-white/10 rounded-lg p-6 hover:border-primary/30 transition-all">
    <div class="flex items-start justify-between mb-4">
        <div class="flex items-center gap-3">
            <!-- Icon based on module_type -->
            <span class="material-symbols-outlined text-primary text-2xl">search</span>
            <div>
                <h3 class="text-white font-bold">DNS Lookup</h3>
                <p class="text-sm text-slate-400 font-mono">google.com</p>
            </div>
        </div>
        <div class="text-right">
            <p class="text-xs text-slate-500">2 hours ago</p>
            <span class="px-2 py-1 bg-primary/20 text-primary text-xs rounded">Completed</span>
        </div>
    </div>
    
    <div class="border-t border-white/10 pt-4 mt-4">
        <div class="grid grid-cols-2 gap-4 mb-4">
            <div>
                <p class="text-xs text-slate-400">Results Found</p>
                <p class="text-white font-mono">15 records</p>
            </div>
            <div>
                <p class="text-xs text-slate-400">Credits Used</p>
                <p class="text-white font-mono">1</p>
            </div>
        </div>
        
        <div class="flex gap-2">
            <button onclick="viewDetails('scan-id')" 
                class="flex-1 px-4 py-2 bg-primary/20 text-primary border border-primary/30 rounded hover:bg-primary/30 transition-all text-sm">
                View Details
            </button>
            <button onclick="exportResults('scan-id')" 
                class="px-4 py-2 bg-white/10 text-white border border-white/10 rounded hover:bg-white/20 transition-all text-sm">
                Export
            </button>
        </div>
    </div>
</div>
```

---

## 🔍 Module-Specific Icons

```javascript
const MODULE_ICONS = {
    'dns_lookup': 'dns',
    'port_scanner': 'security',
    'ip_geolocation': 'location_on',
    'subdomain_recon': 'account_tree',
    'domain_threat_intel': 'shield',
    'ssl_certs': 'verified_user',
    'breach_search': 'lock_open',
    'social_recon': 'groups',
    'phone_lookup': 'phone',
    'tech_profiler': 'code',
    'exif_extractor': 'image',
    'dork_generator': 'manage_search'
};
```

---

## 🎯 Features to Implement

### 1. **Stats Summary** (Top of page)
- Total scans performed
- Scans this week
- Most used module
- Total credits used

### 2. **Filters**
- Dropdown: Filter by module type
- Date picker: Filter by date range
- Search input: Search by query input
- Clear all filters button

### 3. **History Cards**
- Display each scan as a card
- Show: module type, query, timestamp, status, credits used
- Result summary (e.g., "15 DNS records found")
- "View Details" button
- "Export" button (JSON/CSV)

### 4. **Details Modal**
When user clicks "View Details":
```html
<div class="modal">
    <h3>Scan Details</h3>
    <div>
        <p><strong>Module:</strong> DNS Lookup</p>
        <p><strong>Target:</strong> google.com</p>
        <p><strong>Date:</strong> Jan 28, 2026 at 2:30 PM</p>
        <p><strong>Status:</strong> Completed</p>
    </div>
    
    <h4>Results Summary</h4>
    <pre class="bg-black/40 p-4 rounded">
        {result_summary JSON formatted}
    </pre>
    
    <h4>Full Results</h4>
    <pre class="bg-black/40 p-4 rounded max-h-96 overflow-auto">
        {full_result JSON formatted}
    </pre>
    
    <button onclick="closeModal()">Close</button>
</div>
```

### 5. **Export Functionality**
```javascript
function exportResults(scanId, format = 'json') {
    // Get scan data
    // Convert to JSON or CSV
    // Trigger download
    const blob = new Blob([data], { type: 'application/json' });
    const url = URL.createObjectURL(blob);
    const a = document.createElement('a');
    a.href = url;
    a.download = `scan-${scanId}.${format}`;
    a.click();
}
```

### 6. **Pagination**
- Load 20 results at a time
- "Load More" button at bottom
- Or implement infinite scroll

### 7. **Empty State**
When no history exists:
```html
<div class="text-center py-16">
    <span class="material-symbols-outlined text-slate-600 text-6xl mb-4">history</span>
    <h3 class="text-xl text-slate-400 mb-2">No Search History Yet</h3>
    <p class="text-slate-500 mb-6">Start using OSINT modules to see your history here</p>
    <a href="dashboard.html" class="px-6 py-3 bg-primary text-background-dark font-bold rounded">
        Go to Dashboard
    </a>
</div>
```

---

## 📱 Responsive Design

- Desktop (lg): 4 stats cards in row, 1 history card per row
- Tablet (md): 2 stats cards in row, 1 history card per row
- Mobile (sm): 1 stat card per row, 1 history card per row

---

## ✅ Checklist

- [ ] Create `history.html` file
- [ ] Add Supabase scripts to `<head>`
- [ ] Copy navbar from dashboard.html
- [ ] Create stats summary section
- [ ] Build filters section (module, date, search)
- [ ] Implement `loadSearchHistory()` function
- [ ] Implement `displaySearchHistory()` function
- [ ] Create history card template
- [ ] Add details modal
- [ ] Implement export functionality
- [ ] Add pagination or infinite scroll
- [ ] Add empty state design
- [ ] Test with different module types
- [ ] Test filters and search
- [ ] Ensure mobile responsive
- [ ] Add to dashboard navigation (optional)

---

## 🔗 Add to Dashboard (Optional)

In `dashboard.html`, add a link in the sidebar:

```html
<a href="history.html" class="flex items-center gap-3 px-4 py-3 rounded-lg hover:bg-white/5 transition-all">
    <span class="material-symbols-outlined text-primary">history</span>
    <span>Search History</span>
</a>
```

---

## 🚀 Getting Started

1. Create `history.html` in the root directory
2. Copy the basic structure from `dashboard.html` or `profile.html`
3. Add the required scripts to `<head>`
4. Implement `loadSearchHistory()` on page load
5. Style cards to match existing theme
6. Test with your actual search history data

---

## 💡 Tips

- **No Backend Access Needed:** All data fetching uses Supabase client SDK
- **RLS Security:** Database automatically shows only user's own data
- **Real-time Updates:** Consider adding `.on('INSERT')` to auto-refresh
- **Performance:** Use `.limit()` and pagination for large datasets
- **Error Handling:** Always show user-friendly error messages

---

## 📞 Questions?

- Check `dashboard.html` for design reference
- Check `profile.html` for Supabase query examples
- Database structure is in `database/schema.sql`
- All modules already save to `search_history` table

**Happy coding! 🎨**
