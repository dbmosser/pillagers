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

# THE CONTRACT LIST READS FROM THE COUCH (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
  .crow{ padding:12px 14px; border-bottom:1px solid rgba(42,50,61,.35); font-size:15px; }
'@ @'
  .crow{ padding:13px 16px; border-bottom:1px solid rgba(42,50,61,.35); font-size:18px; }   /* v18.66, seen on the Mainframe screenshot (2026-10-07): the contract list read in 15, 13.5, 11 and 10.5 pixel lines across a wide panel; each a few sizes up */
'@

SubRx @'
  .crow .cp{ color:var(--ash); font-size:13.5px; margin-top:4px; display:flex; justify-content:space-between; align-items:center; }
'@ @'
  .crow .cp{ color:var(--ash); font-size:15.5px; margin-top:5px; display:flex; justify-content:space-between; align-items:center; }
'@

SubRx @'
font-weight:700;font-size:10.5px;letter-spacing:.06em;margin-right:8px'
'@ @'
font-weight:700;font-size:12.5px;letter-spacing:.06em;margin-right:8px'
'@

SubRx @'
gd.style.cssText='color:#7fc4a0;font-size:11px;margin-top:2px';
'@ @'
gd.style.cssText='color:#7fc4a0;font-size:13.5px;margin-top:3px';
'@

SubRx @'
var VER='18.65';
'@ @'
var VER='18.66';
'@

$pat = "(?m)^  now:'v18\.65:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v18.66: Contracts on the Mainframe are easier to read. Check 18.66 fails on v18.65',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
