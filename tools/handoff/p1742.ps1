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

# STASH SEARCH AND SORT (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
function stashTabOf(k){
'@ @'
// v17.42, HIS PICK 25 (2026-09-30): stash search and sort. STASH_Q is the search text (this page only, not saved);
// P.stashSort the sort, kept in the save. The search hides cells whose name does not match, so the box keeps focus.
var STASH_Q='';
var STASH_SORTS={'default':'DEFAULT',value:'VALUE',name:'NAME',rarity:'RARITY',count:'COUNT'};
function stashSortKeys(a,counts){
  var m=(typeof P!=='undefined'&&P&&P.stashSort)||'default';
  if(m==='default'||!a||!a.sort) return a;
  a.sort(function(x,y){
    var X=ITEMS[x]||{}, Y=ITEMS[y]||{};
    if(m==='value') return ival(y)-ival(x);
    if(m==='name') return String(X.name||x).localeCompare(String(Y.name||y));
    if(m==='rarity') return ((_RRANK[Y.r]||0)-(_RRANK[X.r]||0))||(ival(y)-ival(x));
    if(m==='count') return ((counts&&counts[y])||0)-((counts&&counts[x])||0);
    return 0;
  });
  return a;
}
function stashFilterApply(){
  var z=document.getElementById('stashgrid'), q=String(STASH_Q||'').trim().toLowerCase(), cs, i, t, on, n=0;
  if(!z) return 0;
  cs=z.querySelectorAll('.cell');
  for(i=0;i<cs.length;i++){ t=String(cs[i].title||'').split('\n')[0].toLowerCase(); on=!q||t.indexOf(q)>=0; cs[i].style.display=on?'':'none'; if(on) n++; }
  return n;
}function stashTabOf(k){
'@

SubRx @'
      tb.appendChild(r2);
'@ @'
      tb.appendChild(r2);
      // v17.42, HIS PICK 25 (2026-09-30): SEARCH AND SORT. A box filters the stash by name as he types (ESC or TAB clears it
      // first, then closes as before), and SORT cycles DEFAULT, VALUE, NAME, RARITY and COUNT, kept in the save.
      var r3=document.createElement('div'); r3.className='invtabs'; r3.style.cssText='padding:4px 0 0 0;gap:6px;display:flex;align-items:center';
      var sq=document.createElement('input'); sq.id='stashsearch'; sq.type='text'; sq.placeholder='search the stash'; sq.value=STASH_Q;
      sq.style.cssText='flex:1;min-width:0;font-size:11px;padding:3px 6px';
      sq.oninput=function(){ STASH_Q=sq.value; stashFilterApply(); };
      sq.onkeydown=function(ev){ if((ev.code==='Escape'||ev.code==='Tab')&&sq.value){ sq.value=''; STASH_Q=''; stashFilterApply(); ev.preventDefault(); ev.stopPropagation(); } };
      var sb=document.createElement('div'); sb.className='invtab'; sb.id='stashsort'; sb.style.fontSize='10.5px';
      sb.textContent='SORT: '+(STASH_SORTS[P.stashSort||'default']||'DEFAULT');
      sb.onclick=function(){ var ks=Object.keys(STASH_SORTS), i=ks.indexOf(P.stashSort||'default'); P.stashSort=ks[(i+1)%ks.length]; saveProfile(); renderHub(); };
      r3.appendChild(sq); r3.appendChild(sb); tb.appendChild(r3);
'@

SubRx @'
  var shown=keysArr.filter(function(k){ return P.stashTab==='all'||tabOf(k)===P.stashTab; });
'@ @'
  var shown=keysArr.filter(function(k){ return P.stashTab==='all'||tabOf(k)===P.stashTab; });
  stashSortKeys(shown,counts);   // v17.42: his pick 25, the sort he chose
'@

SubRx @'
    sl.appendChild(em2);
  }
'@ @'
    sl.appendChild(em2);
  }
  stashFilterApply();   // v17.42: his pick 25, the search holds across a redraw
'@

SubRx @'
var VER='17.41';
'@ @'
var VER='17.42';
'@

$pat = "(?m)^  now:'v17\.41:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v17.42: STASH SEARCH AND SORT, his pick from the feature list, beside the tabs he already had: a search box filters the stash by name as he types (ESC or TAB clears it first), and a SORT button cycles default, value, name, rarity and count, kept in the save. Check 17.42 fails on v17.41',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
