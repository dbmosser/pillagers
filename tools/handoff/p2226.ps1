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

# A GUN TAKES ITS ROUNDS WITH IT (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
function takeRounds(id,mag){
  var m=G.stowAmmo, q=m&&m[id];
  if(q&&q.length) return Math.min(mag,Math.max(0,q.shift()|0));
  return Math.ceil(mag/2);
}
'@ @'
function takeRounds(id,mag){
  var m=G.stowAmmo, q=m&&m[id];
  if(q&&q.length) return Math.min(mag,Math.max(0,q.shift()|0));
  return Math.ceil(mag/2);
}
// v22.26, from the whole-game bug hunt of 2026-10-08 (K37): A STOWED GUN'S ROUNDS LEAVE WITH THE GUN. Only takeRounds ever took an
// entry off the queue, so a gun sold at the stall, handed to a teammate or the hire, or taken by a teammate out of a pile left its
// rounds queued, and the next gun of that model taken from the backpack came up with the old load (often an empty magazine) instead
// of half a magazine. Each of those now drops the oldest entry. A gun lying in his own pile keeps its entry: he may search it back up.
function dropRounds(id){ var q=(typeof G!=='undefined'&&G&&G.stowAmmo)?G.stowAmmo[id]:null; if(q&&q.length) q.shift(); }
'@

SubRx @'
    tot+=Math.round(ival(k)*pedBuyRate()); full+=ival(k); n++; if(k==='bandage') _soldB++;   // v15.36, peddler audit finding 8: a found Bandage he buys
'@ @'
    tot+=Math.round(ival(k)*pedBuyRate()); full+=ival(k); n++; if(k==='bandage') _soldB++;   // v15.36, peddler audit finding 8: a found Bandage he buys
    if(ITEMS[k]&&ITEMS[k].use==='gun'&&ITEMS[k].gk) dropRounds(ITEMS[k].gk);   // v22.26 (K37): a gun sold takes its stowed rounds with it
'@

SubRx @'
              G.bag.splice(_gix,1);
'@ @'
              G.bag.splice(_gix,1);
              if(ITEMS[d.key]&&ITEMS[d.key].use==='gun'&&ITEMS[d.key].gk) dropRounds(ITEMS[d.key].gk);   // v22.26 (K37): a gun given to the hire takes its stowed rounds with it
'@

SubRx @'
    G.bag.splice(ix,1);
    var ib=0;
'@ @'
    G.bag.splice(ix,1);
    if(ITEMS[go.k]&&ITEMS[go.k].use==='gun'&&ITEMS[go.k].gk) dropRounds(ITEMS[go.k].gk);   // v22.26 (K37): a gun handed over takes its stowed rounds with it
    var ib=0;
'@

SubRx @'
  gk=netClean(m.k,24); if(!gk||!WEAPONS[gk]) return 'bad';
'@ @'
  gk=netClean(m.k,24); if(!gk||!WEAPONS[gk]) return 'bad';
  if(!m.late&&typeof G!=='undefined'&&G) dropRounds(gk);   // v22.26 (K37): a gun a teammate took out of his pile takes its stowed rounds with it
'@

SubRx @'
  if(G.sim||!ct||!ct.dropped||!items||!G.spliced||!G.spliced.length) return 0;
'@ @'
  if(!G.sim&&ct&&ct.dropped&&!(typeof ct.dropBy==='number'&&ct.dropBy>0)&&items) for(i=0;i<items.length;i++){ it=ITEMS[items[i]]; if(it&&it.use==='gun'&&it.gk) dropRounds(it.gk); }   // v22.26 (K37): a gun from the host's own pile a teammate took takes its stowed rounds with it
  if(G.sim||!ct||!ct.dropped||!items||!G.spliced||!G.spliced.length) return 0;
'@

SubRx @'
var VER='22.25';
'@ @'
var VER='22.26';
'@

$pat = "(?m)^  now:'v22\.25:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v22.26: A gun that leaves your backpack takes its stowed rounds with it, so the next one of that model comes up on half a magazine. Check 22.26 fails on v22.25',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
