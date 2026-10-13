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

# THE FORGE: PLAYER 2S ELEMENTAL ROUNDS (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
function netShotSend(e,dmg,ang,wk,ar){

'@ @'
function netShotSend(e,dmg,ang,wk,ar,el){

'@

SubRx @'
  if(ar>0) m.ar=+ar;   // v22.04 (K16): a round the host soaks with its own armour for this man: 1, or 1.5 for a back shot
'@ @'
  if(ar>0) m.ar=+ar;   // v22.04 (K16): a round the host soaks with its own armour for this man: 1, or 1.5 for a back shot
  if(el&&ELEM[el]) m.el=el;   // v23.xx (forge7): THE FORGE, the element of player 2's MK III round; the host applies it
'@

SubRx @'
              if(NET.on&&netEntsPeer()) netShotSend(en,edmg,Math.atan2(b.vy,b.vx),WK,_nar); else en.hp-=edmg;
'@ @'
              if(NET.on&&netEntsPeer()) netShotSend(en,edmg,Math.atan2(b.vy,b.vx),WK,_nar,b.el); else en.hp-=edmg;
'@

SubRx @'
  if(typeof m.ar==='number'&&m.ar>=1&&m.ar<=1.5&&!m.wk&&e.armor>0){ var _nab=d/m.ar,
'@ @'
  // v23.xx, THE FORGE (2026-10-12), forge7: PLAYER 2'S ELEMENTAL ROUNDS. The shot word names the element of his MK III round (m.el,
  // checked against ELEM; anything else is ignored). The host runs every status, so it applies the element here, credited to his
  // seat: a burn or an arc kill marks his seat as his round would, and acid eats the plate before the host soaks the round. The
  // acid machine bonus was already applied by his window, so the number he saw is the one that lands.
  var _nel=(typeof m.el==='string'&&ELEM[m.el])?m.el:'';
  if(_nel==='acid'&&typeof m.ar==='number'&&m.ar>=1&&m.ar<=1.5&&!m.wk&&e.armor>0) elemShred(e,d/m.ar);
  if(typeof m.ar==='number'&&m.ar>=1&&m.ar<=1.5&&!m.wk&&e.armor>0){ var _nab=d/m.ar,
'@

SubRx @'
  if(e.hp<=0){ e.byPlayer=false; e.bySeat=s; } else if(!e.downed){ e.byPlayer=false; e.bySeat=0; }
'@ @'
  if(e.hp<=0){ e.byPlayer=false; e.bySeat=s; } else if(!e.downed){ e.byPlayer=false; e.bySeat=0; }
  if(_nel) elemHit(e,_nel,d,s,sx,sy);   // v23.xx (forge7): the element of his round, for his seat
'@

SubRx @'
var VER='25.47';
'@ @'
var VER='25.48';
'@

$pat = "(?m)^  now:'v25\.47:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v25.48: Player 2 elemental rounds burn, shock, freeze and corrode on the host too. Check 25.48 fails on v25.47',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
