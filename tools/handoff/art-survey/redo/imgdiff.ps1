# imgdiff.ps1 -P1 a.jpg -P2 b.jpg : mean abs difference (sum of 3 channels) and the share of pixels differing by more than 24 (sampled every 2nd pixel)
param([string]$P1,[string]$P2)
Add-Type -AssemblyName System.Drawing
$ia=[System.Drawing.Bitmap]::FromFile((Resolve-Path $P1).Path); $ib=[System.Drawing.Bitmap]::FromFile((Resolve-Path $P2).Path)
if($ia.Width -ne $ib.Width -or $ia.Height -ne $ib.Height){ "SIZE DIFFERS $($ia.Width)x$($ia.Height) vs $($ib.Width)x$($ib.Height)"; $ia.Dispose(); $ib.Dispose(); exit }
$sum=0.0; $n=0; $big=0
for($y=0;$y -lt $ia.Height;$y+=2){ for($x=0;$x -lt $ia.Width;$x+=2){
  $p=$ia.GetPixel($x,$y); $q=$ib.GetPixel($x,$y)
  $d=[math]::Abs($p.R-$q.R)+[math]::Abs($p.G-$q.G)+[math]::Abs($p.B-$q.B)
  $sum+=$d; $n++; if($d -gt 24){ $big++ } } }
$ia.Dispose(); $ib.Dispose()
"mean abs diff (sum of 3 channels) = {0:N2}; share of pixels over 24 = {1:P2}" -f ($sum/$n),($big/$n)
