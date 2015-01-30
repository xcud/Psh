<#
.Synopsis
        Gets one or more assemblies loaded into memory in the current AppDomain.
.Example
        PS> Get-Assembly powershell
#>
function Get-Assembly() {
  param($Match, [Switch]$NamesOnly);
	
	$matchingAsms = [Threading.Thread]::GetDomain().GetAssemblies() | ? {$_.Location -match $Match }
	
	if($NamesOnly.IsPresent) {
		$matchingAsms | select @{Name="Name"; Expression={ (dir $_.Location).Name }}
	}
	else {
		$matchingAsms
	}
}
set-alias asm Get-Assembly
