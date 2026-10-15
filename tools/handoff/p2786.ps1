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

# THE SCREEN CLEAR SPARES EVERYTHING SPECIAL (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
    if(!e||!K[e.kind]||!(e.hp>0)||e.boss||e.elite||e.downed||e.finished||e.neutral) continue;
'@ @'
    if(!e||!K[e.kind]||!(e.hp>0)||e.boss||e.elite||e.downed||e.finished||e.neutral||pwrSpecial(e)) continue;   // v27.86 (partyp4): and nothing special
'@

SubRx @'
    if(net) netShotSend(e,9999,Math.atan2(e.y-p.y,e.x-p.x),null);
'@ @'
    if(net) pwrPulseSend(e,p);   // v27.86 (partyp4): a kill that credits nobody, as the solo branch does
'@

SubRx @'
  if(!net&&n>0) styMedal('SCREEN CLEAR',Math.min(PWRX.pulseMax,PWRX.pulsePer*n),p.x,p.y-30);
'@ @'
  if(n>0) styMedal('SCREEN CLEAR',Math.min(PWRX.pulseMax,PWRX.pulsePer*n),p.x,p.y-30);   // v27.86 (partyp4): the flat medal is paid in a linked window too
'@

SubRx @'
// the screen clear: every ordinary machine on the screen dies. Returns how many.
function pwrPulse(p){
'@ @'
// v27.86 (partyp4), from the cloud review of 2026-10-15 (items 8 and 23), and his own words on the screen clear (2026-10-14): "this is like a nuke in zombies? keep it
// i guess but it shouldn't hurt pillagers". The pulse kills the ORDINARY machines on the screen and nothing else. It always spared bosses, elites and pillagers;
// it also spared nobody special: a golden machine (one pickup and the hoard dropped with no GOLD HUNTER), the convoy CARRIER (a plain bulwark, so one press solved
// the whole event), the bounty hunter, the machines the Overseer summoned and the stronghold garrisons (shi, which is 0 for the first stronghold) all died to it.
// pwrSpecial() names them, and the pulse leaves them alone. A linked window used to send the machines to the host as player 2's own rounds of 9999 damage: the
// host throws a word over 1500 away, so nothing died, and had it died each machine would have been his kill, with the score, the streak, the medals, the
// power-up rolls and the air strike charge. It sends a pulse word now (a shot word with nc, 1500, which the host applies and credits to nobody, as the solo pulse
// does), and the flat medal is paid in the linked window too, as it is solo.
function pwrSpecial(e){
  return !!(e&&(e.golden||e.carrier||e.bounty||e.summoned||e.merc||e.friendlyPC||typeof e.shi==='number'));
}
function pwrPulseSend(e,p){
  var q, m;
  if(!e||!e.nid||!NET.on||NET.role!=='join'||!netEntsPeer()) return false;
  q=netPeerOfSeat(0); if(!q) return false;
  m={t:'shot',id:e.nid,dmg:1500,x:+(+p.x).toFixed(1),y:+(+p.y).toFixed(1),a:+Math.atan2(e.y-p.y,e.x-p.x).toFixed(3),nc:1};
  return netSend(q,m);
}
// the screen clear: every ordinary machine on the screen dies. Returns how many.
function pwrPulse(p){
'@

SubRx @'
  if(e.hp<=0){ e.byPlayer=false; e.bySeat=s; } else if(!e.downed){ e.byPlayer=false; e.bySeat=0; }
'@ @'
  if(e.hp<=0){ e.byPlayer=false; e.bySeat=m.nc?0:s; } else if(!e.downed){ e.byPlayer=false; e.bySeat=0; }   // v27.86 (partyp4): a pulse word (nc) kills for nobody
'@

SubRx @'
var VER='27.85';
'@ @'
var VER='27.86';
'@

$pat = "(?m)^  now:'v27\.85:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v27.86: The screen clear leaves golden, carrier, bounty, summoned and stronghold machines alone and credits nobody in co-op. Check 27.86 fails on v27.85',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
