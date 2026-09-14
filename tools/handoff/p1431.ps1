$ErrorActionPreference = 'Stop'
trap { Write-Output "FAILED: $_"; exit 1 }
$p = 'C:\claudecode\dark raiders\dark_raiders.html'
$s = [IO.File]::ReadAllText($p)
$n = 0
function SubRx([string]$old, [string]$new) {
  $pat = ($old -split "`n" | ForEach-Object { [regex]::Escape($_.TrimEnd("`r")) }) -join "\r?\n"
  $c = ([regex]::Matches($script:s, $pat)).Count
  if ($c -ne 1) { throw "regex matched $c times: $($old.Substring(0,[Math]::Min(70,$old.Length)))" }
  $script:s = [regex]::Replace($script:s, $pat, { param($m) $new })
  $script:n++
}

SubRx @'
    if(d<STRIKE_R&&!p.downed){
      S.hit=1;
      damagePlayer(STRIKE_DMG,'lightning','the storm',S.x,S.y);
'@ @'
    if(d<STRIKE_R&&!p.downed){
      S.hit=1;
      // v14.31, weather audit finding 1: A BOLT DOES NOT REACH YOU THROUGH A WALL OR UNDER A ROOF. The strike point is walked
      // only 40 units out of a building and the blast is 118 across, so a player indoors near that wall, or outside behind a
      // solid wall, took 62 damage with nothing in the way checked. His note was that lightning does not strike inside
      // buildings, and the Howler shell and the frag already test the roof and the line. S.hit stays set, so the branch
      // below and its random draw run exactly as before.
      if(!roofAt(p.x,p.y)&&losClear(S.x,S.y,p.x,p.y,G.map.segs))
      damagePlayer(STRIKE_DMG,'lightning','the storm',S.x,S.y);
'@
SubRx @'
      if(dist(E,S)<STRIKE_R){ E.hp-=STRIKE_DMG; E.hitT=.16; if(E.hp<=0) E.byPlayer=false; }
'@ @'
      if(dist(E,S)<STRIKE_R&&!roofAt(E.x,E.y)&&losClear(S.x,S.y,E.x,E.y,G.map.segs)){ E.hp-=STRIKE_DMG; E.hitT=.16; if(E.hp<=0) E.byPlayer=false; }   // v14.31: the same roof and wall
'@
SubRx @'
var VER='14.30';
'@ @'
var VER='14.31';
'@

$pat = "(?m)^  now:'v14\.30:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v14.31: LIGHTNING DOES NOT HIT YOU THROUGH A WALL OR UNDER A ROOF. A strike is walked only 40 units out of a building and its blast reaches 118, so a player indoors near that wall, or outside behind a solid wall, took 62 damage with nothing in the way checked. A bolt now needs him out from under a roof and a clear line to him, and the same for the machines and pillagers it hits. Check 14.31 lands a bolt beside him in the open and inside a building; it fails on v14.30',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
