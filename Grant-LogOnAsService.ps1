function Grant-LogOnAsService() {

    param(
        [Parameter(Mandatory=$true)]
        $Username
    )

    $sid = (new-object System.Security.Principal.NTAccount "$Username").
        Translate([System.Security.Principal.SecurityIdentifier]).Value
    Write-Verbose "Account SID: $($sid)"

    $tmp = [System.IO.Path]::GetTempFileName()
    Write-Verbose "Export current Local Security Policy"
    secedit.exe /export /cfg "$($tmp)" 
    $localSecurityPolicy = Get-Content -Path $tmp 

    $currentSetting = ""
    foreach($line in $localSecurityPolicy) {
	    if( $line -like "SeServiceLogonRight*") {
		    $pair = $line.split("=",[System.StringSplitOptions]::RemoveEmptyEntries)
		    $currentSetting = $pair[1].Trim()
	    }
    }

    if( $currentSetting -notlike "*$($sid)*" ) {
	    Write-Verbose "Modify Setting ""Logon as a Service"""
	
	    if( [string]::IsNullOrEmpty($currentSetting) ) {
		    $currentSetting = "*$($sid)"
	    } else {
		    $currentSetting = "*$($sid),$($currentSetting)"
	    }
	
	    Write-Verbose $currentSetting
	
	    $outfile = @"
[Unicode]
Unicode=yes
[Version]
signature="`$CHICAGO`$"
Revision=1
[Privilege Rights]
SeServiceLogonRight = $($currentSetting)
"@

	    Write-Verbose "Import new settings to Local Security Policy"
	    $outfile | Set-Content -Path $tmp -Encoding Unicode -Force

	    Push-Location (Split-Path $tmp)	
        secedit.exe /configure /db "secedit.sdb" /cfg "$($tmp)" /areas USER_RIGHTS 
        Pop-Location
    }

}