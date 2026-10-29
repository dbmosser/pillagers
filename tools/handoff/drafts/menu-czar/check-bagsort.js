  {v:'VER',what:'the raid backpack is in his three groups (his order 10-29: "Show guns, then usables, then crafting items"): a bag packed in a jumbled order lists its guns first, then the usables, then crafting parts and salvage; the panel draws the headings guns, usables and crafting + salvage in that order, each group starts a row of its own, the crafting tiles are smaller than the gun tiles, a wheel notch over the panel steps a row instead of zooming, and a step down from the last gun lands in the usables, a step down from the usables in the crafting group, and right reaches every stack',
   run:function(){
     if(!(window.__deploy&&window.__state&&window.__endRaid)) return 'SKIP: this fixture cannot deploy';
     if(typeof drawBag!=='function'||typeof bagStacks!=='function'||typeof raidKey!=='function'||typeof ctx==='undefined'||!ctx) return 'SKIP: no raid backpack draw or keys in this build';
     var need=['gun_smg','gun_shotgun','medkit','bandage','frag','ammobox','keycard','scrap','wire','reactor','meat','core'], i;
     for(i=0;i<need.length;i++) if(!ITEMS[need[i]]) return 'SKIP: no '+need[i]+' item in this build';
     if(typeof G!=='undefined'&&G&&G.sim) return 'SKIP: a sim is running';
     var bad=[], g=null, keep=null, seen=[], cx=ctx, realFill=null, ownFill=false, padWas=(typeof PAD==='object'&&PAD)?PAD.on:false, z0=null;
     var GUNS={gun_smg:1,gun_shotgun:1}, USE={medkit:1,bandage:1,frag:1,ammobox:1,keycard:1};
     function grp(k){ return GUNS[k]?0:(USE[k]?1:2); }
     function cellOf(k){ var C=g.bagCells||[]; for(var j=0;j<C.length;j++) if(C[j].key===k) return C[j]; return null; }
     function ixOf(k){ var S=bagStacks(); for(var j=0;j<S.length;j++) if(S[j].key===k) return j; return -1; }
     try{
       __topClear(); __runPrep(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       g=__state(); if(!g||!g.player||g.over) return 'SKIP: no live raid';
       if(G!==g||state!=='raid') return 'SKIP: the page is not in this raid here';
       keep={bag:g.bag,hotAssign:g.hotAssign,bagOpen:g.bagOpen,bagSel:g.bagSel,drag:g.drag,bagBelt:g.bagBelt};
       if(typeof PAD==='object'&&PAD) PAD.on=false;
       // A jumbled bag: junk and parts first, guns and usables scattered through it, nothing on the belt.
       g.bag=['scrap','medkit','wire','gun_smg','meat','frag','scrap','reactor','bandage','gun_shotgun','core','ammobox','scrap','keycard','wire'];
       g.hotAssign={}; g.bagOpen=true; g.drag=null; g.bagBelt=false; g.bagSel=0;
       var S=bagStacks(), order=S.map(function(s){ return grp(s.key); }), last=-1, ok=true;
       if(S.length!==12) return 'SKIP: fifteen pieces made '+S.length+' stacks here, not twelve';
       for(i=0;i<order.length;i++){ if(order[i]<last) ok=false; last=order[i]; }
       if(!ok) bad.push('the backpack stacks run '+S.map(function(s){ return s.key; }).join(', ')+', not guns, then usables, then crafting and salvage');
       // The panel as drawn.
       ownFill=Object.prototype.hasOwnProperty.call(cx,'fillText'); realFill=cx.fillText;
       cx.fillText=function(t){ seen.push(String(t)); return realFill.apply(cx,arguments); };
       seen=[]; drawBag();
       var hg=seen.indexOf('guns'), hu=seen.indexOf('usables'), hc=seen.indexOf('crafting + salvage');
       if(hg<0||hu<0||hc<0) bad.push('the panel does not draw the three group headings (guns '+hg+', usables '+hu+', crafting + salvage '+hc+')');
       else if(!(hg<hu&&hu<hc)) bad.push('the group headings are drawn out of order');
       var cS=cellOf('gun_smg'), cG=cellOf('gun_shotgun'), cM=cellOf('medkit'), cK=cellOf('keycard'), cR=cellOf('reactor'), cW=cellOf('scrap');
       if(!cS||!cG||!cM||!cK||!cR||!cW) bad.push('a stack has no tile on the panel');
       else {
         var gunBot=Math.max(cS.y,cG.y), useTop=Math.min(cM.y,cK.y);
         if(!(useTop>gunBot+1)) bad.push('the usables do not start a row of their own under the guns (first usable top '+Math.round(useTop)+', last gun top '+Math.round(gunBot)+')');
         if(!(Math.min(cR.y,cW.y)>Math.max(cM.y,cK.y)+1)) bad.push('crafting and salvage do not start a row of their own under the usables');
         if(!(cW.w<cS.w*0.85)) bad.push('a crafting tile is '+Math.round(cW.w)+' px wide against a gun tile of '+Math.round(cS.w)+', not smaller');
       }
       // The wheel over the open backpack walks its rows (a group below the fold is in reach of the mouse) and does not zoom the world.
       S=bagStacks();
       if(g.bagPanel&&typeof cv!=='undefined'&&cv&&typeof mouse!=='undefined'){
         g.bagSel=0; g.bagBelt=false; g.bagNavU=null; g.bagWheel=0; mouse.x=g.bagPanel.x+g.bagPanel.w/2; mouse.y=g.bagPanel.y+g.bagPanel.h/2;
         z0=(typeof zoomTarget==='function')?zoomTarget():null;
         cv.dispatchEvent(new WheelEvent('wheel',{deltaY:120,deltaMode:0,bubbles:true,cancelable:true}));
         if(!S[g.bagSel]||grp(S[g.bagSel].key)!==1) bad.push('a wheel notch down over the backpack left the highlight on '+(S[g.bagSel]?S[g.bagSel].key:'nothing')+', not the usables under the first gun');
         if(z0!==null&&zoomTarget()!==z0) bad.push('the wheel over the backpack zoomed the world');
       }
       // The arrows walk the groups: down from the last gun into the usables, down again into crafting; right reaches every stack.
       var lastGun=-1, firstCraft=-1;
       for(i=0;i<S.length;i++){ if(grp(S[i].key)===0) lastGun=i; if(firstCraft<0&&grp(S[i].key)===2) firstCraft=i; }
       g.bagBelt=false; g.bagNavU=null; g.bagSel=lastGun; raidKey('ArrowDown',false,null);
       var d1=S[g.bagSel]?grp(S[g.bagSel].key):-1;
       if(g.bagBelt||d1!==1) bad.push('down from the last gun went to '+(g.bagBelt?'the belt':(S[g.bagSel]?S[g.bagSel].key:'nothing'))+', not a usable under it');
       else { raidKey('ArrowDown',false,null); var d2=S[g.bagSel]?grp(S[g.bagSel].key):-1; if(g.bagBelt||d2!==2) bad.push('down from the usables went to '+(g.bagBelt?'the belt':(S[g.bagSel]?S[g.bagSel].key:'nothing'))+', not the crafting group'); }
       g.bagBelt=false; g.bagNavU=null; g.bagSel=firstCraft; raidKey('ArrowUp',false,null);
       if(g.bagBelt||!S[g.bagSel]||grp(S[g.bagSel].key)!==1) bad.push('up from the first crafting tile did not land in the usables');
       g.bagBelt=false; g.bagSel=0; var seenR={0:1};
       for(i=0;i<S.length;i++){ raidKey('ArrowRight',false,null); seenR[g.bagSel]=1; }
       if(Object.keys(seenR).length!==S.length) bad.push('right visited '+Object.keys(seenR).length+' of '+S.length+' stacks');
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{
       try{ if(realFill){ if(ownFill) cx.fillText=realFill; else delete cx.fillText; } }catch(_f){}
       try{ if(typeof PAD==='object'&&PAD) PAD.on=padWas; }catch(_p){}
       try{ if(z0!==null&&typeof setZoom==='function') setZoom(z0); }catch(_z){}
       try{ if(g&&keep){ g.bag=keep.bag; g.hotAssign=keep.hotAssign; g.bagOpen=keep.bagOpen; g.bagSel=keep.bagSel; g.drag=keep.drag; g.bagBelt=keep.bagBelt; } }catch(_g){}
       try{ var K3=__keysRef(); for(var k3 in K3) K3[k3]=false; }catch(_k){}
       try{ if(g&&!g.over) __endRaid('abandon'); }catch(_e){}
       try{ __topClear(); __resetCfg(); __cleanProfile(); }catch(_c){}
     }
     return bad.length?bad.join('; '):null; }},
