<#
.Synopsis
        Gets a list of services (including Log On As User information)
.Example
        PS> Get-ServiceLogon win

        Name                                          StartName                                     State                                        
        ----                                          ---------                                     -----                                        
        WinDefend                                     LocalSystem                                   Running                                      
        WinHttpAutoProxySvc                           NT AUTHORITY\LocalService                     Running                                      
        Winmgmt                                       localSystem                                   Running                                      
        WinRM                                         NT AUTHORITY\NetworkService                   Running
#>
function Get-ServiceLogon($name) {
    gwmi win32_service | select Name, StartName, State | ? Name -match $name
}