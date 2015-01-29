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
        [parameter(Mandatory=$true, Position=0, ValueFromPipeline=$true)] $Path
    )

    $knownImageHeaders = @{
        jpg = @( "FF", "D8" );
        bmp = @( "42", "4D" );
        gif = @( "47", "49", "46" );
        tif = @( "49", "49", "2A" );
        png = @( "89", "50", "4E", "47", "0D", "0A", "1A", "0A" );
    }

    $bytes = Get-Content $path -Encoding Byte -ReadCount 1 -TotalCount 8

    $knownImageHeaders.Keys | %{ 
        # transform into array of the same length and format as what we're comparing against
        $byteArray = ($bytes | select -first $knownImageHeaders[$_].Length | % { $_.ToString("X2") }) 
        
        # compare the two arrays
        $diff = Compare-Object -ReferenceObject $knownImageHeaders[$_] -DifferenceObject $byteArray
        if(($diff | Measure-Object).Count -eq 0)
        {
            Write-Output $true
            break
        }
    }

    Write-Output $false
}