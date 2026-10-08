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

# A MAP TAG STEPS ASIDE BEFORE IT STEPS DOWN (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
    tries=[[0,0],[0,-(gh+3)],[0,gh+3],[0,-2*(gh+3)],[0,2*(gh+3)],[-(gw*0.6),0],[gw*0.6,0],[0,-3*(gh+3)],[0,3*(gh+3)]];
'@ @'
    // v19.64, seen on the 4K map screenshot (2026-10-08): a tag sits just above its marker, so moving it DOWN off a clash put it on its
    // own marker (CACHE printed across its ring). Up and to the sides are tried first now, down last.
    tries=[[0,0],[0,-(gh+3)],[-(gw*0.6),0],[gw*0.6,0],[0,-2*(gh+3)],[0,gh+3],[0,2*(gh+3)],[0,-3*(gh+3)],[0,3*(gh+3)]];
'@

SubRx @'
var VER='19.63';
'@ @'
var VER='19.64';
'@

$pat = "(?m)^  now:'v19\.63:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v19.64: Map tags no longer land on top of their own markers. Check 19.64 fails on v19.63',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
