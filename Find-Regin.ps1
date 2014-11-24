$sig = @"
2c8b9d2885543d7ade3cae98225e263b
4b6b86c7fec1c574706cecedf44abded
187044596bc1328efa0ed636d8aa4a5c
06665b96e293b23acc80451abb413e50
d240f06e98c8d3e647cbf4d442d79475
6662c390b2bbbd291ec7987388fc75d7
ffb0b9b5b610191051a7bdf0806e1e47
b29ca4f22ae7b7b25f79c1d4a421139d
1c024e599ac055312a4ab75b3950040a
ba7bb65634ce1e30c1e5415be3d1db1d
b505d65721bb2453d5039a389113b566
b269894f434657db2b15949641a67532
bfbe8c3ee78750c3a520480700e440f8
"@.Split()

dir c:\ -Re -ea 0| %{
        $count++; if($count -gt 100) { $count = 0; } 
        Write-Progress -Activity "Scanning for Regin ..." -CurrentOperation $_.FullName -PercentComplete $count ; 
        $_
    } | Get-FileHash -A MD5 -ea 0|? hash -in $sig
