param([string]$In,[string]$Out,[int]$X,[int]$Y,[int]$W,[int]$H,[int]$Scale=3)
Add-Type -AssemblyName System.Drawing
$src=[System.Drawing.Image]::FromFile($In)
$bmp=New-Object System.Drawing.Bitmap ($W*$Scale),($H*$Scale)
$g=[System.Drawing.Graphics]::FromImage($bmp); $g.InterpolationMode='HighQualityBicubic'; $g.PixelOffsetMode='Half'
$g.DrawImage($src,(New-Object System.Drawing.Rectangle 0,0,($W*$Scale),($H*$Scale)),$X,$Y,$W,$H,[System.Drawing.GraphicsUnit]::Pixel)
$bmp.Save($Out,[System.Drawing.Imaging.ImageFormat]::Png); $g.Dispose(); $bmp.Dispose(); $src.Dispose()
