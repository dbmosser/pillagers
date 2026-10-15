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

# SETTINGS LIGHTS THE RIGHT SECTION ON OPEN (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
  openModal('settingsmodal');
}
document.getElementById('exportbtn').onclick=function(){ openSettings('rec'); };
'@ @'
  openModal('settingsmodal');
  // v27.73 (cloud-menus-settings-chip-on-open), CLOUD HUNT 2026-10-15: the section chips were lit while the window was still hidden, where every head reads as
  // at the top, so the last chip (ACCESSIBILITY) lit on every open until a scroll. Now they are lit again once the window shows.
  try{ setSecSpy(document.getElementById('setlist')); }catch(_ss){}
}
document.getElementById('exportbtn').onclick=function(){ openSettings('rec'); };
'@

SubRx @'
var VER='27.72';
'@ @'
var VER='27.73';
'@

$pat = "(?m)^  now:'v27\.72:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v27.73: Opening Settings now lights the chip of the section you are looking at. Check 27.73 fails on v27.72',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
