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

# THE UNDERCROFT BELT SITS IN THE MIDDLE (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
    if(hx<_rL) hx=Math.round(_rL);
'@ @'
    if(hx<_rL) hx=Math.round(_rL);
    // v21.42, from the whole-game bug hunt of 2026-10-08 (W-A2): THE UNDERCROFT BELT IS CENTRED ON THE SCREEN. It was centred in the
    // room a raid leaves between the health block on the left and the gear stack on the right, and the health block is the wider of
    // the two, so on the Undercroft floor, where neither is drawn, the belt sat right of the middle (about 190 pixels on the 4K
    // picture, about 100 at 1080p) under a key line, a station prompt and a backpack that are all centred. Down there it is centred
    // on the screen at the same size; the raid belt does not move.
    if(G&&G.hubFloor) hx=Math.round((W-tw2)/2);
'@

SubRx @'
    bagOpen:true, over:false, sim:0, t:0, pouch:pq,
'@ @'
    bagOpen:true, over:false, sim:0, t:0, pouch:pq, hubFloor:true,   // v21.42 (W-A2): a belt drawn from this is the Undercroft belt, centred on the screen
'@

SubRx @'
var VER='21.41';
'@ @'
var VER='21.42';
'@

$pat = "(?m)^  now:'v21\.41:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v21.42: On the Undercroft floor the belt now sits in the middle of the screen, under the key line. Check 21.42 fails on v21.41',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
