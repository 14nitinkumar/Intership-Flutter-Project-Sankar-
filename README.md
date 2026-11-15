# VyapaarHub — B2B Wholesale Marketplace

> **"Discover Products. Buy in Bulk. Grow Your Business."**

VyapaarHub is a buyer-focused B2B wholesale product discovery and trade enquiry application built with **Flutter**, **Cubit (`flutter_bloc`)**, and **Dio**. It enables retail business owners to discover catalog items, evaluate tiered wholesale volume discounts, enforce Minimum Order Quantities (MOQ), assemble enquiry carts, and submit wholesale procurement enquiries with offline persistence.

The project architecture strictly follows the **Linkfresh** structural conventions, screen-folder organization, network client patterns, and Equatable-free state management.

---

## 🏗️ Architecture & Project Structure

The project implements a feature-driven, modular architecture following Linkfresh patterns:

- **Screen-Folder Pattern:** Every feature screen inside `lib/view/` contains its dedicated screen, Cubit, and State files.
- **Direct Cubit API Handling:** Network calls are managed directly inside Cubits via `DioNetworkClass` implementing `NetworkResponse` (`onResponse` and `onApiError`).
- **Clean State Management:** Uses plain Dart state classes with `copyWith` methods (100% `Equatable`-free).
- **Centralized Utils:** Network layer, routing, design tokens, preference keys, and shared widgets are unified in `lib/utils/`.

### 📁 Directory Layout

```
lib/
├── main.dart                                       # App entry point, navigator keys, global Cubits, MaterialApp.router
├── data/
│   └── services/
│       └── storage_service.dart                    # SharedPreferences local persistence service
├── utils/
│   ├── app_colors.dart                             # Primary brand color tokens (Navy #172B4D, Teal #16A085, Surface)
│   ├── app_theme.dart                              # Material 3 light theme definition
│   ├── common_widgets/
│   │   ├── app_button.dart                         # Primary (Teal), Secondary (Outline), Destructive button variants
│   │   ├── app_text_field.dart                     # Form input with validation and password toggle
│   │   ├── common_loader.dart                      # Modal progress indicator
│   │   ├── common_toast.dart                       # Floating SnackBar toast helper
│   │   ├── common_widgets.dart                     # Barrel export for common UI components
│   │   ├── empty_state_view.dart                   # Standard empty state placeholder
│   │   ├── error_state_view.dart                   # Error state view with retry action
│   │   └── product_card.dart                       # B2B product card with MOQ badge and wholesale price tier
│   ├── models/
│   │   ├── cart_item_model.dart                    # CartItem with dynamic wholesale tier price calculation
│   │   ├── enquiry_model.dart                      # Enquiry record with items snapshot, status, timestamp
│   │   ├── product_model.dart                      # Product, WholesaleMeta (MOQ, TierPrice discounts, Supplier)
│   │   └── user_model.dart                         # UserSession model for demo authentication
│   ├── network_class/
│   │   ├── api_url_constants.dart                  # Base URL, endpoint paths, and integer request codes
│   │   ├── dio_network_class.dart                  # Reusable Dio client with headers, timeout, loader, & error handling
│   │   └── network_response.dart                   # NetworkResponse interface (onResponse, onApiError)
│   ├── preference_keys/
│   │   └── preference_keys.dart                    # Static SharedPreferences storage keys
│   └── routes/
│       └── routes.dart                             # GoRouter declarative configuration with CupertinoPage builders
└── view/
    ├── auth/
    │   ├── auth_cubit.dart                         # Authentication logic (login, registration, session check)
    │   ├── auth_screen.dart                        # Tabbed Sign In & Register Business interface
    │   └── auth_state.dart                         # Auth state representation with copyWith
    ├── cart/
    │   ├── cart_cubit.dart                         # Enquiry cart management, MOQ validation, and persistence
    │   ├── cart_screen.dart                        # Itemized wholesale enquiry cart with quantity stepper
    │   └── cart_state.dart                         # Cart state with subtotal and unit counts
    ├── dashboard/
    │   ├── dashboard_cubit.dart                    # Bottom navigation active tab management
    │   ├── dashboard_screen.dart                   # Main shell scaffold with NavigationBar (Catalog, Cart, Enquiries, Account)
    │   └── dashboard_state.dart                    # Tab index state
    ├── enquiry/
    │   ├── enquiry_cubit.dart                      # Trade enquiry submission and history tracking
    │   ├── enquiry_screen.dart                     # Submitted procurement requests with status badges
    │   └── enquiry_state.dart                      # Enquiry list state
    ├── product/
    │   ├── product_cubit.dart                      # API product fetching, category filters, search, and sorting
    │   ├── product_screen.dart                     # Wholesale product catalog grid with search bar & category chips
    │   └── product_state.dart                      # Catalog state (products, categories, filters, sort)
    ├── product_detail/
    │   ├── product_detail_cubit.dart               # Quantity selection, volume pricing tier calculation
    │   ├── product_detail_screen.dart              # Product gallery, wholesale tier pricing table, MOQ stepper
    │   └── product_detail_state.dart               # Selected quantity, effective unit price, and subtotal
    └── splash/
        ├── splash_cubit.dart                       # Startup session check and delay logic
        ├── splash_screen.dart                      # Animated brand splash view
        └── splash_state.dart                       # Splash readiness state
```

---

## 🎯 Screen & Feature Breakdown

1. **Splash (`view/splash/`)**:
   - Checks stored session credentials in `SharedPreferences`.
   - Routes automatically to `/dashboard` if logged in, or `/auth` if unauthenticated.

2. **Authentication (`view/auth/`)**:
   - Tabbed view for **Sign In** and **Register Business**.
   - Input validation, quick demo credentials auto-fill, and error messaging.

3. **Dashboard (`view/dashboard/`)**:
   - Persistent bottom `NavigationBar` with live cart item count badge.
   - Hosts 4 tabs: **Catalog**, **Cart**, **Enquiries**, and **Account Profile**.
   - Profile tab displays verified GST buyer badge, business settings, and account sign-out.

4. **Product Catalog (`view/product/`)**:
   - Live keyword search across items and suppliers.
   - Horizontal category chips carousel ("All", "Smartphones", "Laptops", etc.).
   - Sort modal bottom sheet (Featured, Price: Low to High, Price: High to Low, Name: A-Z).
   - Responsive product grid with loading shimmer, error state with retry, and empty state.

5. **Product Detail (`view/product_detail/`)**:
   - Image gallery with page indicator dots.
   - Wholesale volume pricing table with tiered bulk discounts (5%, 12%, and 20% off).
   - MOQ-enforcing quantity stepper with live total price computation.
   - "Add to Enquiry" action with confirmation SnackBar.

6. **Enquiry Cart (`view/cart/`)**:
   - Lists added products with MOQ badges, tier-adjusted unit prices, and subtotals.
   - Real-time quantity adjustments preventing drops below product MOQ.
   - Remarks input for suppliers (e.g., GST billing requirements, delivery deadlines).
   - Estimated total calculation and "Request Quote" submission.

7. **Trade Enquiries (`view/enquiry/`)**:
   - Chronological list of submitted enquiries (`#ENQ-XXXX`).
   - Status indicators ("Submitted / Under Review"), timestamps, and item snapshots.

---

## 🌐 Network Architecture (Dio + Request Codes)

API calls use `DioNetworkClass` matching Linkfresh's network communication pattern:

```dart
// Example: ProductCubit implements NetworkResponse
void loadInitialData() {
  DioNetworkClass.fromNetworkClass(
    networkResponse: this,
    endUrl: getProductsUrl,
    requestCode: getProductsReq,
    jsonBody: {'limit': 20, 'skip': 0},
  ).callRequestServiceHeader(false, "get");
}

@override
void onResponse({required int requestCode, required String response}) {
  // Parse response and emit updated state
}

@override
void onApiError({required int requestCode, required String response}) {
  // Handle API failure
}
```

### Endpoints (DummyJSON REST API)
- **Base URL:** `https://dummyjson.com/`
- **Products:** `GET /products?limit=20&skip=0` (`getProductsReq = 1`)
- **Search:** `GET /products/search?q={query}` (`searchProductsReq = 2`)
- **Categories:** `GET /products/category-list` (`getCategoriesReq = 3`)
- **Category Filter:** `GET /products/category/{slug}` (`getProductsByCategoryReq = 4`)
- **Product Details:** `GET /products/{id}` (`getProductDetailReq = 5`)

---

## 💾 Local Persistence

- **User Session:** Tracks login status, user email, and business name via `SharedPreferences`.
- **Enquiry Cart:** Serializes active cart items as JSON to survive app restarts.
- **Enquiry Records:** Persists submitted trade enquiries locally as serialized JSON.

---

## 🚀 Setup & Run Instructions

### Prerequisites
- Flutter SDK `^3.11.0` or higher
- Dart SDK `^3.11.0`

### 1. Clone Repository
```bash
git clone https://github.com/14nitinkumar/Intership-Flutter-Project-Sankar-.git
cd Intership-Flutter-Project-Sankar-
```

### 2. Install Dependencies
```bash
flutter pub get
```

### 3. Analyze Codebase (Zero Issues)
```bash
flutter analyze
```

### 4. Run Unit & Widget Tests
```bash
flutter test
```

### 5. Launch the Application
```bash
flutter run
```

---

## ⚠️ Notes & Demo Assumptions

- **DummyJSON REST API:** Serves as the public catalog API demonstrating pagination, search, and category filtering.
- **Wholesale Bulk Metadata:** Minimum Order Quantities (MOQ), volume tier pricing brackets, and supplier labels are dynamically and deterministically generated per product ID.
- **Trade Enquiry Workflow:** Enquiries are stored locally on the device to demonstrate the end-to-end B2B buyer procurement flow without requiring a live ERP backend.
