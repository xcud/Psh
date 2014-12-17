# work in progress, make a net connection without mapping a drive
Function New-NetworkConnection
{
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true)] $Hostname,
        [Parameter()] [System.Management.Automation.PSCredential] $Credential
    );

    if($Credential) { 
        $username = $Credential.UserName 
        $password = $Credential.GetNetworkCredential().Password
    }
    
    $net = new-object -ComObject WScript.Network
    $net.MapNetworkDrive($null, ("\\{0}" -f $Hostname), $false, $username, $password)
}