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

# The cursor shows over the item wheel (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
var _wantCur=(!p.downed&&(G.bagOpen||G.mapOpen))?'default':
'@ @'
// v28.xx (cw-wheelcursor), HIS ORDER (2026-10-15): "The mouse cursor shows over the wheel while it is open, so the player never loses the cursor when the wheel closes." The arrow is up while a mouse holds the wheel open (a pad keeps its reticle).
  var _wantCur=(!p.downed&&(G.bagOpen||G.mapOpen||(G.wheel&&!G.wheel.pad)))?'default':
'@

SubRx @'
// reticle at the cursor
if(!p.downed&&!G.bagOpen&&!G.mapOpen){
'@ @'
// reticle at the cursor
if(!p.downed&&!G.bagOpen&&!G.mapOpen&&!(G.wheel&&!G.wheel.pad)){   // v28.xx (cw-wheelcursor): the arrow, not the cross, while the wheel is open
'@

SubRx @'
var VER='29.47';
'@ @'
var VER='29.48';
'@

$pat = "(?m)^  now:'v29\.47:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v29.48: The mouse arrow shows over the item wheel while it is open. Check 29.48 fails on v29.47',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
