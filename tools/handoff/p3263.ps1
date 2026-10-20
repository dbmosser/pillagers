$ErrorActionPreference = 'Stop'
trap { Write-Output "FAILED: $_"; exit 1 }
$p = 'C:\claudecode\dark raiders\dark_raiders.html'
$s = [IO.File]::ReadAllText($p)
$n = 0
function SubRx([string]$old, [string]$new) {
  $pat = ($old -split "`n" | ForEach-Object { [regex]::Escape($_.TrimEnd("`r")) }) -join "\r?\n"
  $c = ([regex]::Matches($script:s, $pat)).Count
  if ($c -ne 1) { throw "regex matched $c times: $($old.Substring(0,[Math]::Min(70,$old.Length)))" }
  $new = $new.Replace("`r`n", "`n")
  $script:s = [regex]::Replace($script:s, $pat, { param($m) $new })
  $script:n++
}

# XBOX BUTTON PICTURES (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
function padBrandOf(gp){ var id=(gp&&gp.id)?String(gp.id):''; return /054c|playstation|dualshock|dualsense/i.test(id)?'ps':'xbox'; }
'@ @'
function padBrandOf(gp){ return 'xbox'; }   // v28.xx (cw-cx-xboxonly): his 2.35 a: Xbox button pictures only, for local and handed-over pads.
'@

SubRx @'
var VER='32.62';
'@ @'
var VER='32.63';
'@

$pat = "(?m)^  now:'v32\.62:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v32.63: All live controllers use Xbox button pictures, in both windows. Check 32.63 fails on v32.62',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
