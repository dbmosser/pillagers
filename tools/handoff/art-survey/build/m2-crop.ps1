# m2-crop.ps1 : cut regions out of a 4k shot at 3x for a quick look.  -Src file -Out file -Boxes "x,y,w,h;x,y,w,h" (1080-frame pixels, w and h of the region)
param([string]$Src,[string]$Out,[string]$Boxes)
Add-Type -AssemblyName System.Drawing
$img=[System.Drawing.Image]::FromFile($Src); $k=$img.Width/1920.0
$list=@($Boxes.Split(';') | ForEach-Object { ,($_.Split(',') | ForEach-Object { [double]$_ }) })
$W=0; $H=0; foreach($b in $list){ $W+=[int]($b[2]*3)+6; $H=[Math]::Max($H,[int]($b[3]*3)) }
$bmp=New-Object System.Drawing.Bitmap $W,$H; $g=[System.Drawing.Graphics]::FromImage($bmp); $g.Clear([System.Drawing.Color]::Black); $g.InterpolationMode='HighQualityBicubic'
$x=0; foreach($b in $list){ $dw=[int]($b[2]*3); $dh=[int]($b[3]*3)
  $dst=New-Object System.Drawing.Rectangle $x,0,$dw,$dh
  $g.DrawImage($img,$dst,[int]($b[0]*$k),[int]($b[1]*$k),[int]($b[2]*$k),[int]($b[3]*$k),[System.Drawing.GraphicsUnit]::Pixel); $x+=$dw+6 }
$bmp.Save($Out,[System.Drawing.Imaging.ImageFormat]::Jpeg); $g.Dispose(); $bmp.Dispose(); $img.Dispose()
