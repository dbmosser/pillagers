param([string]$Files)
Add-Type -AssemblyName System.Drawing
foreach($f in $Files.Split(',')){ $b=New-Object System.Drawing.Bitmap $f; $o=@(); $w=$b.Width; $h=$b.Height; foreach($p in @(@(0.08,0.97),@(0.5,0.97),@(0.9,0.97),@(0.5,0.92),@(0.5,0.03))){ $c=$b.GetPixel([int]($p[0]*($w-1)),[int]($p[1]*($h-1))); $o+=("{0},{1},{2}" -f $c.R,$c.G,$c.B) }; Write-Output ("{0} {1}x{2} samples: {3}" -f (Split-Path $f -Leaf),$w,$h,($o -join ' | ')); $b.Dispose() }
