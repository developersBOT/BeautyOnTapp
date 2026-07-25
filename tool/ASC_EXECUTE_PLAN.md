# Master execution prompt — resolve the BeautyOnTApp iOS rejection and resubmit

Paste everything under the line into a capable agent running **on your Mac** (Codex CLI,
or Claude Code on the Mac). It has: this git repo, your logged-in browser (Chrome or
Safari — see `tool/ASC_SUBMIT_CHROME.md` / `tool/ASC_SUBMIT_SAFARI.md` for how to attach),
and access to a **physical iPhone/iPad** for the steps only a device can do.

It executes the plan, but **pauses at every HUMAN step** (device recording, decisions,
anything irreversible) and never edits code/settings/replies without showing you first.

---

You are resolving an App Store rejection for **BeautyOnTApp** (iOS 1.1.2, rejected on
build 8). Work through the phases in order. After each phase, report what you found and
STOP for my go-ahead before anything that changes a live system (Shopify, App Store
Connect, git push, sending a reply). Cite exactly what you observed; if you cannot verify
something, say "NOT VERIFIED" and why — do not guess.

## Ground rules
- **Do NOT remove the "Delete my account" button** from the app's Profile drawer
  (`sections/bottom-bar.liquid`, marker `bot-profile-delete-row`). It is the only in-app
  account-deletion path and Apple requires it (5.1.1(v)). Removing it re-triggers rejection.
- Do not touch Shopify apps Analyzify, Simprosys, or BookX, or feeds/data they manage.
- The three rejection reasons and their state:
  - **4.8** (Google login w/o equivalent) — "Sign in with Google" is now **Off** in Shopify
    → Settings → Customer accounts → Authentication. Storefront login is email-OTP only.
  - **2.1(a)** — "the 'google' button was not responsive" on iPad. Should be gone now Google
    is Off; must be confirmed on an iPad (see Phase 2).
  - **5.1.1(v)** — deletion is reachable in-app: Profile → "Delete my account" →
    `/pages/delete-account`. Must be confirmed end-to-end and screen-recorded (Phase 2).

## Phase 1 — Build (repo)
1. Confirm the rejected binary's source: build 8 = commit `99f2ea9` on branch
   `claude/google-ads-conversion-issues-7epio6`, `pubspec.yaml` = `1.1.2+8`.
2. A higher build is staged: `release/1.1.2-build9` (`1.1.2+9`). Report whether Xcode Cloud
   built/uploaded it (check the Xcode Cloud tab). **Decision for me:** resubmit build 8
   as-is (fixes were server-side, no binary change) OR ship build 9. Recommend build 8
   unless the on-device check in Phase 2 finds an app-level defect.

## Phase 2 — On-device verification (physical iPad — HUMAN + agent)
Do these on a real iPad (the reviewer used iPad Air 11" M3, iPadOS 26.5). This is the part
iPhone-only testing missed.
1. Install the current build. Open the app.
2. **2.1(a) check:** go to the sign-in/Profile area. Is any "Sign in with Google" button
   shown? It should be gone. If it still appears, tap it and note whether it responds; if it
   hangs, capture the Safari Web Inspector console/network (that is the 2.1(a) bug and means
   the button is still being served — stop and tell me its source).
3. **5.1.1(v) check + RECORDING (HUMAN):** screen-record on the device: sign in → open
   Profile → tap **Delete my account** → complete the request → the confirmation screen.
   Save this recording; it must be attached to the Apple reply. No agent can film it.
4. Report: is the Google button gone? Does the delete flow complete to confirmation?

## Phase 3 — Reviewer sign-in (CRITICAL — most likely cause of the next rejection)
The login is **email OTP** (passwordless) and "Sign-In required" is currently OFF with no
demo account, so the reviewer cannot sign in to reach the delete flow. **Recommended (no
code, do today):** turn Sign-In required ON, create a dedicated mailbox you control (e.g. a
Gmail), create/allow a customer account on that email, and hand the reviewer that inbox so
they read the one-time code themselves — the exact Notes block is in Phase 4 step 3. (Cleaner
alternative, needs the developer: have the backend accept a fixed reviewer code for one demo
email.) Do not submit until this is in place; do not invent a password; do **NOT** remove the
delete link to dodge this — removal re-triggers 5.1.1(v).

## Phase 4 — App Store Connect (your logged-in browser)
Attach to my signed-in browser per `tool/ASC_SUBMIT_CHROME.md` (or `_SAFARI`). Then:
1. Open BeautyOnTApp → iOS 1.1.2 version. Attach build 8 (or 9 per Phase 1).
2. Set App Review Information per the Phase 3 decision (demo email + how the reviewer gets
   the code). Do NOT enter a password that does not exist.
3. **Notes** — turn Sign-In required ON and paste this, filling the placeholders with a demo
   email and a webmail login you control:
   > This app uses passwordless email sign-in (a one-time code). To sign in:
   > 1. Tap Sign in and enter the demo email: <<DEMO_EMAIL>>
   > 2. Get the 6-digit code from that inbox at <<WEBMAIL_URL>> (login <<DEMO_EMAIL>> / <<MAILBOX_PASSWORD>>).
   > 3. Enter the code.
   > To verify account deletion: open Profile → tap "Delete my account" → confirm to the
   > confirmation screen. "Sign in with Google" has been removed; the app offers email
   > sign-in only. A screen recording of this flow, captured on a physical iPad, is attached
   > in the Resolution Center reply.
   The ASC "password" field cannot hold a one-time code — put the mailbox login in Notes, above.
4. **Resolution Center reply** (given this is a repeat rejection, reply — don't submit
   silently). Draft, show me BEFORE sending:
   > Thank you for the review. The issues were in our storefront configuration, and have
   > been resolved.
   > 4.8 — "Sign in with Google" has been disabled; the app now offers email sign-in only,
   > so the equivalent-login requirement no longer applies.
   > 2.1(a) — With Google removed, the unresponsive "Google" button no longer appears.
   > 5.1.1(v) — Account deletion is available in-app: sign in, open Profile, tap "Delete my
   > account", and complete the request to confirmation. A screen recording captured on a
   > physical iPad is attached, and reviewer sign-in instructions are in App Review Notes.
5. **HUMAN:** attach the Phase 2 recording to the reply.
6. Only after I confirm recording + reviewer sign-in are in place: Submit for Review (export
   compliance: standard HTTPS only → exempt). Show me the confirmation. Stop.

## Also surface to me (do not action)
- Apple's evidence screenshot `Screenshot-0723-135713.png` in the Resolution Center — open
  and describe it; it shows where the Google button was.
- Developer Program renewal is ~18–19 Aug 2026; confirm auto-renew is ON on the billing
  screen so nothing lapses mid-review.
