<#
.Synopsis
        Compares the first 8 bytes of a given file to a set of known image headers.
.Example
  	PS> dir .\1.tiff | Test-Image
    True

    PS> Test-Image -Path test.ps1
    False
#>
function Test-Image {
    [CmdletBinding()]
    param(
        [parameter(Mandatory=$true, Position=0, ValueFromPipeline=$true)] 
        $Path
    )

    PROCESS {
        $knownImageHeaders = @{
            jpg = @( "FF", "D8" );
            bmp = @( "42", "4D" );
            gif = @( "47", "49", "46" );
            tif = @( "49", "49", "2A" );
            png = @( "89", "50", "4E", "47", "0D", "0A", "1A", "0A" );
            pdf = @( "25", "50", "44", "46" );
        }

        $bytes = Get-Content $path -Encoding Byte -ReadCount 1 -TotalCount 8 -ErrorAction 0

        $retval = $false
        foreach($key in $knownImageHeaders.Keys) {
            $knownHeaderArray = $knownImageHeaders[$key]

            # transform into array of the same length and format as what we're comparing against
            $byteArray = ($bytes | select -first $knownHeaderArray.Length | % { $_.ToString("X2") }) 
            if($byteArray -eq $null) {
                continue
            }

            # compare the two arrays
            $diff = Compare-Object -ReferenceObject $knownHeaderArray -DifferenceObject $byteArray
            if(($diff | Measure-Object).Count -eq 0) {
                $retval = $true
            }
        }

        return $retval
    }
}

function Get-ChildImage {
 [CmdletBinding()]
    param(
        [parameter(Mandatory=$false, Position=0, ValueFromPipeline=$true)] $Path
    )

    Get-ChildItem $Path | ? { Test-Image $_.FullName }
}