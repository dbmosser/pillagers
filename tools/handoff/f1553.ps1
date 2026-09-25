$ErrorActionPreference = 'Stop'
trap { Write-Output "FAILED: $_"; exit 1 }
$p = 'C:\claudecode\dark raiders\tools\mkfixture.ps1'
$s = [IO.File]::ReadAllText($p)
$n = 0
function SubRx([string]$old, [string]$new) {
  $pat = ($old -split "`n" | ForEach-Object { [regex]::Escape($_.TrimEnd("`r")) }) -join "\r?\n"
  $c = ([regex]::Matches($script:s, $pat)).Count
  if ($c -ne 1) { throw "regex matched $c times: $($old.Substring(0,[Math]::Min(70,$old.Length)))" }
  $script:s = [regex]::Replace($script:s, $pat, { param($m) $new })
  $script:n++
}

SubRx @'
  {v:'15.52',what:
'@ @'
  {v:'15.53',what:'SLOT A DATA CORE says when it takes a packed core out of the backpack: with one core loose and one packed it spends the loose one and says nothing of the backpack, with only a packed core it unpacks it, lets its belt key go and names it in the core line, and Arm on the ascent check does the same (rack audit finding)',
   run:function(){
     if(typeof slotCore!=='function'||typeof spendHeld!=='function'||typeof heldCount!=='function'||typeof packedCount!=='function'||typeof stageKitLive!=='function'||!ITEMS.core||!window.__applyLoaded) return 'SKIP: no Mainframe core slot or packing in this build';
     if(typeof say2!=='function') return 'SKIP: no Undercroft answer line in this build';
     if(typeof HOTBAR_N!=='number'||HOTBAR_N<4) return 'SKIP: the tactical belt has fewer than four keys in this build';
     if(G&&!G.over) return 'SKIP: a raid is running, and a core is slotted in the Undercroft';
     var bad=[], snap=null, _say=say, _say2=say2, said=[];
     // A later control that cannot run keeps a failure already found, so the old build fails rather than skips.
     var skip=function(m){ return bad.length?(bad.join('; ')+' (then SKIP: '+m+')'):('SKIP: '+m); };
     // That many cores in the stash, that many of them packed, a packed core bound to belt key 4, nothing slotted, and no freebie
     // kit taken, so the packing is live in P.kit rather than set aside for USE MY OWN GEAR.
     function stage(held,packed){
       var q=__P(), j;
       q.intel=0; q.freeKit=0; q.kitSaved=null; q.stash=[]; q.kit=[]; q.hotAssign={};
       for(j=0;j<held;j++) q.stash.push('core');
       for(j=0;j<packed;j++) q.kit.push('core');
       if(packed) q.hotAssign[3]='core';
     }
     function beltKey(){ return (__P().hotAssign||{})[3]; }
     try{
       __topClear(); __cleanProfile();
       snap=JSON.parse(JSON.stringify(__P()));
       // A raid an earlier check ended leaves G set, and say then writes G.msg rather than the Undercroft toast, so both lines are
       // read from say and say2 themselves: in the Undercroft the toast shows that text word for word.
       say=function(m){ said.push(String(m)); };
       say2=function(m){ said.push(String(m)); };
       // CONTROL: two cores, one of them packed and on the belt. A loose core covers the slot, so the packed one and its key stay
       // and the line says nothing of the backpack, on the old build and the new.
       stage(2,1);
       if(heldCount('core')!==2||packedCount('core')!==1||beltKey()!=='core') return 'SKIP: two cores with one packed on a belt key did not take here';
       said=[]; slotCore();
       var t1=said.join(' ');
       if(!__P().intel||t1.indexOf('Core slotted')<0) return 'SKIP: SLOT A DATA CORE with two cores in the stash slotted nothing here ('+t1.slice(0,80)+')';
       if(heldCount('core')!==1||packedCount('core')!==1||beltKey()!=='core') bad.push('with one core loose and one packed, SLOT A DATA CORE no longer spent the loose one first ('+heldCount('core')+' held, '+packedCount('core')+' packed, belt key '+(beltKey()||'empty')+')');
       if(t1.indexOf('packed')>=0||t1.indexOf('backpack')>=0) bad.push('a core slotted from a loose copy says: '+t1.slice(0,160));
       // THE FIX, ONE: the only core is packed and on the belt.
       stage(1,1);
       if(heldCount('core')!==1||packedCount('core')!==1||beltKey()!=='core') return skip('one packed core on a belt key did not take here');
       said=[]; slotCore();
       var t2=said.join(' ');
       // CONTROL: the core was slotted and spent.
       if(!__P().intel||heldCount('core')!==0||t2.indexOf('Core slotted')<0) return skip('SLOT A DATA CORE with one packed core slotted nothing here ('+t2.slice(0,80)+')');
       if(t2.indexOf('1 packed Data Core')<0||t2.indexOf('backpack')<0) bad.push('SLOT A DATA CORE took the only core, packed for the next ascent, out of the backpack and said only: '+t2.slice(0,160));
       if(beltKey()!==undefined) bad.push('SLOT A DATA CORE took the only packed core and left belt key 4 on '+beltKey()+', which is gone');
       // THE FIX, TWO: the Arm button on the Intel row of the ascent check, the same staging. No route opens that window today,
       // so its row is drawn by the same call every change on it makes.
       var sl=document.getElementById('stageload');
       if(typeof renderStage!=='function'||!sl) return skip('no ascent check Intel row in this document');
       stage(1,1);
       try{ renderStage(); }catch(e3){ return skip('the ascent check would not draw here: '+(e3&&e3.message||e3)); }
       var arm=null, bs=sl.querySelectorAll('button');
       for(var i=0;i<bs.length;i++) if(String(bs[i].textContent||'').trim()==='Arm') arm=bs[i];
       if(!arm||typeof arm.onclick!=='function') return skip('the ascent check offered no Arm with one packed core in the stash here');
       said=[]; arm.onclick();
       var t3=said.join(' ');
       // CONTROL: the core was armed and spent.
       if(!__P().intel||heldCount('core')!==0) return skip('Arm on the ascent check armed no core here');
       if(t3.indexOf('1 packed Data Core')<0||t3.indexOf('backpack')<0) bad.push('Arm on the ascent check took the only core, packed for the next ascent, out of the backpack and said '+(t3?t3.slice(0,160):'nothing'));
       if(beltKey()!==undefined) bad.push('Arm on the ascent check took the only packed core and left belt key 4 on '+beltKey()+', which is gone');
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{
       say=_say; say2=_say2;
       try{ if(snap) __applyLoaded(snap); }catch(_r){}
       try{ renderMainframe(); }catch(_m){}
       try{ renderStage(); }catch(_st){}
       try{ __topClear(); __cleanProfile(); }catch(_c){}
     }
     return bad.length?bad.join('; '):null; }},
  {v:'15.52',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
