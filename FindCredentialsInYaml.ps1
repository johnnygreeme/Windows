# [~] ============================================================================== [~]
# [~] FindCredentialsInYaml.ps1
# [~] ============================================================================== [~]
# Description:
#   Searches all .yaml and .yml files under C:\Users (recursively)
#   for patterns that resemble usernames or passwords based on
#   commonly used configuration keys (e.g., DB_USER, POSTGRES_PASSWORD).
#
#   Uses regex to extract values following known credential keys.
#   Outputs file path along with any detected username or password.
#
# Note:
#   This script is intended for security audits or personal use
#   on systems you own or have explicit permission to scan.
#   It does NOT parse YAML structurally—only uses regex,
#   so false positives (e.g., from comments) are possible.
# [~] ============================================================================== [~]

# Define target directory and file extensions
$SearchPath = "C:\Users"
$IncludeExtensions = "*.yaml", "*.yml"

# Regex pattern to match common credential-related keys and their values
# Group 2 = username-like value, Group 4 = password-like value
$CredentialPattern = '(?im)(username|login_user|PGADMIN_DEFAULT_EMAIL|POSTGRES_USER|MYSQL_USER|DB_USER|DB_USERNAME):\s*(\S+)|(password|login_password|PGADMIN_DEFAULT_PASSWORD|POSTGRES_PASSWORD|MYSQL_PASSWORD|DB_PASS|DB_PASSWORD):\s*(\S+)'

Write-Host "[*] Scanning for credentials in YAML files under $SearchPath..." -ForegroundColor Cyan

# Recursively find all YAML/YML files (suppressing access errors)
Get-ChildItem -Path $SearchPath -Recurse -Include $IncludeExtensions -ErrorAction SilentlyContinue | ForEach-Object {
    $FilePath = $_.FullName

    # Read entire file as a single string for efficient regex matching
    try {
        $Content = Get-Content -Path $FilePath -Raw -ErrorAction Stop
    } catch {
        # Skip unreadable files (e.g., locked or permission-denied)
        return
    }

    # Perform regex match across the whole file
    $CredentialMatches = [regex]::Matches($Content, $CredentialPattern)

    # Skip if no matches found
    if ($CredentialMatches.Count -eq 0) { return }

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

    # Output result if at least one credential field was found
    if ($Username -or $Password) {
        Write-Host ("File: `"{0}`" | User: `"{1}`" | Pass: `"{2}`"" -f $FilePath, $Username, $Password) -ForegroundColor Yellow
    }
}

Write-Host "[+] Scan completed." -ForegroundColor Green
