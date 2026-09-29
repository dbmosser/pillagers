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

# A HIRE IS SPENT AT THE LIFT, SO A REFRESH OR A CLOSED TAB MID-RAID NO LONGER BRINGS HIM BACK FOR FREE (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
  if(NET.on&&NET.role==='host'&&!G.sim) netUpAnnounce(G);   // v15.79: the party is told to ascend into this world (the net section)
'@ @'
  if(NET.on&&NET.role==='host'&&!G.sim) netUpAnnounce(G);   // v15.79: the party is told to ascend into this world (the net section)
  // v17.21, co-op hunt 2026-09-28: THE HIRE IS SPENT AT THE LIFT, as the Data Core below is. It was spent only in endRaid, so a
  // raid that ended by the page going away (F5, a closed tab, a crash) left him hired in the save and the next ascent dropped him
  // in again with no fee. The raid keeps his id and endRaid settles him from it as before; P.mercOut is the saved marker the
  // loader bills a page-away death benefit from. After the party word above, which carries the hire to the party, and never on
  // a party guest build (NET.upHold), whose own hire is not the man who went up.
  if(P.merc&&!G.sim&&!NET.upHold){ G.mercId=P.merc; P.mercOut={id:P.merc,dead:0}; P.merc=null; saveProfile(); }
'@

SubRx @'
        rec3.deaths++; saveProfile();
'@ @'
        rec3.deaths++; if(G.mercId&&P.mercOut&&typeof P.mercOut==='object') P.mercOut.dead=1; saveProfile();   // v17.21, co-op hunt 2026-09-28: the save says he died, so a page-away still bills him
'@

SubRx @'
  if(!G.sim&&P) delete P.raidSpliced;
'@ @'
  if(!G.sim&&P) delete P.raidSpliced;
  // v17.21, co-op hunt 2026-09-28: the hire this raid spent at the lift (startRaid) is settled below from P.merc as it always was,
  // and an instant quit keeps him; the saved marker the loader bills a page-away death from is done with.
  if(!G.sim&&P){ delete P.mercOut; if(G.mercId&&!P.merc) P.merc=G.mercId; }
'@

SubRx @'
          delete P.raidSpliced;
'@ @'
          delete P.raidSpliced;
          // v17.21, co-op hunt 2026-09-28: a hire is spent at the lift, so a raid that ended by the page going away leaves no hire
          // to drop in again for free. If he died up there first, his death benefit is billed here, as the card would have billed it.
          if(P.mercOut&&typeof P.mercOut==='object'&&P.mercOut.dead){ P.credits-=MERC_DEATH; if(typeof P.mercOut.id==='string'){ var _moR=idRec(P.mercOut.id); _moR.standing=Math.min(_moR.standing,-1); } }
          delete P.mercOut;
'@

SubRx @'
var VER='17.20';
'@ @'
var VER='17.21';
'@

$pat = "(?m)^  now:'v17\.20:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v17.21: Co-op hunt 2026-09-28, hire: P.merc was cleared only by the settle inside endRaid, and nothing at the lift or in the loader touched it, so after F5, a closed tab or a crash mid-raid the save still held the hire and the next buildRaid spawned him again with no fee; G.mercDead lived only in the raid, so the death benefit was never billed either. startRaid now spends the hire after the party word (netUpAnnounce) and never on a party guest build (NET.upHold): the raid keeps his id in G.mercId, P.merc is cleared and a saved marker P.mercOut is written. His death marks the marker dead in the save it already makes. endRaid puts G.mercId back into P.merc at its top, so the settle below and the instant quit branch (which keeps the hire) work as before, and drops the marker. The loader bills MERC_DEATH and marks his standing down, as the card would, when the marker says he died, then drops it. No number moved and no new words. Check 17.21 fails on v17.20',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
