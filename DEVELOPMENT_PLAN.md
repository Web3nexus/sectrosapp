# Sectros Mobile — Development Plan

> WhatsApp-style design · Brand color palette · Strict role-based auth · Full API integration

---

## Design Philosophy (WhatsApp-Inspired)

The app follows WhatsApp's core UX principles adapted for business management:

| WhatsApp Principle | App Adaptation |
|---|---|
| Clean, minimal chrome | No unnecessary UI elements, content-first layout |
| Status dots (online/green) | Role-based status indicators (active/away/off-duty) |
| Chat threads | Order threads, reservation threads, support chats |
| Bubble-based layout | Card bubbles for tables, orders, reservations |
| Bottom nav (tabs) | Floating frosted-glass bottom nav with role-adaptive items |
| Green brand accent | Sectros blue `#2563eb` as primary |
| Typography-first | Poppins font, bold weight hierarchy |
| Instant feel | Skeleton loading, micro-animations, optimistic updates |
| Dark mode native | System-aware dark theme with deep navy `#020617` |

---

## Color Palette (Sectros Brand)

```
Primary:     #2563EB  (blue-600)     — buttons, links, active states
Secondary:   #7C3AED  (violet-600)   — highlights, badges
Accent:      #F59E0B  (amber-500)    — warnings, features
Success:     #10B981  (emerald-500)  — confirmed, active
Destructive: #EF4444  (red-500)      — errors, delete
Surface:     #FFFFFF  (light)        — cards, modals
             #1E293B  (dark/slate-800)
Background:  #F9FAFB  (light)        — scaffold
             #020617  (dark/slate-950)
Text:        #0F172A  (light/slate-900)
             #F8FAFC  (dark/slate-50)
```

---

## Phase 1: Foundation (Current — 70% done)

### ✅ Already Built
- Project setup: Riverpod, GoRouter, Dio, FlutterSecureStorage
- Auth screens: Login, Register, Forgot Password, Splash
- Dashboard: Stats grid + quick action buttons
- Orders: List with kitchen status workflow
- Tables: Grid with status colors
- Reservations: List with status dots
- Profile: User info + settings tiles + logout
- Navigation: Shell route with floating bottom nav
- Theme: Light + dark mode with Poppins font

### 🔧 Needs Refactoring
| Issue | Fix |
|---|---|
| iOS blue `#007AFF` colors | Replace with Sectros brand palette |
| Hardcoded API URL `https://sectros.com/api` | Use API gateway pattern with env config |
| No auto-login | Check token on splash, rehydrate user |
| No auth route guard | Redirect unauthenticated to `/login` |
| Logout doesn't clear secure storage | Call `apiService.logout()` |
| Empty `core/utils/` | Add helpers, constants, error utilities |
| No offline handling | Add connectivity check + retry |
| Kitchen status endpoint ambiguous | Use dedicated status endpoints |

---

## Phase 2: Brand & Design Overhaul (WhatsApp-Style)

### 2.1 Re-theme with Brand Colors
- Replace `#007AFF` → `#2563EB` everywhere
- Replace `#5856D6` → `#7C3AED` (secondary)
- Replace `#FF9500` → `#F59E0B` (accent)
- Replace `#34C759` → `#10B981` (success)
- Replace `#FF3B30` → `#EF4444` (destructive)
- Replace background/surface with brand values

### 2.2 Redesign UI Components (WhatsApp-Fancy)
| Component | Redesign |
|---|---|
| Bottom nav | Frosted glass (`BackdropFilter` blur), brand blue active indicator, role-adaptive items |
| Cards | Rounded `24px`, subtle shadows, border highlight |
| Order list | WhatsApp-chat style: avatar + preview + time + status badge |
| Table grid | Large tappable bubbles with status glow (green/amber/red) |
| Reservation cards | Timeline-style with dot connectors |
| Dashboard stats | Metric bubbles with animated counters |
| Input fields | Rounded `16px`, filled, clean labels |
| Buttons | Pill-shaped, solid primary, ghost secondary |
| Empty states | Lottie animations + brand messaging |
| Pull-to-refresh | Haptic feedback + brand-colored spinner |
| Loading | Skeleton shimmer (WhatsApp-style gray pulse) |

### 2.3 Fancy Additions
- **Staggered list animations** on screen entry (each card fades in with delay)
- **Hero transitions** for detail screens
- **Haptic feedback** on important actions (confirm, error)
- **Swipe actions** on list items (mark done, delete)
- **Contextual status bar** (brand-colored with readable text)
- **Frosted glass modals** for confirmations
- **Animated bottom sheet** for create/edit flows

---

## Phase 3: Features by Role (Strict Auth)

### 3.1 API Layer Overhaul
- Create `.env` config with dev/staging/prod base URLs
- Add token refresh interceptor
- Add auth state provider (auto-rehydrate from secure storage)
- Add route guard (`redirect` in GoRouter based on auth state)
- Add request/response logging interceptor (debug mode)

### 3.2 Feature Map by Role

#### Owner (`role=owner`) — Full Access
| Feature | API Endpoint | Status |
|---|---|---|
| Dashboard insights | `GET /dashboard/stats` | ✅ Built |
| Menu management | `GET/POST/PUT/DELETE /menu/categories`, `/menu/items` | ❌ Missing |
| Staff management | `GET/POST/PUT/DELETE /staff` | ❌ Missing |
| Table management | `GET/POST/PATCH /tables` | ✅ Read-only |
| Order management | `GET/POST/PUT/DELETE /orders` | ✅ List + status |
| Reservation mgmt | `GET/POST/PUT/DELETE /reservations` | ✅ List + status |
| Financial reports | `GET /expenses` | ❌ Missing |
| Inventory tracking | `GET/POST/PUT/DELETE /inventory` | ❌ Missing |
| Billing & plan | `GET /billing/plans`, `/billing/status` | ❌ Missing |
| Automation/AI | `GET/POST /automation/*` | ❌ Missing |
| Website builder | `GET/POST /builder/*` | ❌ Missing |
| Gallery/Content | `GET/POST/PUT/DELETE /gallery`, `/reviews`, `/blog-posts` | ❌ Missing |
| Brand settings | `GET/POST /branding` | ❌ Missing |
| Notifications | `GET /notifications`, `POST /read-all` | ❌ Missing |
| Waitlist | `GET/POST/PUT/DELETE /waitlist` | ❌ Missing |
| Shifts & Attendance | `GET/POST/PUT/DELETE /shifts`, `/attendance` | ❌ Missing |
| Multi-branch | `GET/POST/PUT/DELETE /branches` | ❌ Missing |
| Shift handover | `GET/POST/PUT/DELETE /settlements` | ❌ Missing |
| Integrations | `GET/POST/PUT/DELETE /integrations` | ❌ Missing |

#### Staff (`role=staff`) — Limited by Feature Flags
| Feature | Condition |
|---|---|
| Dashboard (limited) | Always |
| Orders (view + status update) | `feature=orders` |
| Tables (view + status) | `feature=table_management` |
| Menu (view only) | `feature=menu_builder` |
| Waitlist (add/view) | `feature` flag |
| Reservations (view + status) | `feature` flag |
| Profile + 2FA | Always |

#### Super Admin (separate auth) — Future Phase
Manages platform tenants via central API. Separate mobile flow.

### 3.3 Auth Integration Points
| API | Method | When Called |
|---|---|---|
| `POST /login` | AuthController | On login form submit |
| `POST /login/verify-2fa` | AuthController | If 2FA required |
| `POST /auth/register` | AuthController | On registration |
| `POST /forgot-password` | AuthController | Password reset request |
| `POST /reset-password` | AuthController | Password reset execution |
| `GET /user` | Closure (tenant) | On app start (auto-login) |
| `POST /logout` | AuthController | On logout |
| `PATCH /staff/{id}/2fa` | StaffController | Toggle 2FA from settings |

### 3.4 Error Handling Strategy
```
User Action → API Call → Success → Update UI (optimistic)
                       → 401     → Clear token → Redirect to /login
                       → 403     → Show "Access Denied" toast
                       → 422     → Show validation errors inline
                       → 429     → Show "Too many requests" with retry
                       → 500     → Show "Something went wrong" + retry button
                       → No network → Show offline banner + queue
```

---

## Phase 4: Build Order (Priority Sequence)

### Sprint 1 — Auth & Foundation Fixes (Days 1-2)
- [ ] Replace color palette with Sectros brand
- [ ] Add `.env` config with API base URL
- [ ] Implement auto-login (check token → `GET /user` → rehydrate)
- [ ] Add auth route guard (redirect to `/login` if unauthenticated)
- [ ] Fix logout to clear secure storage
- [ ] Add skeleton shimmer loading everywhere
- [ ] Add pull-to-refresh to all list screens
- [ ] Add error handling utility (retry, offline detection)

### Sprint 2 — WhatsApp-Style Redesign (Days 3-5)
- [ ] Redesign bottom nav (frosted glass, brand colors)
- [ ] Redesign order list (chat-style cards with avatars)
- [ ] Redesign table grid (bubble cards with status glow)
- [ ] Redesign reservation list (timeline style)
- [ ] Redesign dashboard (metric bubbles, animated counters)
- [ ] Redesign profile (clean settings, avatar, 2FA toggle)
- [ ] Add staggered list animations
- [ ] Add hero transitions to detail screens
- [ ] Redesign login/register (branded, WhatsApp-clean)
- [ ] Add Lottie empty states

### Sprint 3 — Owner Features (Days 6-10)
- [ ] Menu management (categories + items CRUD)
- [ ] Staff management (list, create, edit, delete, 2FA toggle)
- [ ] Table management (create, edit, delete, status change)
- [ ] Reservation management (create, edit, cancel, confirm)
- [ ] Order detail screen (items, total, status timeline)
- [ ] Expense tracking (list + create)
- [ ] Inventory tracking (list + create + stock adjust)
- [ ] Dashboard comparison (multi-branch stats)

### Sprint 4 — Content & Settings (Days 11-13)
- [ ] Gallery management (upload images, delete)
- [ ] Review management (view, respond)
- [ ] Blog management (create, edit, publish)
- [ ] Brand settings (business name, phone, address, social links)
- [ ] Billing plan view (current plan, upgrade options)
- [ ] Notification center (list, mark read, mark all read)
- [ ] Waitlist management (add, notify, seat, cancel)
- [ ] Shift management (list, create, edit)

### Sprint 5 — Automation & Advanced (Days 14-16)
- [ ] Quick actions: New Order flow
- [ ] Quick actions: Add Reservation flow
- [ ] AI automation screen (activity feed, settings)
- [ ] Social connections (link/unlink Facebook, Instagram)
- [ ] Receipt scanning (AI-powered)
- [ ] Multi-branch switching
- [ ] Shift handover / settlement

### Sprint 6 — Polish & Release (Days 17-18)
- [ ] Dark mode polish (all screens)
- [ ] Accessibility audit
- [ ] Performance optimization (list rebuilding, image caching)
- [ ] Error tracking setup (Sentry)
- [ ] Analytics events
- [ ] iOS/Android build config
- [ ] Beta testing

---

## Architecture Rules

### API Request Pattern
```dart
// Every API call must:
// 1. Handle loading state
// 2. Handle success with data
// 3. Handle error with user-friendly message
// 4. Handle 401 → redirect to login
// 5. Handle 403 → show access denied

Future<void> fetchOrders() async {
  state = state.copyWith(isLoading: true, error: null);
  try {
    final response = await _api.client.get('/orders');
    state = state.copyWith(
      isLoading: false,
      orders: (response.data as List).map((j) => Order.fromJson(j)).toList(),
    );
  } on DioException catch (e) {
    if (e.response?.statusCode == 401) {
      await _api.logout();
      // Router redirect will handle navigation
    } else {
      state = state.copyWith(
        isLoading: false,
        error: _friendlyError(e),
      );
    }
  }
}
```

### State Management Pattern
```dart
@immutable
class OrdersState {
  final bool isLoading;
  final String? error;
  final List<Order> orders;

  const OrdersState({this.isLoading = false, this.error, this.orders = const []});

  OrdersState copyWith({bool? isLoading, String? error, List<Order>? orders}) {
    return OrdersState(
      isLoading: isLoading ?? this.isLoading,
      error: error,
      orders: orders ?? this.orders,
    );
  }
}
```

### Widget Pattern (WhatsApp-Style)
```dart
// Every list item: rounded, clean, status-aware
class OrderChatTile extends StatelessWidget {
  // → Rounded 20px card
  // → Leading: avatar circle with status dot
  // → Title: customer/business name (bold)
  // → Subtitle: preview of order items
  // → Trailing: time + status badge
  // → OnTap: navigate to detail
}
```

---

## API Base URL Strategy

```dart
// lib/core/config/app_config.dart
class AppConfig {
  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'https://sectros.com',
  );

  static const String apiPrefix = '/api';
  static String get apiUrl => '$baseUrl$apiPrefix';
}

// Usage: flutter run --dart-define=API_BASE_URL=https://sectrosweb.test
```

---

## Current File Structure (After Refactor)

```
lib/
├── main.dart
├── app.dart                              # MaterialApp.router (extracted)
├── core/
│   ├── api/
│   │   ├── api_service.dart              # Dio client + interceptors
│   │   └── api_error.dart                # Error handling utilities
│   ├── config/
│   │   └── app_config.dart               # Env vars, constants
│   ├── theme/
│   │   ├── app_colors.dart               # Brand color palette
│   │   └── app_theme.dart                # Light + dark ThemeData
│   └── utils/
│       ├── date_utils.dart               # Time formatting helpers
│       └── validators.dart               # Form validation
├── features/
│   ├── auth/
│   │   ├── data/
│   │   │   └── auth_repository.dart       # API calls for auth
│   │   ├── domain/
│   │   │   └── auth_state.dart            # Auth state model
│   │   └── presentation/
│   │       ├── auth_notifier.dart
│   │       ├── login_screen.dart
│   │       ├── register_screen.dart
│   │       ├── forgot_password_screen.dart
│   │       └── splash_screen.dart
│   ├── dashboard/ (stats + quick actions)
│   ├── orders/ (chat-style order list)
│   ├── reservations/ (timeline-style)
│   ├── tables/ (bubble grid)
│   ├── menu/ (categories + items CRUD)
│   ├── staff/ (list + create + edit)
│   ├── inventory/ (tracking + adjust)
│   ├── expenses/ (list + create)
│   ├── waitlist/ (add + notify + seat)
│   ├── gallery/ (image management)
│   ├── reviews/ (view + respond)
│   ├── blog/ (posts CRUD)
│   ├── billing/ (plans + status)
│   ├── notifications/ (center + settings)
│   ├── automation/ (AI + social)
│   ├── shifts/ (schedule + attendance)
│   ├── branches/ (multi-branch)
│   ├── profile/ (settings + 2FA)
│   └── builder/ (website builder — future)
├── models/
│   ├── user.dart
│   ├── order.dart
│   ├── reservation.dart
│   ├── table_model.dart
│   ├── menu_category.dart
│   ├── menu_item.dart
│   ├── staff_profile.dart
│   ├── inventory_item.dart
│   ├── expense.dart
│   ├── waitlist_entry.dart
│   ├── notification.dart
│   └── shift.dart
└── widgets/
    ├── main_layout.dart                  # Shell route scaffold
    ├── common/
    │   ├── brand_app_bar.dart             # Styled AppBar
    │   ├── brand_button.dart              # Pill-shaped button
    │   ├── brand_input.dart               # Rounded input
    │   ├── brand_card.dart                # WhatsApp-style card
    │   ├── status_badge.dart              # Colored status pill
    │   ├── skeleton_loader.dart           # Shimmer loading
    │   ├── empty_state.dart               # Lottie empty view
    │   ├── error_view.dart                # Error + retry
    │   └── confirm_sheet.dart             # Frosted glass modal
    └── business_type_adapter.dart         # Labels by business type
```
