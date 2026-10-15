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

if ($s.Contains("  {v:'27.02',what:")) { throw "check 27.02 is in the fixture already" }

SubRx @'
  {v:'27.01',what:
'@ @'
  {v:'27.02',what:'career5, his yes to stash sort, filter and lock (34): SORT gains TYPE, the chips filter the stash, a locked item is never sold by the sell button (even tagged junk), has no sell on its menu or hover, is starred and stays at the front whatever the sort, and an old save loads',
   run:function(){
     if(!(window.__P&&window.__applyLoaded)) return 'SKIP: this fixture has no profile';
     if(typeof stashLocked!=='function') return 'there is no stash lock in this build';
     var bad=[], snap=null, q, hub=document.getElementById('hub'), hubWas=hub.classList.contains('on'), i, a, rows, labs, chips, cells, n, order, ix, prev, tabs, c0, t, cell, kept, seenK;
     function labels(r){ var o=[],j; for(j=0;j<r.length;j++) if(r[j]&&r[j].label) o.push(r[j].label); return o.join('|'); }
     function cellCount(){ return document.querySelectorAll('#stashgrid .cell').length; }
     try{
       snap=JSON.parse(JSON.stringify(__P()));
       __topClear(); __runPrep(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       q=__P(); q.stash=['scrap','scrap','wire','cell','bandage','medkit','gun_smg','optic','gun_rifle','gun_lmg']; q.kit=[]; q.keep={}; q.junk={}; q.stashSort='default'; q.stashTab='all'; q.stashChip=''; q.weapons=['pistol'];
       hub.classList.add('on');
       // ONE: SORT gains TYPE, and it groups
       if(STASH_SORTS.type!=='TYPE') bad.push('ONE: the sort list has no TYPE');
       q.stashSort='type';
       a=['scrap','gun_smg','bandage','optic','wire','medkit','cell','gun_rifle']; stashSortKeys(a,{});
       order=['gun','use','part','salvage','key','other']; prev=-1; tabs={};
       for(i=0;i<a.length;i++){ ix=order.indexOf(stashTabOf(a[i])); tabs[ix]=1; if(ix<prev){ bad.push('ONE: the TYPE sort has '+a[i]+' after a later group'); break; } prev=ix; }
       if(Object.keys(tabs).length<3) bad.push('ONE: the test items fall in fewer than 3 groups');
       // TWO: the lock
       if(stashLockToggle('scrap')!==true||!stashLocked('scrap')) bad.push('TWO: the lock did not set');
       q.junk.scrap=1; q.junk.wire=1;
       if(sellable('scrap')) bad.push('TWO: a locked, tagged item is sellable');
       if(!sellable('wire')) bad.push('TWO: an unlocked junk item is not sellable');
       c0=q.credits;
       document.getElementById('sellall').onclick();
       n=q.stash.filter(function(s){ return s==='scrap'; }).length;
       if(n!==2) bad.push('TWO: SELL JUNK sold a locked item ('+n+' of 2 left)');
       if(q.stash.indexOf('wire')>=0) bad.push('TWO: SELL JUNK left the unlocked junk');
       if(!(q.credits>c0)) bad.push('TWO: SELL JUNK paid nothing');
       q.stash.push('wire');
       // THREE: the menu and the hover
       rows=itemMenuRows('scrap','stash',2); labs=labels(rows);
       if(labs.indexOf('Unlock')<0) bad.push('THREE: a locked item has no Unlock on its menu ('+labs+')');
       if(labs.indexOf('Sell one')>=0||labs.indexOf('Sell all')>=0) bad.push('THREE: a locked item can be sold from its menu ('+labs+')');
       rows=itemMenuRows('wire','stash',1); labs=labels(rows);
       if(labs.indexOf('Lock (keep)')<0) bad.push('THREE: an unlocked item has no Lock on its menu ('+labs+')');
       if(labs.indexOf('Sell one')<0) bad.push('THREE: an unlocked item lost its Sell one ('+labs+')');
       // FOUR: a locked item stays at the front whatever the sort
       stashLockToggle('cell');
       q.stashSort='value'; a=['gun_rifle','scrap','cell','gun_lmg']; stashSortKeys(a,{}); stashPinLocked(a);
       if(a.slice(0,2).indexOf('cell')<0||a.slice(0,2).indexOf('scrap')<0) bad.push('FOUR: the locked items are not at the front ('+a.join(',')+')');
       // FIVE: the stash draws it, starred, with the chips
       q.stashSort='default'; renderHub();
       kept=document.querySelectorAll('#stashgrid .cell.kept');
       if(kept.length!==2) bad.push('FIVE: '+kept.length+' starred cells for 2 locked items');
       for(i=0;i<kept.length;i++) if(!kept[i].querySelector('.kstar')){ bad.push('FIVE: a locked cell has no star'); break; }
       chips=document.querySelectorAll('#stashchips .kchip');
       if(chips.length!==4) bad.push('FIVE: '+chips.length+' chips, not 4');
       cell=document.querySelector('#stashgrid .cell.kept'); if(cell&&typeof cell.onmouseenter==='function'){ cell.onmouseenter(); t=(document.getElementById('stashacts')||{}).textContent||''; if(t.indexOf('Unlock')<0||t.indexOf('Sell one')>=0) bad.push('FIVE: the hover of a locked item reads "'+t.slice(0,60)+'"'); }
       // SIX: each chip filters
       function press(w){ var b=document.querySelector('#stashchips .kchip[data-chip="'+w+'"]'); if(!b) { bad.push('SIX: no chip '+w); return false; } b.click(); return true; }
       n=0; seenK={}; q.stash.forEach(function(k){ if(!seenK[k]){ seenK[k]=1; if(ITEMS[k]&&(ITEMS[k].use==='heal'||ITEMS[k].use==='stim')) n++; } });
       if(n<1) bad.push('SIX: the test stash holds no medical item');
       if(press('med')&&cellCount()!==n) bad.push('SIX: MEDICAL shows '+cellCount()+' cells, not '+n);
       n=0; seenK={}; q.stash.forEach(function(k){ if(!seenK[k]){ seenK[k]=1; if(ival(k)>=1000) n++; } });
       if(n<1) bad.push('SIX: the test stash holds no valuable item');
       if(press('val')&&cellCount()!==n) bad.push('SIX: VALUABLES shows '+cellCount()+' cells, not '+n);
       if(press('lock')&&cellCount()!==2) bad.push('SIX: LOCKED shows '+cellCount()+' cells, not 2');
       n=0; seenK={}; q.stash.forEach(function(k){ if(!seenK[k]){ seenK[k]=1; n++; } }); n+=(q.weapons||[]).length;
       if(press('all')&&cellCount()!==n) bad.push('SIX: ALL shows '+cellCount()+' cells, not '+n);
       if(q.stashChip) bad.push('SIX: ALL left the chip at '+q.stashChip);
       // SEVEN: a chip with nothing under it lets go, and an old save loads
       q.stashChip='lock'; stashLockToggle('scrap'); stashLockToggle('cell'); renderHub();
       if(q.stashChip) bad.push('SEVEN: an empty LOCKED chip stayed on');
       delete q.keep; delete q.stashChip;
       try{ renderHub(); if(stashLocked('scrap')) bad.push('SEVEN: a save with no locks has a lock'); }catch(ex){ bad.push('SEVEN: an old save threw: '+(ex&&ex.message||ex)); }
     }catch(x2){ bad.push('threw: '+(x2&&x2.message||x2)); }
     finally{
       try{ if(!hubWas) hub.classList.remove('on'); }catch(_h){}
       try{ if(snap) __applyLoaded(snap); }catch(_r){}
       try{ __topClear(); __resetCfg(); __cleanProfile(); }catch(_c){}
     }
     return bad.length?bad.slice(0,8).join('; '):null; }},
  {v:'27.01',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
