# render.ps1 : turn mockup HTML files into pictures for the menu survey (2026-10-18, his "give me questions for menus with
# images so that we can really dial in on how this shit should look").
#   powershell -NoProfile -ExecutionPolicy Bypass -File tools/handoff/menu-survey/render.ps1 -Html tools/handoff/menu-survey/mock/q01-a.html [-Html ...]
# For each file: headless Chrome renders it at 1920x1080 to mock/NAME.png, then a 1280-wide JPEG (quality 82) is written to
# img/NAME.jpg for the survey page. Prints one line per file: OK path bytes, or FAIL reason. Its own short-lived Chrome per file
# (a fresh temp profile, closed when done); never port 8802; never his Chrome profile.
param([string[]]$Html)
$ErrorActionPreference = 'Stop'
Add-Type -AssemblyName System.Drawing
$root = Split-Path $PSScriptRoot -Parent | Split-Path -Parent | Split-Path -Parent
$chrome = 'C:\Program Files\Google\Chrome\Application\chrome.exe'
if (-not (Test-Path $chrome)) { $chrome = "${env:ProgramFiles(x86)}\Google\Chrome\Application\chrome.exe" }
$imgDir = Join-Path $PSScriptRoot 'img'; New-Item -ItemType Directory -Force $imgDir | Out-Null
$enc = @([System.Drawing.Imaging.ImageCodecInfo]::GetImageEncoders() | Where-Object { $_.MimeType -eq 'image/jpeg' })[0]
foreach ($h in ($Html | ForEach-Object { $_ -split ',' } | Where-Object { $_ })) {
  try {
    $p = if ([IO.Path]::IsPathRooted($h)) { $h } else { Join-Path $root $h }
    $p = (Resolve-Path $p).Path
    $name = [IO.Path]::GetFileNameWithoutExtension($p)
    $png = Join-Path (Split-Path $p) ($name + '.png')
    $prof = Join-Path $env:TEMP ('msurvey-' + [guid]::NewGuid().ToString('N').Substring(0, 8))
    # 10-18 his order "change all text shown to player to lowercase only": every mockup is drawn in lower case, from a temp copy beside it
    $src0 = [IO.File]::ReadAllText($p); $lcs = '<style>*,*::before,*::after{text-transform:lowercase!important}</style>'
    $src1 = if ($src0 -match '</head>') { $src0.Replace('</head>', $lcs + '</head>') } elseif ($src0 -match '(?i)<!doctype[^>]*>') { [regex]::Replace($src0, '(?i)(<!doctype[^>]*>)', ('$1' + $lcs), 1) } else { $lcs + $src0 }
    $lcp = Join-Path (Split-Path $p) ('_lc_' + $name + '.html'); [IO.File]::WriteAllText($lcp, $src1, (New-Object Text.UTF8Encoding $false))
    $url = 'file:///' + ($lcp -replace '\\', '/')
    $args2 = @('--headless=new', '--disable-gpu', '--hide-scrollbars', "--user-data-dir=`"$prof`"", '--allow-file-access-from-files',
      '--window-size=1920,1080', '--force-device-scale-factor=1', '--virtual-time-budget=4000', "--screenshot=`"$png`"", "`"$url`"")
    Start-Process -FilePath $chrome -ArgumentList $args2 -Wait -WindowStyle Hidden -RedirectStandardError (Join-Path $env:TEMP 'msurvey-err.txt')
    Start-Sleep -Milliseconds 300
    Remove-Item -Recurse -Force $prof -ErrorAction SilentlyContinue
    Remove-Item -Force $lcp -ErrorAction SilentlyContinue
    if (-not (Test-Path $png)) { "FAIL $h (no picture)"; continue }
    $src = [System.Drawing.Image]::FromFile($png)
    $w = 1280; $hh = [int]($src.Height * $w / $src.Width)
    $bmp = New-Object System.Drawing.Bitmap $w, $hh
    $g = [System.Drawing.Graphics]::FromImage($bmp); $g.InterpolationMode = 'HighQualityBicubic'; $g.DrawImage($src, 0, 0, $w, $hh)
    $ep = New-Object System.Drawing.Imaging.EncoderParameters 1
    $ep.Param[0] = [System.Drawing.Imaging.EncoderParameter]::new([System.Drawing.Imaging.Encoder]::Quality, [long]82)
    $jpg = Join-Path $imgDir ($name + '.jpg'); $bmp.Save($jpg, $enc, $ep)
    $g.Dispose(); $bmp.Dispose(); $src.Dispose()
    "OK $jpg $((Get-Item $jpg).Length)"
  } catch { "FAIL $h $($_.Exception.Message)" }
}
