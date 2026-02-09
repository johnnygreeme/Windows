# [~] ============================================================================== [~]
# [~] FindCredentialsInClipboard.ps1
# [~] ============================================================================== [~]
# Description:
#   Analyzes the current clipboard content for patterns that resemble
#   usernames or passwords based on commonly used configuration keys
#   (e.g., DB_USER, POSTGRES_PASSWORD, etc.).
#
#   Uses the same regex logic as the file-based scanner.
#   Outputs any detected username or password.
#
# Requirements:
#   - PowerShell 5.1+ (Windows) with access to Windows Forms or WPF clipboard APIs.
#   - Works only on Windows (clipboard support is OS-specific).
#
# Note:
#   This script is intended for security audits or personal use.
#   It does NOT parse structured data (e.g., YAML/JSON) — only applies regex.
#   False positives (e.g., from comments or examples) are possible.
# [~] ============================================================================== [~]

# Ensure clipboard access is available (Windows only)
if (-not ("System.Windows.Forms.Clipboard" -as [type])) {
    Add-Type -AssemblyName System.Windows.Forms
}

# Get clipboard text
try {
    $ClipboardContent = [System.Windows.Forms.Clipboard]::GetText()
} catch {
    Write-Host "[!] Failed to read clipboard. Make sure you're running on Windows and clipboard contains text." -ForegroundColor Red
    exit 1
}

if ([string]::IsNullOrWhiteSpace($ClipboardContent)) {
    Write-Host "[!] Clipboard is empty or contains no text." -ForegroundColor Yellow
    exit 0
}

Write-Host "[*] Analyzing clipboard content for credentials..." -ForegroundColor Cyan

# Regex pattern (same as in file scanner)
$CredentialPattern = '(?im)(username|login_user|PGADMIN_DEFAULT_EMAIL|POSTGRES_USER|MYSQL_USER|DB_USER|DB_USERNAME):\s*(\S+)|(password|login_password|PGADMIN_DEFAULT_PASSWORD|POSTGRES_PASSWORD|MYSQL_PASSWORD|DB_PASS|DB_PASSWORD):\s*(\S+)'

# Perform regex match on clipboard text
$CredentialMatches = [regex]::Matches($ClipboardContent, $CredentialPattern)

if ($CredentialMatches.Count -eq 0) {
    Write-Host "[+] No credential-like patterns found in clipboard." -ForegroundColor Green
    exit 0
}

# Initialize extracted values
$Username = $null
$Password = $null

# Extract the latest (or only) username and password found
foreach ($Match in $CredentialMatches) {
    if ($Match.Groups[2].Success) {
        $Username = $Match.Groups[2].Value
    }
    elseif ($Match.Groups[4].Success) {
        $Password = $Match.Groups[4].Value
    }
}

# Output result if anything was found
if ($Username -or $Password) {
    Write-Host ("[!] Credentials detected:`n    User: `"{0}`"`n    Pass: `"{1}`"" -f $Username, $Password) -ForegroundColor Magenta
} else {
    Write-Host "[+] Patterns matched, but no usable values extracted." -ForegroundColor Green
}
