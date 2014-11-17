$source = @"
using System;
using System.Runtime.InteropServices;
using System.Security.Principal;
using System.Text;
using System.Collections.Generic;

public static class ADPermissions {
public static string[] EnumRights()
 {
     List<string> retval = new List<string>();
     uint length = 0;
 
     bool res = GetTokenInformation(WindowsIdentity.GetCurrent().Token, TOKEN_INFORMATION_CLASS.TokenPrivileges, IntPtr.Zero, length, out length);
     IntPtr tokenInformation = Marshal.AllocHGlobal(unchecked((int)length));
     res = GetTokenInformation(WindowsIdentity.GetCurrent().Token, TOKEN_INFORMATION_CLASS.TokenPrivileges, tokenInformation, length, out length);
     if (res)
     {
         TOKEN_PRIVILEGES privs = (TOKEN_PRIVILEGES)Marshal.PtrToStructure(tokenInformation, typeof(TOKEN_PRIVILEGES));
         for (int i = 0; i < privs.Count; i++)
         {
             IntPtr ptr = new IntPtr(tokenInformation.ToInt64() + sizeof(uint) + i * Marshal.SizeOf(typeof(LUID_AND_ATTRIBUTES)));
             LUID_AND_ATTRIBUTES privInfo = (LUID_AND_ATTRIBUTES)Marshal.PtrToStructure(ptr, typeof(LUID_AND_ATTRIBUTES));
             StringBuilder name = new StringBuilder();
             IntPtr luidPtr = Marshal.AllocHGlobal(Marshal.SizeOf(typeof(LUID)));
             Marshal.StructureToPtr(privInfo.Luid, luidPtr, false);
             int size = 0;
             LookupPrivilegeName(null, luidPtr, null, ref size);
             name.EnsureCapacity(size);
             LookupPrivilegeName(null, luidPtr, name, ref size);
             Marshal.FreeHGlobal(luidPtr);
 
             retval.Add(name.ToString());
         }
     }
 
     Marshal.FreeHGlobal(tokenInformation);

     return retval.ToArray();
 }
 
 
 #region Interop
 [StructLayout(LayoutKind.Sequential)]
 struct LUID
 {
     public uint LowPart;
     public int HighPart;
 }
 
 [StructLayout(LayoutKind.Sequential)]
 struct LUID_AND_ATTRIBUTES
 {
     public LUID Luid;
     public uint Attributes;
 }
 
 [StructLayout(LayoutKind.Sequential)]
 struct TOKEN_PRIVILEGES
 {
     public uint Count;
 }

 enum TOKEN_INFORMATION_CLASS
        {
            TokenUser = 1,
            TokenGroups,
            TokenPrivileges,
            TokenOwner,
            TokenPrimaryGroup,
            TokenDefaultDacl,
            TokenSource,
            TokenType,
            TokenImpersonationLevel,
            TokenStatistics,
            TokenRestrictedSids,
            TokenSessionId,
            TokenGroupsAndPrivileges,
            TokenSessionReference,
            TokenSandBoxInert,
            TokenAuditPolicy,
            TokenOrigin
        }

 [DllImport("advapi32.dll", SetLastError = true)]
 static extern bool GetTokenInformation(
     IntPtr TokenHandle,
     TOKEN_INFORMATION_CLASS TokenInformationClass,
     IntPtr TokenInformation,
     uint TokenInformationLength,
     out uint ReturnLength);
 
 [DllImport("advapi32.dll", SetLastError = true, CharSet = CharSet.Auto)]
 public static extern bool LookupPrivilegeName(
    string lpSystemName,
    IntPtr lpLuid,
    System.Text.StringBuilder lpName,
    ref int cchName);
 
 #endregion
 }
"@

Add-Type -TypeDefinition $source

<#
.Synopsis
        Gets a list of policy user rights associated with the current user token.
.Example
        PS> Get-Rights

        SeShutdownPrivilege
        SeChangeNotifyPrivilege
        SeUndockPrivilege
        SeIncreaseWorkingSetPrivilege
        SeTimeZonePrivilege
        
#>
function Get-Rights() {
	[ADPermissions]::EnumRights();
}