function Start-ElevatedProcess
{
	$file, [string]$arguments = $args;
	$psi = new-object System.Diagnostics.ProcessStartInfo $file;
	$psi.Arguments = $arguments;
	$psi.Verb = "runas";
	[System.Diagnostics.Process]::Start($psi);
}
Set-Alias sudo Start-ElevatedProcess