$ErrorActionPreference = 'Stop'
trap { Write-Output "FAILED: $_"; exit 1 }
$p = 'C:\claudecode\dark raiders\tools\mkfixture.ps1'
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

if ($s.Contains("  {v:'17.42',what:")) { throw "check 17.42 is in the fixture already" }

SubRx @'
  {v:'17.41',what:
'@ @'
  {v:'17.42',what:'the stash sorts by name, count, value or rarity from a SORT button kept in the save, and a search box hides every item whose name does not match',
   run:function(){
     if(typeof stashSortKeys!=='function'||typeof stashFilterApply!=='function') return 'this build has no stash search or sort';
     if(typeof renderHub!=='function'||!(window.__P&&window.__applyLoaded&&window.__hubEnter)) return 'SKIP: this fixture cannot reach the Stash screen';
     var zone=document.getElementById('stashgrid'), hub=document.getElementById('hub');
     if(!zone||!hub) return 'SKIP: no stash grid in this document';
     if(G&&!G.over) return 'SKIP: a raid is running';
     var bad=[], snap=null, hubWas=hub.classList.contains('on'), NM={}, k;
     ['scrap','wire','bandage'].forEach(function(x){ if(ITEMS[x]) NM[ITEMS[x].name.toLowerCase()]=x; });
     if(Object.keys(NM).length<3) return 'SKIP: the staged items are missing';
     function order(){ zone=document.getElementById('stashgrid'); var o=[]; [].slice.call(zone.querySelectorAll('.cell')).forEach(function(c){ if(c.style.display==='none') return; var t=String(c.title||'').split('\n')[0].replace(/\s+x\d+$/,'').toLowerCase(); if(NM[t]) o.push(NM[t]); }); return o; }
     try{
       __topClear(); __cleanProfile();
       snap=JSON.parse(JSON.stringify(__P()));
       var q=__P(); q.stash=['scrap','wire','wire','bandage','bandage','bandage']; q.kit=[]; delete q.stashTab; q.stashSort='name';
       try{ __hubEnter(); }catch(_h){}
       renderHub();
       if(!document.getElementById('stashsort')||!document.getElementById('stashsearch')) bad.push('the stash has no SORT button or search box');
       var o=order(), want=Object.keys(NM).sort(function(a,b){ return a.localeCompare(b); }).map(function(n){ return NM[n]; });
       if(o.join()!==want.join()) bad.push('SORT NAME drew '+o.join()+' not '+want.join());
       __P().stashSort='count'; renderHub(); o=order();
       if(o[0]!=='bandage') bad.push('SORT COUNT did not put the three Bandages first ('+o.join()+')');
       STASH_Q=ITEMS.scrap.name.slice(0,4); stashFilterApply(); o=order();
       if(o.join()!=='scrap') bad.push('a search for '+STASH_Q+' left '+o.join()+' showing');
       STASH_Q=''; stashFilterApply(); o=order();
       if(o.length!==3) bad.push('clearing the search did not show every item again ('+o.join()+')');
       var sb=document.getElementById('stashsort'); if(sb){ sb.click(); if(__P().stashSort==='count') bad.push('the SORT button did not move to the next sort'); }
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{
       try{ STASH_Q=''; }catch(_q){}
       try{ if(snap) __applyLoaded(snap); }catch(_r){}
       try{ if(hubWas){ renderHub(); hub.classList.add('on'); } else hub.classList.remove('on'); }catch(_hb){}
       try{ __topClear(); __cleanProfile(); }catch(_c){}
     }
     return bad.length?bad.join('; '):null; }},
  {v:'17.41',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
