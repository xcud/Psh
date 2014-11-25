# Get-PSOwner.psm1
# Author:       xcud
#
# PS Example> ps chrome* | get-psowner
# Name                                    Handle                                  Owner
# ----                                    ------                                  -----
# chrome.exe                              1940                                    ben
# chrome.exe                              5892                                    ben

function Get-PSOwner
{	
	PROCESS {	
		gwmi Win32_Process -Filter ("Handle={0}" -f $_.id ) | 
			% { Add-Member `
				-InputObject $_ `
				-MemberType NoteProperty `
				-Name Owner `
				-Value ($_.GetOwner().User) `
				-PassThru } | 
			select Name, Handle, Owner
	}
}

