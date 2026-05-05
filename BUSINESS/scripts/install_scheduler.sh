#!/bin/bash
# ============================================================
# FRANCHISE UNDERWORLD — LAUNCHD SCHEDULER INSTALLER
# Fires autonomous_publisher.sh daily at 11:00 AM MDT (17:00 UTC)
# Run once: bash install_scheduler.sh
# ============================================================

PLIST_LABEL="com.franchiseunderworld.publisher"
PLIST_PATH="$HOME/Library/LaunchAgents/$PLIST_LABEL.plist"
PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
SCRIPT="$PROJECT_ROOT/BUSINESS/scripts/autonomous_publisher.sh"
LOG_OUT="$PROJECT_ROOT/BUSINESS/logs/launchd_out.log"
LOG_ERR="$PROJECT_ROOT/BUSINESS/logs/launchd_err.log"

mkdir -p "$PROJECT_ROOT/BUSINESS/logs"

# Get today's day-of-month to pass as the day argument
DAY_CMD="/bin/sh -c 'bash $SCRIPT \$(date +%-d)'"

cat > "$PLIST_PATH" << EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN"
  "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
  <key>Label</key>
  <string>$PLIST_LABEL</string>

  <key>ProgramArguments</key>
  <array>
    <string>/bin/bash</string>
    <string>$SCRIPT</string>
    <string>--day-of-month</string>
  </array>

  <key>StartCalendarInterval</key>
  <dict>
    <key>Hour</key>
    <integer>17</integer>
    <key>Minute</key>
    <integer>0</integer>
  </dict>

  <key>StandardOutPath</key>
  <string>$LOG_OUT</string>

  <key>StandardErrorPath</key>
  <string>$LOG_ERR</string>

  <key>RunAtLoad</key>
  <false/>
</dict>
</plist>
EOF

echo "✅ Plist written to: $PLIST_PATH"

# Load it
launchctl unload "$PLIST_PATH" 2>/dev/null
launchctl load "$PLIST_PATH"

echo "✅ Scheduler installed. Posts will fire daily at 11:00 AM MDT (17:00 UTC)."
echo "   To verify: launchctl list | grep franchiseunderworld"
echo "   To remove: launchctl unload $PLIST_PATH && rm $PLIST_PATH"
