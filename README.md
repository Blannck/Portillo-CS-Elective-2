# 🏓 PicklePro — Pickleball E-Commerce Flutter Application

> **CS Elective 2 — Final Exam Project**  
> Built with Flutter 3.47+, Riverpod state management, and Supabase backend (PostgreSQL, Auth, Storage, Row-Level Security, and Triggers).

---

## 📋 Project Overview

**PicklePro** is a role-based Flutter e-commerce application dedicated to pickleball equipment, apparel, footwear, and accessories. The platform enforces strict role separation between **Admins** and **Customers** across both the mobile user interface and the database layer through Row-Level Security (RLS) and stored procedures.

- **Primary Products**: Performance Carbon Paddles, Court Shoes, USAPA Tournament Balls, Tour Backpacks, Ultra-Tacky Grips, and Portable Net Systems.
- **State Management**: Flutter Riverpod (`NotifierProvider`, `AsyncNotifierProvider`, `FutureProvider`, `StreamProvider`).
- **Backend**: Supabase (PostgreSQL with RLS, Auth triggers, Stored Procedures).
- **Authentication**: Email/Password and Google OAuth sign-in.
- **Theme**: Custom pickleball athletic theme (Electric Court Lime `#0FA958`, Deep Court Navy `#0F172A`, and Volt accents).

---

## 👥 Roles & Authorization Matrix

| Capability | Signed Out | Customer | Admin |
| :--- | :---: | :---: | :---: |
| Sign up & Log in (Email & Google) | ✅ Yes | N/A | N/A |
| View Products & Categories | ❌ No | ✅ Yes | ✅ Yes |
| Search, Filter (Category & Price Slider) | ❌ No | ✅ Yes | ✅ Yes |
| Add a Product to Catalog | ❌ No | ❌ No | ✅ Yes (FAB) |
| Edit Product Details | ❌ No | ❌ No | ✅ Yes (Card & Detail) |
| Delete a Product | ❌ No | ❌ No | ✅ Yes (Named Confirmation) |
| Manage Categories | ❌ No | ❌ No | ✅ Yes |
| Add Items to Cart | ❌ No | ✅ Yes | ❌ No |
| Place Order / Checkout | ❌ No | ✅ Yes | ❌ No |
| View Own Past Orders | ❌ No | ✅ Yes | ❌ No |
| View All Customer Orders | ❌ No | ❌ No | ✅ Yes |
| Update Order Status | ❌ No | ❌ No | ✅ Yes |

---

## 🏛 Clean Architecture & Layered Structure

The project strictly abides by architectural separation:
1. **Screens / UI Layer** (`lib/pages/`, `lib/widgets/`): Consume Riverpod providers; handle loading, data, error, and empty states. Free of raw HTTP/Supabase calls.
2. **State Management Layer** (`lib/providers/`): Manages reactive state (`AsyncNotifier`, `Notifier`). Bridges screens to services.
3. **Services / Data Access Layer** (`lib/services/`): The **only** layer with direct access to `SupabaseClient`.
4. **Domain Models** (`lib/models/`): Immutable Dart models with `fromJson`, `toJson`, and `copyWith`.

### Directory Layout
```
lib/
├── constants/
│   └── app_colors.dart            # Pickleball theme palette
├── theme/
│   └── app_theme.dart             # Material 3 Light and Dark themes
├── models/
│   ├── category.dart              # Product category model
│   ├── product.dart               # Product catalog model
│   ├── product_filter.dart        # Search, category, price range, sort
│   ├── cart_item.dart             # In-memory customer cart item
│   ├── order.dart                 # Order record with items snapshot
│   ├── order_item.dart            # Itemized line item with unit price paid
│   └── user_profile.dart          # Profile joined with roles
├── services/
│   ├── auth_gate.dart             # Session routing gate (Login vs Products)
│   ├── auth_service.dart          # Supabase Auth & Google OAuth
│   ├── product_service.dart       # Chained search, category, and price queries
│   ├── category_service.dart      # Category CRUD
│   ├── order_service.dart         # Atomic checkout and order history
│   └── profile_service.dart       # User profile and role checks
├── providers/
│   ├── supabase_provider.dart     # SupabaseClient provider
│   ├── auth_providers.dart        # AuthState, user profile, isAdminProvider
│   ├── category_provider.dart     # Async categories provider
│   ├── product_filter_provider.dart # Search query, category, price range
│   ├── product_provider.dart      # Catalog notifier (handles CRUD)
│   ├── cart_provider.dart         # Cart state (persists across screens)
│   ├── order_provider.dart        # Customer orders, admin orders & checkout
│   └── theme_provider.dart        # Theme mode toggle
├── widgets/
│   ├── product_card.dart          # Role-adaptive product card
│   ├── filter_bar.dart            # Search with debounce & category chips
│   ├── price_range_sheet.dart     # Interactive RangeSlider & sort modal
│   ├── cart_icon_badge.dart       # Real-time cart badge
│   ├── order_card.dart            # Customer & admin order tile
│   └── role_badge.dart            # Role indicator pill
├── pages/
│   ├── auth/
│   │   ├── login_page.dart        # Email/password & Google sign-in
│   │   └── signup_page.dart       # Registration (populates profiles trigger)
│   ├── admin/
│   │   ├── add_edit_product_page.dart # Product form with presets & validation
│   │   ├── admin_order_list_page.dart # View all orders & update status
│   │   └── category_management_page.dart # Add, edit, delete categories
│   ├── customer/
│   │   ├── cart_page.dart         # Cart with quantity limits & total
│   │   ├── checkout_confirmation_page.dart # Post-checkout receipt
│   │   └── order_history_page.dart # Customer order history
│   ├── product_detail_page.dart   # Full specs, photo & add to cart
│   └── products_page.dart         # Main catalog screen
└── main.dart                      # App entrypoint with dotenv and Supabase init
```

---

## 🔒 Security & Checkout Integrity: Why Hiding a Button is NOT Security

In modern web and mobile applications, simply hiding an "Add Product", "Delete", or "Checkout" button in the client UI offers **zero actual security**. A malicious actor can easily intercept network traffic or craft raw HTTP requests directly to the Supabase REST endpoint.

**PicklePro enforces true database security through three layers:**

1. **Row-Level Security (RLS) on Every Table**:
   - `products` & `categories`: Only users where `public.is_admin() = true` can execute `INSERT`, `UPDATE`, or `DELETE`. Regular customers can only `SELECT`.
   - `profiles`: Customers can only read and update their own record, and RLS prevents modifying `role_id`.
   - `orders` & `order_items`: Customers can only read rows where `user_id = auth.uid()`. Admins can read all orders and update statuses.
2. **Database-Enforced Checkout Integrity (`create_order` RPC)**:
   - Client applications **never** send order totals or authoritative unit prices.
   - The `create_order` PostgreSQL function runs as an atomic transaction (`SECURITY DEFINER`):
     - Acquires row-level locks (`SELECT ... FOR UPDATE`) on the ordered products.
     - Verifies current real-time stock in the database.
     - Calculates the authoritative total using prices stored in the database.
     - Atomically decrements the stock by the ordered quantity.
     - Writes the `orders` header and writes line snapshots into `order_items`.
     - If any item has insufficient stock or is invalid, the entire transaction rolls back cleanly with a clear exception.
3. **Cart Stock Safety**:
   - Customer UI checks available stock and prevents selecting quantities above remaining inventory. Out-of-stock items are disabled.

---

## 🗄️ Database Setup Instructions (Supabase)

1. Open your [Supabase Dashboard](https://supabase.com/dashboard) and select your project.
2. Navigate to **SQL Editor** on the left menu.
3. Open [`supabase_setup.sql`](file:///d:/Codes/final_exam/supabase_setup.sql) from this repository, copy its full contents, paste into the SQL editor, and click **Run**.
4. The script will automatically:
   - Create tables: `roles`, `profiles`, `categories`, `products`, `orders`, `order_items`.
   - Create functions: `handle_new_user()`, `is_admin()`, and `create_order(items JSONB)`.
   - Attach trigger: `on_auth_user_created` on `auth.users`.
   - Configure all Row-Level Security policies.
   - Populate categories and realistic pickleball seed products.

### Promoting a User to Admin
Every new account created via the app starts with the `customer` role. To promote an account to `admin`:
```sql
UPDATE public.profiles
SET role_id = (SELECT id FROM public.roles WHERE role = 'admin')
WHERE email = 'YOUR_EMAIL@HERE.COM';
```

---

## 📸 Required Submission Screenshots Guide

As required by the exam rubric, take the following 4 screenshots from your Supabase Dashboard:

1. **Database Schema**:
   - Go to **Database** -> **Schema Visualizer** (or **Tables**).
   - Capture the diagram showing the 6 related tables (`roles`, `profiles`, `categories`, `products`, `orders`, `order_items`).
2. **Database Functions and Triggers**:
   - Go to **Database** -> **Functions** (shows `handle_new_user`, `is_admin`, `create_order`).
   - Go to **Database** -> **Triggers** (shows `on_auth_user_created` on `auth.users`).
3. **Users Table**:
   - Go to **Authentication** -> **Users** (shows registered accounts).
   - Go to **Table Editor** -> **profiles** (shows corresponding profiles, names, and assigned `role_id`).
4. **Row-Level Security (RLS) Policies**:
   - Go to **Authentication** -> **Policies** (or **Database** -> **Tables** -> **RLS**).
   - Capture the active policies on `profiles`, `categories`, `products`, `orders`, and `order_items`.

Save these images into a Google Drive folder and set access to **"Anyone with the link can view"**.

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
