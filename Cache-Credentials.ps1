
function Set-CachedCredentials($name) {
    Read-Host -Prompt "Username" | Out-File $env:LocalAppData\$name-username.txt
    Read-Host -Prompt "Password" -AsSecureString | ConvertFrom-SecureString | Out-File $env:LocalAppData\$name-encryptedPassword.txt
}

function Get-CachedCredentials($name) {
    $securePassword = gc $env:LocalAppData\$name-encryptedPassword.txt | ConvertTo-SecureString
    $username = gc $env:LocalAppData\$name-username.txt
    Write-Output (New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $username, $securePassword)
}