# Cursor Prompt: Forex & Gold Trading Journal App

Copy everything below into Cursor as your project prompt / initial instruction.

---

## Project Overview

Build a **Flutter trading journal app** for a forex and gold (XAUUSD) trader to log trades, track performance, and refine strategies over time. The app is **fully offline** — no backend, no internet dependency, all data stored locally.

## Tech Stack

- **Flutter** (latest stable)
- **State Management:** `flutter_bloc` (Cubit where simple, Bloc where event-driven logic is needed)
- **Local Database:** `hive` + `hive_flutter` (no Isar, no sqflite)
- **Local Auth:** `local_auth` (fingerprint / Face ID)
- **Dependency Injection:** `get_it`
- **Routing:** `go_router`
- **Charts:** `fl_chart` (for equity curve, win/loss breakdown, R-multiple distribution)
- **Other:** `intl` (date/number formatting), `uuid`, `flutter_svg`, `google_fonts` (or a bundled font), `equatable`

## Architecture

Strict **Clean Architecture**, feature-first folder structure:

```
lib/
├── main.dart
├── app.dart
├── core/
│   ├── constants/
│   │   ├── app_strings.dart        // ALL user-facing text lives here
│   │   ├── app_colors.dart
│   │   ├── app_text_styles.dart
│   │   ├── app_dimens.dart         // spacing, radius, icon sizes
│   │   └── app_assets.dart
│   ├── theme/
│   │   └── app_theme.dart          // single dark ThemeData, no hardcoded colors elsewhere
│   ├── di/
│   │   └── injection_container.dart
│   ├── router/
│   │   └── app_router.dart
│   ├── usecases/
│   │   └── usecase.dart            // base UseCase<Type, Params> abstract class
│   ├── error/
│   │   └── failures.dart
│   ├── utils/
│   │   ├── date_formatter.dart
│   │   ├── currency_formatter.dart
│   │   └── validators.dart
│   └── widgets/                    // shared dumb widgets (buttons, cards, empty states)
│
├── features/
│   ├── splash/
│   │   └── presentation/
│   ├── auth/
│   │   ├── domain/ (entities, repository interface, usecases: authenticate, checkBiometricAvailability)
│   │   ├── data/ (local_auth wrapper as datasource, repository impl)
│   │   └── presentation/ (bloc, pages, widgets)
│   ├── dashboard/
│   │   ├── domain/ (entities: PerformanceMetrics, usecases: getMetrics, getEquityCurve)
│   │   ├── data/
│   │   └── presentation/
│   ├── trade/
│   │   ├── domain/ (entity: Trade, usecases: addTrade, updateTrade, deleteTrade, getTrades, getTradeById)
│   │   ├── data/ (Hive TradeModel + TypeAdapter, TradeRepositoryImpl, HiveTradeDatasource)
│   │   └── presentation/ (bloc, add/edit trade page, trade list page, trade detail page)
│   ├── strategy/
│   │   ├── domain/ (entity: Strategy, usecases: addStrategy, updateStrategy, deleteStrategy, getStrategies)
│   │   ├── data/
│   │   └── presentation/
│   └── settings/
│       ├── domain/
│       ├── data/ (SettingsModel in Hive: theme prefs, currency, biometric toggle, default lot size)
│       └── presentation/
│
└── injection_container.dart
```

**Rules:**
- No widget should reference a raw hex color, raw string literal, or magic number for spacing — always pull from `AppColors`, `AppStrings`, `AppDimens`.
- Domain layer has zero Flutter/Hive imports — pure Dart entities and abstract repositories.
- Each feature's Bloc/Cubit only talks to its own usecases, never directly to Hive.

## Data Models (Hive)

### Trade
```
- id (String, uuid)
- instrument (enum: XAUUSD, EURUSD, GBPUSD, USDJPY, GBPJPY, custom string fallback)
- direction (enum: long, short)
- entryPrice (double)
- exitPrice (double?)
- stopLoss (double)
- takeProfit (double?)
- lotSize (double)
- entryDateTime (DateTime)
- exitDateTime (DateTime?)
- outcome (enum: win, loss, breakeven, open)
- pnl (double?)              // in account currency
- pnlPips (double?)
- riskRewardPlanned (double?)  // calculated from SL/TP at entry
- riskRewardActual (double?)   // calculated at close
- strategyId (String?)       // optional FK to Strategy
- notes (String?)
- screenshotPaths (List<String>?)  // local file paths, optional
- tags (List<String>?)       // e.g. "news event", "revenge trade", "A+ setup"
- emotionBefore (enum?: calm, confident, anxious, fomo, revenge, tilted)
- emotionAfter (enum?: satisfied, regretful, neutral, frustrated)
- accountBalanceAtEntry (double?)
```

### Strategy
```
- id (String, uuid)
- name (String)
- description (String)
- createdAt (DateTime)
- isActive (bool)            // allow archiving without deleting history
```

### Settings
```
- isBiometricEnabled (bool)
- baseCurrency (String, default "USD")
- startingBalance (double?)
- defaultRiskPercent (double?)
- themeMode (always dark for v1, but store for future light mode)
```

Register all Hive TypeAdapters in `injection_container.dart` before `runApp`.

## Screens & Features

### 1. Splash Screen
- App logo/name centered on dark background, brief fade-in animation
- Checks: Hive initialized? Biometric enabled in settings? → routes to Auth screen or Dashboard

### 2. Local Auth (Biometric Lock)
- Triggered on app open if enabled in Settings
- Fingerprint / Face ID via `local_auth`
- Fallback: device PIN/pattern if biometrics unavailable
- Toggle to enable/disable from Settings (require auth to disable it)

### 3. Dashboard
Detailed metrics, laid out in scrollable sections with `fl_chart`:
- **Summary cards:** Total P&L, Win Rate %, Total Trades, Average R:R, Profit Factor
- **Equity curve** (line chart of cumulative P&L over time)
- **Win/Loss breakdown** (donut chart)
- **Performance by instrument** (bar chart — XAUUSD vs EURUSD vs GBPUSD etc.)
- **Performance by strategy** (bar chart — which strategy is actually working)
- **Performance by emotion tag** (surfaces revenge-trading/FOMO patterns)
- **Best/Worst trade** highlight cards
- **Filter bar:** date range (7D/30D/90D/All/Custom), instrument, strategy

### 4. Trade Input Screen
- Instrument selector (chips/dropdown: XAUUSD, EURUSD, GBPUSD + custom entry)
- Direction toggle (Long/Short)
- Entry price, SL, TP, lot size fields with numeric keyboard
- Auto-calculated planned R:R shown live as user types SL/TP
- Optional strategy selector (dropdown populated from Strategies list, "None" default)
- Date/time picker for entry (defaults to now)
- For closing a trade: exit price/time, auto-calculated P&L and actual R:R
- Notes field (multiline)
- Tags (multi-select chips, user can add custom tags)
- Emotion before/after (optional icon-based selector)
- Screenshot attachment (optional, pick from gallery, stored as local file path)
- Save as **Draft/Open** or **Closed**

### 5. Strategies Screen (inside Settings)
- List of strategies (name + short description preview)
- Add/Edit strategy: Name field, Description field (multiline)
- Archive instead of hard-delete if strategy is used in past trades (prevents orphaned references)
- Tapping a strategy shows a mini performance summary (win rate, avg R:R using that strategy) — ties back into Dashboard data

### 6. Settings Screen
- Biometric lock toggle
- Base currency selector
- Starting balance / default risk % (used for R:R and position-size suggestions)
- Export data (JSON/CSV export of all trades — useful since it's offline-only, this is the user's backup)
- Import data (restore from exported file)
- Strategies (navigates to Strategies screen)
- Clear all data (with confirmation dialog)
- App version / About

## Suggested Additional Features (with reasoning)

- **Trade calculator widget** on the input screen: auto-suggests lot size based on stop-loss distance, account balance, and risk %. *Reason: prevents the #1 retail trading mistake — inconsistent position sizing — without leaving the app.*
- **Data export/import (JSON/CSV):** *Reason: since this is offline-only with no cloud backup, losing the phone means losing months of journal data. Export is not optional — it's the safety net.*
- **Open trades widget on Dashboard:** quick list of currently open positions with running notes. *Reason: a journal isn't just for closed trades — reviewing open trade thesis is part of discipline.*
- **Tag-based filtering + emotion tagging:** *Reason: most trading journals only show P&L stats. Tying performance to emotional state (revenge trading, FOMO entries) is what actually changes behavior — this is the feature that makes the journal a coaching tool, not just a spreadsheet replacement.*
- **Streak tracker** (consecutive wins/losses): *Reason: helps catch tilt early — a trader who just lost 3 in a row benefits from a visible nudge before entering trade #4.*
- **Weekly/Monthly recap screen:** auto-generated summary card ("This week: 12 trades, 58% win rate, best pair: XAUUSD"). *Reason: passive reflection — most traders never sit down to actually review; surfacing it removes the friction.*
- **Reminder notification (optional, local only):** e.g. "Log yesterday's trades" if no entry was added in 24h. *Reason: journals fail because of inconsistent logging, not lack of desire — a gentle local nudge (no server needed) fixes this.*
- **Screenshot attachment per trade:** *Reason: chart context at entry is often more useful in review than the numbers alone.*

## Visual Design Direction

- **Dark theme only** for v1 — deep charcoal/near-black background (`#0E0F12` or similar), not pure black, to keep depth in cards/shadows
- Accent color: a single strong accent (e.g. electric green for profit, muted red for loss — avoid pure red/green, use slightly desaturated tones for a premium feel)
- Cards with subtle elevation/border rather than harsh shadows
- Rounded corners (12–16px) consistently via `AppDimens`
- Typography: one clean sans-serif (e.g. Inter or Manrope via `google_fonts`), tight hierarchy — large numerals for stats, muted labels
- Micro-interactions: subtle fade/slide transitions between screens (`go_router` custom transitions), haptic feedback on save/delete actions
- Empty states designed properly (e.g. "No trades yet — log your first trade" with an illustration, not just blank space)

## Deliverables Expected From Cursor

1. Full folder structure scaffolded per the architecture above
2. All Hive models + generated adapters (`build_runner`)
3. Centralized `AppStrings`, `AppColors`, `AppTextStyles`, `AppDimens`, `AppTheme`
4. Each feature with domain/data/presentation layers and a working Bloc/Cubit
5. `go_router` setup with route guards (auth check before Dashboard)
6. `get_it` service locator wired in `main.dart`
7. Working end-to-end flow: Splash → Auth → Dashboard → Add Trade → back to Dashboard with updated metrics

Please scaffold this step by step, starting with `core/` (constants, theme, DI, router), then `auth`, then `trade` + `strategy` (since dashboard depends on trade data), then `dashboard`, then `settings`, then `splash` last to tie routing together.
