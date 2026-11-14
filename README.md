# VyapaarHub — B2B Wholesale Marketplace

> **"Discover Products. Buy in Bulk. Grow Your Business."**

VyapaarHub is a buyer-focused B2B wholesale product discovery and trade enquiry application built with **Flutter** and **Cubit (`flutter_bloc`)**. It enables retail business owners to discover catalog items, evaluate tiered wholesale volume discounts, enforce Minimum Order Quantities (MOQ), assemble enquiry carts, and submit wholesale procurement enquiries with offline persistence.

---

## 🏗️ Architecture & Structure

The project implements a clean layered architecture with a strict separation of concerns:

```
Presentation (3 Screen Files & Common Widgets)
      ↓
State Management (Cubits & Immutable States)
      ↓
Repositories (Domain boundary & data aggregation)
      ↓
Data Sources (DummyJSON REST API & SharedPreferences Local Storage)
```

### 📁 Directory Layout

```
lib/
├── main.dart                       # App entrypoint, SharedPreferences bootstrap, MultiBlocProvider
├── core/
│   ├── app_colors.dart             # Primary Navy (#172B4D), Action Teal (#16A085), Material 3 tokens
│   ├── app_theme.dart              # Material 3 ThemeData (14dp card radius, 12dp input radius)
│   ├── app_routes.dart             # GoRouter configuration (/splash, /auth, /dashboard, /listing, /details)
│   └── preference_keys.dart        # SharedPreferences persistence keys
├── data/
│   ├── models/
│   │   ├── product_model.dart      # Product, WholesaleMeta (MOQ, TierPrice discounts, Supplier)
│   │   ├── cart_item_model.dart    # CartItem with dynamic wholesale tier price calculation
│   │   ├── enquiry_model.dart      # Enquiry record with items snapshot, status, timestamp
│   │   └── user_model.dart         # UserSession model for demo authentication
│   ├── services/
│   │   ├── api_service.dart        # DummyJSON REST API client using http
│   │   └── storage_service.dart    # SharedPreferences JSON persistence layer
│   └── repositories/
│       ├── product_repository.dart # Product queries, search, categories, and detail fetching
│       ├── cart_repository.dart    # Cart item loading and serialization
│       ├── enquiry_repository.dart # Enquiry history loading and persistence
│       └── auth_repository.dart    # Demo login/signup and session management
├── logic/
│   ├── auth/                       # AuthCubit & AuthState (AuthAuthenticated, AuthUnauthenticated, etc.)
│   ├── product/                    # ProductCubit & ProductState (ProductLoaded, ProductEmpty, SortOption)
│   ├── cart/                       # CartCubit & CartState (CartState with MOQ enforcement)
│   └── enquiry/                    # EnquiryCubit & EnquiryState (EnquiryLoaded, EnquirySubmitted)
├── common_widgets/
│   ├── app_button.dart             # Primary (Teal), Secondary (Outline), Destructive buttons
│   ├── app_text_field.dart         # Form text input with password toggle & validation styling
│   ├── product_card.dart           # B2B product card with MOQ badge & wholesale starting price
│   ├── empty_state_view.dart       # Empty state graphic, message, and action
│   └── error_state_view.dart       # Error view with Retry callback
└── view/                           # EXACTLY 3 SCREEN FILES
    ├── auth_screen.dart            # SplashScreen & AuthScreen (Sign In / Sign Up toggle)
    ├── dashboard_screen.dart       # DashboardScreen (Home, Enquiry Cart, Enquiry History / Profile)
    └── product_screen.dart         # ProductListingScreen & ProductDetailScreen
```

---

## 🎯 Screen & Feature Breakdown

The entire UI is systematically organized within **exactly 3 screen files**:

1. **`lib/view/auth_screen.dart`**:
   - **`SplashScreen`**: Checks persisted user session in `SharedPreferences` and routes to `/dashboard` or `/auth`. Displays the VyapaarHub branding and loading indicator.
   - **`AuthScreen`**: Tabbed authentication supporting both **Sign In** and **Create Account**. Features validated email/password inputs, demo credentials auto-fill shortcut (`buyer@vyapaarhub.com`), and loading feedback.

2. **`lib/view/dashboard_screen.dart`**:
   - **`DashboardScreen`**: Shell view hosting the persistent Bottom Navigation Bar with 3 tabs:
     - **Home Tab**: Greeting, search bar, promotional wholesale banner, horizontal category chips carousel, and featured wholesale products feed.
     - **Enquiry Cart Tab**: Itemized enquiry list with thumbnail, title, volume tier pricing, quantity increment/decrement controls (enforcing MOQ), item deletion with confirmation dialog, buyer note input, estimated wholesale summary, and "Submit Bulk Enquiry" action.
     - **Enquiries & Profile Tab**: Profile card with verified buyer status, locally saved enquiry records (`#ENQ-XXXX`) with status badges ("Submitted / Under Review"), expandable item breakdown, and a sign-out button that clears the session while preserving submitted enquiry history.

3. **`lib/view/product_screen.dart`**:
   - **`ProductListingScreen`**: Search field with live search, horizontal category filter chips ("All", "Smartphones", "Laptops", etc.), sort options (Featured, Price: Low to High, Price: High to Low, Name: A-Z), loading shimmer, error state with Retry, and empty state.
   - **`ProductDetailScreen`**: Hero image display, title, category, stock availability, wholesale MOQ banner, **Wholesale Bulk Pricing Tiers Table** (showing 5%, 12%, and 20% discounts for higher order volumes), interactive quantity selector enforcing `>= MOQ`, live subtotal calculation, and "Add to Enquiry" button with SnackBar feedback.

---

## 🔌 API Endpoints (DummyJSON REST API)

- **Products Feed:** `GET https://dummyjson.com/products?limit=20&skip=0`
- **Keyword Search:** `GET https://dummyjson.com/products/search?q={query}`
- **Categories:** `GET https://dummyjson.com/products/category-list`
- **Category Filter:** `GET https://dummyjson.com/products/category/{slug}`
- **Product Details:** `GET https://dummyjson.com/products/{id}`

---

## 💾 Local Persistence

- **Session Management:** Stores session flag, user email, and display name in `SharedPreferences`.
- **Enquiry Cart:** Serializes active cart items as JSON in `SharedPreferences` so cart items survive app restarts.
- **Enquiry History:** Persists all submitted enquiries locally as serialized JSON records.

---

## 🚀 Setup & Run Instructions

```bash
# 1. Clone repository
git clone https://github.com/Abhishek-142004/Intership-Flutter-Project-Sankar-.git
cd Intership-Flutter-Project-Sankar-

# 2. Get dependencies
flutter pub get

# 3. Analyze codebase (Zero warnings)
flutter analyze

# 4. Run tests
flutter test

# 5. Launch app on connected device or emulator
flutter run
```

### Build Release APK:
```bash
flutter build apk --release
```

---

## ⚠️ Demo Honesty & Limitations

- **DummyJSON API:** Used as a sample public REST API for demonstrating dynamic catalog fetching, search, and category filtering.
- **Wholesale Metadata:** Minimum Order Quantities (MOQ), volume tier pricing, and supplier labels are local demonstration metadata deterministically generated per product ID.
- **Enquiry Submission:** Enquiries are stored locally on the device using `SharedPreferences`; they demonstrate the buyer workflow without connecting to real ERP/supplier ordering systems.
- **Authentication:** Demo authentication flow designed for assignment evaluation.
