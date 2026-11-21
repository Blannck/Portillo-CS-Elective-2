# 🏓 PicklePro — Pickleball E-Commerce Flutter Application

> **CS Elective 2 — Final Exam Project**  

---

## 📋 Project Overview

**PicklePro** is a role-based Flutter e-commerce application dedicated to pickleball equipment, apparel, footwear, and accessories. The platform enforces strict role separation between **Admins** and **Customers** across both the mobile user interface and the database layer through Row-Level Security (RLS) and stored procedures.

- **Primary Products**: Performance Carbon Paddles, Court Shoes, USAPA Tournament Balls, Tour Backpacks, Ultra-Tacky Grips, and Portable Net Systems.
- **State Management**: Flutter Riverpod (`NotifierProvider`, `AsyncNotifierProvider`, `FutureProvider`, `StreamProvider`).
- **Backend**: Supabase (PostgreSQL with RLS, Auth triggers, Stored Procedures).
- **Authentication**: Email/Password and Google OAuth sign-in.
- **Theme**: Custom pickleball athletic theme (Electric Court Lime `#0FA958`, Deep Court Navy `#0F172A`, and Volt accents).

---

### Promoting a User to Admin
Every new account created via the app starts with the `customer` role. To promote an account to `admin`:
```sql
UPDATE public.profiles
SET role_id = (SELECT id FROM public.roles WHERE role = 'admin')
WHERE email = 'YOUR_EMAIL@HERE.COM';
```

---

## 🚀 Running the App Locally

```bash
# 1. Fetch dependencies
flutter pub get

# 2. Run analysis
dart analyze

# 3. Run unit tests
flutter test

# 4. Launch app (Chrome / Edge / Android / Windows)
flutter run
```
