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

# PLAYER 2 SHOOTING A PILLAGER WHO MADE PEACE NOW COSTS PLAYER 2, NOT PLAYER 1 (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
      if(_fMine) e.pHitT=.3;   // v11.37: only YOUR charge provokes
'@ @'
      if(_fMine){ e.pHitT=.3; e.pHitSeat=0; }   // v11.37: only YOUR charge provokes; v17.31, co-op hunt 2026-09-28: and it is the host player own, not a seat
'@

SubRx @'
        _me.hitT=.16; _me.pHitT=.3;   // v11.37: your strike provokes
'@ @'
        _me.hitT=.16; _me.pHitT=.3; _me.pHitSeat=0;   // v11.37: your strike provokes; v17.31, co-op hunt 2026-09-28: yours, not a seat
'@

SubRx @'
              en.pHitT=.3;   // v11.37: YOUR round, so it may provoke and it may earn a grudge
'@ @'
              en.pHitT=.3; en.pHitSeat=0;   // v11.37: YOUR round, so it may provoke and it may earn a grudge; v17.31, co-op hunt 2026-09-28: yours, not a seat
'@

SubRx @'
          e.friendlyPC=0; e.hostile=true; e.grudge=true;
          if(!G.sim){
            var rb=idRec(e.ident); rb.standing=Math.min((rb.standing||0)-3,-1); saveProfile();
            say(e.name+' trusted you.');
          }
'@ @'
          e.friendlyPC=0; e.hostile=true; e.grudge=true;
          // v17.31, co-op hunt 2026-09-28: the standing and the line belong to whoever fired. A round from player 2 (pHitSeat, set in
          // netShotTake) cut the host player save and printed the line in his window; now that seat is told (netBetrayTake) and it
          // comes off his own save. A hit of the host player still charges the host, but never once he has left the raid (specOut).
          var _bs=e.pHitSeat|0; e.pHitSeat=0;
          if(!G.sim&&_bs>0){ var _bq=netPeerOfSeat(_bs); if(_bq) netSend(_bq,{t:'betray',seat:_bs,id:e.nid|0}); }
          else if(!G.sim&&!(G.player&&G.player.specOut)){
            var rb=idRec(e.ident); rb.standing=Math.min((rb.standing||0)-3,-1); saveProfile();
            say(e.name+' trusted you.');
          }
'@

SubRx @'
  e.hp-=d; e.hitT=.16; e.pHitT=.3;
'@ @'
  e.hp-=d; e.hitT=.16; e.pHitT=.3; e.pHitSeat=s;   // v17.31, co-op hunt 2026-09-28: and whose round it was, so a man who made peace turned by it charges that seat
'@

SubRx @'
  if(m.t==='kill') return netKillTake(peer,m);   // v15.80: a kill credited to this seat, from the host
'@ @'
  if(m.t==='kill') return netKillTake(peer,m);   // v15.80: a kill credited to this seat, from the host
  if(m.t==='betray') return netBetrayTake(peer,m);   // v17.31, co-op hunt 2026-09-28: a man who made peace was turned by this seat round, from the host
'@

SubRx @'
// The bodies as this window holds them, for the test page handle.
'@ @'
// v17.31, co-op hunt 2026-09-28: A MAN WHO MADE PEACE, TURNED BY THIS PLAYER ROUND. The host turns him for the party (updateEnts)
// and sends this word to the seat that fired; the standing he loses and the line come off this window own save, as a kill word
// does, where they used to come off the host player save. Only while this raid is running, up top on the party seed.
function netBetrayTake(peer,m){
  var e, rb;
  if(!peer||peer.state!=='in'||NET.role!=='join') return 'ignored';
  if(typeof m.seat==='number'&&m.seat!==NET.seat) return 'ignored';
  if(!netEntsPeer()) return 'down';
  e=(NET.entMap&&NET.entMap[m.id|0])||(NET.entDead&&NET.entDead[m.id|0])||null;
  if(!e||!e.ident) return 'gone';
  rb=idRec(e.ident); rb.standing=Math.min((rb.standing||0)-3,-1); saveProfile();
  sayWhenFree((e.name||'He')+' trusted you.');
  return 'betray';
}
// The bodies as this window holds them, for the test page handle.
'@

SubRx @'
var VER='17.30';
'@ @'
var VER='17.31';
'@

$pat = "(?m)^  now:'v17\.30:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v17.31: Parley betrayal in co-op, co-op hunt 2026-09-28: netShotTake stamps pHitT for a round from any seat and leaves a friendlyPC man friendly, so the betrayal branch in the host updateEnts turned him and then ran idRec, saveProfile and say in the host window, cutting player 1 standing with that identity to at most -1 and printing the line there, even with player 1 out of the raid (no specOut guard, unlike the v17.11 fixes). Player 2 own rival record was never touched. Now netShotTake records the seat (e.pHitSeat) and the host own charge, strike and round clear it to 0. In the branch the man still turns for everyone (friendlyPC 0, hostile, grudge); when a seat fired, the host sends that seat a new word {t:betray,seat,id} and writes nothing to its own save; otherwise the host save is charged as before, but not while the host player is out and spectating. The new netBetrayTake on the player 2 window resolves the body from entMap or entDead and applies the same -3 floor -1 to his own save and says the same line. No number moved. Check 17.31 fails on v17.30',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
