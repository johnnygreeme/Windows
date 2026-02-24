$paths = "C:\Windows\System32\GroupPolicy", "C:\Windows\SYSVOL\sysvol"
$ext = "*.ps1","*.bat","*.cmd","*.vbs","*.js","*.xml","*.ini","*.txt"

$files = Get-ChildItem -Path $paths -Include $ext -Recurse -ErrorAction SilentlyContinue

foreach ($file in $files) {
    $userLines = Select-String -Path $file.FullName -Pattern "username|user|login|email|mail|admin|account|uid" -CaseSensitive:$false -ErrorAction SilentlyContinue
    $passLines = Select-String -Path $file.FullName -Pattern "password|passwd|pass|secret|pwd|token" -CaseSensitive:$false -ErrorAction SilentlyContinue

    if ($userLines -or $passLines) {
        Write-Output "File: `"$($file.FullName)`""
        
        if ($userLines) {
            foreach ($line in $userLines) {
                Write-Output "User: `"$($line.Line)`""
            }
        } else {
            Write-Output "User: `"-`""
        }

        if ($passLines) {
            foreach ($line in $passLines) {
                Write-Output "Pass: `"$($line.Line)`""
            }
        } else {
            Write-Output "Pass: `"-`""
        }
    }
}
