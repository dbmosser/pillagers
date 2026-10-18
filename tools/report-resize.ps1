# report-resize.ps1 : shrinks pictures for the morning/evening report (tools/report.mjs calls it once per report).
# Input: a JSON file holding a list of {src, dst, w, q}: the source picture, the small JPEG to write, the width in pixels, the quality 1-100.
# Windows only (uses System.Drawing). ASCII only (PowerShell 5.1 reads .ps1 as ANSI). It reads the sources and writes only the dst files.
param([string]$Jobs)
$ErrorActionPreference = 'Stop'
Add-Type -AssemblyName System.Drawing
$list = Get-Content -Raw -LiteralPath $Jobs | ConvertFrom-Json
$enc = [System.Drawing.Imaging.ImageCodecInfo]::GetImageEncoders() | Where-Object { $_.MimeType -eq 'image/jpeg' } | Select-Object -First 1
foreach ($j in @($list)) {
  try {
    $img = [System.Drawing.Image]::FromFile([string]$j.src)
    $w = [int]$j.w; if ($img.Width -le $w) { $w = $img.Width }
    $h = [int][math]::Round($img.Height * $w / $img.Width)
    $bmp = New-Object System.Drawing.Bitmap($w, $h)
    $g = [System.Drawing.Graphics]::FromImage($bmp)
    $g.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
    $g.DrawImage($img, 0, 0, $w, $h)
    $ep = New-Object System.Drawing.Imaging.EncoderParameters(1)
    $ep.Param[0] = New-Object System.Drawing.Imaging.EncoderParameter([System.Drawing.Imaging.Encoder]::Quality, [long]$j.q)
    $bmp.Save([string]$j.dst, $enc, $ep)
    $g.Dispose(); $bmp.Dispose(); $img.Dispose()
    'ok ' + $j.dst
  } catch {
    'fail ' + $j.src + ' ' + $_.Exception.Message
  }
}
