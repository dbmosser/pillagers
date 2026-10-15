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

# STASH SORT, FILTER AND LOCK (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
var STASH_SORTS={'default':'DEFAULT',value:'VALUE',name:'NAME',rarity:'RARITY',count:'COUNT'};
'@ @'
var STASH_SORTS={'default':'DEFAULT',value:'VALUE',name:'NAME',rarity:'RARITY',count:'COUNT',type:'TYPE'};   // v26.xx (career5): and TYPE
'@

SubRx @'
if(m==='count') return ((counts&&counts[y])||0)-((counts&&counts[x])||0);
'@ @'
if(m==='type'){ var _to=['gun','use','part','salvage','key','other']; return (_to.indexOf(stashTabOf(x))-_to.indexOf(stashTabOf(y)))||(ival(y)-ival(x)); }   // v26.xx (career5): the stash sorted by type
    if(m==='count') return ((counts&&counts[y])||0)-((counts&&counts[x])||0);
'@

SubRx @'
function stashSortKeys(a,counts){
'@ @'
// v26.xx (career5), HIS YES (2026-10-14) to suggestion 34, STASH SORT, FILTER AND LOCK: "sort by type, rarity or value; filter chips; and a lock on an item so it is never sold or
// moved by sorting". SORT gains TYPE beside DEFAULT, VALUE, NAME, RARITY and COUNT (guns, supplies, parts, salvage, keys, the rest, the dearer first inside each). A row of FILTER CHIPS
// under the tabs shows ALL, MEDICAL (heals and stims), VALUABLES ($1,000 or more each) and LOCKED, each with its count; one chip is on at a time (P.stashChip, kept in the save; a chip
// with nothing under it lets go by itself), and the armoury row is hidden while a chip is on. THE LOCK is per item: Lock (keep) on the item menu (right-click, or Y on a controller)
// and a Lock button on the hover line put a star on the cell and the item in P.keep (item key to 1, an old save has none). A locked item is never sold by SELL JUNK AND LOOSE SALVAGE
// (sellable says no, even for a tagged junk item), has no Sell one or Sell all on its menu or its hover line, and is pinned to the front of the grid whatever the sort, so no sort
// moves it. Locking changes nothing else: the item can still be packed, put on a key and used.
var STASH_CHIPS=[['','ALL'],['med','MEDICAL'],['val','VALUABLES'],['lock','LOCKED']];
function stashLocked(k){ return !!(P&&P.keep&&typeof P.keep==='object'&&P.keep[k]); }
function stashLockToggle(k){
  if(!P||!ITEMS[k]) return false;
  if(!P.keep||typeof P.keep!=='object'||Array.isArray(P.keep)) P.keep={};
  if(P.keep[k]) delete P.keep[k]; else P.keep[k]=1;
  try{ saveProfile(); }catch(_s){}
  return !!P.keep[k];
}
function stashChipOk(k,c){
  var t=ITEMS[k];
  if(c===undefined) c=(P&&P.stashChip)||'';
  if(!c) return true;
  if(c==='lock') return stashLocked(k);
  if(!t) return false;
  if(c==='med') return t.use==='heal'||t.use==='stim';
  if(c==='val') return ival(k)>=1000;
  return true;
}
function stashChipN(c,keys,counts){
  var n=0, i;
  for(i=0;i<keys.length;i++) if(stashChipOk(keys[i],c)) n+=(counts&&counts[keys[i]])||1;
  return n;
}
function stashPinLocked(a){
  var lk=[], rest=[], i;
  if(!a||!a.length) return a;
  for(i=0;i<a.length;i++){ if(stashLocked(a[i])) lk.push(a[i]); else rest.push(a[i]); }
  if(!lk.length) return a;
  a.length=0;
  for(i=0;i<lk.length;i++) a.push(lk[i]);
  for(i=0;i<rest.length;i++) a.push(rest[i]);
  return a;
}
careerStyle('careercss5',
  '.kchips{display:flex;gap:8px;flex:1 1 100%;align-items:center;padding:8px 0 6px 0}'+
  '.kchip{font-family:var(--f-cond);font-weight:600;font-size:14px;letter-spacing:.12em;text-transform:uppercase;padding:5px 12px;border:1px solid var(--ui-line-hi);color:var(--tx-2);background:rgba(0,0,0,.25);cursor:pointer;clip-path:polygon(7px 0,100% 0,100% 100%,0 100%,0 7px)}'+
  '.kchip b{font-weight:700;margin-left:8px;opacity:.7}'+
  '.kchip.on{color:var(--acc-ink);background:var(--acc);border-color:var(--acc)}'+
  '#stashgrid .cell.kept{box-shadow:inset 0 0 0 1px var(--acc)}'+
  '#stashgrid .cell .kstar{position:absolute;left:3px;top:1px;font-size:14px;line-height:1;color:var(--acc);pointer-events:none}');
function stashSortKeys(a,counts){
'@

SubRx @'
var shown=keysArr.filter(function(k){ return P.stashTab==='all'||tabOf(k)===P.stashTab; });
'@ @'
var shown=keysArr.filter(function(k){ return P.stashTab==='all'||tabOf(k)===P.stashTab; }).filter(function(k){ return stashChipOk(k); });   // v26.xx (career5): and the chip
'@

SubRx @'
stashSortKeys(shown,counts);   // v17.42: his pick 25, the sort he chose
'@ @'
stashSortKeys(shown,counts);   // v17.42: his pick 25, the sort he chose
  stashPinLocked(shown);   // v26.xx (career5): a locked item stays at the front, whatever the sort
'@

SubRx @'
r3.appendChild(sq); r3.appendChild(sb); r3.appendChild(cxb); r3.appendChild(trb); tb.appendChild(r3);
'@ @'
r3.appendChild(sq); r3.appendChild(sb); r3.appendChild(cxb); r3.appendChild(trb); tb.appendChild(r3);
      if(P.stashChip&&!stashChipN(P.stashChip,keysArr,counts)) P.stashChip='';   // v26.xx (career5): a chip with nothing under it lets go
      { var r4=document.createElement('div'); r4.className='kchips'; r4.id='stashchips';   // the filter chips
        STASH_CHIPS.forEach(function(C){
          var cb=document.createElement('button'); cb.className='kchip'+(((P.stashChip||'')===C[0])?' on':''); cb.setAttribute('data-chip',C[0]||'all');
          cb.innerHTML=C[1]+'<b>'+stashChipN(C[0],keysArr,counts)+'</b>';
          cb.onclick=function(){ P.stashChip=C[0]; saveProfile(); renderHub(); };
          r4.appendChild(cb);
        });
        tb.appendChild(r4); }
'@

SubRx @'
if(sl&&(P.stashTab==='all'||P.stashTab==='gun')){
'@ @'
if(sl&&!P.stashChip&&(P.stashTab==='all'||P.stashTab==='gun')){   // v26.xx (career5): the armoury row waits while a chip is on
'@

SubRx @'
if(!shown.length&&sl&&!((P.stashTab==='gun'||P.stashTab==='all')&&(P.weapons||[]).length)){
'@ @'
if(!shown.length&&sl&&!(!P.stashChip&&(P.stashTab==='gun'||P.stashTab==='all')&&(P.weapons||[]).length)){
'@

SubRx @'
cell.className='cell c-'+(dispR(k)||'common')+(isJunk?' junk':'');
'@ @'
cell.className='cell c-'+(dispR(k)||'common')+(isJunk?' junk':'')+(stashLocked(k)?' kept':'');
'@

SubRx @'
cell.innerHTML=iconImgHTML(k,30)+(counts[k]>1?('<span class="cnt">'+counts[k]+'</span>'):'');
'@ @'
cell.innerHTML=iconImgHTML(k,30)+(counts[k]>1?('<span class="cnt">'+counts[k]+'</span>'):'');
    if(stashLocked(k)) cell.innerHTML+='<span class="kstar">\u2605</span>';   // v26.xx (career5): the lock
'@

SubRx @'
(isJunk?'  &middot;  <span style="color:var(--rust)">TAGGED JUNK</span>':'')+
'@ @'
(isJunk?'  &middot;  <span style="color:var(--rust)">TAGGED JUNK</span>':'')+
        (stashLocked(k)?'  &middot;  <span style="color:var(--amber)">LOCKED</span>':'')+
'@

SubRx @'
      act('Sell one',function(){
'@ @'
      act(stashLocked(k)?'Unlock':'Lock',function(){ stashLockToggle(k); renderHub(); });   // v26.xx (career5)
      if(!stashLocked(k)) act('Sell one',function(){
'@

SubRx @'
    rows.push({label:isJ?'Untag junk':'Tag as junk',hint:isJ?null:'$'+ival(key).toLocaleString()+' each',
'@ @'
    rows.push({label:stashLocked(key)?'Unlock':'Lock (keep)',hint:stashLocked(key)?null:'never sold',act:function(){ stashLockToggle(key); refreshInv(); }});   // v26.xx (career5)
    rows.push({label:isJ?'Untag junk':'Tag as junk',hint:isJ?null:'$'+ival(key).toLocaleString()+' each',
'@

SubRx @'
held>0&&_hbS&&_hbS.classList.contains('on')) rows.push({label:'Sell one'
'@ @'
held>0&&_hbS&&_hbS.classList.contains('on')&&!stashLocked(key)) rows.push({label:'Sell one'
'@

SubRx @'
_sn>1&&_hbS&&_hbS.classList.contains('on')) rows.push({label:'Sell all '+_sn
'@ @'
_sn>1&&_hbS&&_hbS.classList.contains('on')&&!stashLocked(key)) rows.push({label:'Sell all '+_sn
'@

SubRx @'
function sellable(k){
'@ @'
function sellable(k){
  if(stashLocked(k)) return false;   // v26.xx (career5): a locked item is never sold by the sell button, tagged junk or not
'@

SubRx @'
var VER='27.01';
'@ @'
var VER='27.02';
'@

$pat = "(?m)^  now:'v27\.01:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v27.02: The stash sorts by type, filters by chip, and any item can be locked. Check 27.02 fails on v27.01',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
