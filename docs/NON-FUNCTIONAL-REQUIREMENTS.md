# Shift Worker Sleep Non-Functional Requirements

**Document:** NON-FUNCTIONAL-REQUIREMENTS.md  
**Product:** Shift Worker Sleep  
**Publisher:** Heldig Lab  
**Source of Truth:** [SPEC.md](./SPEC.md)  
**Related Documents:** [ARCHITECTURE.md](./ARCHITECTURE.md), [REQUIREMENTS.md](./REQUIREMENTS.md)

## Purpose

This document defines the quality attributes, constraints, and operational standards for the Shift Worker Sleep app. It strictly enforces the "One Price Forever" and "Zero Backend" principles while recognizing that users interact with this app while exhausted.

---

## 1. Privacy & Security (NFR-100)

| ID | Requirement | Metric / Standard |
|---|---|---|
| NFR-101 | **Zero-Knowledge Architecture** | No shift schedules, sleep times, or personal metrics shall be transmitted to Heldig Lab or any 3rd party analytics provider. |
| NFR-102 | **No Identity Anchor** | The system shall not require email, phone, or social login. The app is completely anonymous. |
| NFR-103 | **Data At Rest** | The local SQLite database shall be stored in the app's protected sandbox directory. |
| NFR-104 | **HealthKit Isolation** | If HealthKit/HealthConnect is authorized, data shall only flow between the OS API and the local SQLite database. |

## 2. Performance & Efficiency (NFR-200)

| ID | Requirement | Metric / Standard |
|---|---|---|
| NFR-201 | **Cold Start Time** | App shall reach the interactable Upcoming Shifts dashboard in < 1.0 second. |
| NFR-202 | **Math Latency** | Calculating the optimal sleep window from a shift schedule must complete in < 50ms to ensure the UI feels instant. |
| NFR-203 | **Audio Efficiency** | Background white noise playback must utilize hardware-accelerated audio APIs to minimize battery drain (< 3% battery per 8 hours). |

## 3. Reliability & Availability (NFR-300)

| ID | Requirement | Metric / Standard |
|---|---|---|
| NFR-301 | **Offline Autonomy** | 100% of the application's core logic (Scheduling, Alarm Setting, Audio, Math) must remain functional without an internet connection. |
| NFR-302 | **Alarm Resilience** | The app must utilize the native OS Alarm/Notification APIs so that alarms fire reliably even if the app is force-closed or the OS kills the background task. |

## 4. Usability & Accessibility (NFR-400)

| ID | Requirement | Metric / Standard |
|---|---|---|
| NFR-401 | **Fatigue-Friendly UX** | The interface must rely on high-contrast colors, extremely large touch targets (min 48x48pt), and explicit confirmation dialogs for destructive actions. Users are often sleep-deprived when making decisions here. |
| NFR-402 | **Dark Room Mode** | The active sleep screen must emit minimal light. It must use a pure black `#000000` background (turning off OLED pixels) and dim red text to preserve night vision. |

## 5. Monetization Constraint (NFR-500)

| ID | Requirement | Metric / Standard |
|---|---|---|
| NFR-501 | **One-Time Paid App** | The app shall be configured as a Paid App ($4.99) in the App Store/Play Store. |
| NFR-502 | **No IAP** | No In-App Purchases, subscriptions, or RevenueCat integrations shall exist in the codebase. |
| NFR-503 | **No Ads** | No ad SDKs (AdMob, Google Mobile Ads) shall be included in the binary. |
