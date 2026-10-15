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

# ONE ROW ON THE STASH (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'

      if(P.stashChip&&!stashChipN(P.stashChip,keysArr,counts)) P.stashChip='';   // v26.xx (career5): a chip with nothing under it lets go
      { var r4=document.createElement('div'); r4.className='kchips'; r4.id='stashchips';   // the filter chips
        STASH_CHIPS.forEach(function(C){
          var cb=document.createElement('button'); cb.className='kchip'+(((P.stashChip||'')===C[0])?' on':''); cb.setAttribute('data-chip',C[0]||'all');
          cb.innerHTML=C[1]+'<b>'+stashChipN(C[0],keysArr,counts)+'</b>';
          cb.onclick=function(){ P.stashChip=C[0]; saveProfile(); renderHub(); };
          r4.appendChild(cb);
        });
        tb.appendChild(r4); }
'@ @'

'@

SubRx @'
var STASH_CHIPS=[['','ALL'],['med','MEDICAL'],['val','VALUABLES'],['lock','LOCKED']];
'@ @'
// v26.xx (career8), HIS WORD (2026-10-14, on the v27.02 stash): "why 2 menus here?". There is ONE row. VALUABLES ($1,000 or more each) and LOCKED are two more TABS on the category
// row, after KEYS and OTHER and before the search box, counted by the same rule as the others (so no count disagrees with ALL), one selection at a time across the whole row (P.stashTab).
// The second row with its own ALL is gone, and MEDICAL with it (CONSUMABLES covers it). A tab with nothing under it lets go by itself, as OTHER does. A chip a save kept (P.stashChip)
// is moved into the tab once if it was VALUABLES or LOCKED and dropped otherwise.
function stashTabOk(k,t){
  if(!t||t==='all') return true;
  if(t==='val') return ival(k)>=1000;
  if(t==='lock') return stashLocked(k);
  return stashTabOf(k)===t;
}
'@

SubRx @'
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

'@ @'

'@

SubRx @'
A row of FILTER CHIPS
// under the tabs shows ALL, MEDICAL (heals and stims), VALUABLES ($1,000 or more each) and LOCKED, each with its count; one chip is on at a time (P.stashChip, kept in the save; a chip
// with nothing under it lets go by itself), and the armoury row is hidden while a chip is on.
'@ @'
Two more TABS on the category row, VALUABLES ($1,000 or more each) and LOCKED, with their counts, one tab on at a time (career8: it was a second row of chips).
'@

SubRx @'
  '.kchips{display:flex;gap:8px;flex:1 1 100%;align-items:center;padding:8px 0 6px 0}'+
  '.kchip{font-family:var(--f-cond);font-weight:600;font-size:14px;letter-spacing:.12em;text-transform:uppercase;padding:5px 12px;border:1px solid var(--ui-line-hi);color:var(--tx-2);background:rgba(0,0,0,.25);cursor:pointer;clip-path:polygon(7px 0,100% 0,100% 100%,0 100%,0 7px)}'+
  '.kchip b{font-weight:700;margin-left:8px;opacity:.7}'+
  '.kchip.on{color:var(--acc-ink);background:var(--acc);border-color:var(--acc)}'+

'@ @'

'@

SubRx @'
['salvage','SALVAGE'],['key','KEYS'],['other','OTHER']];
'@ @'
['salvage','SALVAGE'],['key','KEYS'],['other','OTHER'],['val','VALUABLES'],['lock','LOCKED']];   // v26.xx (career8): and VALUABLES and LOCKED on the one row
'@

SubRx @'
var cnt=keysArr.filter(function(k){ return T[0]==='all'||tabOf(k)===T[0]; })
'@ @'
var cnt=keysArr.filter(function(k){ return stashTabOk(k,T[0]); })
'@

SubRx @'
if(T[0]==='other'&&!cnt){ if(P.stashTab==='other') P.stashTab='all'; return; }
'@ @'
if(T[0]==='other'&&!cnt){ if(P.stashTab==='other') P.stashTab='all'; return; }
        if((T[0]==='val'||T[0]==='lock')&&!cnt&&P.stashTab===T[0]) P.stashTab='all';   // v26.xx (career8): an empty VALUABLES or LOCKED lets go
'@

SubRx @'
if(!P.stashTab) P.stashTab='all';
'@ @'
if(P.stashChip!==undefined){ if(P.stashChip==='val'||P.stashChip==='lock') P.stashTab=P.stashChip; delete P.stashChip; }   // v26.xx (career8): the v27.02 chip moves into the tab, once
  if(!P.stashTab) P.stashTab='all';
'@

SubRx @'
var shown=keysArr.filter(function(k){ return P.stashTab==='all'||tabOf(k)===P.stashTab; }).filter(function(k){ return stashChipOk(k); });   // v26.xx (career5): and the chip
'@ @'
var shown=keysArr.filter(function(k){ return stashTabOk(k,P.stashTab); });   // v26.xx (career8): the tab, VALUABLES and LOCKED among them
'@

SubRx @'
if(sl&&!P.stashChip&&(P.stashTab==='all'||P.stashTab==='gun')){   // v26.xx (career5): the armoury row waits while a chip is on
'@ @'
if(sl&&(P.stashTab==='all'||P.stashTab==='gun')){
'@

SubRx @'
if(!shown.length&&sl&&!(!P.stashChip&&(P.stashTab==='gun'||P.stashTab==='all')&&(P.weapons||[]).length)){
'@ @'
if(!shown.length&&sl&&!((P.stashTab==='gun'||P.stashTab==='all')&&(P.weapons||[]).length)){
'@

SubRx @'
var VER='27.20';
'@ @'
var VER='27.21';
'@

$pat = "(?m)^  now:'v27\.20:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v27.21: The stash filter is one row of tabs again, with VALUABLES and LOCKED on it. Check 27.21 fails on v27.20',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
