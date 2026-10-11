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

# ONE PROMPT AT A TIME (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
  return {w:w,by:y-a-LH(4)+h};
}
'@ @'
  return {w:w,by:y-a-LH(4)+h};
}
// v22.67, the raid text rewrite (R25): ONE PROMPT AT A TIME. With a door he holds the key for and a crate both in reach, both
// prompts said [E], and E did the door first; beside a downed pillager, a survivor and a crate it was three [E] prompts at once.
// promptPick names the one target a held E acts on this frame, read from the order updatePlayer takes E in: a door he has the
// key for (opened first, before anything else looks at E), the seal (cutting returns and owns the key), a downed teammate (his
// revive eats E), a downed pillager, the survivor who wants an item, the Peddler (unless a crate underfoot comes first), the ring
// he stands in (E there calls or extracts instead of searching), then the crate. Only that E prompt is drawn. A locked door with
// no key in the backpack is not an E target (E does nothing there), so its LOCKED label still shows, and so does the search
// prompt inside a ring, which names X, the key that searches there.
function doorKeyIx(door){
  var i, it;
  if(!door||!G||!G.bag) return -1;
  for(i=0;i<G.bag.length;i++){ it=ITEMS[G.bag[i]]; if(it&&it.use==='key'&&it.door===door.id) return i; }
  return -1;
}
function promptPick(p){
  var st;
  if(!G||!p||p.downed||G.over) return '';
  if(G.nearDoor&&doorKeyIx(G.nearDoor)>=0) return 'door';
  if(G.seal&&!G.seal.done&&G.nearSeal) return 'seal';
  try{ if(typeof NET!=='undefined'&&NET&&NET.on&&typeof netMateDown==='function'&&netMateDown(p)>=0) return 'mate'; }catch(_m){}
  if(G.nearDown) return 'down';
  st=G.nearStray; if(st&&st.kind==='stray'&&st.found&&!st.helped&&!st.hostile&&dist(st,p)<=70) return 'give';
  if(G.nearPed&&!G.pedBlocked&&typeof pedOpen==='function'&&pedOpen()) return 'deal';
  if(G.nearPad) return 'ring';
  if(G.nearContainer&&!G.searching) return 'search';
  return '';
}
'@

SubRx @'
  // projected world labels
  if(G.nearDoor&&!(G.player&&G.player.downed)){   // v14.08: not while down
'@ @'
  // projected world labels
  var _pk=promptPick(p);   // v22.67 (R25): the one target a held E acts on; only its E prompt is drawn
  if(G.nearDoor&&!(G.player&&G.player.downed)&&(_pk==='door'||doorKeyIx(G.nearDoor)<0)){   // v14.08: not while down; v22.67 (R25): an UNLOCK prompt only when E acts on it
'@

SubRx @'
  if(G.nearDown&&!p.downed){
'@ @'
  if(G.nearDown&&!p.downed&&_pk==='down'){   // v22.67 (R25): one prompt at a time
'@

SubRx @'
  if(nc2&&!G.searching&&!p.downed){
'@ @'
  if(nc2&&!G.searching&&!p.downed&&(_pk==='search'||G.nearPad)){   // v22.67 (R25): one prompt at a time; in a ring it names X, its own key
'@

SubRx @'
  if(padZ&&!p.downed){
'@ @'
  if(padZ&&!p.downed&&!(_pk&&_pk!=='ring'&&_pk!=='search')){   // v22.67 (R25): one prompt at a time
'@

SubRx @'
    if(G.over||p.downed) return;
    for(var _si=0;
'@ @'
    if(G.over||p.downed||_pk!=='give') return;   // v22.67 (R25): one prompt at a time
    for(var _si=0;
'@

SubRx @'
  if(!G.over&&G.seal&&!G.seal.done&&G.nearSeal&&!p.downed){
'@ @'
  if(!G.over&&G.seal&&!G.seal.done&&G.nearSeal&&!p.downed&&_pk==='seal'){   // v22.67 (R25): one prompt at a time
'@

SubRx @'
      ? (pedOpen()?(G.nearPed===ne?(G.pedBlocked?'THE PEDDLER  (search the crate first)':'THE PEDDLER  ['+keyLabel('KeyE','E')+'] DEAL'):'THE PEDDLER'):'THE PEDDLER  [CLOSED]')
'@ @'
      ? (pedOpen()?(G.nearPed===ne?(G.pedBlocked?'THE PEDDLER  (search the crate first)':(promptPick(G.player)==='deal'?('THE PEDDLER  ['+keyLabel('KeyE','E')+'] DEAL'):'THE PEDDLER')):'THE PEDDLER'):'THE PEDDLER  [CLOSED]')   // v22.67 (R25): DEAL only when E deals
'@

SubRx @'
var VER='22.66';
'@ @'
var VER='22.67';
'@

$pat = "(?m)^  now:'v22\.66:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v22.67: Only one E prompt is drawn at a time, the one a held E acts on. Check 22.67 fails on v22.66',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
