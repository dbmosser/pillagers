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

if ($s.Contains("  {v:'27.21',what:")) { throw "check 27.21 is in the fixture already" }

SubRx @'
  {v:'27.20',what:
'@ @'
  {v:'27.21',what:'career8, his word on the v27.02 stash, why 2 menus: there is ONE filter row with ONE ALL, VALUABLES and LOCKED are tabs on it before the search box, no MEDICAL and no chips row, one tab selected at a time, the counts agree with ALL, the lock stays, and a saved chip moves into the tab',
   run:function(){
     if(!(window.__P&&window.__applyLoaded)) return 'SKIP: this fixture has no profile';
     if(typeof stashLocked!=='function'||typeof stashTabOk!=='function') return 'there is no one-row stash in this build';
     var bad=[], snap=null, q, hub=document.getElementById('hub'), hubWas=hub.classList.contains('on'), i, tabs, labs, on, n, seenK, tb, ix, allN, valN, lockN, t, cellsN;
     function tabsNow(){ return Array.prototype.slice.call(document.querySelectorAll('#stashtabs .invtab')); }
     function pick(w){ var tt=tabsNow(), j; for(j=0;j<tt.length;j++) if(tt[j].textContent.indexOf(w)===0){ tt[j].click(); return true; } bad.push('no tab '+w); return false; }
     function cellCount(){ return document.querySelectorAll('#stashgrid .cell').length; }
     function numOf(el){ var m=/(\d+)\s*$/.exec(el.textContent); return m?+m[1]:-1; }
     try{
       snap=JSON.parse(JSON.stringify(__P()));
       __topClear(); __runPrep(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       q=__P(); q.stash=['scrap','scrap','wire','cell','bandage','medkit','gun_smg','optic','gun_rifle','gun_lmg']; q.kit=[]; q.keep={core:1,scrap:1}; q.junk={}; q.stashSort='default'; q.stashTab='all'; q.weapons=['pistol']; delete q.stashChip;
       q.stash.push('core');
       hub.classList.add('on');
       renderHub();
       // ONE: one filter row, one ALL, no chips, no MEDICAL
       if(document.getElementById('stashchips')||document.querySelector('.kchip')) bad.push('ONE: a second row of chips is still drawn');
       tabs=tabsNow(); labs=tabs.map(function(e){ return e.textContent; });
       n=labs.filter(function(s){ return s.indexOf('ALL')===0; }).length;
       if(n!==1) bad.push('ONE: '+n+' tabs start with ALL ('+labs.join('|')+')');
       if(labs.join('|').indexOf('MEDICAL')>=0) bad.push('ONE: a MEDICAL tab is still there');
       ix={}; labs.forEach(function(s,k){ ['KEYS','VALUABLES','LOCKED','ARMORY'].forEach(function(w){ if(s.indexOf(w)===0) ix[w]=k; }); });
       if(ix.VALUABLES===undefined||ix.LOCKED===undefined) bad.push('ONE: VALUABLES and LOCKED are not tabs ('+labs.join('|')+')');
       else if(!(ix.VALUABLES>ix.KEYS&&ix.LOCKED>ix.VALUABLES)) bad.push('ONE: the tab order is wrong ('+labs.join('|')+')');
       tb=document.getElementById('stashtabs'); n=0; if(tb) Array.prototype.forEach.call(tb.children,function(c){ if(c.classList.contains('invtabs')) n++; });
       if(document.querySelectorAll('#stashtabs .kchips').length) bad.push('ONE: a chip row exists');
       // TWO: the counts follow the same rule
       allN=numOf(tabs[0]); valN=-1; lockN=-1;
       tabs.forEach(function(e){ if(e.textContent.indexOf('VALUABLES')===0) valN=numOf(e); if(e.textContent.indexOf('LOCKED')===0) lockN=numOf(e); });
       seenK={}; n=0; q.stash.forEach(function(k){ if(ival(k)>=1000) n++; });
       if(valN!==n) bad.push('TWO: VALUABLES counts '+valN+', not '+n);
       n=0; q.stash.forEach(function(k){ if(stashLocked(k)) n++; });
       if(lockN!==n) bad.push('TWO: LOCKED counts '+lockN+', not '+n);
       if(!(allN>=valN&&allN>=lockN)) bad.push('TWO: ALL counts '+allN+' against '+valN+' valuable and '+lockN+' locked');
       if(allN!==q.stash.length+q.weapons.length) bad.push('TWO: ALL counts '+allN+', not '+(q.stash.length+q.weapons.length));
       // THREE: one tab on at a time; VALUABLES and LOCKED filter the grid
       if(pick('VALUABLES')){
         on=tabsNow().filter(function(e){ return e.classList.contains('on'); });
         if(on.length!==1||on[0].textContent.indexOf('VALUABLES')!==0) bad.push('THREE: '+on.length+' tabs on after VALUABLES');
         n=0; seenK={}; q.stash.forEach(function(k){ if(!seenK[k]){ seenK[k]=1; if(ival(k)>=1000) n++; } });
         if(cellCount()!==n) bad.push('THREE: VALUABLES shows '+cellCount()+' cells, not '+n);
       }
       if(pick('LOCKED')){
         on=tabsNow().filter(function(e){ return e.classList.contains('on'); });
         if(on.length!==1||on[0].textContent.indexOf('LOCKED')!==0) bad.push('THREE: '+on.length+' tabs on after LOCKED');
         n=0; seenK={}; q.stash.forEach(function(k){ if(!seenK[k]&&stashLocked(k)){ seenK[k]=1; n++; } });
         if(cellCount()!==n) bad.push('THREE: LOCKED shows '+cellCount()+' cells, not '+n);
       }
       if(pick('GUNS')){
         on=tabsNow().filter(function(e){ return e.classList.contains('on'); });
         if(on.length!==1) bad.push('THREE: '+on.length+' tabs on after GUNS');
       }
       // FOUR: the lock is still there: star, menu, never sold, pinned first
       q.stashTab='all'; q.junk={scrap:1,wire:1}; q.stashSort='value'; renderHub();
       if(document.querySelectorAll('#stashgrid .cell.kept').length<1||!document.querySelector('#stashgrid .cell.kept .kstar')) bad.push('FOUR: no starred cell');
       if(sellable('scrap')) bad.push('FOUR: a locked item is sellable');
       t=itemMenuRows('scrap','stash',2).map(function(r){ return r.label||''; }).join('|');
       if(t.indexOf('Unlock')<0||t.indexOf('Sell one')>=0) bad.push('FOUR: the menu of a locked item reads '+t);
       // FIVE: an empty LOCKED tab lets go, and a saved chip moves into the tab once
       q.stashTab='lock'; delete q.keep; renderHub();
       if(q.stashTab!=='all') bad.push('FIVE: an empty LOCKED tab stayed on ('+q.stashTab+')');
       q.keep={core:1}; q.stashTab='all'; q.stashChip='lock'; renderHub();
       if(q.stashTab!=='lock'||q.stashChip!==undefined) bad.push('FIVE: a saved LOCKED chip did not move into the tab (tab '+q.stashTab+', chip '+q.stashChip+')');
       q.stashTab='all'; q.stashChip='med'; renderHub();
       if(q.stashTab!=='all'||q.stashChip!==undefined) bad.push('FIVE: a saved MEDICAL chip was not dropped (tab '+q.stashTab+', chip '+q.stashChip+')');
       delete q.keep;
       try{ q.stashTab='all'; renderHub(); }catch(ex){ bad.push('FIVE: a save with no locks threw: '+(ex&&ex.message||ex)); }
     }catch(x2){ bad.push('threw: '+(x2&&x2.message||x2)); }
     finally{
       try{ if(!hubWas) hub.classList.remove('on'); }catch(_h){}
       try{ if(snap) __applyLoaded(snap); }catch(_r){}
       try{ __topClear(); __resetCfg(); __cleanProfile(); }catch(_c){}
     }
     return bad.length?bad.slice(0,8).join('; '):null; }},
  {v:'27.20',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
