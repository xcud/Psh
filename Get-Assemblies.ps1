<#
.Synopsis
        Gets a list of the assemblies loaded into memory in the current AppDomain.
.Example
        PS> Get-Assemblies powershell
#>
function Get-Assemblies() {
  param($Match, [Switch]$NamesOnly);
	
	$matchingAsms = [Threading.Thread]::GetDomain().GetAssemblies() | ? {$_.Location -match $Match }
	
	if($NamesOnly.IsPresent) {
		$matchingAsms | select @{Name="Name"; Expression={ (dir $_.Location).Name }}
	}
	else {
		$matchingAsms
	}
}
set-alias asm Get-Assemblies
