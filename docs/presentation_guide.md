# KharchaBook — Presentation & Viva Demonstration Guide
**Subject:** Mobile Application Development (MAD) — BS-IT 6A  
**Institution:** Bahria University Islamabad  
**Project:** KharchaBook — Student Expense Manager  
**Authors:**
* Zain Kashif — Enrollment: `01-135232-107`
* Huraira Minhas — Enrollment: `01-135232-030`

---

## 1. App Introduction & Problem Statement
* **The Student Reality:** Students manage tight monthly allowances (pocket money / hostel budgets) where cash transactions are routinely forgotten.
* **Why existing apps fail students:** Commercial apps are ad-heavy, bloated with complex bank syncing, or require desktop browsers.
* **The Solution:** A lightweight mobile expense manager engineered for sub-10-second fast entry, automatic budget threshold warnings (at 80% and 100%), and glanceable category analytics.

---

## 2. Architecture & Technical Stack
* **Client Framework:** Flutter (Dart 3.x), Material 3 Design
* **Backend:** Supabase Cloud (PostgreSQL with Row Level Security + Auth)
* **Design Philosophy:** Editorial Fintech / Swiss Minimalism — high-contrast typography, 1px crisp borders, zero AI-slop / glassmorphism.
* **Decoupled Architecture:** Clean repository pattern (`ExpenseRepository` & `AuthRepository`) allowing seamless switching between local mock mode and cloud Supabase mode without altering UI screens.

---

## 3. Screen Breakdown (7 Core Screens)
1. **S1 Splash Screen:** Branding monogram, session verification, smooth routing.
2. **S2 Login Screen:** University email and password validation with inline error diagnostics.
3. **S3 Register Screen:** New student registration with password confirmation and automatic profile creation.
4. **S4 Dashboard (Home):** Hero budget card, dynamic budget status meter (Safe / 80% Warning / 100% Exceeded), filter chips, and grouped chronological transaction list.
5. **S5 Add / Edit Transaction:** Numeric keypad with student quick increment chips (+50, +100, +500, +1000), quick presets ('Mess bill', 'Metro fare', 'Photostat'), category selector grid, date picker, and note.
6. **S6 Stats & Analytics:** Month-by-month switcher, `fl_chart` interactive category donut breakdown, income vs expense comparison bar chart.
7. **S7 Profile & Settings:** Student account info, inline monthly budget editor, password change, and logout.

---

## 4. Live Viva Demonstration Script (Step-by-Step)
1. **Launch App:** Show Splash screen transition into Dashboard.
2. **Examine Dashboard:** Highlight the Monthly Budget Hero Card (shows `Rs. 15,000` limit, spent `Rs. 8,310`, remaining `Rs. 6,690`).
3. **Log a Quick Transaction:** Tap the `+` FAB. Enter `Rs. 250` for "Chai & Paratha at Gate 2", category "Food & Dining", tap "Record Transaction". Show that the dashboard ledger and remaining balance update instantly.
4. **Filter & Search:** Tap Search icon -> type "Metro" or select "Transport" -> verify instant filtering.
5. **Show Visual Analytics:** Tap the Analytics tab -> show Donut Chart with interactive slices and top spending categories (Hostel Mess, Metro, Food).
6. **Demonstrate Budget Warning:** Go to Profile -> Edit Monthly Budget to `Rs. 9,000`. Show how the dashboard progress bar instantly shifts into amber `85% Spent` status and triggers local threshold notification.

---

## 5. Challenges Faced & Solutions
1. **Handling Offline & Testing without Network Lag:**  
   *Solution:* Designed an abstract `ExpenseRepository` so the app operates with zero lag in `MockExpenseRepository` mode and connects to `SupabaseExpenseRepository` with a single config flag.
2. **Android 13+ Notification Permissions:**  
   *Solution:* Configured notification channels and runtime permission requests in `NotificationService`.
3. **Chart Responsiveness on Varied Aspect Ratios:**  
   *Solution:* Tuned `fl_chart` radius dynamically inside flexible layout containers.
