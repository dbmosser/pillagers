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
  {v:'15.51',what:
'@ @'
  {v:'15.52',what:'BUILD A RACK keeps the controller highlight when it greys out: on a faked controller two A presses on BUILD A RACK with parts for two racks build two racks, with parts for one rack and a Data Core the second A slots no core and leaves the highlight on BUILD A RACK, and at nine racks the second A after the tenth rack folds no Array (rack audit finding)',
   run:function(){
     if(typeof pollPad!=='function'||typeof padMenu!=='function'||typeof padSetFocus!=='function'||typeof padFocusables!=='function'||typeof PAD==='undefined') return 'SKIP: no pad menu in this build';
     if(typeof openOps!=='function'||typeof buildRack!=='function'||typeof renderMainframe!=='function'||typeof RACK_COST==='undefined'||typeof RACK_CAP==='undefined'||typeof ARRAY_RACKS==='undefined'||!ITEMS.core||!window.__applyLoaded) return 'SKIP: no Mainframe racks, Arrays or Data Core in this build';
     if(!(ARRAY_RACKS>=2&&ARRAY_RACKS<=RACK_CAP)) return 'SKIP: an Array does not take a wall of racks in this build';
     var op=document.getElementById('opmodal'), bb=document.getElementById('mfbuild');
     if(!op||!bb||!document.getElementById('mfslot')||!document.getElementById('mfarray')) return 'SKIP: no Mainframe window with its rack, Array and core buttons in this document';
     if(G&&!G.over) return 'SKIP: a raid is running, and racks are built in the Undercroft';
     var NG=navigator.getGamepads;
     if(typeof NG!=='function') return 'SKIP: this browser has no pad interface to fake';
     var bad=[], stubbed=false, snap=null, _say=say, said=[], keepPad=null, wasOn=op.classList.contains('on');
     try{ navigator.getGamepads=function(){ return []; }; stubbed=(navigator.getGamepads!==NG); }catch(_s){}
     if(!stubbed){ try{ navigator.getGamepads=NG; }catch(_r0){} return 'SKIP: this browser will not let the pad be faked'; }
     // A later control that cannot run keeps a failure already found, so the old build fails rather than skips.
     var skip=function(m){ return bad.length?(bad.join('; ')+' (then SKIP: '+m+')'):('SKIP: '+m); };
     function padWith(down){
       var bts=[],i;
       for(i=0;i<17;i++) bts.push({pressed:(i===down),value:(i===down)?1:0,touched:(i===down)});
       var fake={connected:true,id:'probe pad',index:0,mapping:'standard',timestamp:1,axes:[0,0,0,0],buttons:bts};
       navigator.getGamepads=function(){ return [fake]; };
     }
     // That many racks up, the parts for that many more loose in the stash, a Data Core when asked, nothing slotted or packed.
     function stage(racks,sets,core){
       var q=__P(), k, j;
       q.racks=racks; q.arrays=0; q.intel=0; q.kit=[]; q.hotAssign={}; q.stash=[];
       for(k in RACK_COST){ for(j=0;j<RACK_COST[k]*sets;j++) q.stash.push(k); }
       if(core) q.stash.push('core');
     }
     function cores(){ var c=0,st=__P().stash||[]; for(var i=0;i<st.length;i++) if(st[i]==='core') c++; return c; }
     function label(){ return PAD.focus?('"'+(String(PAD.focus.textContent||'').trim()||PAD.focus.id||'a control')+'"'):'nothing'; }
     // The Mainframe on its RACKS tab and the highlight put on BUILD A RACK, then A, let go, one idle poll, A again and let go.
     function presses(){
       openOps('mf');
       padWith(-1); pollPad();
       if(padFocusables(op).indexOf(bb)<0) return 'BUILD A RACK is not a live control laid out where a pad can reach it here';
       padSetFocus(bb); pollPad();
       if(PAD.focus!==bb) return 'the highlight would not stay on BUILD A RACK here';
       padWith(0); pollPad(); padWith(-1); pollPad(); pollPad();
       padWith(0); pollPad(); padWith(-1); pollPad();
       return null;
     }
     try{
       __topClear(); __runPrep(); __cleanProfile();
       snap=JSON.parse(JSON.stringify(__P()));
       keepPad={aSpent:PAD.aSpent,announced:PAD.announced};
       say=function(m){ said.push(String(m)); };
       // CONTROL: parts for two racks and a Data Core. BUILD A RACK is still live after the first rack, so both presses build a
       // rack and no core is slotted: the faked A reaches the highlighted button, and the highlight stays while it is live.
       stage(0,2,true);
       var why=presses();
       if(why) return 'SKIP: '+why;
       if(__P().racks!==2||__P().intel||cores()!==1) return 'SKIP: two A presses on BUILD A RACK with parts for two racks left '+__P().racks+' racks, '+(__P().intel?'a core slotted':'no core slotted')+' and '+cores()+' cores in the stash here, so the faked A cannot be read';
       // THE FIX, ONE: parts for one rack and a Data Core. The rack greys BUILD A RACK out, and SLOT A DATA CORE is live below it.
       stage(0,1,true);
       why=presses();
       if(why) return skip(why);
       // CONTROL: the first A built the one rack.
       if(__P().racks!==1) return skip('the first A with parts for one rack left '+__P().racks+' racks here');
       if(__P().intel||cores()!==1) bad.push('with parts for one rack and a Data Core, the A after the rack slotted the core ('+cores()+' left in the stash, the next ascent carries intel), where that A should do nothing');
       if(PAD.focus!==bb) bad.push('after the last rack he could afford the controller highlight left BUILD A RACK for '+label());
       // THE FIX, TWO: one rack short of an Array and parts for one. The rack greys BUILD A RACK out and makes the fold live.
       stage(ARRAY_RACKS-1,1,false);
       why=presses();
       if(why) return skip(why);
       // CONTROL: the rack was built. Racks plus a wall of racks for each Array is the same whether or not a fold followed.
       var q3=__P(), r3=q3.racks||0, a3=q3.arrays||0;
       if(r3+a3*ARRAY_RACKS!==ARRAY_RACKS) return skip('the first A at '+(ARRAY_RACKS-1)+' racks left '+r3+' racks and '+a3+' Arrays here');
       if(a3!==0||r3!==ARRAY_RACKS) bad.push('at '+(ARRAY_RACKS-1)+' racks, the A after the rack that filled the wall folded it into an Array ('+r3+' racks and '+a3+' Arrays left), where that A should do nothing');
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{
       say=_say;
       try{ navigator.getGamepads=function(){ return []; }; pollPad(); }catch(_p0){}
       try{ padSetFocus(null); PAD.focus=null; PAD.focusIx=-1; PAD.focusMd=null; padRelease(); }catch(_pr){}
       try{ navigator.getGamepads=NG; }catch(_p){}
       try{ if(keepPad){ PAD.aSpent=keepPad.aSpent; PAD.announced=keepPad.announced; } }catch(_kp){}
       try{ if(!wasOn) op.classList.remove('on'); }catch(_o){}
       try{ if(snap) __applyLoaded(snap); }catch(_r){}
       try{ renderMainframe(); }catch(_m){}
       try{ var K3=__keysRef(); for(var k3 in K3) K3[k3]=false; }catch(_k){}
       try{ __topClear(); __cleanProfile(); }catch(_c){}
     }
     return bad.length?bad.join('; '):null; }},
  {v:'15.51',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
