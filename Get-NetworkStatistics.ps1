<#
.Synopsis
  Splits an ipaddress string from 'netstat' into its respective address/port parts.
.Example
	PS> Split-AddressPort [fe80::4442:f854:4707:3c0f%15]:1900
	fe80::4442:f854:4707:3c0f%15
	1900
#>
function Split-AddressPort([string]$ipaddressAsString) {
	$ipaddress = $ipaddressAsString -as [ipaddress]
	if ($ipaddress.AddressFamily -eq 'InterNetworkV6') 
    { 
       $retvalAddress = $ipaddress.IPAddressToString 
       $retvalPort = $ipaddressAsString.split('\]:')[-1] 
    } 
    else 
    { 
        $retvalAddress = $ipaddressAsString.split(':')[0] 
        $retvalPort = $ipaddressAsString.split(':')[-1] 
    }  
	return @($retvalAddress, $retvalPort);
}

<#
.Synopsis
	PowerShellized netstat. Building on Shay Levy's work
		Shay Levy's Blog => http://blogs.microsoft.co.il/blogs/scriptfanatic/
.Example
	PS> Get-NetworkStatistics skype | ft -AutoSize
.Example	
	PS> Get-NetworkStatistics -ProcessName system
.Example	
	PS> Get-NetworkStatistics -Address 192.168.1.1
.Example	
	PS> Get-NetworkStatistics -Port 80
#>
function Get-NetworkStatistics 
{ 
	param(	
		[string]$ProcessName, 
		[net.ipaddress]$Address, 
		[int]$Port = -1,
		[int]$ProcessId = -1
	)

	$properties = 'Protocol','LocalAddress','LocalPort', 
				  'RemoteAddress','RemotePort','State','ProcessName','PID' 

    $netstatEntries = netstat -ano | Select-String -Pattern '\s+(TCP|UDP)'

	foreach($_ in $netstatEntries) {
	
        $item = $_.line.split(" ",[System.StringSplitOptions]::RemoveEmptyEntries) 

        if($item[1] -notmatch '^\[::') 
        {            
			($localAddress, $localPort) = Split-AddressPort($item[1])			
			($remoteAddress, $remotePort) = Split-AddressPort($item[2])

			$netProcessName = (Get-Process -Id $item[-1] -ErrorAction SilentlyContinue).Name
			
			# apply ProcessName filter
			if(![string]::IsNullOrEmpty($ProcessName) -and 
				[string]::Compare($ProcessName, $netProcessName, $true) -ne 0) {
				continue
			}

			# apply Port filter
			if($Port -ne -1 -and $localPort -ne $Port -and $remotePort -ne $Port) {
				continue
			}
			
			# apply Address filter
			if($Address -ne $null -and $localAddress -ne $Address -and $remoteAddress -ne $Address) {
				continue
			}
			
			# apply PID filter
			$netPID = $item[-1]
			if($ProcessId -ne -1 -and $ProcessId -ne $netPID) {
				continue
			}

			New-Object PSObject -Property @{ 
                PID = $netPID 
                ProcessName = $netProcessName 
                Protocol = $item[0] 
                LocalAddress = $localAddress 
                LocalPort = $localPort 
                RemoteAddress = $remoteAddress 
                RemotePort = $remotePort 
                State = if($item[0] -eq 'tcp') {$item[3]} else {$null} 
            } | Select-Object -Property $properties 
        } 
    } 
}

