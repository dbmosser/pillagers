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

# SETTINGS TOAST HIDDEN (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
#root #setlist .setjump button{ padding:0; white-space:nowrap; flex:0 0 auto; }
'@ @'
#root #setlist .setjump button{ padding:0; white-space:nowrap; flex:0 0 auto; }

/* v28.xx (cw-settoast) critic c-31 (Settings, P0): "a toast sits inside the modal header, between the title and the close button; toasts never sit over a modal". Now a toast waits out of sight while Settings or Keys is open. */
body:has(#settingsmodal.on) #hubtoast, body:has(#keysmodal.on) #hubtoast{ visibility:hidden; }
'@

SubRx @'
var VER='29.77';
'@ @'
var VER='29.78';
'@

$pat = "(?m)^  now:'v29\.77:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v29.78: Toasts wait while Settings is open. Check 29.78 fails on v29.77',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
