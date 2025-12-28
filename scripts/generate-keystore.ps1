# ============================================================
# CLUCK RUSH - Keystore Generation Script
# ============================================================
# This script generates a JKS keystore for signing Android apps.
#
# PRIVACY GUARANTEE:
# - This script does NOT read any system information
# - This script does NOT access IP, location, or user data
# - This script does NOT auto-fill any values
# - All inputs are manually provided by the user
#
# REQUIREMENTS:
# - Java JDK installed (keytool command available)
# - PowerShell 5.0 or later
# ============================================================

Write-Host ""
Write-Host "============================================================" -ForegroundColor Cyan
Write-Host "  CLUCK RUSH - Keystore Generation Script" -ForegroundColor Cyan
Write-Host "============================================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "This script will generate a signing keystore for your app." -ForegroundColor Yellow
Write-Host "All information must be entered manually - nothing is auto-filled." -ForegroundColor Yellow
Write-Host ""
Write-Host "PRIVACY: This script does NOT collect system, IP, or location data." -ForegroundColor Green
Write-Host ""

# ============================================================
# CHECK FOR KEYTOOL
# ============================================================
Write-Host "Checking for Java keytool..." -ForegroundColor Gray
try {
    $keytoolVersion = keytool -help 2>&1 | Select-String "keytool"
    if (-not $keytoolVersion) {
        throw "keytool not found"
    }
    Write-Host "[OK] keytool found" -ForegroundColor Green
} catch {
    Write-Host "[ERROR] Java keytool not found. Please install Java JDK." -ForegroundColor Red
    Write-Host "Download from: https://adoptium.net/" -ForegroundColor Yellow
    exit 1
}

Write-Host ""
Write-Host "============================================================" -ForegroundColor Cyan
Write-Host "  COMPANY INFORMATION (Required for Certificate)" -ForegroundColor Cyan
Write-Host "============================================================" -ForegroundColor Cyan
Write-Host ""

# ============================================================
# COLLECT COMPANY INFORMATION (Manual Input Only)
# ============================================================

# 1. Organization Name
Write-Host "1. Organization/Company Name" -ForegroundColor White
Write-Host "   Example: Nura Technologies LLC" -ForegroundColor DarkGray
$orgName = Read-Host "   Enter Organization Name"
if ([string]::IsNullOrWhiteSpace($orgName)) {
    Write-Host "[ERROR] Organization name is required." -ForegroundColor Red
    exit 1
}

Write-Host ""

# 2. Organizational Unit
Write-Host "2. Organizational Unit/Department" -ForegroundColor White
Write-Host "   Example: Mobile Development" -ForegroundColor DarkGray
$orgUnit = Read-Host "   Enter Organizational Unit"
if ([string]::IsNullOrWhiteSpace($orgUnit)) {
    Write-Host "[ERROR] Organizational unit is required." -ForegroundColor Red
    exit 1
}

Write-Host ""

# 3. City/Locality
Write-Host "3. City/Locality" -ForegroundColor White
Write-Host "   Example: San Francisco" -ForegroundColor DarkGray
$city = Read-Host "   Enter City"
if ([string]::IsNullOrWhiteSpace($city)) {
    Write-Host "[ERROR] City is required." -ForegroundColor Red
    exit 1
}

Write-Host ""

# 4. State/Province
Write-Host "4. State/Province" -ForegroundColor White
Write-Host "   Example: California" -ForegroundColor DarkGray
$state = Read-Host "   Enter State/Province"
if ([string]::IsNullOrWhiteSpace($state)) {
    Write-Host "[ERROR] State/Province is required." -ForegroundColor Red
    exit 1
}

Write-Host ""

# 5. Country Code (2-letter)
Write-Host "5. Country Code (2 letters)" -ForegroundColor White
Write-Host "   Example: US, UK, DE, JP" -ForegroundColor DarkGray
$country = Read-Host "   Enter 2-Letter Country Code"
if ([string]::IsNullOrWhiteSpace($country) -or $country.Length -ne 2) {
    Write-Host "[ERROR] Country code must be exactly 2 letters." -ForegroundColor Red
    exit 1
}
$country = $country.ToUpper()

Write-Host ""
Write-Host "============================================================" -ForegroundColor Cyan
Write-Host "  KEYSTORE CREDENTIALS" -ForegroundColor Cyan
Write-Host "============================================================" -ForegroundColor Cyan
Write-Host ""

# 6. Key Alias
Write-Host "6. Key Alias (identifier for your key)" -ForegroundColor White
Write-Host "   Example: nura-release-key" -ForegroundColor DarkGray
$keyAlias = Read-Host "   Enter Key Alias"
if ([string]::IsNullOrWhiteSpace($keyAlias)) {
    Write-Host "[ERROR] Key alias is required." -ForegroundColor Red
    exit 1
}

Write-Host ""

# 7. Keystore Password
Write-Host "7. Keystore Password (min 6 characters)" -ForegroundColor White
Write-Host "   This password protects the keystore file" -ForegroundColor DarkGray
$keystorePassword = Read-Host "   Enter Keystore Password" -AsSecureString
$keystorePasswordPlain = [Runtime.InteropServices.Marshal]::PtrToStringAuto([Runtime.InteropServices.Marshal]::SecureStringToBSTR($keystorePassword))
if ($keystorePasswordPlain.Length -lt 6) {
    Write-Host "[ERROR] Password must be at least 6 characters." -ForegroundColor Red
    exit 1
}

Write-Host ""

# 8. Key Password
Write-Host "8. Key Password (min 6 characters)" -ForegroundColor White
Write-Host "   This password protects the key itself (can be same as keystore password)" -ForegroundColor DarkGray
$keyPassword = Read-Host "   Enter Key Password" -AsSecureString
$keyPasswordPlain = [Runtime.InteropServices.Marshal]::PtrToStringAuto([Runtime.InteropServices.Marshal]::SecureStringToBSTR($keyPassword))
if ($keyPasswordPlain.Length -lt 6) {
    Write-Host "[ERROR] Password must be at least 6 characters." -ForegroundColor Red
    exit 1
}

Write-Host ""

# ============================================================
# GENERATE KEYSTORE
# ============================================================

$keystoreFile = "release-keystore.jks"
$dname = "CN=$orgName, OU=$orgUnit, O=$orgName, L=$city, ST=$state, C=$country"

Write-Host "============================================================" -ForegroundColor Cyan
Write-Host "  GENERATING KEYSTORE" -ForegroundColor Cyan
Write-Host "============================================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Distinguished Name: $dname" -ForegroundColor Gray
Write-Host ""

# Remove existing keystore if present
if (Test-Path $keystoreFile) {
    Remove-Item $keystoreFile -Force
}

# Generate keystore using keytool
try {
    # Use the call operator & which handles arguments with spaces correctly
    & keytool `
        -genkeypair `
        -v `
        -keystore $keystoreFile `
        -alias $keyAlias `
        -keyalg RSA `
        -keysize 2048 `
        -validity 10000 `
        -storepass $keystorePasswordPlain `
        -keypass $keyPasswordPlain `
        -dname "$dname"
    
    if ($LASTEXITCODE -ne 0) {
        throw "keytool returned exit code $LASTEXITCODE"
    }
    
    if (-not (Test-Path $keystoreFile)) {
        throw "Keystore file was not created"
    }
    
    Write-Host "[OK] Keystore generated successfully!" -ForegroundColor Green
    
} catch {
    Write-Host "[ERROR] Failed to generate keystore: $_" -ForegroundColor Red
    exit 1
}

Write-Host ""

# ============================================================
# ENCODE KEYSTORE TO BASE64
# ============================================================

Write-Host "============================================================" -ForegroundColor Cyan
Write-Host "  ENCODING KEYSTORE TO BASE64" -ForegroundColor Cyan
Write-Host "============================================================" -ForegroundColor Cyan
Write-Host ""

$keystoreBytes = [System.IO.File]::ReadAllBytes($keystoreFile)
$keystoreBase64 = [Convert]::ToBase64String($keystoreBytes)

# Save base64 to file
$base64File = "keystore-base64.txt"
$keystoreBase64 | Out-File -FilePath $base64File -Encoding ASCII -NoNewline

Write-Host "[OK] Base64 encoding saved to: $base64File" -ForegroundColor Green
Write-Host ""

# ============================================================
# OUTPUT GITHUB SECRETS INSTRUCTIONS
# ============================================================

Write-Host "============================================================" -ForegroundColor Green
Write-Host "  GITHUB SECRETS SETUP INSTRUCTIONS" -ForegroundColor Green
Write-Host "============================================================" -ForegroundColor Green
Write-Host ""
Write-Host "Add the following secrets to your GitHub repository:" -ForegroundColor Yellow
Write-Host "  Settings > Secrets and variables > Actions > New repository secret" -ForegroundColor Gray
Write-Host ""
Write-Host "============================================================" -ForegroundColor White

Write-Host ""
Write-Host "SECRET 1: NURA_KEYSTORE_BASE64" -ForegroundColor Cyan
Write-Host "  Value: (contents of $base64File - DO NOT SHARE!)" -ForegroundColor Gray
Write-Host ""

Write-Host "SECRET 2: NURA_KEYSTORE_PASSWORD" -ForegroundColor Cyan
Write-Host "  Value: (your keystore password - DO NOT SHARE!)" -ForegroundColor Gray
Write-Host ""

Write-Host "SECRET 3: NURA_KEY_ALIAS" -ForegroundColor Cyan
Write-Host "  Value: $keyAlias" -ForegroundColor White
Write-Host ""

Write-Host "SECRET 4: NURA_KEY_PASSWORD" -ForegroundColor Cyan
Write-Host "  Value: (your key password - DO NOT SHARE!)" -ForegroundColor Gray
Write-Host ""

Write-Host "============================================================" -ForegroundColor White
Write-Host ""

# ============================================================
# SECURITY REMINDERS
# ============================================================

Write-Host "============================================================" -ForegroundColor Red
Write-Host "  SECURITY REMINDERS" -ForegroundColor Red
Write-Host "============================================================" -ForegroundColor Red
Write-Host ""
Write-Host "1. NEVER commit the keystore (.jks) file to version control" -ForegroundColor Yellow
Write-Host "2. NEVER share your passwords with anyone" -ForegroundColor Yellow
Write-Host "3. BACKUP your keystore file securely - if lost, you cannot update your app!" -ForegroundColor Yellow
Write-Host "4. DELETE the base64 file after adding it to GitHub Secrets" -ForegroundColor Yellow
Write-Host "5. The keystore is valid for 10,000 days (~27 years)" -ForegroundColor Gray
Write-Host ""

# ============================================================
# FILES GENERATED
# ============================================================

Write-Host "============================================================" -ForegroundColor Cyan
Write-Host "  FILES GENERATED" -ForegroundColor Cyan
Write-Host "============================================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "  1. $keystoreFile - Your signing keystore (KEEP SAFE!)" -ForegroundColor White
Write-Host "  2. $base64File - Base64 encoded keystore for GitHub Secrets" -ForegroundColor White
Write-Host ""
Write-Host "After setting up GitHub Secrets, delete these files:" -ForegroundColor Yellow
Write-Host "  - $base64File (sensitive)" -ForegroundColor Gray
Write-Host "  - Move $keystoreFile to a secure backup location" -ForegroundColor Gray
Write-Host ""

Write-Host "============================================================" -ForegroundColor Green
Write-Host "  KEYSTORE GENERATION COMPLETE!" -ForegroundColor Green
Write-Host "============================================================" -ForegroundColor Green
Write-Host ""

# Clear sensitive variables from memory
$keystorePasswordPlain = $null
$keyPasswordPlain = $null
[System.GC]::Collect()

