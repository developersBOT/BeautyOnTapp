#!/usr/bin/env bash
#
# BeautyOnTApp — Local Google Ads Auditor installer
# ---------------------------------------------------------------------------
# Sets up the daily 07:30 SAST sweep on your own computer, so the auditor runs
# before the cloud fleet's 08:00 SAST cascade.
#
#   ./install.sh          # install / reinstall the schedule
#   ./install.sh --status # show whether it is installed and when it last ran
#   ./install.sh --remove # uninstall the schedule
#
# macOS  -> launchd (survives reboots, catches up missed runs)
# Linux  -> cron
# ---------------------------------------------------------------------------

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
RUNNER="$SCRIPT_DIR/run-gads-audit.sh"
LABEL="com.beautyontapp.gads-auditor"
PLIST="$HOME/Library/LaunchAgents/$LABEL.plist"

# 07:30 SAST. If the machine's clock is already SAST this is simply 07:30.
RUN_HOUR=7
RUN_MINUTE=30

info()  { printf '  %s\n' "$*"; }
ok()    { printf '  \033[32m✓\033[0m %s\n' "$*"; }
warn()  { printf '  \033[33m!\033[0m %s\n' "$*"; }
fail()  { printf '  \033[31m✗\033[0m %s\n' "$*" >&2; }

case "${1:-install}" in
  --status)
    echo "BeautyOnTApp local Google Ads auditor — status"
    if [[ "$(uname)" == "Darwin" ]]; then
      if launchctl list | grep -q "$LABEL"; then ok "launchd job installed ($LABEL)"; else warn "not installed"; fi
      [[ -f "$PLIST" ]] && info "plist: $PLIST"
    else
      if crontab -l 2>/dev/null | grep -q "run-gads-audit.sh"; then ok "cron entry installed"; else warn "not installed"; fi
    fi
    LOG_DIR="${LOG_DIR:-$HOME/Library/Logs/beautyontapp-gads-auditor}"
    if [[ -d "$LOG_DIR" ]]; then
      last="$(ls -t "$LOG_DIR"/run-*.log 2>/dev/null | head -1 || true)"
      [[ -n "$last" ]] && info "last run log: $last" || info "no runs yet"
    fi
    exit 0
    ;;
  --remove)
    echo "Removing the scheduled auditor..."
    if [[ "$(uname)" == "Darwin" ]]; then
      launchctl unload "$PLIST" 2>/dev/null || true
      rm -f "$PLIST"
      ok "launchd job removed"
    else
      crontab -l 2>/dev/null | grep -v "run-gads-audit.sh" | crontab - || true
      ok "cron entry removed"
    fi
    exit 0
    ;;
esac

echo "BeautyOnTApp — installing the local Google Ads auditor"
echo

# ---- 1. Config ------------------------------------------------------------
if [[ ! -f "$SCRIPT_DIR/config.env" ]]; then
  cp "$SCRIPT_DIR/config.example.env" "$SCRIPT_DIR/config.env"
  ok "created config.env from the example"
  warn "EDIT IT before the first run: $SCRIPT_DIR/config.env"
  info "set REPO_DIR to your local clone, and WATCH_DIRS to wherever you save Google Ads exports"
else
  ok "config.env already exists (left untouched)"
fi

# shellcheck disable=SC1091
source "$SCRIPT_DIR/config.env"
chmod +x "$RUNNER"

# ---- 2. Dedicated exports folder -----------------------------------------
EXPORT_DIR="$HOME/BeautyOnTApp-GoogleAds"
mkdir -p "$EXPORT_DIR"
ok "exports folder ready: $EXPORT_DIR"
info "drop Google Ads downloads here (or anywhere in WATCH_DIRS)"

# ---- 3. Preflight ---------------------------------------------------------
if command -v "${CLAUDE_BIN:-claude}" >/dev/null 2>&1; then
  ok "Claude Code CLI found: $(command -v "${CLAUDE_BIN:-claude}")"
else
  fail "Claude Code CLI not found. Install it, or set CLAUDE_BIN in config.env."
fi

if [[ -d "${REPO_DIR:-}/.git" ]]; then
  ok "repo found: $REPO_DIR"
else
  fail "REPO_DIR '${REPO_DIR:-unset}' is not a git clone — fix config.env before running."
fi

# ---- 4. Schedule ----------------------------------------------------------
if [[ "$(uname)" == "Darwin" ]]; then
  mkdir -p "$HOME/Library/LaunchAgents"
  cat > "$PLIST" <<PLISTEOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>Label</key>
    <string>$LABEL</string>
    <key>ProgramArguments</key>
    <array>
        <string>/bin/bash</string>
        <string>$RUNNER</string>
    </array>
    <key>StartCalendarInterval</key>
    <dict>
        <key>Hour</key>
        <integer>$RUN_HOUR</integer>
        <key>Minute</key>
        <integer>$RUN_MINUTE</integer>
    </dict>
    <key>RunAtLoad</key>
    <false/>
    <key>StandardOutPath</key>
    <string>${LOG_DIR:-$HOME/Library/Logs/beautyontapp-gads-auditor}/launchd.out.log</string>
    <key>StandardErrorPath</key>
    <string>${LOG_DIR:-$HOME/Library/Logs/beautyontapp-gads-auditor}/launchd.err.log</string>
</dict>
</plist>
PLISTEOF

  mkdir -p "${LOG_DIR:-$HOME/Library/Logs/beautyontapp-gads-auditor}"
  launchctl unload "$PLIST" 2>/dev/null || true
  launchctl load "$PLIST"
  ok "scheduled daily at $(printf '%02d:%02d' $RUN_HOUR $RUN_MINUTE) via launchd"
else
  CRON_LINE="$RUN_MINUTE $RUN_HOUR * * * /bin/bash $RUNNER >/dev/null 2>&1"
  ( crontab -l 2>/dev/null | grep -v "run-gads-audit.sh" ; echo "$CRON_LINE" ) | crontab -
  ok "scheduled daily at $(printf '%02d:%02d' $RUN_HOUR $RUN_MINUTE) via cron"
fi

echo
echo "Next steps:"
info "1. Check config.env is correct:  $SCRIPT_DIR/config.env"
info "2. Test the sweep without running Claude or pushing:"
echo "        DRY_RUN=1 $RUNNER"
info "3. Do a real run now:"
echo "        $RUNNER"
echo
ok "Installed. It runs every morning at 07:30, before the cloud fleet at 08:00."
