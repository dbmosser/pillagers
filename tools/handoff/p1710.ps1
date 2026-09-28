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

# A BANDAGE OR PLATE YOUR TEAMMATE COULD NOT TAKE (HE WENT DOWN, DIED OR LEFT THE RAID) COMES BACK TO YOUR BACKPACK (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
    g=NET.up[i]; if(!netUpShown(g)||g.dn) continue;
'@ @'
    // v17.10, co-op hunt 2026-09-28: a seat whose raid on this seed has ended (netUpGone) is nobody to heal, though a late
    // position word of his still draws him for a moment; a heal sent to him was lost. Skipped, as the pick-up wait skips him.
    g=NET.up[i]; if(!netUpShown(g)||netUpGone(g)||g.dn) continue;
'@

SubRx @'
  var p=G.player, s=PR.aid, g=NET.up[s], nm=netSeatName(s)||'your teammate', it=ITEMS[PR.key], i;
  if(!g||!netUpShown(g)||g.dn||Math.hypot(g.x-p.x,g.y-p.y)>NET_REV_R*1.5){
    G.bag.push(PR.key);
    if(PR.issB){ G.issuedBandages=(G.issuedBandages||0)+1; if(G.bandSeen!==undefined) G.bandSeen++; }   // v17.07, co-op hunt 2026-09-28: still a loaner
    say(nm+' moved away. '+(it?it.name:'It')+' kept.'); return false;
  }
  if(NET.role==='host') netAidPass(s,NET.seat,PR.key);
'@ @'
  var p=G.player, s=PR.aid, g=NET.up[s], nm=netSeatName(s)||'your teammate', it=ITEMS[PR.key], i, r;
  // v17.10, co-op hunt 2026-09-28: a teammate whose raid has ended is gone too (netUpGone), and on the host a heal that could
  // not be passed to anyone (no link on his seat, or the send failed) was lost while the line said Patched up; both keep it,
  // and a kept loaner Bandage stays a loaner (v17.07).
  function kept(why){
    G.bag.push(PR.key);
    if(PR.issB){ G.issuedBandages=(G.issuedBandages||0)+1; if(G.bandSeen!==undefined) G.bandSeen++; }   // v17.07, co-op hunt 2026-09-28: still a loaner
    say(nm+why+(it?it.name:'It')+' kept.'); return false;
  }
  if(!g||!netUpShown(g)||netUpGone(g)||g.dn||Math.hypot(g.x-p.x,g.y-p.y)>NET_REV_R*1.5) return kept(' moved away. ');
  if(NET.role==='host'){ r=netAidPass(s,NET.seat,PR.key); if(r!=='passed'&&r!=='aid') return kept(' could not take it. '); }
'@

SubRx @'
  if(typeof G==='undefined'||!G||G.over||G.sim||!G.player||!it) return 'no raid';
  p=G.player; if(p.downed) return 'down';
'@ @'
  // v17.10, co-op hunt 2026-09-28: a heal or plate that lands here when it cannot be used (this raid is over, he is down, or he
  // is in his death beat, where a heal went into a dead man) was thrown away while the teammate who spent it read Patched up.
  // It now goes back to him (netAidBack), who puts it back in his backpack.
  if(typeof G==='undefined'||!G||G.over||G.sim||!G.player||!it){ if(it) netAidBack(by,key,'gone'); return 'no raid'; }
  p=G.player; if(p.downed||p.dying){ netAidBack(by,key,'down'); return 'down'; }
'@

SubRx @'
  if(NET.role==='host') return netAidPass(m.s,peer.seat,netClean(m.k,24));
'@ @'
  // v17.10, co-op hunt 2026-09-28: an aid word from a friend that the host could not pass on (no link on that seat, or the send
  // failed) was lost while the friend read Patched up; it now goes back to him (netAidBack), as a refused one does.
  if(NET.role==='host'){ var r=netAidPass(m.s,peer.seat,netClean(m.k,24)); if(r==='nobody'||r==='lost') netAidBack(peer.seat,netClean(m.k,24),'gone'); return r; }
'@

SubRx @'
var VER='17.09';
'@ @'
var VER='17.10';
'@

$pat = "(?m)^  now:'v17\.09:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v17.10: Aid items, co-op hunt 2026-09-28: once netAidFinish sent the aid word the item lived only in that word. netAidApply turned it down when the raid was over (no raid) or he was down, and when he was in his death beat (downed cleared, hp 0) it poured the heal into a dead man, and in each case nothing went back, so the item was lost and the healer read Patched up. The healer decided from his last state word, which lags a fresh down by up to NET_HUB_STEP, and a late position word after the out word re-files an extracted teammate as standing. netAidApply now sends every refused item back with the aidx word (netAidBack, from the draft before) and also refuses a man in his death beat. netAidTarget and netAidFinish skip a seat marked out on this seed (netUpGone), as the pick-up wait does. On the host, netAidFinish now reads what netAidPass answers, and when nobody could take it (no link on that seat, or the send failed) the item stays in the backpack with the line NAME could not take it. ITEM kept, and an aid word from a friend that netAidTake on the host could not pass on (nobody, or lost) goes back to that friend the same way. No number moved. Check 17.10 fails on v17.09',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
