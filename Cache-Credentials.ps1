
function Set-CachedCredentials() {
    Read-Host -Prompt "Username" | Out-File $env:LocalAppData\username.txt
    Read-Host -Prompt "Password" -AsSecureString | ConvertFrom-SecureString | Out-File $env:LocalAppData\encryptedPassword.txt
}

function Get-CachedCredentials() {
    $securePassword = gc $env:LocalAppData\encryptedPassword.txt | ConvertTo-SecureString
    $username = gc $env:LocalAppData\username.txt
    Write-Output (New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $username, $securePassword)
}