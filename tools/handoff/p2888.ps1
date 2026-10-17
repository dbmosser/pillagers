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

# PLAYER 2 BLASTS GO PAST THE SHIELD (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
function netShotSend(e,dmg,ang,wk,ar,el){
'@ @'
function netShotSend(e,dmg,ang,wk,ar,el,sk){   // v28.xx (cw-blastshield), CLOUD HUNT 2026-10-15: sk marks a gun round, the only blow the host soaks on a SHIELDED elite
'@

SubRx @'
  if(ar>0) m.ar=+ar;   // v22.04 (K16): a round the host soaks with its own armour for this man: 1, or 1.5 for a back shot
'@ @'
  if(ar>0) m.ar=+ar;   // v22.04 (K16): a round the host soaks with its own armour for this man: 1, or 1.5 for a back shot
  if(sk) m.sk=1;   // v28.xx (cw-blastshield), CLOUD HUNT 2026-10-15: a gun round: the host soaks it with the shield as its own rounds; a blast, a mine, fists or an air strike go past it
'@

SubRx @'
              if(NET.on&&netEntsPeer()) netShotSend(en,edmg,Math.atan2(b.vy,b.vx),WK,_nar,b.el); else en.hp-=affixSoak(en,edmg);   // v15.80: on a linked window the host runs this body, so the round is a request to the host with the damage worked out here
'@ @'
              if(NET.on&&netEntsPeer()) netShotSend(en,edmg,Math.atan2(b.vy,b.vx),WK,_nar,b.el,1); else en.hp-=affixSoak(en,edmg);   // v15.80: on a linked window the host runs this body, so the round is a request to the host with the damage worked out here   // v28.xx (cw-blastshield), CLOUD HUNT 2026-10-15: player 2 round is marked for the shield soak
'@

SubRx @'
  e.hp-=affixSoak(e,d); e.hitT=.16; e.pHitT=.3; e.pHitSeat=s; hitStopOn(e,d); suppHit(e);   // v26.xx (ai22): and player 2's rounds that land pin him as yours do   // v17.31, co-op hunt 2026-09-28: and whose round it was, so a man who made peace turned by it charges that seat
'@ @'
  e.hp-=(m.sk?affixSoak(e,d):d); e.hitT=.16; e.pHitT=.3; e.pHitSeat=s; hitStopOn(e,d); suppHit(e);   // v26.xx (ai22): and player 2's rounds that land pin him as yours do   // v17.31, co-op hunt 2026-09-28: and whose round it was, so a man who made peace turned by it charges that seat   // v28.xx (cw-blastshield), CLOUD HUNT 2026-10-15: only a round soaks on the shield (v26.72), as on the host
'@

SubRx @'
var VER='28.87';
'@ @'
var VER='28.88';
'@

$pat = "(?m)^  now:'v28\.87:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v28.88: Player 2s grenades, melee and air strike now go straight past a shielded elites shield, the same as player 1s. Check 28.88 fails on v28.87',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
