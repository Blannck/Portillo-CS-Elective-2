# Supabase-Flutter Price Filter & Pagination Project

A Flutter application integrating **Supabase** backend with:
- **Price Range Filtering**: Interactive price slider using chained Supabase queries (`.gte('price', min).lte('price', max)`).
- **Pagination**: 6 to 8 max products per page using Supabase range pagination (`.range(from, to)`).
- **State Management**: Handled via `Provider` (`ChangeNotifier`).
- **CRUD Operations**: Building on today's session with Insert, Update (`.update()`), and Delete (`.delete()`) operations.

---

## 🛠 Features

1. **Price Filtering (`RangeSlider`)**:
   - Customers can select a range of prices (e.g., ₱0 - ₱300) with quick filter presets (< ₱50, ₱50 - ₱100, etc.).
   - Employs Supabase's chained range filters:
     ```dart
     query = query.gte('price', minPrice).lte('price', maxPrice);
     ```

2. **Pagination (6-8 items per page)**:
   - Configurable between 6, 7, and 8 items per page via quick selector.
   - Calculates page offsets and queries Supabase using zero-based range pagination:
     ```dart
     final from = (page - 1) * pageSize;
     final to = from + pageSize - 1;
     final response = await query
         .order('price', ascending: true)
         .range(from, to);
     ```
   - Complete page navigation controls with previous/next and dynamic page number chips.

3. **Update & Delete**:
   - Tap the edit icon on any product card to update its name, price, and stock via `.update().eq('id', id)`.
   - Tap the delete icon to remove a product with confirmation via `.delete().eq('id', id)`.
   - Tap the `+` button in the app bar to insert new products.

4. **Search by Substring**:
   - Text search filtering with `.ilike('name', '%query%')`.

---

## 🚀 Supabase Setup

The project is connected to:
- **Project URL**: `https://bbvnzsbshhnyjiclylat.supabase.co`
- **Publishable Key**: `sb_publishable_skNu3pLy46vry9vCWHiJuw_c_8To_eb`

To set up the `products` table and sample products in your Supabase dashboard:
1. Open [Supabase Dashboard](https://bbvnzsbshhnyjiclylat.supabase.co) -> **SQL Editor**.
2. Run the script provided in [`supabase_setup.sql`](file:///d:/Codes/backend_filter_pagination/supabase_setup.sql).
3. Alternatively, you can use the in-app "Seed Mock Products" button (cloud icon in the AppBar) once the table is created.

---

## 🧪 Testing

Run automated tests:
```bash
flutter test
```
All unit tests and widget tests verify:
- Model JSON serialization/deserialization
- Provider state changes, price range filters, and pagination math
- UI rendering of the price slider and pagination bar
