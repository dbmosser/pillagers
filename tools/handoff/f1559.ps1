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
  {v:'15.58',what:
'@ @'
  {v:'15.59',what:'the Undercroft backpack names only keys that work on the floor: in a raid the selected Compact SMG still names the arrows, Z to drop and ENTER to equip, and Z drops it, while on the Undercroft floor, where the arrows, Z and ENTER leave the backpack, the selection and the gun as they were, the same selected gun names none of them and still names the drag to the tactical belt, and with a controller it names no D-pad drop (first run audit finding)',
   run:function(){
     if(!(window.__deploy&&window.__state&&window.__endRaid&&window.__P&&window.__applyLoaded&&window.__hubEnter)) return 'SKIP: this fixture cannot deploy, reach the floor and restore the profile';
     if(typeof drawBag!=='function'||typeof drawHubBag!=='function'||typeof hubBagOpenSet!=='function'||typeof withHubBag!=='function'||typeof bagStacks!=='function'||typeof raidKey!=='function') return 'SKIP: no backpack draw, Undercroft backpack or raid keys in this build';
     if(typeof ctx==='undefined'||!ctx||typeof PAD==='undefined'||!PAD||typeof keys==='undefined') return 'SKIP: no canvas, pad state or keys in this build';
     if(!ITEMS.gun_smg||ITEMS.gun_smg.use!=='gun'||!ITEMS.bandage) return 'SKIP: no Compact SMG gun item or Bandage in this build';
     if(typeof G!=='undefined'&&G&&G.sim) return 'SKIP: a sim is running';
     var bad=[], g=null, snap=null, keep=null, seen=[], cx=ctx, realFill=null, ownFill=false, _say=say, _blip=blip, padWas=PAD.on;
     var wnWas=(typeof WNSEEN!=='undefined')?WNSEEN:null, GUN=ITEMS.gun_smg.name, DRAG='drag to tactical belt';
     // Needles for words the floor must not draw, assembled so the check never finds its own source.
     var AN='ARROWS'+' move', ZN='Z drop'+' one', EN='ENTER'+' equip', DN='DPAD L'+' drop';
     // A later control that cannot run keeps a failure already found, so the old build fails rather than skips.
     var skip=function(m){ return bad.length?(bad.join('; ')+' (then SKIP: '+m+')'):('SKIP: '+m); };
     // keys is replaced by a fresh object on the way to the floor, so it is looked up by name every time.
     function clearKeys(){ try{ for(var kk in keys) keys[kk]=false; }catch(_k){} }
     function has(t,w){ return t.indexOf(w)>=0; }
     function drawn(fn){ seen=[]; try{ fn(); }catch(_d){ return null; } return seen.join(' | '); }
     function gunIx(){ var st=bagStacks(); for(var i=0;i<st.length;i++) if(st[i].key==='gun_smg') return i; return -1; }
     function tap(c){
       window.dispatchEvent(new KeyboardEvent('keydown',{code:c,key:c,bubbles:true,cancelable:true}));
       window.dispatchEvent(new KeyboardEvent('keyup',{code:c,key:c,bubbles:true,cancelable:true}));
     }
     try{
       __topClear(); __runPrep(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       snap=JSON.parse(JSON.stringify(__P()));
       ownFill=Object.prototype.hasOwnProperty.call(cx,'fillText');
       realFill=cx.fillText;
       cx.fillText=function(t){ seen.push(String(t)); return realFill.apply(cx,arguments); };
       say=function(){}; blip=function(){};
       PAD.on=false;
       // THE RAID: a Bandage and the Compact SMG in the open backpack, with the gun selected.
       __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       g=__state(); if(!g||!g.player||g.over) return 'SKIP: no live raid';
       if(G!==g||state!=='raid'||!g.containers) return 'SKIP: the page is not in this raid here';
       keep={bag:g.bag,hotAssign:g.hotAssign,bagOpen:g.bagOpen,bagSel:g.bagSel,drag:g.drag,trade:g.trade,emoteBar:g.emoteBar,mapOpen:g.mapOpen,nCont:g.containers.length};
       g.bag=['bandage','gun_smg']; g.hotAssign={}; g.bagOpen=true; g.drag=null; g.trade=null; g.emoteBar=false; g.mapOpen=false;
       g.bagSel=gunIx();
       if(g.bagSel<0) return 'SKIP: the Compact SMG is not a stack in the raid backpack here';
       var r1=drawn(drawBag);
       // CONTROL: the raid backpack draws the selected gun and its key hint line.
       if(r1===null) return 'SKIP: drawing the raid backpack threw here';
       if(!has(r1,GUN)||!has(r1,DRAG)) return 'SKIP: the raid backpack did not draw the selected Compact SMG and its key hint line here';
       if(!has(r1,AN)||!has(r1,ZN)||!has(r1,EN)) bad.push('in a raid the backpack hint for the selected Compact SMG no longer names the arrows, Z to drop and ENTER to equip, which all work there');
       PAD.on=true; var r2=drawn(drawBag); PAD.on=false;
       if(r2===null) return skip('drawing the raid backpack with a controller on threw here');
       if(!has(r2,DN)) bad.push('in a raid with a controller the backpack hint no longer names the D-pad drop, which works there');
       // CONTROL: Z in the raid drops the selected gun, so the raid hint is true and the needle is the working key.
       clearKeys(); raidKey('KeyZ',false,null); clearKeys();
       if(g.bag.length!==1||g.bag[0]!=='bandage') return skip('Z in the raid backpack did not drop the selected Compact SMG here');
       g.containers.length=keep.nCont;
       g.bag=keep.bag; g.hotAssign=keep.hotAssign; g.bagOpen=keep.bagOpen; g.bagSel=keep.bagSel; g.drag=keep.drag; g.trade=keep.trade; g.emoteBar=keep.emoteBar; g.mapOpen=keep.mapOpen;
       keep=null;
       __endRaid('abandon'); __topClear();
       // THE FLOOR: the same two things packed, the Undercroft backpack opened, the gun selected.
       __hubEnter();
       if(state!=='hub') return skip('the fixture did not reach the Undercroft floor (state '+state+')');
       var q=__P(); q.kit=['bandage','gun_smg']; q.hotAssign={};
       hubBagOpenSet(true);
       if(!hubBagOpen||!hubBagG) return skip('the Undercroft backpack did not open');
       var hx=-1; withHubBag(function(){ hx=gunIx(); });
       if(hx<0) return skip('the Compact SMG is not a stack in the Undercroft backpack here');
       hubBagG.bagSel=hx;
       // CONTROL: on the floor the arrows, Z and ENTER leave the backpack, the selection and the gun as they were, so a hint
       // naming them is untrue here.
       var bag0=hubBagG.bag.join(','), eq0=q.equipped, sec0=q.equippedSec;
       clearKeys(); tap('ArrowRight'); tap('KeyZ'); tap('Enter'); clearKeys();
       if(!hubBagOpen||!hubBagG) return skip('a key on the floor closed the Undercroft backpack here');
       if(hubBagG.bag.join(',')!==bag0||hubBagG.bagSel!==hx||q.equipped!==eq0||q.equippedSec!==sec0) return skip('on the floor the arrows, Z or ENTER changed the backpack, the selection or the gun here, so a hint naming them would be true');
       var f1=drawn(drawHubBag);
       // CONTROL: the floor draws the selected gun and a hint line naming the drag. drawHubBag swallows a throw, so the words
       // are looked for rather than trusted.
       if(f1===null||!has(f1,GUN)||!has(f1,DRAG)) return skip('the Undercroft backpack did not draw the selected Compact SMG and a hint line naming the drag to the tactical belt here');
       var named=[];
       if(has(f1,AN)) named.push('the arrows');
       if(has(f1,ZN)) named.push('Z to drop');
       if(has(f1,EN)) named.push('ENTER to equip');
       if(named.length) bad.push('on the Undercroft floor the backpack hint for the selected Compact SMG names '+named.join(', ')+', and none of those keys does anything down here');
       PAD.on=true; var f2=drawn(drawHubBag); PAD.on=false;
       // CONTROL: with the controller flag up the floor backpack header says VIEW, so the flag reached the draw.
       if(f2===null||!has(f2,'VIEW to close')) return skip('with a controller on, the Undercroft backpack header did not say VIEW here');
       if(has(f2,DN)) bad.push('on the Undercroft floor with a controller the backpack hint names the D-pad drop, and the floor reads no D-pad');
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{
       clearKeys();
       try{ if(realFill){ if(ownFill) cx.fillText=realFill; else delete cx.fillText; } }catch(_f){}
       try{ say=_say; blip=_blip; PAD.on=padWas; }catch(_s){}
       try{ if(wnWas!==null) WNSEEN=wnWas; }catch(_w){}
       try{ if(g&&keep){ g.containers.length=keep.nCont; g.bag=keep.bag; g.hotAssign=keep.hotAssign; g.bagOpen=keep.bagOpen; g.bagSel=keep.bagSel; g.drag=keep.drag; g.trade=keep.trade; g.emoteBar=keep.emoteBar; g.mapOpen=keep.mapOpen; } }catch(_g){}
       try{ if(g&&!g.over) __endRaid('abandon'); }catch(_e){}
       // Shut without the commit, so the staged kit is never saved; the snapshot below puts the profile back.
       try{ if(hubBagG) hubBagG.drag=null; hubBagG=null; hubBagOpen=false; }catch(_hb){}
       // The way to the floor may have opened a first run window over it; it is shut again, as check 15.57 does.
       try{ if(snap&&state==='hub'){ var mo=document.querySelectorAll('.modal.on'); for(var mi=0;mi<mo.length;mi++) mo[mi].classList.remove('on'); } }catch(_m){}
       try{ if(snap) __applyLoaded(snap); }catch(_r){}
       try{ __topClear(); __resetCfg(); __cleanProfile(); }catch(_c){}
     }
     return bad.length?bad.join('; '):null; }},
  {v:'15.58',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
