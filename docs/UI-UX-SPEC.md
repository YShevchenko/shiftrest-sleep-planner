# Shift Worker Sleep UI/UX Specification

**Document:** UI-UX-SPEC.md  
**Product:** Shift Worker Sleep  
**Publisher:** Heldig Lab  
**Source of Truth:** [SPEC.md](./SPEC.md)  
**Related Documents:** [ARCHITECTURE.md](./ARCHITECTURE.md), [REQUIREMENTS.md](./REQUIREMENTS.md)

## 1. Design Philosophy

Shift Worker Sleep is built for users who are often tired, stressed, and managing unpredictable schedules. The UI must be:

- **High-Contrast & Large:** Touch targets must be oversized. Text must be highly legible. Avoid small, low-contrast fonts.
- **Action Before Analysis:** The app tells the user *what to do next* (e.g., "Sleep in 45 mins") before asking them to analyze a chart.
- **Calm & Supportive:** The visual language should reduce anxiety, using soft, dark colors and avoiding bright, jarring alert reds unless absolutely necessary.
- **Trust (Zero-Backend):** No accounts, no sign-ins, no "upgrade to Pro" buttons.

---

## 2. Visual Identity

### 2.1 Color Palette

| Name | Hex Code | Usage |
|---|---|---|
| **Primary (Brand)** | `#5B86E5` | Main actions, active shift blocks, 'Sleep Now' buttons |
| **Background (Dark Theme Default)** | `#12141C` | The app uses a dark theme by default to reduce eye strain. |
| **Surface (Dark)** | `#1E212B` | Cards, shift blocks, modal backgrounds |
| **Text (Primary)** | `#FFFFFF` | Main headings, large numbers |
| **Text (Secondary)**| `#A0AAB2` | Subtext, labels |
| **Dark Room Mode (Text)**| `#FF3B30` | Deep red text on pure black background for night vision preservation |

### 2.2 Typography

- **Headings:** System Sans-Serif (SF Pro/Roboto) - Bold, large sizing (24pt+).
- **Body:** System Sans-Serif - Regular (16pt+).
- **Time Displays:** Large, easily readable monospaced or highly legible tabular numbers.

---

## 3. Motion & Interaction

### 3.1 Gesture Language
- **Swipe to Delete:** Remove a shift from the upcoming schedule.
- **Drag to Adjust:** In the Sleep Planner timeline, dragging the edges of a "Sleep Block" to adjust start/end times.

### 3.2 Transitions
- **Dark Room Mode Toggle:** A slow, 1-second fade to black, transitioning the UI into its low-light state.
- **Screen Transitions:** Standard horizontal slides.

---

## 4. Screen Specifications (Vibecodable 6-Screen Architecture)

### 4.1 Onboarding
- **Welcome Screen:** Large, friendly text explaining "We do the sleep math for your shifts." Features a large "Enter First Shift" button. Emphasizes "100% Private & Offline."

### 4.2 Schedule Dashboard (Home)
- **Top Area:** "Next Shift" summary card (e.g., "Night Shift starts at 19:00").
- **Middle Area:** A vertically scrolling list of the next 7 days. Days with shifts show a colored block. Empty days show "Off."
- **FAB (Floating Action Button):** A large `+` button in the bottom right to quickly add a new shift.

### 4.3 Add/Edit Shift Modal
- **Form Layout:** Clean, oversized inputs for Start Time, End Time, and Shift Type (Day/Night/On-Call).
- **Commute Slider:** A slider to set average commute time (defaults to saved user preference).
- **Save Button:** Full-width primary button at the bottom.

### 4.4 Sleep Planner & Recommendation
- **Header:** "Based on your next shift..."
- **Recommendation Card:** A large, highly visible recommended sleep window (e.g., "Sleep: 09:00 - 16:30").
- **Action:** A prominent "Accept & Set Alarm" button.
- **Timeline Visualization:** A horizontal Gantt-style bar showing the current time, the recommended sleep block, and the upcoming shift block.

### 4.5 Dark Room (Active Sleep Mode)
- **Visuals:** Pure black background (`#000000`). Large, dim red text showing the current time and "Alarm set for XX:XX."
- **Controls:** Oversized, dim red icons to toggle White Noise/Brown Noise on or off. A slider for local volume control.
- **Wake Action:** A "Slide to Wake Up" gesture (to prevent accidental taps) that stops the noise and logs the sleep.

### 4.6 History & Settings
- **History View:** A simple list comparing "Planned" vs "Actual" sleep hours over the last 14 days.
- **Settings:** Options to set default commute time, toggle Apple Health/HealthConnect sync, "Export Data (JSON)", and "Clear All Data."

---

## Error & Edge States

- **Empty state (no shifts):** "Add your first shift to get personalized sleep recommendations." Displayed on the Schedule Dashboard with a large `+` button centered below the message. The Next Shift summary card is hidden until the first shift is added.
- **No sleep window available (back-to-back shifts):** Warning card on the Sleep Planner screen with a caution icon: "Your shifts are too close together for a full sleep cycle. Consider a 90-minute nap between X:XX and X:XX." The nap window is calculated from the gap between shifts. The "Accept & Set Alarm" button adapts to set a nap alarm instead.
- **Notification permission denied:** Persistent banner at the top of the Schedule Dashboard: "Sleep reminders and alarms won't work without notifications. Enable in Settings." The banner includes a tappable "Enable" link that opens system settings. The banner persists across sessions until permission is granted.
- **Alarm failed to fire:** On next app open after a missed alarm: "Your alarm at X:XX may not have fired. Did you wake up on time?" Two options: "Yes, I woke up" (logs the planned wake time) and "No, I overslept" (allows the user to log their actual wake time for accurate sleep tracking).
- **Audio playback failure (white noise):** Toast notification in Dark Room mode: "Couldn't play audio. Check your volume and ringer switch." The noise toggle shows a warning indicator. The alarm functionality is unaffected.
- **Dark Room mode accidental exit:** If the user taps outside the Dark Room controls or swipes to leave, a confirmation dialog appears: "Leave Dark Room mode?" with "Stay" and "Leave" buttons. This prevents accidental brightness exposure that could disrupt night vision adaptation.
- **Import validation failure:** Alert dialog: "This file doesn't match the expected format. Make sure it's an unmodified Shift Worker Sleep export." Single "OK" button to dismiss. No data is modified.
- **Sleep math edge case:** When a shift crosses midnight, the display clearly shows "Night Shift: 11 PM - 7 AM" with the date range indicated (e.g., "Mon night - Tue morning"). The sleep window is calculated correctly relative to the shift end time, not the calendar date.
