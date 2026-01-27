# AIIOSINT Project Report

## 1. Introduction

### What is OSINT?
**Open Source Intelligence (OSINT)** refers to the collection, analysis, and dissemination of information that is publicly available and legally accessible. It involves gathering data from open sources such as social media, public records, websites, and databases to produce actionable intelligence. OSINT is a critical component of modern cybersecurity, threat intelligence, and investigative work.

### Why Do We Need OSINT?
In an increasingly digital world, information is scattered across the internet. OSINT allows us to:
*   **Identify Security Vulnerabilities**: By seeing what information is publicly exposed, organizations can close security gaps before attackers exploit them.
*   **Verify Identities**: Confirming the legitimacy of users, domains, or entities to prevent fraud and phishing.
*   **Investigate Threats**: Tracing the digital footprints of malicious actors or suspicious activities.
*   **Conduct Due Diligence**: Gathering background information for business or legal purposes.

### Purpose of this Project
**AIIOSINT** is a comprehensive, modular web-based OSINT dashboard designed to centralize various reconnaissance tools. It provides a unified interface for gathering intelligence on domains, emails, IP addresses, and user identities using a mix of real-time APIs and passive data sources.

---

## 2. Project Usage

To use this project, simply open the `index.html` or `dashboard.html` file in a modern web browser. 

*   **Dashboard**: The central hub (`dashboard.html`) provides quick access to all available modules.
*   **Navigation**: Each module has a "Dashboard" button to return to the main menu.
*   **Input**: Most tools require a specific target input (e.g., Domain, IP Address, Email, or Username).
*   **Execution**: Click the "Analyze", "Scan", or "Search" button to trigger the intelligence gathering process.
*   **Reports**: Many modules allow you to export the findings as CSV, JSON, or Text reports.

**Note**: This is a client-side application using standard HTML, CSS (Tailwind), and JavaScript. No backend server installation is required, but an active internet connection is necessary to reach the external APIs.

---

## 3. Module Definitions & Mechanics

This project is divided into specialized modules, each targeting a specific type of intelligence gathering:

### 3.1. Breach Search & Auth (`breach-search.html`)
*   **Definition**: A tool to check if an email address has been compromised in known data breaches and to validate the email's deliverability.
*   **Why is it used**: To assess the risk associated with an email identity and verify if it is a real, active account.
*   **How it works**: 
    1.  **Validation**: Uses Regex to check syntax and a local blacklist to flag disposable/burner domains.
    2.  **MX Check**: Queries Cloudflare's DNS over HTTPS (DoH) API to verify if the domain has valid Mail Exchange (MX) records.
    3.  **Breach Check**: Connects to the **XposedOrNot API** (via a CORS proxy) to search for the email in a database of over 10 billion leaked records.

### 3.2. Domain Threat Intel (`domain-threat-intel.html`)
*   **Definition**: An analyzer for domain registration details and heuristic risk assessment.
*   **Why is it used**: To understand the ownership, age, and potential risk level of a domain (e.g., detecting newly created phishing domains).
*   **How it works**:
    1.  **IP Resolution**: Resolves the domain to an IP using Cloudflare DoH.
    2.  **RDAP/Whois**: Fetches registration data (Registrar, Dates, Abuse Contacts) from `rdap.org`.
    3.  **Risk Engine**: Calculates a risk score based on the domain's age (Newer = Higher Risk) and DNSSEC status.

### 3.3. Exif Extractor (`exif-extractor.html`)
*   **Definition**: A forensic tool for extracting metadata (EXIF) from images.
*   **Why is it used**: To uncover hidden details in images, such as the camera model, settings, and most importantly, GPS coordinates.
*   **How it works**:
    1.  **Extraction**: Uses the `ExifReader` library to parse binary image files client-side.
    2.  **Analysis**: Scans for specific tags (GPS, Make, Model) to calculate an "Intelligence Score".
    3.  **Mapping**: If GPS data is found, it plots the exact location on a dark-themed map using `Leaflet.js`.

### 3.4. Phone Lookup (`phone-lookup.html`)
*   **Definition**: A phone number intelligence tool to validate formats and find associated online profiles.
*   **Why is it used**: To gather information on a target using only a phone number.
*   **How it works**:
    1.  **Parsing**: Uses Google's `libphonenumber-js` to validate the number, extract the country code, and determine the line type (Mobile/Fixed).
    2.  **Messaging Links**: Generates direct "Click-to-Chat" links for WhatsApp and Telegram to check for profile pictures or "Last Seen" status.
    3.  **Dorking**: Generates Google Search queries specific to the number to find it in leaks, social media, or classified ads.

### 3.5. Port Scanner (`port-scanner.html`)
*   **Definition**: A passive port scanner and vulnerability mapper.
*   **Why is it used**: To identify open ports and services on a target IP without actively attacking it, effectively "mapping" its attack surface.
*   **How it works**:
    1.  **Passive Scan**: Instead of sending packets directly (which is noisy/illegal), it queries the **InternetDB (Shodan)** API to retrieve cached port data.
    2.  **Vulnerability Mapping**: Correlates open ports with known CVEs (Common Vulnerabilities and Exposures) returned by the database.

### 3.6. Subdomain Recon (`subdomain-recon.html`)
*   **Definition**: A dual-mode (Active/Passive) scanner for discovering subdomains.
*   **Why is it used**: To expand the attack surface by finding hidden or forgotten subdomains (e.g., `dev.target.com`, `admin.target.com`).
*   **How it works**:
    *   **Passive Mode**: Queries **crt.sh** (Certificate Transparency logs) to find subdomains that have had SSL certificates issued. This is undetectable by the target.
    *   **Active Mode**: Takes the passive list and actively resolves each subdomain to an IP address using DNS queries to confirm if they are still live.

### 3.7. Tech Stack Profiler (`tech-stack-profiler.html`)
*   **Definition**: A tool intended to fingerprint the technologies used by a website (e.g., CMS, Web Server, Frameworks).
*   **Why is it used**: To understand the technical architecture of a target, often to identify outdated or vulnerable software components.
*   **How it works**: 
    *   *Note: See "Mock Data" section below.*
    *   The interface simulates the process of analyzing HTTP headers (like `X-Powered-By`) and script tags to identify signatures.

### 3.8. Social Recon (`social-recon.html`)
*   **Definition**: A username enumeration tool to find profiles across multiple social networks.
*   **Why is it used**: To perform identity resolution by finding where else a specific username exists on the web.
*   **How it works**:
    *   It iterates through a list of 25+ platforms (GitHub, Twitter, Instagram, etc.).
    *   **Direct Check**: For supported sites, it uses a CORS proxy to fetch the profile page and checks the HTTP Status Code (200 OK = Found, 404 = Not Found).
    *   **Manual**: For sites with strict bot protection (like Instagram), it provides direct links for manual verification.

### 3.9. IP Geo-Int (`ip-geolocation.html`)
*   **Definition**: A geolocation tracker for IP addresses.
*   **Why is it used**: To determine the physical location, ISP, and ASN of a target server or user.
*   **How it works**:
    1.  **Resolution**: Can accept a Domain (resolves to IP via Cloudflare) or a direct IP.
    2.  **Lookup**: Queries the `ipapi.co` API to retrieve geographic coordinates, city, country, and ISP details.
    3.  **Visualization**: Shows the location on an interactive map.

### 3.10. SSL Intelligence (`ssl-certs.html`)
*   **Definition**: An analyzer for SSL/TLS certificates.
*   **Why is it used**: To map an organization's infrastructure via its certificate history and detect expired or misissued certificates.
*   **How it works**:
    1.  **Log Search**: Queries the **CertSpotter API** to retrieve a history of certificates issued for a domain.
    2.  **Analysis**: Parses the data to show Issuer Organizations, Validity dates, and Subject Alternative Names (SANs) which often reveal other related domains.

### 3.11. DNS Analyzer (`dns-lookup.html`)
*   **Definition**: A comprehensive DNS record enumerator.
*   **Why is it used**: To retrieve the technical "phonebook" records of a domain, essential for understanding mail flow, verification, and hosting.
*   **How it works**:
    *   Performs parallel fetch requests to Cloudflare's DoH API for multiple record types: `A` (IP), `AAAA` (IPv6), `MX` (Mail), `TXT` (Text/Auth), `NS` (Name Servers), and `CNAME` (Aliases).

### 3.12. Dork Generator (`dork-generator.html`)
*   **Definition**: A "Google Dork" query builder.
*   **Why is it used**: To use advanced search engine operators to find sensitive information indexed by Google (e.g., exposed passwords, config files, internal docs).
*   **How it works**:
    *   Takes a domain or username as input.
    *   It populates a database of pre-written advanced search queries (Dorks).
    *   Clicking a dork opens a Google search pre-filled with the query targeting the specific input.

---

## 4. Usage of Mock Data

While most modules in this project utilize real-time APIs (Cloudflare, Shodan, CertSpotter, etc.) to fetch live data, the **Tech Stack Profiler** currently utilizes mock data for demonstration purposes due to browser-side limitations.

### 4.1. Tech Stack Profiler (`tech-stack-profiler.html`)
*   **Limitation**: Accurately fingerprinting a remote server's technology stack (analyzing headers, cookies, and HTML source) directly from a client-side browser is restricted by **CORS (Cross-Origin Resource Sharing)** policies. A browser cannot simply read the raw headers of `google.com` unless `google.com` explicitly allows it.
*   **Implementation**: 
    *   The module contains a `mockDB` array with sample technology signatures (e.g., Nginx, React, Node.js, Docker).
    *   When the "Analyze" button is clicked, the application simulates a scanning loading bar and randomly "detects" technologies from this internal database to demonstrate how the UI and reporting would function in a production environment (which would typically require a backend proxy to bypass CORS).
*   **Location in Code**: `tech-stack-profiler.html` (Script section, `const mockDB = [...]`).

*All other modules perform actual network requests to third-party public APIs to retrieve real-world data.*
