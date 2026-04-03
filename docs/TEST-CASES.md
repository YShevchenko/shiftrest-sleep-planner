# Shift Worker Sleep Detailed Test Cases

**Document:** TEST-CASES.md  
**Product:** Shift Worker Sleep  
**Publisher:** Heldig Lab  
**Source of Truth:** [REQUIREMENTS.md](./REQUIREMENTS.md)  
**Related Documents:** [TEST-PLAN.md](./TEST-PLAN.md)

## Purpose

This document provides step-by-step test cases for Shift Worker Sleep. It focuses on validating the schedule inputs, sleep math engine, and the "Dark Room" audio/alarm features.

---

## 1. Schedule & Math (TC-100)

### TC-101: Add Standard Night Shift
**Objective:** Verify the math engine calculates daytime sleep correctly.
1. Launch the app and tap "Enter Shift".
2. Set Start Time: 23:00 (Today).
3. Set End Time: 07:00 (Tomorrow).
4. Set Commute: 30 minutes.
5. Save.
6. **Expected Result:** The app recommends a sleep window starting at 08:00 (07:00 + 30m commute + 30m wind down) and ending at 16:00 (8 hours total).

### TC-102: Quick Turnaround (Split Sleep)
**Objective:** Verify the engine recommends naps when the gap between shifts is short.
1. Add Shift 1: 07:00 - 15:00.
2. Add Shift 2: 23:00 - 07:00 (Same day).
3. **Expected Result:** The app detects a 8-hour gap (15:00 to 23:00). Subtracting commutes (e.g., 2x30m), it recommends a 4-5 hour "Nap" block before the night shift (e.g., 16:00 to 21:00).

---

## 2. Alarms & Notifications (TC-200)

### TC-201: Wind Down Notification
**Objective:** Verify the OS schedules local notifications.
1. Accept a recommended sleep window starting at 14:00.
2. Put the app in the background.
3. Set the system clock to 12:59.
4. Wait 1 minute.
5. **Expected Result:** At exactly 13:00 (60 minutes prior), a local push notification fires: "Time to wind down. Your sleep block starts in 60 minutes."

### TC-202: Offline Alarm Wake
**Objective:** Verify the wake alarm functions without internet and respects OS volume overrides.
1. Accept a sleep window ending at 16:00.
2. Enable Airplane Mode.
3. Lock the device.
4. Set system clock to 15:59.
5. Wait 1 minute.
6. **Expected Result:** At exactly 16:00, the alarm triggers and wakes the screen. Swiping the notification brings up the "Log Sleep" modal.

---

## 3. Dark Room Mode (TC-300)

### TC-301: Pure Black UI
**Objective:** Verify the UI prevents light bleed.
1. Enter an active sleep block.
2. Open the "Dark Room" mode.
3. Take a screenshot and analyze the hex codes.
4. **Expected Result:** The background is exactly `#000000` (pure black) to turn off OLED pixels. All text is `#FF3B30` (dim red) to preserve night vision.

### TC-302: Background White Noise
**Objective:** Verify audio loops seamlessly.
1. In Dark Room mode, tap the "White Noise" icon.
2. Put the app in the background.
3. Listen for 3 minutes (past the typical 1-2 minute loop point of an audio file).
4. **Expected Result:** The audio loops perfectly without any audible "pop" or gap.

---

## 4. Extended Schedule, Sleep & Data Tests (TC-100/200/300 continued)

### TC-103: Add Shift with Commute Time
**Objective:** Verify the sleep window calculation accounts for commute offset.
1. Tap "Enter Shift".
2. Set Start Time: 06:00, End Time: 14:00.
3. Set Commute: 45 minutes.
4. Save.
5. **Expected Result:** The app calculates the sleep window starting from 14:45 (14:00 + 45m commute) plus wind-down time. The recommended sleep block (e.g., 15:45 to 23:45 for 8 hours) correctly offsets both the commute and wind-down period. The visual timeline shows the commute as a distinct segment between the shift end and sleep start.

### TC-104: Back-to-Back Shifts — Nap Recommendation
**Objective:** Verify nap recommendation for quick turnarounds under 6 hours of available sleep.
1. Add Shift 1: 06:00 - 14:00.
2. Add Shift 2: 18:00 - 02:00 (same day).
3. Set Commute: 30 minutes.
4. **Expected Result:** The gap between shifts is 4 hours (14:00 to 18:00). After subtracting commutes (2x30m = 1 hour), only 3 hours remain — well under 6 hours. The app recommends a nap block (e.g., 14:30 to 17:00) instead of a full sleep block. A "Quick Turnaround" warning or label is displayed.

### TC-105: Clone Previous Shift
**Objective:** Verify all fields are copied when cloning a shift.
1. Add a shift: Start 22:00, End 06:00, Commute 30 min, Type "Night Shift".
2. From the calendar or shift list, select the shift and tap "Clone" / "Duplicate".
3. **Expected Result:** A new shift entry appears pre-filled with identical values: Start 22:00, End 06:00, Commute 30 min, Type "Night Shift". The date defaults to the next unscheduled day. All fields are editable before saving.

### TC-106: Set Repeating Shift Pattern
**Objective:** Verify repeating pattern populates the 14-day calendar.
1. Tap "Add Pattern" or "Repeating Shift".
2. Define a pattern: 4 days on (Night Shift 22:00-06:00), 4 days off.
3. Set the pattern start date to today.
4. Save.
5. **Expected Result:** The 14-day calendar view populates with the repeating pattern: 4 shift days followed by 4 off days, cycling through the 14-day window. Each shift day shows the correct times. Off days are clearly marked as free. Sleep recommendations are generated for each shift day.

### TC-107: Wind Down Notification Timing
**Objective:** Verify the notification fires exactly 60 minutes before planned sleep start.
1. Accept a recommended sleep window starting at 15:00.
2. Background the app.
3. Advance the system clock to 13:59.
4. Wait 1 minute.
5. **Expected Result:** At exactly 14:00 (60 minutes before the 15:00 sleep start), a local push notification fires with text like "Time to wind down. Your sleep block starts in 60 minutes." The notification appears even if the app is backgrounded or the screen is locked.

### TC-108: Wake Alarm Fires at Confirmed Wake Time
**Objective:** Verify the OS native alarm triggers at the correct time.
1. Accept a sleep window ending at 21:00 (wake time).
2. Lock the device and let the system clock reach 21:00.
3. **Expected Result:** At exactly 21:00, the alarm fires and wakes the screen. The alarm sound plays at system alarm volume. Dismissing the alarm opens the "Log Sleep" modal where the user can record actual sleep hours.

### TC-109: Dark Room Mode — Pure Black UI with Red Text
**Objective:** Verify the Dark Room UI minimizes light emission.
1. Enter an active sleep block.
2. Open "Dark Room" mode.
3. Take a screenshot and inspect the pixel colors.
4. **Expected Result:** The entire background is pure black (#000000), which turns off OLED pixels. All visible text and icons use dim red (#FF3B30 or similar). No blue, white, or bright-colored UI elements are present. The status bar is hidden or also pure black. Screen brightness is at minimum.

### TC-110: White Noise Seamless Looping
**Objective:** Verify audio loops without audible gaps over extended playback.
1. In Dark Room mode, select "White Noise" from the sound options.
2. Play the audio and listen continuously for 10 minutes.
3. **Expected Result:** The white noise loops seamlessly with no audible gap, pop, click, or volume dip at the loop point. The audio continues uninterrupted when the app is backgrounded or the screen is locked.

### TC-111: Log Actual Sleep After Wake
**Objective:** Verify planned vs actual comparison is displayed.
1. Accept a planned sleep window: 08:00 to 16:00.
2. After the wake alarm fires at 16:00, open the "Log Sleep" modal.
3. Enter actual sleep: fell asleep at 08:30, woke at 15:45.
4. Save.
5. **Expected Result:** The sleep history view shows both the planned block (08:00-16:00, 8 hours) and the actual block (08:30-15:45, 7h 15m) side by side. The difference is clearly labeled (e.g., "45 min less than planned").

### TC-112: Rate Sleep Quality with Tags
**Objective:** Verify subjective quality rating and tags are saved.
1. After logging actual sleep, the app prompts for quality rating.
2. Select a rating of 2 out of 5 stars.
3. Add tags: "noisy" and "caffeine".
4. Save.
5. **Expected Result:** The sleep log entry shows the 2/5 rating and both tags ("noisy", "caffeine"). The tags appear in the history view alongside the date and sleep duration. The data persists across app restarts.

### TC-113: View Sleep History — Planned vs Actual Chart
**Objective:** Verify the history chart accurately reflects logged data.
1. Log sleep for 7 consecutive days with varying planned and actual times.
2. Navigate to the Sleep History / Analytics screen.
3. **Expected Result:** A chart displays planned sleep blocks vs actual sleep blocks for the past 7 days. Each day shows two bars or overlaid segments. The chart data matches the individually logged entries exactly. Average sleep duration and quality are summarized.

### TC-114: Export Data as JSON
**Objective:** Verify the export includes all user data.
1. Add 5 shifts, accept 5 sleep plans, and log 5 actual sleep entries with quality ratings.
2. Navigate to Settings > Export Data > JSON.
3. Save and inspect the file.
4. **Expected Result:** The JSON file contains all 5 shifts (with start/end times, commute, type), all 5 sleep plans (planned windows), all 5 sleep logs (actual times, quality ratings, tags), and any repeating patterns. No fields are missing or null unexpectedly.

### TC-115: Import JSON Backup
**Objective:** Verify full data restoration from backup.
1. Export data as JSON per TC-114.
2. Navigate to Settings > "Delete All Data" and confirm.
3. Navigate to Settings > Import Data.
4. Select the previously exported JSON file.
5. **Expected Result:** All shifts, sleep plans, and sleep logs are fully restored. The 14-day calendar repopulates with the imported shifts. Sleep history charts reflect the imported logs. Scheduled alarms and notifications are re-created for future shifts.

### TC-116: Airplane Mode — Full Offline Functionality
**Objective:** Verify all features work without network connectivity.
1. Enable Airplane Mode on the device.
2. Add a new shift, accept a sleep recommendation, enter Dark Room mode, play white noise, set an alarm, and log sleep.
3. **Expected Result:** Every feature works identically to online mode. Sleep math calculations complete instantly. Dark Room mode launches with audio playback. The alarm fires at the scheduled time. No error messages, loading spinners, or network-related warnings appear.

### TC-117: Delete All Data — Complete Wipe
**Objective:** Verify "Delete All Data" removes everything including scheduled notifications.
1. Add 5 future shifts, accept 5 sleep plans with alarms, and log 3 past sleep entries.
2. Navigate to Settings > "Delete All Data". Confirm.
3. Check the OS pending notifications queue (via debugging tools).
4. **Expected Result:** The dashboard is completely empty. The 14-day calendar shows no shifts. The sleep history is blank. The SQLite database is wiped. All 5 scheduled wake alarms and 5 wind-down notifications have been cancelled from the OS notification queue.

---

## 5. Privacy & Data Erasure (TC-400)

### TC-401: Complete Wipe
**Objective:** Verify "Clear All Data" removes shifts and scheduled alarms.
1. Add 5 future shifts and accept 5 alarms.
2. Go to Settings > "Clear All Data". Confirm.
3. Check the OS pending notifications queue (via debugging tools).
4. **Expected Result:** The dashboard is empty. The SQLite database is wiped. All 5 scheduled alarms and wind-down notifications have been cancelled.
