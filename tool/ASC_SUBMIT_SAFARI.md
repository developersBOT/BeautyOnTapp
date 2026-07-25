# Local agent prompt — submit BeautyOnTApp for App Store review using Safari

Paste everything under the line into a **coding/browser agent running on your Mac**
(Codex CLI, or Claude Code on the Mac). It drives **your own Safari**, which is
already signed in to App Store Connect, using AppleScript (`osascript`) and
screenshots (`screencapture`). It reuses your logged-in session, so there are **no
passwords to enter anywhere**.

One-time Safari setup so AppleScript can drive the page:
- Safari → Settings → Advanced → tick **Show features for web developers**.
- Safari → **Develop** menu → tick **Allow JavaScript from Apple Events**.

Fill in the two placeholders (`<<DEMO_EMAIL>>`, `<<DEMO_PASSWORD>>`) first — a real
customer account on beautyontapp.com the reviewer can sign in with.

---

You are on my Mac and may run shell commands. Drive my **already signed-in Safari**
to resubmit an app for App Store review. Use AppleScript for navigation and clicks
and `screencapture -x /tmp/asc.png` to see the page after each step; describe what
you see and STOP before the final "Submit for Review" for my confirmation. Never
type a password. This is a live production submission — if a page differs from these
steps, screenshot it and ask me instead of guessing.

Navigate with:
    osascript -e 'tell application "Safari" to set URL of front document to "URL"'
Read/click/fill with:
    osascript -e 'tell application "Safari" to do JavaScript "JS_HERE" in front document'
Screenshot with:
    screencapture -x /tmp/asc.png   (then view /tmp/asc.png)

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

3. **App Review Information:**
   - Tick **Sign-In required**.
   - User Name: `<<DEMO_EMAIL>>`
   - Password: `<<DEMO_PASSWORD>>`
   - **Notes:**
     > Account deletion is available in-app: sign in, open the Profile sheet, tap
     > "Delete my account", which opens the deletion request and completes to a
     > confirmation. Third-party "Sign in with Google" has been removed; the app now
     > offers email sign-in only. A screen recording of the deletion flow, captured
     > on a physical device, is attached in the Resolution Center reply.
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
