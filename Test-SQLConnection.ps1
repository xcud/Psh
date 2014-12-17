Function Test-SQLConnection
{
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true)] $DatabaseInstance,
        [Parameter(ParameterSetName="SQL", Mandatory=$true)] [System.Management.Automation.PSCredential] $Credential,
        [Parameter(ParameterSetName="Windows")] [System.Management.Automation.SwitchParameter] $UserWindowsAuth
    );

    if($UserWindowsAuth.IsPresent) {
        $connectionString = "Data Source={0};Integrated Security=true;Initial Catalog=master;Connect Timeout=3;" -f $DatabaseInstance
    }
    else {
        $connectionString = "Data Source={0};Integrated Security=false;Initial Catalog=master;Connect Timeout=3;User={1};Password={2}" -f $DatabaseInstance, $Credential.UserName, $Credential.GetNetworkCredential().Password
    }
    $sqlConn = New-Object System.Data.SqlClient.SqlConnection $connectionString
    $sqlConn.Open()
    if ($sqlConn.State -eq 'Open')
    {
        $sqlConn.Close();
        Write-Output $true
    }
    else {
        Write-Output $false
    }
 }
