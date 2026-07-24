#!/usr/bin/env bash
#
# BeautyOnTApp — Local Google Ads Auditor (fleet agent 07)
# ---------------------------------------------------------------------------
# Runs ON T'S OWN COMPUTER, where the Google Ads exports actually live.
#
# There is no Google Ads API or MCP connector, so the cloud fleet is blind to
# the account's real numbers. This script closes that gap: it sweeps every
# Google Ads export on the machine, hands the full list to a headless Claude
# Code agent that audits ALL of them, then pushes both the audit and the
# normalized exports to the automation/reports branch — so cloud agents 01
# (PPC Audit) and 05 (Keywords + Negatives) wake up with real data.
#
# Scheduled daily at 07:30 SAST by install.sh, ahead of the 08:00 cloud run.
#
# Usage:
#   ./run-gads-audit.sh              # normal run
#   DRY_RUN=1 ./run-gads-audit.sh    # discover + list only, no Claude, no push
# ---------------------------------------------------------------------------

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# ---- Load config ----------------------------------------------------------
if [[ -f "$SCRIPT_DIR/config.env" ]]; then
  # shellcheck disable=SC1091
  source "$SCRIPT_DIR/config.env"
else
  echo "ERROR: $SCRIPT_DIR/config.env not found." >&2
  echo "Run:   cp '$SCRIPT_DIR/config.example.env' '$SCRIPT_DIR/config.env'   then edit it." >&2
  exit 1
fi

REPO_DIR="${REPO_DIR:?REPO_DIR must be set in config.env}"
WATCH_DIRS="${WATCH_DIRS:?WATCH_DIRS must be set in config.env}"
MAX_AGE_DAYS="${MAX_AGE_DAYS:-0}"
LOG_DIR="${LOG_DIR:-$HOME/Library/Logs/beautyontapp-gads-auditor}"
CLAUDE_BIN="${CLAUDE_BIN:-claude}"
CLAUDE_PERMISSION_FLAG="${CLAUDE_PERMISSION_FLAG:---permission-mode acceptEdits}"
CLAUDE_MODEL="${CLAUDE_MODEL:-}"
DRY_RUN="${DRY_RUN:-0}"

mkdir -p "$LOG_DIR"
RUN_TS="$(date +%Y%m%d-%H%M%S)"
LOG_FILE="$LOG_DIR/run-$RUN_TS.log"

log() { printf '%s  %s\n' "$(date '+%Y-%m-%d %H:%M:%S')" "$*" | tee -a "$LOG_FILE"; }

log "=== BeautyOnTApp local Google Ads auditor — run $RUN_TS ==="

# ---- Preflight ------------------------------------------------------------
if [[ ! -d "$REPO_DIR/.git" ]]; then
  log "ERROR: REPO_DIR '$REPO_DIR' is not a git repository."
  log "Clone it first:  git clone <repo-url> '$REPO_DIR'"
  exit 1
fi

if [[ "$DRY_RUN" != "1" ]] && ! command -v "$CLAUDE_BIN" >/dev/null 2>&1; then
  log "ERROR: Claude Code CLI '$CLAUDE_BIN' not found on PATH."
  log "Install it, or set CLAUDE_BIN in config.env to its full path."
  exit 1
fi

# SAST is the business timezone; the whole fleet dates its work that way.
DATE_SAST="$(TZ=Africa/Johannesburg date +%F)"
log "Business date (SAST): $DATE_SAST"

# ---- Discover EVERY candidate export --------------------------------------
# T's instruction: view all of them, don't skip. So we sweep broadly (all
# CSV/XLSX in the watch dirs) and let the agent classify. Non-Google-Ads files
# are reported as ignored-with-reason rather than silently dropped.
FILE_LIST="$(mktemp "${TMPDIR:-/tmp}/gads-files-XXXXXX.txt")"
trap 'rm -f "$FILE_LIST"' EXIT

: > "$FILE_LIST"
found_count=0
missing_dirs=()

for dir in $WATCH_DIRS; do
  # Expand a leading ~ if the config used a literal tilde inside quotes.
  dir="${dir/#\~/$HOME}"
  if [[ ! -d "$dir" ]]; then
    missing_dirs+=("$dir")
    continue
  fi

  find_args=( "$dir" -type f \( -iname '*.csv' -o -iname '*.xlsx' -o -iname '*.xls' -o -iname '*.tsv' \) )
  if [[ "$MAX_AGE_DAYS" != "0" ]]; then
    find_args+=( -mtime "-${MAX_AGE_DAYS}" )
  fi

  while IFS= read -r -d '' f; do
    # size in bytes and human mtime, portable across macOS (BSD) and Linux (GNU)
    if stat -f%z "$f" >/dev/null 2>&1; then
      size=$(stat -f%z "$f"); mtime=$(stat -f '%Sm' -t '%Y-%m-%d %H:%M' "$f")
    else
      size=$(stat -c%s "$f"); mtime=$(stat -c '%y' "$f" | cut -d'.' -f1)
    fi
    printf '%s\t%s bytes\t%s\n' "$f" "$size" "$mtime" >> "$FILE_LIST"
    found_count=$((found_count + 1))
  done < <(find "${find_args[@]}" -print0 2>/dev/null)
done

log "Discovered $found_count candidate export file(s) across: $WATCH_DIRS"
if [[ ${#missing_dirs[@]} -gt 0 ]]; then
  log "NOTE: watch directories that do not exist (skipped): ${missing_dirs[*]}"
fi

if [[ "$found_count" -eq 0 ]]; then
  log "No CSV/XLSX files found in the watch directories. Nothing to audit."
  log "Save your Google Ads exports into one of: $WATCH_DIRS"
  exit 0
fi

log "File list written to $FILE_LIST"
if [[ "$DRY_RUN" == "1" ]]; then
  log "--- DRY RUN: files that would be audited ---"
  cat "$FILE_LIST" | tee -a "$LOG_FILE"
  log "--- DRY RUN complete. No Claude invocation, no push. ---"
  exit 0
fi

# ---- Sync the repo to the operational branch ------------------------------
cd "$REPO_DIR"

if [[ -n "$(git status --porcelain)" ]]; then
  log "WARNING: working tree at $REPO_DIR is dirty. Stashing local changes."
  git stash push -u -m "gads-auditor autostash $RUN_TS" >>"$LOG_FILE" 2>&1 || true
fi

log "Fetching automation/reports branch..."
git fetch origin automation/reports >>"$LOG_FILE" 2>&1
git checkout -B automation/reports origin/automation/reports >>"$LOG_FILE" 2>&1
log "On branch: $(git rev-parse --abbrev-ref HEAD)"

# ---- Build the prompt -----------------------------------------------------
PROMPT_TEMPLATE="$SCRIPT_DIR/audit-prompt.md"
if [[ ! -f "$PROMPT_TEMPLATE" ]]; then
  log "ERROR: prompt template not found at $PROMPT_TEMPLATE"
  exit 1
fi

# Only single-line values are substituted, so sed is safe here. The (possibly
# huge) file list is passed by PATH and read by the agent itself.
PROMPT="$(sed \
  -e "s|{{DATE}}|$DATE_SAST|g" \
  -e "s|{{REPO_DIR}}|$REPO_DIR|g" \
  -e "s|{{WATCH_DIRS}}|$WATCH_DIRS|g" \
  -e "s|{{FILE_LIST_PATH}}|$FILE_LIST|g" \
  -e "s|{{FILE_COUNT}}|$found_count|g" \
  "$PROMPT_TEMPLATE")"

# ---- Run the headless agent -----------------------------------------------
log "Invoking Claude Code to audit all $found_count file(s)..."

claude_args=( -p "$PROMPT" --add-dir "$REPO_DIR" )
for dir in $WATCH_DIRS; do
  dir="${dir/#\~/$HOME}"
  [[ -d "$dir" ]] && claude_args+=( --add-dir "$dir" )
done
# shellcheck disable=SC2206
claude_args+=( $CLAUDE_PERMISSION_FLAG )
[[ -n "$CLAUDE_MODEL" ]] && claude_args+=( --model "$CLAUDE_MODEL" )

set +e
"$CLAUDE_BIN" "${claude_args[@]}" 2>&1 | tee -a "$LOG_FILE"
claude_status=${PIPESTATUS[0]}
set -e

if [[ $claude_status -ne 0 ]]; then
  log "ERROR: Claude Code exited with status $claude_status. See $LOG_FILE"
  exit $claude_status
fi

log "=== Run complete. Log: $LOG_FILE ==="
