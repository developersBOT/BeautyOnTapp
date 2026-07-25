# Local agent prompt — submit BeautyOnTApp for App Store review using Chrome

Paste everything under the line into a **coding/browser agent running on your Mac**
(Codex CLI, or Claude Code on the Mac with a Playwright / Chrome-DevTools MCP). It
drives **your own Chrome**, already signed in to App Store Connect, over the Chrome
DevTools Protocol. It reuses your logged-in session, so there are **no passwords to
enter anywhere**.

One-time setup so an agent can attach to your logged-in window — quit Chrome fully,
then relaunch it once from Terminal:

    /Applications/Google\ Chrome.app/Contents/MacOS/Google\ Chrome \
      --remote-debugging-port=9222 --profile-directory="Default"

Log in again at https://appstoreconnect.apple.com if prompted. The agent connects to
`http://localhost:9222` (e.g. Playwright `chromium.connectOverCDP('http://localhost:9222')`,
or `chrome-remote-interface`).

Fill in the two placeholders (`<<DEMO_EMAIL>>`, `<<DEMO_PASSWORD>>`) first — a real
customer account on beautyontapp.com the reviewer can sign in with.

---

You are on my Mac. Connect to my already signed-in Chrome via the DevTools Protocol
at `http://localhost:9222` (do not launch a fresh, logged-out browser). Drive it to
resubmit an app for App Store review. Take a screenshot after each step and describe
what you see. Never type a password. STOP before the final "Submit for Review" for my
confirmation. This is a live production submission — if a page differs from these
steps, screenshot it and ask me instead of guessing.

### What is being fixed (context — do not change app code)
Apple rejected iOS **1.1.2 (8)**. All three reasons were fixed on the Shopify
storefront, not in the app binary:
- 4.8 Login Services + 2.1(a): "Sign in with Google" was **disabled in Shopify →
  Settings → Customer accounts**. Nothing to change in the app.
- 5.1.1(v): account deletion is reachable in-app via the Profile sheet →
  **"Delete my account"**.

### DO NOT REMOVE ANYTHING FROM THE APP
The only removal (Google sign-in) is already done in Shopify settings. **Do NOT
remove the "Delete my account" button** — it is the only in-app path to account
deletion and Apple requires it; removing it causes another 5.1.1(v) rejection.
There is no app-code change to make here.

### Submission steps
1. Go to https://appstoreconnect.apple.com/apps , open **BeautyOnTApp**, then the
   iOS **1.1.2** version page (state should be Rejected/editable).

2. **Build:** confirm build **8** is attached, or attach the newest valid build
   (build **9** if it has finished processing). If none is valid, stop and tell me.

3. **App Review Information — reviewer sign-in (IMPORTANT):** the app login is email OTP
   (passwordless), so there is NO password to enter — do not invent one. The reviewer must
   still be able to sign in to verify account deletion. Set up ONE of: a demo customer email
   whose inbox the reviewer can open (put the webmail login in Notes); a fixed reviewer code
   the backend accepts for a demo email (documented in Notes); or confirm with the developer
   how a reviewer completes the OTP. Then in **Notes** state the reviewer sign-in method plus:
     > Account deletion is available in-app: sign in, open the Profile sheet, tap
     > "Delete my account", which opens the deletion request and completes to a
     > confirmation. "Sign in with Google" has been removed; the app now offers email
     > sign-in only. A screen recording captured on a physical device is attached in the
     > Resolution Center reply.
   - Save.

4. **Resolution Center** (left sidebar → Resolution Center → open thread): paste
   this reply, then tell me BEFORE sending:
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

5. **HUMAN STEP — cannot be automated:** I must attach the **screen recording**
   (open app → sign in → Profile → Delete my account → confirmation, filmed on a
   physical iPhone) to the Resolution Center reply. Pause; let me attach it and send.

6. **Submit:** after I confirm the recording is attached, click **Add for Review /
   Submit for Review** and answer the submission questions (export compliance: the
   app uses only standard HTTPS → **exempt**). Show me the final confirmation. Stop.
