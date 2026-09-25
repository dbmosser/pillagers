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
  {v:'15.53',what:
'@ @'
  {v:'15.54',what:'with the freebie kit taken, BUILD A RACK names the packed parts it uses: with one board more than a rack needs and three boards and a Medkit packed, a rack with no freebie kit names the 2 packed boards it takes; after TAKE THE FREEBIE KIT sets that packing aside, the rack names the same 2, the set-aside list keeps 1 board and the Medkit, and the lift question counts what MY LOADOUT then takes up (rack audit finding)',
   run:function(){
     if(typeof buildRack!=='function'||typeof spendHeld!=='function'||typeof packedCount!=='function'||typeof heldCount!=='function'||typeof rackAfford!=='function'||typeof stageKitLive!=='function'||typeof RACK_COST==='undefined'||!window.__applyLoaded) return 'SKIP: no mainframe racks or packing in this build';
     if(typeof renderFreeKit!=='function'||typeof freeKitRestore!=='function'||typeof askKit!=='function') return 'SKIP: no freebie kit button, restore or lift question in this build';
     if(!(RACK_COST.board>=2)||!ITEMS.board||!ITEMS.medkit) return 'SKIP: the rack cost takes fewer than two Circuit Boards in this build';
     if(G&&!G.over) return 'SKIP: a raid is running, and a rack is built in the Undercroft';
     var bad=[], snap=null, _say=say, said=[], _ay=ASKYES, _aa=ASKALT;
     var nm=function(k){ return (ITEMS[k]&&ITEMS[k].name)||k; };
     var cnt=function(list,k){ var c=0; for(var i=0;i<(list||[]).length;i++) if(list[i]===k) c++; return c; };
     // One board more than the rack needs, three of them packed: the loose ones cover all but EXP, so EXP packed boards are used.
     var H=RACK_COST.board+1, PK=3, EXP=Math.max(0,RACK_COST.board-(H-PK)), KIT=['board','board','board','medkit'];
     // A later control that cannot run keeps a failure already found, so the old build fails rather than skips.
     var skip=function(m){ return bad.length?(bad.join('; ')+' (then SKIP: '+m+')'):('SKIP: '+m); };
     // The rack cost held, one extra board and a Medkit in the stash, KIT packed, no freebie kit, no rack built, no belt key.
     function stage(){
       var Q=__P(), fk, fj;
       Q.racks=0; Q.arrays=0; Q.freeKit=0; Q.kitSaved=null; Q.hotAssign={}; Q.stash=[];
       for(fk in RACK_COST) for(fj=0;fj<RACK_COST[fk]+(fk==='board'?1:0);fj++) Q.stash.push(fk);
       Q.stash.push('medkit'); Q.kit=KIT.slice();
     }
     try{
       __topClear(); __cleanProfile();
       snap=JSON.parse(JSON.stringify(__P()));
       // A raid an earlier check ended leaves G set, and say then writes G.msg rather than the Undercroft toast, so the line
       // is read from say itself: in the Undercroft the toast shows that text word for word.
       say=function(m){ said.push(String(m)); };
       if(!(EXP>0&&EXP<PK)) return 'SKIP: this rack cost leaves no set-aside board to count here';
       // CONTROL: no freebie kit taken. The rack takes the EXP packed boards the loose ones cannot cover and names them, on the
       // old build and the new.
       stage();
       if(heldCount('board')!==H||packedCount('board')!==PK||!rackAfford()) return 'SKIP: the parts and the packing did not take here';
       said=[]; buildRack();
       var t0=said.join(' ');
       if(__P().racks!==1||t0.indexOf('Rack 1')<0) return 'SKIP: the rack was not built here ('+t0.slice(0,80)+')';
       if(t0.indexOf(' '+EXP+' packed '+nm('board'))<0||cnt(stageKitLive(),'board')!==PK-EXP) return 'SKIP: with no freebie kit taken the rack did not take and name '+EXP+' packed boards here ('+t0.slice(0,120)+')';
       // THE FIX: the same parts and packing, then TAKE THE FREEBIE KIT on its real button, which sets the packing aside.
       stage();
       renderFreeKit();
       var fb=document.querySelector('.fkbtn');
       if(!fb||typeof fb.onclick!=='function') return 'SKIP: the freebie kit button was not drawn';
       try{ fb.onclick(); }catch(_fb){}
       var q=__P(), ks=q.kitSaved&&q.kitSaved.kit;
       // CONTROL: the kit is taken, the packing is set aside whole, nothing is left packed, and the parts still pay for a rack.
       if(!q.freeKit||!Array.isArray(ks)||cnt(ks,'board')!==PK||cnt(ks,'medkit')!==1||stageKitLive().length||heldCount('board')!==H||!rackAfford()) return 'SKIP: taking the freebie kit did not set the packing aside here';
       said=[]; buildRack();
       var t1=said.join(' ');
       // CONTROL: the rack was built.
       if(__P().racks!==1||t1.indexOf('Rack 1')<0) return 'SKIP: the rack with the freebie kit taken was not built here ('+t1.slice(0,80)+')';
       q=__P(); ks=(q.kitSaved&&q.kitSaved.kit)||[];
       if(t1.indexOf(' '+EXP+' packed '+nm('board'))<0||t1.indexOf('backpack')<0) bad.push('with the freebie kit taken over '+PK+' packed boards, a rack that left '+heldCount('board')+' board in the stash says only: '+t1.slice(0,160));
       if(cnt(ks,'board')!==PK-EXP) bad.push('after the rack the packing set aside for USE MY OWN GEAR still names '+cnt(ks,'board')+' boards, while the stash holds '+heldCount('board'));
       if(cnt(ks,'medkit')!==1) bad.push('the rack took the Medkit off the packing set aside');
       // THE LIFT: the question counts the packing that MY LOADOUT then takes up.
       var ss=document.getElementById('asksub');
       if(!ss) return skip('no lift question text in this document');
       askKit();
       var m=(/the (\d+) items? you packed/).exec(String(ss.textContent||''));
       if(!m) return skip('the lift question named no packed items here ("'+String(ss.textContent||'').slice(0,80)+'")');
       freeKitRestore();
       var up=(__P().kit||[]).length;
       // CONTROL: MY LOADOUT gives back the one board still held and the Medkit.
       if(up!==2) return skip('MY LOADOUT gave back '+up+' items here, not the board still held and the Medkit');
       if(+m[1]!==up) bad.push('the lift question says the '+m[1]+' items you packed, while MY LOADOUT takes up '+up);
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{
       say=_say; ASKYES=_ay; ASKALT=_aa;
       try{ var am=document.getElementById('askmodal'); if(am) am.classList.remove('on'); }catch(_am){}
       try{ if(snap) __applyLoaded(snap); }catch(_r){}
       try{ renderFreeKit(); }catch(_rf){}
       try{ renderMainframe(); }catch(_m){}
       try{ __topClear(); __cleanProfile(); }catch(_c){}
     }
     return bad.length?bad.join('; '):null; }},
  {v:'15.53',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
