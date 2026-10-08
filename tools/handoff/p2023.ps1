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

# THE ACHIEVEMENTS LIST IS READABLE (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
h+='<div style="display:flex;gap:10px;font-size:11.5px;padding:2px 0;color:'
'@ @'
h+='<div style="display:flex;gap:14px;font-size:14px;padding:3px 0;color:'
'@

SubRx @'
'<span style="width:150px">'+(P.ach[a.id]?'':'LOCKED ')+a.n+'</span>
'@ @'
'<span style="width:230px;flex:0 0 230px">'+(P.ach[a.id]?'':'LOCKED ')+a.n+'</span>
'@

SubRx @'
'<div style="font-size:10.5px;letter-spacing:.2em;color:var(--ash);margin-bottom:6px">ACHIEVEMENTS  '
'@ @'
'<div style="font-size:13px;letter-spacing:.2em;color:var(--ash);margin-bottom:6px">ACHIEVEMENTS  '
'@

SubRx @'
var VER='20.22';
'@ @'
var VER='20.23';
'@

$pat = "(?m)^  now:'v20\.22:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v20.23: The achievements list under YOUR STATS is easier to read. Check 20.23 fails on v20.22',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
