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

# AN ARMOURY GUN THE HOST DROPS AND PLAYER 2 PICKS UP IS NO LONGER IN BOTH SAVES (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
function netSrchEndSeat(s){ return (NET.role==='host')?netSrchEnd(s):false; }
'@ @'
function netSrchEndSeat(s){ return (NET.role==='host')?netSrchEnd(s):false; }
// v17.06, co-op hunt 2026-09-28: an armoury gun the host dropped and one of the party searched up has left this raid for good
// (it is banked on his save), so it comes off the list an abandon or a closed window puts back in the host armoury. It stayed
// on it, and the one gun was in both saves. One id per gun handed over, and only from a pile the host dropped, so a found field
// copy in an ordinary box never takes the host own gun off the list.
function netGunsGone(ct,items){
  var i, it, j, n=0;
  if(G.sim||!ct||!ct.dropped||!items||!G.spliced||!G.spliced.length) return 0;
  for(i=0;i<items.length;i++){
    it=ITEMS[items[i]]; if(!it||it.use!=='gun'||!it.gk) continue;
    j=G.spliced.indexOf(it.gk); if(j<0) continue;
    G.spliced.splice(j,1); n++;
    if(P&&Array.isArray(P.raidSpliced)){ j=P.raidSpliced.indexOf(it.gk); if(j>=0) P.raidSpliced.splice(j,1); }
  }
  if(n) saveProfile();
  return n;
}
'@

SubRx @'
      netSend(q,{t:'loot',cid:r.cid,items:items,done:1});
      delete NET.holds[s];
    } else if(items.length) netSend(q,{t:'loot',cid:r.cid,items:items});
'@ @'
      netGunsGone(ct,items);   // v17.06, co-op hunt 2026-09-28: a host armoury gun handed over is his no more
      netSend(q,{t:'loot',cid:r.cid,items:items,done:1});
      delete NET.holds[s];
    } else if(items.length){ netGunsGone(ct,items); netSend(q,{t:'loot',cid:r.cid,items:items}); }
'@

SubRx @'
var VER='17.05';
'@ @'
var VER='17.06';
'@

$pat = "(?m)^  now:'v17\.05:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v17.06: Co-op, host armoury gun copied into both saves. Putting an armoury gun in the backpack takes it out of P.weapons and records it in G.spliced and P.raidSpliced so an abandon (or the loader after a closed window) can put it back. A pile the host drops is numbered and shared, so player 2 could search it up through the host and bank the gun on his own save, while the host lists still named it and the host abandon or the next load pushed it back into his armoury too. netSrchTick now calls netGunsGone for every item the host hands to a teammate: for a pile the host dropped, each gun key takes one matching id off G.spliced and P.raidSpliced and the profile is saved. Only dropped piles, and one id per gun, so a found field copy in an ordinary box never costs the host his own gun, and solo play is untouched. Check 17.06 fails on v17.05',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
