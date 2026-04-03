# Shift Worker Sleep Test Plan

**Document:** TEST-PLAN.md  
**Product:** Shift Worker Sleep  
**Publisher:** Heldig Lab  
**Source of Truth:** [REQUIREMENTS.md](./REQUIREMENTS.md)  
**Related Documents:** [ARCHITECTURE.md](./ARCHITECTURE.md), [NON-FUNCTIONAL-REQUIREMENTS.md](./NON-FUNCTIONAL-REQUIREMENTS.md)

## 1. Quality Strategy

Shift Worker Sleep must be profoundly reliable. If the app's math is wrong or an alarm fails to fire, the user misses a shift or loses critical rest. Our QA strategy focuses heavily on **Algorithmic Accuracy** (validating sleep window math across hundreds of edge cases) and **Alarm Resilience** (ensuring OS-level alarms trigger reliably).

### 1.1 Testing Tiers
- **Unit Tests:** Exhaustive testing of the "Sleep Math Engine" (calculating commutes, split-shifts, and night-to-day transitions).
- **Integration Tests:** SQLite read/writes, HealthKit/HealthConnect permission flows.
- **E2E Tests:** Complete flows (Input Shift -> View Recommendation -> Accept Alarm -> Wake Up -> Log Sleep).
- **Manual QA:** Validating the Dark Room mode (checking for light bleed), testing alarm reliability when the app is backgrounded or killed.

---

## 2. Test Environments

| Environment | Description |
|---|---|
| **Jest / Node** | Headless unit testing for the math engine. |
| **iOS Simulator** | Validating accessibility scaling (Dynamic Type) and contrast. |
| **Physical iOS Device** | Testing background audio (White Noise) and Local Notifications. |
| **Physical Android Device** | Testing AlarmManager APIs and Doze mode resilience. |

---

## 3. Core Test Scenarios

### 3.1 The Math Engine (Unit Testing Focus)
- Validate sleep windows for a standard Day Shift (09:00 - 17:00).
- Validate sleep windows for a standard Night Shift (23:00 - 07:00).
- Validate split-sleep recommendations for "Quick Turnarounds" (e.g., 07:00-15:00, then returning at 23:00).
- Validate nap recommendations when the primary sleep window is constrained to < 6 hours.

### 3.2 Alarm & Notification Reliability
- Validate that the "Wind Down" notification fires 60 minutes before the accepted sleep block.
- Validate that the wake alarm fires exactly at the end of the sleep block, even if the device screen is locked.
- Validate that alarms survive an OS reboot.

### 3.3 Audio & Dark Room Mode
- Validate that the white noise loops seamlessly without audio pops.
- Validate that the white noise continues playing when the screen locks.
- Validate that the Dark Room UI uses only pure black (`#000000`) and red (`#FF3B30`).

### 3.4 Data Privacy & Offline State
- Verify the app functions perfectly in Airplane Mode.
- Verify that exporting JSON works correctly.
- Verify that "Clear All Data" permanently wipes the SQLite database and removes all scheduled local notifications/alarms.
