# host-settings-export.ps1 : reads this PC's look-and-feel so vm-setup.ps1 can copy it into the VM.
# Read-only for Windows settings: it changes nothing here. It only writes files next to itself:
#   host-settings.json  (look-and-feel values, with the registry value kinds)    wallpaper.*  (only when the desktop shows a picture)
#   start2.bin + start-layout.json (Start menu pins, best effort)               host-apps.json (installed programs, from winget)
#   logs\host-settings-export-<time>.log
# Run:  powershell -ExecutionPolicy Bypass -File "C:\claudecode\dark raiders\tools\migrate\host-settings-export.ps1"
# Needs no administrator window. Safe to repeat.
# ASCII only (Windows PowerShell 5.1 in a fresh VM reads scripts as ANSI). Works in Windows PowerShell 5.1 and PowerShell 7.
# v2 2026-10-19: more visual-effect keys, value kinds, solid-color desktop detected (the old export shipped a stale picture),
#                winget output is shown instead of hidden, Start layout export, locale facts.
$ErrorActionPreference = 'Continue'
$dir = $PSScriptRoot
if (-not $dir) { Write-Host 'Please run this from its file, not pasted into a window.'; exit 1 }

# ---------------------------------------------------------------- log
$logDir = Join-Path $dir 'logs'
$log = ''
try {
  if (-not (Test-Path -LiteralPath $logDir)) { New-Item -ItemType Directory -Force -Path $logDir | Out-Null }
  $log = Join-Path $logDir ('host-settings-export-' + (Get-Date -Format 'yyyyMMdd-HHmmss') + '.log')
  Set-Content -LiteralPath $log -Value ('# host-settings-export started ' + (Get-Date -Format 's') + ' on ' + $env:COMPUTERNAME) -Encoding ASCII
} catch { $log = '' }
function Say([string]$text, [string]$level = 'INFO') {
  $color = 'Gray'
  if ($level -eq 'OK') { $color = 'Green' } elseif ($level -eq 'WARN') { $color = 'Yellow' } elseif ($level -eq 'FAIL') { $color = 'Red' }
  Write-Host ($level.PadRight(5) + ' ' + $text) -ForegroundColor $color
  if ($log) { try { Add-Content -LiteralPath $log -Value ((Get-Date -Format 'HH:mm:ss') + ' [' + $level + '] ' + $text) -Encoding ASCII } catch { } }
}

# ---------------------------------------------------------------- registry reading (values + kinds)
$kindsOut = [ordered]@{}
function Read-Vals($path, $names) {
  $o = [ordered]@{}
  $k = [ordered]@{}
  $item = $null
  try { $item = Get-Item -LiteralPath $path -ErrorAction Stop } catch { }
  foreach ($n in $names) {
    try {
      $v = (Get-ItemProperty -Path $path -Name $n -ErrorAction Stop).$n
      if ($v -is [byte[]]) { $o[$n] = @{ bin = [Convert]::ToBase64String($v) } }
      else { $o[$n] = $v }
      if ($item) {
        $rn = $n
        if ($n -eq '(default)') { $rn = '' }
        try { $k[$n] = [string]$item.GetValueKind($rn) } catch { }
      }
    } catch {}
  }
  if ($k.Count -gt 0) { $kindsOut[$path] = $k }
  $o
}

# These go into "registry": vm-setup.ps1 writes them into the VM (its allow-list covers these keys).
$reg = [ordered]@{
  'HKCU:\Software\Microsoft\Windows\CurrentVersion\Themes\Personalize' = @('AppsUseLightTheme','SystemUsesLightTheme','EnableTransparency','ColorPrevalence')
  'HKCU:\Software\Microsoft\Windows\DWM' = @('AccentColor','ColorizationColor','ColorPrevalence','ColorizationAfterglow','EnableWindowColorization','EnableAeroPeek')
  'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Accent' = @('AccentColorMenu','StartColorMenu','AccentPalette')
  'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced' = @('TaskbarAl','TaskbarDa','TaskbarMn','ShowTaskViewButton','ShowCopilotButton','HideFileExt','Hidden','ShowSuperHidden','LaunchTo','TaskbarGlomLevel','MMTaskbarEnabled','MMTaskbarMode','Start_TrackDocs','Start_TrackProgs','Start_Layout','Start_IrisRecommendations','Start_AccountNotifications','TaskbarSi','NavPaneExpandToCurrentFolder','NavPaneShowAllFolders','ShowStatusBar','UseCompactMode','SeparateProcess','TaskbarAnimations','ListviewAlphaSelect','ListviewShadow')
  'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced\TaskbarDeveloperSettings' = @('TaskbarEndTask')
  'HKCU:\Software\Microsoft\Windows\CurrentVersion\Search' = @('SearchboxTaskbarMode','BingSearchEnabled')
  'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\CabinetState' = @('FullPath')
  'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\StuckRects3' = @('Settings')
  'HKCU:\Control Panel\Desktop' = @('WallpaperStyle','TileWallpaper','MenuShowDelay','FontSmoothing','FontSmoothingType','CursorBlinkRate','DragFullWindows','UserPreferencesMask')
  'HKCU:\Control Panel\Desktop\WindowMetrics' = @('MinAnimate')
  'HKCU:\Control Panel\Colors' = @('Background')
  'HKCU:\Control Panel\Mouse' = @('MouseSpeed','MouseThreshold1','MouseThreshold2','MouseSensitivity','DoubleClickSpeed','MouseTrails','SnapToDefaultButton','SwapMouseButtons')
  'HKCU:\Control Panel\Keyboard' = @('KeyboardDelay','KeyboardSpeed')
  'HKCU:\Control Panel\International' = @('LocaleName','sShortDate','sLongDate','sShortTime','sTimeFormat','iFirstDayOfWeek','iMeasure')
  'HKCU:\Control Panel\Cursors' = @('(default)')
}
# These go into "registryExtra": look-and-feel values vm-setup.ps1 does not write yet (they are outside its allow-list). Kept for when it does.
$regExtra = [ordered]@{
  'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\VisualEffects' = @('VisualFXSetting')
  'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Wallpapers' = @('BackgroundType')
}
Say 'reading look-and-feel settings ...'
$vals = [ordered]@{}
foreach ($k in $reg.Keys) { $r = Read-Vals $k $reg[$k]; if (@($r.Keys).Count -gt 0) { $vals[$k] = $r } }
$valsExtra = [ordered]@{}
foreach ($k in $regExtra.Keys) { $r = Read-Vals $k $regExtra[$k]; if (@($r.Keys).Count -gt 0) { $valsExtra[$k] = $r } }
$nVals = 0
foreach ($k in $vals.Keys) { $nVals += @($vals[$k].Keys).Count }
Say ($nVals.ToString() + ' values read from ' + @($vals.Keys).Count + ' keys (plus ' + @($valsExtra.Keys).Count + ' extra keys)') 'OK'

# ---------------------------------------------------------------- desktop background: picture or solid color?
$bgType = $null
try { $bgType = (Get-ItemProperty 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Wallpapers' -Name BackgroundType -ErrorAction Stop).BackgroundType } catch {}
$wp = $null; try { $wp = (Get-ItemProperty 'HKCU:\Control Panel\Desktop' -Name WallPaper -ErrorAction Stop).WallPaper } catch {}
$bgColor = $null; try { $bgColor = [string](Get-ItemProperty 'HKCU:\Control Panel\Colors' -Name Background -ErrorAction Stop).Background } catch {}
$wpOut = $null
$wpMode = 'unknown'
$transcoded = Join-Path $env:APPDATA 'Microsoft\Windows\Themes\TranscodedWallpaper'
if (($bgType -eq 1) -and (-not $wp)) {
  # Solid color: Windows keeps the LAST picture in TranscodedWallpaper, so copying it would send a stale picture.
  $wpMode = 'solid'
  Say ('the desktop is a solid color (background type 1, color "' + $bgColor + '"), not a picture. No wallpaper file is exported.') 'OK'
  foreach ($old in @(Get-ChildItem -LiteralPath $dir -Filter 'wallpaper.*' -File -ErrorAction SilentlyContinue)) {
    try { Remove-Item -LiteralPath $old.FullName -Force -ErrorAction Stop; Say ('removed the old ' + $old.Name + ' from the kit (it was the last picture, not the current desktop)') 'WARN' } catch { Say ('could not remove the old ' + $old.Name + ': ' + $_.Exception.Message) 'WARN' }
  }
}
elseif ($wp -and (Test-Path -LiteralPath $wp)) {
  $wpMode = 'picture'
  $wpOut = 'wallpaper' + [IO.Path]::GetExtension($wp)
  Copy-Item -LiteralPath $wp -Destination (Join-Path $dir $wpOut) -Force
  Say ('wallpaper picture copied: ' + $wpOut) 'OK'
}
elseif (Test-Path -LiteralPath $transcoded) {
  $wpMode = 'picture'
  if ($bgType -eq 2 -or $bgType -eq 3) { $wpMode = 'slideshow-or-spotlight' }
  $wpOut = 'wallpaper.jpg'
  Copy-Item -LiteralPath $transcoded -Destination (Join-Path $dir $wpOut) -Force
  Say ('wallpaper copied from the current-picture cache (mode ' + $wpMode + ')') 'OK'
}
else { Say 'no wallpaper found' 'WARN' }

# ---------------------------------------------------------------- Start menu
$start2 = Join-Path $env:LOCALAPPDATA 'Packages\Microsoft.Windows.StartMenuExperienceHost_cw5n1h2txyewy\LocalState\start2.bin'
if (Test-Path -LiteralPath $start2) { Copy-Item -LiteralPath $start2 -Destination (Join-Path $dir 'start2.bin') -Force; Say 'Start menu layout file start2.bin copied' 'OK' }
else { Say 'start2.bin not found (the Start menu has never been customised?)' 'WARN' }
$startLayout = $null
try {
  if (Get-Command Export-StartLayout -ErrorAction SilentlyContinue) {
    $slPath = Join-Path $dir 'start-layout.json'
    Export-StartLayout -Path $slPath -ErrorAction Stop
    if (Test-Path -LiteralPath $slPath) { $startLayout = 'start-layout.json'; Say 'Start layout also exported as start-layout.json (format UNVERIFIED on this Windows build)' 'OK' }
  }
} catch { Say ('Export-StartLayout did not work: ' + $_.Exception.Message + ' (not needed; start2.bin is the main copy)') 'WARN' }

# ---------------------------------------------------------------- taskbar pins
$pins = @()
$tb = Join-Path $env:APPDATA 'Microsoft\Internet Explorer\Quick Launch\User Pinned\TaskBar'
if (Test-Path -LiteralPath $tb) {
  try {
    $sh = New-Object -ComObject WScript.Shell
    foreach ($l in Get-ChildItem -LiteralPath $tb -Filter *.lnk) { $pins += [ordered]@{ name = $l.BaseName; target = $sh.CreateShortcut($l.FullName).TargetPath } }
  } catch { Say ('could not read the taskbar pin shortcuts: ' + $_.Exception.Message) 'WARN' }
}
$tbBytes = -1
try { $tbBytes = @((Get-ItemProperty 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Taskband' -Name Favorites -ErrorAction Stop).Favorites).Count } catch {}
$pinsNote = 'unknown'
if ($pins.Count -gt 0) { $pinsNote = 'from the taskbar pin shortcuts' }
elseif ($tbBytes -ge 0 -and $tbBytes -le 1) { $pinsNote = 'none: the taskbar on this PC has no pinned apps' }
elseif ($tbBytes -gt 1) { $pinsNote = 'unknown: Windows 11 keeps the pins in a binary list (Taskband Favorites, ' + $tbBytes + ' bytes) that cannot be copied safely; name the apps to pin' }
Say ('taskbar pins: ' + $pins.Count + ' (' + $pinsNote + ')')

# ---------------------------------------------------------------- language, locale, power
$langs = @(); try { $langs = @(Get-WinUserLanguageList | ForEach-Object { $_.LanguageTag }) } catch {}
$geoId = $null; try { $geoId = [int](Get-WinHomeLocation).GeoId } catch {}
$sysLocale = $null; try { $sysLocale = (Get-WinSystemLocale).Name } catch {}
$power = ''
try { $power = (powercfg /getactivescheme) -join ' ' } catch {}
$osText = ''
try { $osText = (Get-CimInstance Win32_OperatingSystem).Caption + ' ' + [Environment]::OSVersion.Version.ToString() } catch {}

# ---------------------------------------------------------------- write host-settings.json
$out = [ordered]@{
  exported        = (Get-Date).ToString('s')
  exporter        = 'host-settings-export v2 2026-10-19'
  computer        = $env:COMPUTERNAME
  os              = $osText
  timeZone        = (Get-TimeZone).Id
  culture         = (Get-Culture).Name
  languages       = $langs
  geoId           = $geoId
  systemLocale    = $sysLocale
  powerPlan       = $power
  wallpaper       = $wpOut
  wallpaperMode   = $wpMode
  backgroundColor = $bgColor
  startLayout     = $startLayout
  taskbarPins     = $pins
  taskbarPinsNote = $pinsNote
  registry        = $vals
  registryExtra   = $valsExtra
  registryKinds   = $kindsOut
}
$json = $out | ConvertTo-Json -Depth 8
$json = [regex]::Replace($json, '[^\x00-\x7F]', { param($m) ('\u' + ([int][char]$m.Value).ToString('x4')) })
Set-Content -LiteralPath (Join-Path $dir 'host-settings.json') -Value $json -Encoding ASCII
Say 'wrote host-settings.json' 'OK'

# ---------------------------------------------------------------- installed programs (winget), shown instead of hidden
$appsPath = Join-Path $dir 'host-apps.json'
$wingetOk = $false
$wg = Get-Command winget -ErrorAction SilentlyContinue
if (-not $wg) { Say 'winget was not found on this PC, so the program list will come from the installed Store apps instead' 'WARN' }
else {
  Say 'asking winget for the list of installed programs (up to 3 minutes) ...'
  $so = [IO.Path]::GetTempFileName(); $se = [IO.Path]::GetTempFileName()
  $code = -1
  try {
    $p = Start-Process -FilePath $wg.Source -ArgumentList ('export -o "' + $appsPath + '" --accept-source-agreements --disable-interactivity') -NoNewWindow -PassThru -RedirectStandardOutput $so -RedirectStandardError $se
    $null = $p.Handle
    if ($p.WaitForExit(180000)) { $code = $p.ExitCode } else { try { $p.Kill() } catch { }; Say 'winget did not finish in 3 minutes and was stopped' 'WARN' }
  } catch { Say ('could not start winget: ' + $_.Exception.Message) 'WARN' }
  foreach ($f in @($so, $se)) {
    try {
      foreach ($line in (Get-Content -LiteralPath $f -ErrorAction SilentlyContinue)) {
        $t = ([string]$line -replace '[^\x20-\x7E]', '').Trim()
        if ($t -and ($t -notmatch '^[-\\|/ ]+$')) { Say ('   winget: ' + $t) }
      }
    } catch { }
    try { Remove-Item -LiteralPath $f -Force -ErrorAction SilentlyContinue } catch { }
  }
  if (($code -eq 0) -and (Test-Path -LiteralPath $appsPath)) { $wingetOk = $true; Say 'wrote host-apps.json' 'OK' }
  else { Say ('winget export did not produce host-apps.json (exit code ' + $code + ')') 'WARN' }
}
if (-not $wingetOk) {
  # Fallback: the Store app names of this PC, in the same shape (Sources / Packages / PackageIdentifier) so vm-setup.ps1 can read it.
  try {
    $names = @(Get-AppxPackage -ErrorAction Stop | Where-Object { -not $_.IsFramework } | ForEach-Object { [string]$_.Name } | Sort-Object -Unique)
    $pk = @($names | ForEach-Object { [ordered]@{ PackageIdentifier = $_ } })
    $fb = [ordered]@{ Origin = 'Store app names (winget export did not work)'; CreationDate = (Get-Date).ToString('s'); Sources = @([ordered]@{ Packages = $pk }) }
    Set-Content -LiteralPath $appsPath -Value ($fb | ConvertTo-Json -Depth 6) -Encoding ASCII
    Say ('wrote host-apps.json from ' + $names.Count + ' Store app names (fallback)') 'OK'
  } catch { Say ('could not list the Store apps either: ' + $_.Exception.Message) 'WARN' }
}

Say ('done: host-settings.json, wallpaperMode=' + $wpMode + ', wallpaper=' + $wpOut + ', pins=' + $pins.Count + ', start2=' + (Test-Path -LiteralPath (Join-Path $dir 'start2.bin')) + ', host-apps=' + (Test-Path -LiteralPath $appsPath)) 'OK'
if ($log) { Write-Host ('      log file: ' + $log) -ForegroundColor DarkGray }
