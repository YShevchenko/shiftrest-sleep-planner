#!/bin/bash
# Script to generate Shift Worker Sleep UI designs using Google Stitch
# Requires gcloud application-default credentials

set -e

WORK_DIR="/Users/yts/lab/planned/shift-worker-sleep/docs/stitch-designs"
mkdir -p "$WORK_DIR"
LOG_FILE="$WORK_DIR/generation.log"

echo "Starting Stitch Generation for Shift Worker Sleep..." > "$LOG_FILE"

# Get Token
TOKEN=$(gcloud auth application-default print-access-token)
export STITCH_ACCESS_TOKEN=$TOKEN
export GOOGLE_CLOUD_PROJECT=lab-apps-490222

export PATH="/opt/homebrew/bin:$PATH"

# 1. Create Project
echo "Creating project..." | tee -a "$LOG_FILE"
PROJECT_JSON=$(stitch-mcp tool create_project -d '{"title": "Shift Worker Sleep - Vibecodable"}' -o json)
PROJECT_ID=$(echo "$PROJECT_JSON" | grep -o '"name":"projects/[^"]*' | cut -d'/' -f2 | head -1)

echo "Project ID: $PROJECT_ID" | tee -a "$LOG_FILE"

if [ -z "$PROJECT_ID" ]; then
  echo "Failed to create project." | tee -a "$LOG_FILE"
  exit 1
fi

# Define prompts
declare -a PROMPTS=(
  "Mobile app onboarding screen for a shift worker sleep app. Dark theme default. Large, high-contrast typography emphasizing 'We do the sleep math for your shifts'. A massive primary blue 'Enter First Shift' button. Text at bottom: '100% Private & Offline'. UI is calm and avoids jarring alert colors."
  "Mobile app dashboard for a shift worker sleep app. Dark theme. Top area has a summary card: 'Night Shift starts at 19:00'. Below is a vertically scrolling list of the next 7 days. Days with shifts show a solid blue block with times. Empty days show 'Off'. A large floating action button '+' is in the bottom right."
  "Mobile app modal for adding a work shift. Dark theme. Clean, oversized form inputs for 'Start Time', 'End Time', and 'Shift Type' (Day/Night/On-Call). Below is a slider to set 'Commute Time'. A full-width primary blue 'Save Shift' button is at the bottom."
  "Mobile app sleep planner screen. Dark theme. Header: 'Based on your next shift...'. Below is a large recommendation card showing 'Sleep Window: 09:00 - 16:30'. A prominent 'Accept & Set Alarm' button below it. At the bottom, a horizontal Gantt-style timeline bar showing the current time, recommended sleep block, and upcoming shift block."
  "Mobile app active sleep mode screen called 'Dark Room'. Pure black background to preserve night vision. Extremely large, dim red typography showing the current time '14:30' and 'Alarm set for 16:30'. Below are oversized dim red icons to toggle 'White Noise' on/off with a volume slider. A large 'Slide to Wake Up' gesture area at the bottom."
  "Mobile app history and settings screen. Dark theme. Top section is a simple list comparing 'Planned Sleep' vs 'Actual Sleep' hours for the last 14 days. Bottom section contains large, easily tappable buttons for 'Export Data to JSON' and 'Clear All Data'. Minimalist and highly legible."
)

declare -a FILENAMES=(
  "01_Onboarding"
  "02_Dashboard"
  "03_AddShift"
  "04_SleepPlanner"
  "05_DarkRoom"
  "06_HistorySettings"
)

# 2. Generate Screens
for i in "${!PROMPTS[@]}"; do
  export STITCH_ACCESS_TOKEN=$(gcloud auth application-default print-access-token)
  PROMPT="${PROMPTS[$i]}"
  FILENAME="${FILENAMES[$i]}"
  
  echo "Generating Screen $((i+1))/6: $FILENAME..." | tee -a "$LOG_FILE"
  
  SCREEN_JSON=$(stitch-mcp tool generate_screen_from_text -d "{\"projectId\": \"$PROJECT_ID\", \"prompt\": \"$PROMPT\"}" -o json || true)
  SCREEN_ID=$(echo "$SCREEN_JSON" | grep -o '"name":"projects/[^"]*/screens/[^"]*' | cut -d'/' -f4 | head -1)
  
  if [ -n "$SCREEN_ID" ]; then
    echo "  Success! Screen ID: $SCREEN_ID" | tee -a "$LOG_FILE"
    echo "  Fetching HTML..." | tee -a "$LOG_FILE"
    CODE_JSON=$(stitch-mcp tool get_screen_code -d "{\"projectId\": \"$PROJECT_ID\", \"screenId\": \"$SCREEN_ID\"}" -o json || true)
    echo "$CODE_JSON" > "$WORK_DIR/$FILENAME.json"
    echo "  Saved to $FILENAME.json" | tee -a "$LOG_FILE"
  else
    echo "  Failed to generate screen. Response: $SCREEN_JSON" | tee -a "$LOG_FILE"
  fi
done

echo "All generation tasks completed!" | tee -a "$LOG_FILE"