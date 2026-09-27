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

# ON A CONTROLLER B BACKS OUT OF THE MAP, THE BACKPACK AND THE STALL (stability pass before his co-op session, 2026-09-27).

SubRx @'
    if(now&&!PAD.prev[n]){ raidKey(PADTAP[n],false,null); keys[PADTAP[n]]=false; }
'@ @'
    // v16.58, stability (controller audit): B IS ESC ON A CONTROLLER. With the map, the backpack or the emote bar open B sent
    // Space, a dodge roll under the open panel, and a child pressing B to shut it rolled instead. B now backs out of what is open.
    if(now&&!PAD.prev[n]&&n===1&&!G.over&&(G.mapOpen||G.bagOpen||G.emoteBar)&&backOut()){ keys['Space']=false; }
    else if(now&&!PAD.prev[n]){ raidKey(PADTAP[n],false,null); keys[PADTAP[n]]=false; }
'@

SubRx @'
    if(pressed(9)&&!PAD.prev[9]){ raidKey('KeyP',false,null); keys['KeyP']=false; }
'@ @'
    if(pressed(9)&&!PAD.prev[9]){ raidKey('KeyP',false,null); keys['KeyP']=false; }
    if(pressed(1)&&!PAD.prev[1]){ G.trade=null; G.pedLock=1; G.pedSel=0; }   // v16.58: and B walks away from the stall, as X does
'@

SubRx @'
var VER='16.57';
'@ @'
var VER='16.58';
'@

$pat = "(?m)^  now:'v16\.57:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v16.58: ON A CONTROLLER B BACKS OUT OF THE MAP, THE BACKPACK AND THE STALL. Stability pass before a co-op session. B is the way out on a controller, but with the map or the backpack open it did a dodge roll under the panel, and at the peddler stall it did nothing. B now shuts the map, the backpack and the emote bar and walks away from the stall; with nothing open it still rolls. Check 16.58 fails on v16.57',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
