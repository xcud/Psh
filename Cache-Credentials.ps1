
function Set-CachedCredential($name) {
    $cred = Get-Credential
    $cred.UserName | Out-File $env:LocalAppData\$name.username.txt
    $cred.Password | ConvertFrom-SecureString | Out-File $env:LocalAppData\$name.password.encrypted.txt
}

function Get-CachedCredential($name) {
    $securePassword = gc $env:LocalAppData\$name.password.encrypted.txt | ConvertTo-SecureString
    $username = gc $env:LocalAppData\$name.username.txt
    Write-Output (New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $username, $securePassword)
}