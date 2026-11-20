# Release & Deployment Guide for Arrow Escape

This guide provides step-by-step instructions for building, signing, and deploying **Arrow Escape** to the Google Play Store (Android) and Apple App Store (iOS).

Written in simple, beginner-friendly instructions with bilingual explanations (English & সহজ বাংলা).

---

## PART 1: Android Production Build Guide (গুগল প্লে স্টোর রিলিজ)

### Step 1: Create a Release Keystore (আপলোড কীস্টোর তৈরি)

Run the following command in your terminal/PowerShell to generate your private signing key:

```powershell
keytool -genkey -v -keystore D:/ArrowPuzzleGame/android/upload-keystore.jks -storetype JKS -keyalg RSA -keysize 2048 -validity 10000 -alias upload
```

*When prompted:*
- Enter a secure password (e.g., store it safely in your password manager).
- Enter your name/organization when asked.
- **IMPORTANT:** Keep `upload-keystore.jks` completely safe. If lost, you cannot update your app on Google Play!

---

### Step 2: Configure `key.properties` (কী প্রোপার্টিজ সেটআপ)

Create a file named `android/key.properties` (copy from `android/key.properties.example`):

```properties
storePassword=YOUR_KEYSTORE_PASSWORD
keyPassword=YOUR_KEY_PASSWORD
keyAlias=upload
storeFile=upload-keystore.jks
```

*(Note: `key.properties` and `*.jks` are automatically ignored by `.gitignore` so they are never exposed to public Git).*

---

### Step 3: Build Android App Bundle (.aab) & APK (.apk)

Open PowerShell in `d:/ArrowPuzzleGame` and run:

#### 1. Build Google Play Store Bundle (.aab — Recommended for Play Console):
```powershell
flutter build appbundle --release
```
*Output file location:*
`build/app/outputs/bundle/release/app-release.aab`

#### 2. Build Universal APK (ডিভাইসে সরাসরি টেস্ট করার জন্য):
```powershell
flutter build apk --release
```
*Output file location:*
`build/app/outputs/flutter-apk/app-release.apk`

---

### Step 4: Google Play Console Submission Steps (প্লে কনসোলে আপলোড)

1. **Log in:** Go to [Google Play Console](https://play.google.com/console).
2. **Create App:** Click **Create app** > Name: `Arrow Escape: Puzzle Maze` > Game > Free.
3. **Store Listing:** Copy title, short description, and full description from [STORE_LISTING.md](file:///d:/ArrowPuzzleGame/docs/STORE_LISTING.md).
4. **App Graphics:** Upload App Icon (512x512), Feature Graphic (1024x500), and Gameplay Screenshots.
5. **App Content:**
   - **Privacy Policy:** Paste link to your hosted privacy policy (or GitHub Pages link of [PRIVACY_POLICY.md](file:///d:/ArrowPuzzleGame/docs/PRIVACY_POLICY.md)).
   - **Ads:** Select *"Yes, my app contains ads"* (Google AdMob).
   - **Target Audience:** Select Ages 13 and up (or Everyone).
   - **Data Safety:** Declare anonymous analytics and advertising IDs.
6. **Upload Build:** Go to **Release** > **Internal testing** (or **Production**) > Upload `app-release.aab`.
7. **Review & Rollout:** Click **Review Release** and start rollout!

---

## PART 2: iOS Production Build Guide (অ্যাপল অ্যাপ স্টোর রিলিজ)

> **Important Notice for Beginners (জরুরি তথ্য):**  
> Native iOS builds, code signing, and IPA archives require a Mac computer with macOS and Xcode installed. If you are on Windows, you can transfer this project directory to a Mac or use a cloud Mac service (such as Codemagic, GitHub Actions macOS runner, or MacStadium).

### Step 1: Open project in Xcode on Mac
```bash
cd ios
pod install
cd ..
open ios/Runner.xcworkspace
```

### Step 2: Configure Apple Developer Team
1. In Xcode, click **Runner** in the project navigator.
2. Select **Signing & Capabilities**.
3. Under **Team**, select your Apple Developer account.
4. Set Bundle Identifier to: `io.antigravity.arrowpuzzle.arrowPuzzleGame`.

### Step 3: Build IPA Archive
Run in terminal:
```bash
flutter build ipa --release
```
Or in Xcode:
1. Select **Product > Archive**.
2. Once the archive succeeds in the Organizer window, click **Distribute App**.
3. Choose **App Store Connect** > **Upload** > Click **Next** until uploaded to TestFlight.

---

## PART 3: Post-Launch Monitoring Plan (লঞ্চের পরবর্তী তদারকি)

1. **Crash & ANR Monitoring:**
   - Check Google Play Console > Android Vitals daily during the first 2 weeks.
   - Keep Crash rate under 1.09% and ANR rate under 0.47%.
2. **Review & Rating Feedback:**
   - Monitor player reviews. If players find a specific level confusing, note level seeds for difficulty tuning.
3. **AdMob Fill Rate & eCPM:**
   - Check AdMob Dashboard to ensure mediation and ad requests are successfully serving ads without excessive drop-offs.
4. **Content Roadmap:**
   - Phase 11+: Introduce seasonal skin packs (e.g. Winter Frost, Cyberpunk Red), daily challenge tournaments, and bonus chapter packs.
