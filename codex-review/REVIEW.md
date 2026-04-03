# Codex Review — 2026-04-03

## Documentation

- **Concept:** Shift Worker Sleep is a schedule-driven sleep planning app for adults with irregular work schedules (nurses, EMTs, warehouse workers, firefighters, retail staff). Users enter upcoming shifts; the app calculates optimal sleep windows, recommends wake times, suggests naps, and provides wind-down tools (dark room mode, white/brown/pink noise). Priced at $4.99 one-time purchase with zero backend, zero ads, zero subscriptions.
- **Spec completeness:** The `docs/` directory contains 8 documents (SPEC.md, REQUIREMENTS.md, ARCHITECTURE.md, NON-FUNCTIONAL-REQUIREMENTS.md, UI-UX-SPEC.md, TEST-PLAN.md, TEST-CASES.md, MARKETING.md) plus Stitch design assets. Requirements are enumerated with IDs (FR-001 through FR-043, NFR-101 through NFR-503). The spec is thorough on product positioning, personas, and feature scope.
- **Stack mismatch:** SPEC.md and ARCHITECTURE.md both specify "React Native with Expo, SQLite local storage" and reference Zustand, React Navigation, expo-sqlite, and Expo AV. The actual codebase is a **Flutter/Dart** app using `sqflite`, `provider`, `audioplayers`, and `flutter_local_notifications`. The architecture doc's system context diagram, component model, and tech choices do not match the implementation. This needs to be reconciled — either the docs are stale from an earlier plan or the implementation deviated without updating specs.
- **Marketing:** `docs/MARKETING.md` is minimal (20 lines). It identifies the Tier-2 niche targeting strategy, ad platforms (Facebook/LinkedIn with exact job-title targeting), and the core hook. It does not include budgets, CPI/LTV targets, creative test plans, retention benchmarks, or a UA scaling framework. For a $4.99 paid app where every install must be profitable, this gap makes paid acquisition hard to execute or measure.

## Code & Monetization

- **Code root:** `shiftrest_app/` is a Flutter project (Dart SDK ^3.11.3, version 1.0.1+1). The codebase follows a clean architecture layout: `domain/models/`, `domain/services/`, `domain/repositories/`, `data/database/`, `data/repositories/`, `presentation/screens/`, `presentation/providers/`, `presentation/widgets/`, and `services/`.
- **Domain models:** `Shift`, `SleepPlan`, `SleepBlock`, `NoisePreset`, `WindDownRoutine` — all with serialization (toMap/fromMap).
- **Domain services:** `SleepCalculator` (12.8 KB, the core math engine handling single-block, core-with-nap, split-sleep, and off-day strategies with cumulative sleep debt tracking), `CircadianModel` (alertness curves, phase descriptions, optimal nap timing), `AlarmService` (smart wake time aligned to 90-minute sleep cycles), `NoiseService` (audio playback).
- **Screens implemented (8):** Schedule, Sleep Plan, Dark Room, History, Circadian, Nap, Wind Down, Settings.
- **Widgets (7):** Circadian clock, Gantt timeline, nap timer, noise player, shift calendar, shift entry dialog, sleep block widget.
- **State management:** Provider with 4 providers (ShiftProvider, SleepPlanProvider, DarkRoomProvider, SettingsProvider).
- **Database:** `sqflite` with `app_database.dart` and two repository implementations (SQLiteShiftRepository, SQLiteSleepRepository).
- **Health integration:** `services/health_service.dart` wraps the `health` package for optional HealthKit/HealthConnect sleep session read/write (FR-035).

### IAP service contradicts the spec

- `services/iap_service.dart` implements a full in-app purchase flow for a "shiftrest_pro" non-consumable product using the `in_app_purchase` Flutter package (^3.2.0) and `SharedPreferences` for persisting unlock state. It includes purchase, restore, and stream-based status handling.
- **This directly violates the product specification.** NFR-502 states: "No In-App Purchases, subscriptions, or RevenueCat integrations shall exist in the codebase." NFR-501 defines the app as a "Paid App ($4.99) in the App Store/Play Store" — meaning the full app is unlocked at purchase, with no IAP tier.
- The IAP service also lacks backend receipt validation, making it vulnerable to jailbreak/sideload bypasses, but this is moot if the spec's paid-upfront model is followed. The `in_app_purchase` dependency should be removed from `pubspec.yaml` and the service deleted, unless the monetization model has intentionally changed (in which case SPEC.md, REQUIREMENTS.md, and NON-FUNCTIONAL-REQUIREMENTS.md all need updating).

## Stability & Revenue Risks

1. **Architecture docs are wrong.** The React Native/Expo/Zustand/expo-sqlite architecture described in ARCHITECTURE.md does not match the Flutter/sqflite/Provider codebase. Any developer onboarding from the docs will be confused immediately. Risk: wasted time, incorrect technical decisions.
2. **IAP violates the spec.** If the app ships with IAP gating features behind a "Pro" unlock while also being listed as a $4.99 paid app, users will feel double-charged. If the intent has shifted to freemium-with-IAP, three core docs need rewriting and the $4.99 paid-upfront positioning in MARKETING.md and SPEC.md becomes misleading.
3. **No receipt validation.** If the IAP service stays, purchase state relies solely on SharedPreferences — trivially bypassable and invisible to analytics. Chargebacks and refunds will not be detected.
4. **Marketing lacks execution detail.** MARKETING.md identifies the right niche targeting approach but provides no budgets, CPI/LTV thresholds, creative variants, or retention funnel metrics. For a one-time-purchase app, unit economics must be precise — a $4.99 app cannot absorb loose UA spending.
5. **Test coverage is partial but solid where it exists.** Four test files cover the sleep calculator (13 tests across single-block, core-with-nap, split-sleep, off-day, schedule-wide, overlap detection, and gap calculation), alarm service (4 tests for smart wake cycle alignment), circadian model (8 tests for alertness curves, nap timing, sleep quality, and phase descriptions), and model serialization (12 tests for Shift, SleepBlock, and SleepPlan roundtrips). No widget tests or integration tests exist yet. The TEST-PLAN.md calls for E2E tests and manual QA (alarm resilience after force-close, Dark Room light bleed, white noise looping) that are not yet automated.
6. **Audio assets assumed but unverified.** `pubspec.yaml` references `assets/sounds/white_noise.mp3`, `brown_noise.mp3`, and `pink_noise.mp3`. Their presence and looping quality have not been verified in this review.

## Next Steps

1. **Resolve the monetization contradiction.** Decide whether the app is paid-upfront ($4.99, no IAP — as specified) or freemium-with-IAP (as coded). If paid-upfront: remove `iap_service.dart`, drop the `in_app_purchase` and `shared_preferences` (if only used for IAP) dependencies, and keep the spec as-is. If freemium: rewrite SPEC.md sections 12.1-12.7, REQUIREMENTS.md NFR-501/502, and NON-FUNCTIONAL-REQUIREMENTS.md NFR-500 block to reflect the new model.
2. **Update ARCHITECTURE.md to reflect the actual Flutter stack.** Replace all references to React Native, Expo, Zustand, expo-sqlite, Expo Notifications, Expo AV, and React Navigation with the actual dependencies: Flutter, sqflite, Provider, flutter_local_notifications, audioplayers, and the health package. Update the system context diagram and component model accordingly.
3. **Expand MARKETING.md.** Add CPI/LTV targets per geo, budget allocation across Facebook and LinkedIn, creative test hypotheses (e.g., nurse persona vs. warehouse persona), retention benchmarks (Day-1, Day-7, Day-30), and a break-even model for the $4.99 price point.
4. **Add widget and integration tests.** The domain-layer unit tests are a good start. Next priority: widget tests for the 8 screens (especially the shift entry dialog and sleep plan acceptance flow), and integration tests covering the SQLite repositories and the full shift-to-alarm pipeline.
5. **Verify audio assets.** Confirm the three noise files exist under `assets/sounds/`, loop without audible pops, and meet the battery efficiency target (NFR-203: < 3% per 8 hours of playback).
