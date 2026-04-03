# Shift Worker Sleep Requirements

**Document:** REQUIREMENTS.md  
**Product:** Shift Worker Sleep  
**Publisher:** Heldig Lab  
**Source of Truth:** [SPEC.md](./SPEC.md)  
**Related Documents:** [ARCHITECTURE.md](./ARCHITECTURE.md), [NON-FUNCTIONAL-REQUIREMENTS.md](./NON-FUNCTIONAL-REQUIREMENTS.md)

## Purpose

This document enumerates the functional requirements (FR) and high-level non-functional requirements (NFR) for the Shift Worker Sleep app (v1.0). The overriding constraint for all requirements is that **the app is a one-time purchase ($4.99) with absolutely no subscriptions, ads, or backend infrastructure.**

---

## 1. Functional Requirements

### 1.1 Schedule Management (FR-001 to FR-010)

| ID | Requirement | Priority |
|---|---|---|
| FR-001 | The system shall allow users to input work shifts (start time, end time, shift type). | High |
| FR-002 | The system shall allow users to define default commute times to accurately calculate available sleep windows. | High |
| FR-003 | The system shall allow users to clone previous shifts or set repeating shift patterns. | High |
| FR-004 | The system shall display an upcoming 14-day calendar view highlighting scheduled shifts. | High |

### 1.2 Sleep Math & Recommendations (FR-011 to FR-020)

| ID | Requirement | Priority |
|---|---|---|
| FR-011 | The system shall calculate the maximum available "Sleep Opportunity" between shifts, factoring in commutes. | High |
| FR-012 | The system shall recommend a primary sleep block (e.g., 7-9 hours) within the Sleep Opportunity. | High |
| FR-013 | If the Sleep Opportunity is < 6 hours, the system shall recommend a split-sleep strategy or a pre-shift nap. | High |
| FR-014 | The system shall allow the user to manually adjust the recommended sleep and wake times. | High |
| FR-015 | The system shall display a visual timeline (Gantt chart style) showing the shift, the commute, and the sleep block. | Medium |

### 1.3 Alarms & Wind Down (FR-021 to FR-030)

| ID | Requirement | Priority |
|---|---|---|
| FR-021 | The system shall set a native OS alarm for the confirmed wake time. | High |
| FR-022 | The system shall send a local push notification (e.g., 60 mins before sleep) to trigger the "Wind Down" routine. | High |
| FR-023 | The system shall provide a "Dark Room" mode (pure black UI, minimal red text) during active sleep windows. | High |
| FR-024 | The system shall provide offline, looping white, brown, and pink noise audio during the Dark Room mode. | High |

### 1.4 Logging & History (FR-031 to FR-040)

| ID | Requirement | Priority |
|---|---|---|
| FR-031 | The system shall prompt the user to log actual sleep hours upon dismissing the wake alarm. | High |
| FR-032 | The system shall allow users to log subjective sleep quality (1-5 scale) and tags (e.g., "noisy," "caffeine"). | High |
| FR-033 | The system shall store all sleep logs locally in SQLite. | High |
| FR-034 | The system shall display a history view comparing "Planned Sleep" vs "Actual Sleep." | Medium |
| FR-035 | The system shall allow optional read/write integration with Apple Health (iOS) and HealthConnect (Android). | Medium |

### 1.5 Export & Data (FR-041 to FR-050)

| ID | Requirement | Priority |
|---|---|---|
| FR-041 | The system shall allow the user to export all schedule and sleep data as a JSON file. | High |
| FR-042 | The system shall allow the user to import a JSON file to restore their schedule and logs. | High |
| FR-043 | The system shall provide a "Delete All Data" button to instantly wipe the SQLite database. | High |

---

## 2. Non-Functional Requirements (High-Level)

| ID | Category | Requirement |
|---|---|---|
| NFR-001 | **Privacy** | **Zero-Backend:** No shift schedules or sleep logs shall ever be transmitted to Heldig Lab or any third-party server. |
| NFR-002 | **Monetization** | The app shall be a one-time paid upfront app ($4.99). No recurring subscriptions, ads, or restricted "Pro" tiers shall exist. |
| NFR-003 | **Offline** | 100% of the application's features (including sleep math and audio) must work in Airplane Mode. |
| NFR-004 | **Accessibility** | The UI must use high-contrast text and support system accessibility text scaling, as users will often interact with it while fatigued. |
