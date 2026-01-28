# Database Setup Instructions

## ✅ Already Completed
1. ✅ Main schema.sql has been run
2. ✅ Email column migration (add_email_column.sql) has been run
3. ✅ Authentication is working

## 🔄 What to Run Now

### Step 1: Add Dashboard Statistics Function
**File:** `database/dashboard_stats.sql`

**Instructions:**
1. Open Supabase dashboard → SQL Editor
2. Copy the entire contents of `dashboard_stats.sql`
3. Paste and click **Run**
4. You should see: "Success. No rows returned"

**What this does:**
- Adds a function called `get_dashboard_stats()` 
- Returns real-time statistics for the dashboard (total scans, scans today, current credits, etc.)
- Does NOT modify any existing tables or data

---

## 📊 Database Schema Summary

Your database now has:

### Tables (4)
1. **users** - User profiles (codename, country, credits, etc.)
2. **search_history** - Every search performed by users
3. **credit_transactions** - Credit usage/purchase history
4. **saved_reports** - Exported reports

### Functions (7)
1. **handle_new_user()** - Auto-creates profile on signup ✅
2. **deduct_credits()** - Deducts credits when user searches
3. **add_credits()** - Adds credits (for future purchase feature)
4. **get_user_stats()** - Profile page statistics ✅ (already used)
5. **get_recent_searches()** - Recent search history
6. **can_perform_search()** - Check if user has enough credits
7. **get_dashboard_stats()** - Dashboard statistics 🆕 (need to add)

---

## ❓ Common Questions

### Q: Will this break my API calls?
**A: NO!** 

Here's how it works:
```javascript
// Your existing API call (UNCHANGED)
const response = await fetch('https://api.example.com/data');
const results = await response.json();

// Display results to user (UNCHANGED)
displayResults(results);

// NEW: Save to database AFTER everything works
await saveSearchHistory('dns_lookup', targetDomain, results);
```

**What stays the same:**
- All API endpoints remain unchanged
- Your DNS lookups still use Cloudflare DoH
- Port scanner still uses InternetDB
- Breach search still uses XposedOrNot
- etc.

**What we ADD:**
- After the API returns results, we save a copy to Supabase
- Deduct 1 credit from user balance
- This happens AFTER the search completes

### Q: What if the database save fails?
**A:** The user still gets their search results! We'll wrap the save in try-catch so it doesn't break anything.

### Q: Do I need to modify any APIs?
**A:** No! We only add code AFTER the API calls finish.

---

## 🎯 Next Steps (After Running dashboard_stats.sql)

Once you run the dashboard stats function, we'll:

1. **Update dashboard.html** - Replace hardcoded stats with real data
2. **Add search history to each module** - Save searches after API calls complete
3. **Show credits before searches** - Display remaining credits in UI

Let me know when you've run the dashboard_stats.sql file!
