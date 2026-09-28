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

# AN ISSUED BANDAGE STAYS A LOANER WHEN IT PASSES BETWEEN TEAMMATES (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
          tm:+(+(ct.time||1)).toFixed(2),d:(typeof ct.d==='number')?ct.d:-1,dr:ct.dropped?1:0,op:ct.opened?1:0,n:ct.loot?ct.loot.length:0};
'@ @'
          tm:+(+(ct.time||1)).toFixed(2),d:(typeof ct.d==='number')?ct.d:-1,dr:ct.dropped?1:0,op:ct.opened?1:0,n:ct.loot?ct.loot.length:0,
          ib:ct.issuedB?1:0};   // v17.07, co-op hunt 2026-09-28: a pile holding an issued Bandage says so, so it stays a loaner on the window that takes it
'@

SubRx @'
  if(m.ca) ct.cache=1; if(m.sg) ct.strong=1; if(m.cp) ct.camp=1; if(m.dr) ct.dropped=1;
'@ @'
  if(m.ca) ct.cache=1; if(m.sg) ct.strong=1; if(m.cp) ct.camp=1; if(m.dr) ct.dropped=1;
  if(m.ib) ct.issuedB=1;   // v17.07, co-op hunt 2026-09-28: grantLoot puts it back on this window issued count, as a pile of his own would
'@

SubRx @'
  p[arm?'prepA':'prep'].aid=s;
'@ @'
  p[arm?'prepA':'prep'].aid=s;
  // v17.07, co-op hunt 2026-09-28: an issued Bandage held out to a teammate is spent from the issued count here, as dropItem does
  // (and from what the count last saw, so the frame tracker does not spend it twice), and the wind-up remembers it, so if the
  // teammate walks off and it comes back it goes back on the count. It came back as a find and was banked at the extraction.
  if(!arm&&key==='bandage'&&(G.issuedBandages||0)>0){ G.issuedBandages--; if(G.bandSeen!==undefined) G.bandSeen--; p.prep.issB=1; }
'@

SubRx @'
  if(!g||!netUpShown(g)||g.dn||Math.hypot(g.x-p.x,g.y-p.y)>NET_REV_R*1.5){ G.bag.push(PR.key); say(nm+' moved away. '+(it?it.name:'It')+' kept.'); return false; }
'@ @'
  if(!g||!netUpShown(g)||g.dn||Math.hypot(g.x-p.x,g.y-p.y)>NET_REV_R*1.5){
    G.bag.push(PR.key);
    if(PR.issB){ G.issuedBandages=(G.issuedBandages||0)+1; if(G.bandSeen!==undefined) G.bandSeen++; }   // v17.07, co-op hunt 2026-09-28: still a loaner
    say(nm+' moved away. '+(it?it.name:'It')+' kept.'); return false;
  }
'@

SubRx @'
var VER='17.06';
'@ @'
var VER='17.07';
'@

$pat = "(?m)^  now:'v17\.06:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v17.07: Co-op, issued Bandages banked as finds. A drop keeps an issued Bandage issued by marking the pile issuedB (v13.90), but netContNewWord did not carry the mark, so the copy player 2 window builds in netContMake had none and grantLoot on his window counted the Bandage as found, banked at his extraction. The word now carries ib and netContMake sets issuedB, so grantLoot raises the issued count on the window that takes it. The teammate heal spliced the Bandage out and the frame tracker spent it from the issued count, then netAidFinish pushed it back when the teammate walked off and the tracker read that as a find. netAidStart now spends an issued Bandage from the count itself, as dropItem does (with G.bandSeen so it is not spent twice), and marks the wind-up issB; the moved away branch of netAidFinish puts it back on the count. A finished heal still spends it as before. No number moved. Check 17.07 fails on v17.06',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
