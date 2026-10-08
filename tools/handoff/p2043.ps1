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

# A DEBT SURVIVES A RELOAD (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
    if(typeof _v!=='number'||!isFinite(_v)||_v<0) P[_k]=Math.max(0,(typeof _v==='number'&&isFinite(_v))?_v:0);
'@ @'
    // v20.43, from the whole-game bug hunt of 2026-10-08 (H34): A DEBT SURVIVES A RELOAD. A hire who dies costs a death benefit
    // and can leave the credits below zero (the run card says you are in debt, and the hire bench says a hire can do that), but
    // this floor set them back to 0 on the next load, so F5 wiped any debt for free, as often as he liked; the page-away bill of
    // v17.21 lasted one load. Credits that are a real number now load as they are, below zero or not. A value that is not a
    // number at all is still set to 0, and every other counter keeps its floor.
    if(typeof _v!=='number'||!isFinite(_v)||(_v<0&&_k!=='credits')) P[_k]=Math.max(0,(typeof _v==='number'&&isFinite(_v))?_v:0);
'@

SubRx @'
var VER='20.42';
'@ @'
var VER='20.43';
'@

$pat = "(?m)^  now:'v20\.42:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v20.43: Reloading the game no longer wipes a debt left by a hire who died. Check 20.43 fails on v20.42',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
