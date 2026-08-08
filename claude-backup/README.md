# Claude Skills Backup

Backup of all 99 Claude skills from the remote session (taken 2026-08-08), for installing on a Mac.

## Install on your Mac

Clone or pull this branch, then copy the skills into Claude's user skills directory:

```bash
mkdir -p ~/.claude/skills
cp -R claude-backup/skills/ ~/.claude/skills/
```

Claude Code (CLI, desktop app, and IDE extensions) picks up skills from `~/.claude/skills` automatically on the next session.

## Plugins

Plugins are not files — they are enabled at the claude.ai account level and sync to any device you sign into. Currently enabled on this account:

- finance
- productivity
- small-business
- pdf-viewer
- figma
- searchfit-seo
- engineering

Nothing to install for these on the Mac: sign in to the same Claude account and they are available. Manage them at claude.ai under Settings → Plugins (or via the plugin marketplace in Claude Code).
