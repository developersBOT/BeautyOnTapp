# Local agent prompt — submit BeautyOnTApp for App Store review via Chrome

Paste everything under the line into a **browser-capable agent running on your Mac**
(Codex CLI with browser control, Claude Code with a Playwright/Chrome-DevTools MCP,
or any Playwright driver). It drives **your own Chrome that is already logged into
App Store Connect**, so there are no credentials to enter.

Before you start it: open Chrome, sign in at https://appstoreconnect.apple.com,
and — so an agent can attach to that exact window — quit Chrome and relaunch it once with:

    /Applications/Google\ Chrome.app/Contents/MacOS/Google\ Chrome \
      --remote-debugging-port=9222 --profile-directory="Default"

Then log in again if prompted. The agent connects to `http://localhost:9222`.

Fill in the two placeholders (`<<DEMO_EMAIL>>`, `<<DEMO_PASSWORD>>`) first — a real
customer account on beautyontapp.com the reviewer can sign in with.

---

You are operating my Google Chrome on macOS via the Chrome DevTools Protocol on
`http://localhost:9222`. Chrome is already signed in to App Store Connect. Do the
steps below carefully. Take a screenshot after each step and tell me what you see.
Do NOT enter any password anywhere. STOP and ask me before the final "Submit".

App: **BeautyOnTApp**, iOS version **1.1.2** (currently in a Rejected state).

1. Go to https://appstoreconnect.apple.com/apps , open **BeautyOnTApp**, then the
   iOS **1.1.2** version page.

2. **Build:** in the Build section, confirm build **8** is attached (or attach the
   newest build whose status is "Ready to Submit"/valid — build **9** if it has
   finished processing). If no valid build is present, stop and tell me.

3. **App Review Information:**
   - Tick **Sign-In required**.
   - User Name: `<<DEMO_EMAIL>>`
   - Password: `<<DEMO_PASSWORD>>`
   - In **Notes**, paste:
     > Account deletion is available in-app: sign in, open the Profile sheet, and
     > tap "Delete my account", which opens the deletion request and completes to a
     > confirmation. Third-party "Sign in with Google" has been removed; the app now
     > offers email sign-in only. A screen recording of the deletion flow, captured
     > on a physical device, is attached in the Resolution Center reply.
   - Save.

4. **Resolution Center reply** (left sidebar → Resolution Center → the open thread):
   paste this, then tell me BEFORE sending:
   > Thank you for the review. All three issues were in our storefront, not the app
   > binary, and have been resolved.
   >
   > Guideline 4.8 — Third-party "Sign in with Google" has been removed. The app now
   > offers email sign-in only, so the equivalent-login requirement no longer applies.
   >
   > Guideline 2.1(a) — The unresponsive "Google" button no longer exists, as that
   > sign-in provider has been removed.
   >
   > Guideline 5.1.1(v) — Account deletion is available in-app: sign in, open the
   > account Profile, and select "Delete my account", which completes to confirmation.
   > A screen recording captured on a physical device is attached, and a demo account
   > is provided in App Review Information.

5. **HUMAN STEP — do not skip, cannot be automated:** I must attach the
   **screen recording** (sign in → Profile → Delete my account → confirmation,
   filmed on a physical iPhone/iPad) to the Resolution Center reply. Pause here and
   let me attach it and hit send on the reply.

6. **Submit:** back on the version page, once I confirm the recording is attached,
   click **Add for Review** / **Submit for Review** and complete the submission
   questions (export compliance = the app uses only standard HTTPS encryption →
   "exempt"). Show me the final confirmation screen. Stop.

If anything on a page differs from these steps, screenshot it and ask me rather than
guessing — this is a live production submission.
