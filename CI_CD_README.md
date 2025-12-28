# Cluck Rush - CI/CD Setup Guide

This guide explains how to set up automated Android builds with GitHub Actions.

---

## 📋 Overview

The CI/CD pipeline automatically:
- ✅ Builds **signed APK** files (split by ABI for smaller downloads)
- ✅ Builds **signed AAB** file (for Google Play Store upload)
- ✅ Uses keystore from GitHub Secrets (secure, no secrets exposed)
- ✅ Cleans up sensitive files after build
- ✅ Uploads artifacts for download

---

## 🔐 Privacy & Security Statement

### Keystore Generation Script (`scripts/generate-keystore.ps1`)

**This script is safe and privacy-respecting:**

| What it does | What it does NOT do |
|--------------|---------------------|
| ✅ Prompts for company details manually | ❌ Does NOT read system information |
| ✅ Generates keystore locally | ❌ Does NOT access IP address |
| ✅ Outputs base64 for GitHub Secrets | ❌ Does NOT collect location data |
| ✅ All inputs are user-provided | ❌ Does NOT auto-fill any values |
| ✅ Clears passwords from memory | ❌ Does NOT send data anywhere |

---

## 🚀 Quick Start

### Step 1: Generate a Keystore

Run the keystore generation script:

```powershell
# Navigate to project root
cd C:\Users\YourName\Desktop\Cluck

# Run the script
.\scripts\generate-keystore.ps1
```

The script will prompt you for:
1. **Organization Name** (e.g., "Nura Technologies LLC")
2. **Organizational Unit** (e.g., "Mobile Development")
3. **City** (e.g., "San Francisco")
4. **State/Province** (e.g., "California")
5. **Country Code** (e.g., "US")
6. **Key Alias** (e.g., "nura-release-key")
7. **Keystore Password** (min 6 characters)
8. **Key Password** (min 6 characters)

**Output files:**
- `release-keystore.jks` - Your signing keystore (BACKUP THIS!)
- `keystore-base64.txt` - Base64 encoded keystore for GitHub

### Step 2: Add GitHub Secrets

1. Go to your GitHub repository
2. Navigate to **Settings** → **Secrets and variables** → **Actions**
3. Click **New repository secret** and add these 4 secrets:

| Secret Name | Value |
|-------------|-------|
| `NURA_KEYSTORE_BASE64` | Contents of `keystore-base64.txt` |
| `NURA_KEYSTORE_PASSWORD` | Your keystore password |
| `NURA_KEY_ALIAS` | Your key alias (e.g., "nura-release-key") |
| `NURA_KEY_PASSWORD` | Your key password |

### Step 3: Secure Your Keystore

After adding secrets to GitHub:

```powershell
# Delete the base64 file (it's now in GitHub Secrets)
Remove-Item keystore-base64.txt

# Move keystore to a secure backup location
Move-Item release-keystore.jks "C:\SecureBackup\cluck-rush-keystore.jks"
```

⚠️ **IMPORTANT:** If you lose your keystore, you cannot update your app on the Play Store!

### Step 4: Push and Build

```bash
git add .
git commit -m "Add CI/CD workflow"
git push origin main
```

The workflow triggers automatically on:
- Push to `main` or `master` branches
- Push to `release/*` branches
- Pull requests to `main` or `master`
- Manual trigger from Actions tab

---

## 📦 Download Build Artifacts

1. Go to **Actions** tab in your GitHub repository
2. Click on the latest workflow run
3. Scroll down to **Artifacts**
4. Download:
   - `cluck-rush-apk-{sha}` - Contains APK files for each architecture
   - `cluck-rush-aab-{sha}` - Contains AAB file for Play Store

---

## 🔧 Workflow Configuration

The workflow is located at `.github/workflows/android-release.yml`.

### Key Features:

```yaml
# Triggers
on:
  push:
    branches: [main, master, release/*]
  pull_request:
    branches: [main, master]
  workflow_dispatch:  # Manual trigger

# Environment
env:
  FLUTTER_VERSION: '3.24.0'
  JAVA_VERSION: '17'
```

### Build Steps:

1. **Checkout code**
2. **Setup Java 17**
3. **Setup Flutter**
4. **Get dependencies** (`flutter pub get`)
5. **Decode keystore** from GitHub Secrets
6. **Build APK** (`flutter build apk --release --split-per-abi`)
7. **Build AAB** (`flutter build appbundle --release`)
8. **Cleanup** sensitive files
9. **Upload artifacts**

---

## 🛡️ Security Features

| Feature | Description |
|---------|-------------|
| **Base64 Encoding** | Keystore is stored as base64 in GitHub Secrets |
| **Runtime Decoding** | Keystore is decoded only during build |
| **Secret Masking** | GitHub automatically masks secret values in logs |
| **Post-build Cleanup** | Keystore and key.properties are deleted after build |
| **Gitignore Protection** | Keystore files are gitignored |

---

## 📁 File Structure

```
Cluck/
├── .github/
│   └── workflows/
│       └── android-release.yml    # GitHub Actions workflow
├── android/
│   ├── app/
│   │   ├── build.gradle.kts       # Signing configuration
│   │   └── proguard-rules.pro     # ProGuard/R8 rules
│   └── key.properties             # Created by CI (gitignored)
├── scripts/
│   └── generate-keystore.ps1      # Keystore generation script
├── .gitignore                     # Excludes sensitive files
└── CI_CD_README.md               # This file
```

---

## 🐛 Troubleshooting

### Build fails with "Keystore not found"

Ensure all 4 secrets are correctly set in GitHub:
- `NURA_KEYSTORE_BASE64`
- `NURA_KEYSTORE_PASSWORD`
- `NURA_KEY_ALIAS`
- `NURA_KEY_PASSWORD`

### Build fails with "R8: Missing class com.google.android.play.core..."

The ProGuard rules in `android/app/proguard-rules.pro` should handle this. If not, ensure the file exists and contains the `-dontwarn` rules for Play Core classes.

### Local release build fails

For local release builds without signing:
```bash
flutter build apk --debug
```

For local release builds with signing, create `android/key.properties` manually:
```properties
storePassword=YOUR_KEYSTORE_PASSWORD
keyPassword=YOUR_KEY_PASSWORD
keyAlias=YOUR_KEY_ALIAS
storeFile=PATH_TO_YOUR_KEYSTORE.jks
```

### APK/AAB not signed

Check the workflow logs for the "Decode Keystore" step. It should show:
```
✅ Keystore decoded successfully
📦 Keystore size: XXXX bytes
✅ key.properties created successfully
```

---

## 📝 Updating the Workflow

To change Flutter version:
```yaml
env:
  FLUTTER_VERSION: '3.25.0'  # Update to desired version
```

To change trigger branches:
```yaml
on:
  push:
    branches:
      - main
      - develop  # Add more branches
```

---

## 🔗 Resources

- [Flutter Android Deployment](https://docs.flutter.dev/deployment/android)
- [GitHub Actions Documentation](https://docs.github.com/en/actions)
- [Android App Signing](https://developer.android.com/studio/publish/app-signing)

---

## ⚠️ Important Reminders

1. **NEVER** commit keystore files (`.jks`, `.keystore`) to version control
2. **NEVER** commit `key.properties` to version control
3. **BACKUP** your keystore file securely - it cannot be recovered!
4. **ROTATE** secrets if you suspect they've been compromised
5. The keystore generated by the script is valid for **10,000 days (~27 years)**

