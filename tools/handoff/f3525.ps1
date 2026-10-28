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

if ($s.Contains("  {v:'35.25',what:")) { throw "check 35.25 is in the fixture already" }

SubRx @'
  {v:'35.24',what:
'@ @'
  {v:'35.25',what:'cw-beltwheel (his orders of 10-27): a belt item works like the wheel, its key or a click takes it out and the trigger uses it, the key again puts it away, and an item on the wheel drags onto a belt key',
   run:function(){
     var bad=[], g, p, w, m, sl, i, ks=[], cells, c, cm, cnt, n0, f0, bi, an, kq, cellOf;
     function idx(k2){ var q; for(q=0;q<w.list.length;q++) if(w.list[q].k===k2) return q; return -1; }
     try{
       __topClear(); __runPrep(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       __deploy({kit:['gun_carbine','medkit','medkit','bandage','frag','frag'],safe:null,mapIx:0,seed:4242});
       if(state!=='raid'||!G||G.over) throw new Error('no live raid to test on');
       G.mapFirst=0; G.mapOpen=false; G.bagOpen=false; if(pauseOpen) togglePauseBox(false); syncPause();
       g=G; p=g.player; keys={}; mouse.down=false; p.hand=null; g.drag=null; g.wheel=null; p.hp=30; p.healQ=0; p.prep=null; p.prepA=null; p.cooking=false;
       cnt=function(k){ return g.bag.filter(function(q){ return q===k; }).length; };
       sl=hotbarSlots();
       for(i=0;i<sl.length&&ks.length<3;i++) if(sl[i]&&sl[i].vacant) ks.push(i);
       for(i=0;i<sl.length&&ks.length<3;i++) if(sl[i]&&ks.indexOf(i)<0&&!(sl[i].kind==='gun'&&sl[i].inHand)) ks.push(i);
       if(ks.length<3) throw new Error('fewer than three free keys');
       g.hotAssign=g.hotAssign||{}; g.hotAuto=g.hotAuto||{};
       g.hotAssign[ks[0]]='frag'; g.hotAssign[ks[1]]='medkit'; delete g.hotAuto[ks[0]]; delete g.hotAuto[ks[1]]; delete g.hotAssign[ks[2]]; classKeysSettle();
       sl=hotbarSlots();
       if(!sl[ks[0]]||sl[ks[0]].kind!=='throw'||!sl[ks[1]]||sl[ks[1]].kind!=='heal') throw new Error('staging: the keys show '+(sl[ks[0]]&&sl[ks[0]].kind)+' and '+(sl[ks[1]]&&sl[ks[1]].kind));
       // ONE: the frag key takes the frag out and throws nothing
       f0=throwHave('frag');
       kq=slotKeyCode(ks[0]); raidKey(kq,false,null); keys[kq]=false;
       if(!p.hand||p.hand.k!=='frag') bad.push('ONE: key '+slotKeyName(ks[0])+' left '+(p.hand?p.hand.k:'nothing')+' in hand, not the frag');
       if(throwHave('frag')<f0||p.cooking) bad.push('ONE: the key threw or cooked the frag');
       // TWO: the same key again puts it away
       raidKey(kq,false,null); keys[kq]=false;
       if(p.hand) bad.push('TWO: a second press left '+p.hand.k+' in hand');
       // THREE: the medkit key takes it out; nothing is spent until a fresh pull of the trigger
       n0=cnt('medkit');
       kq=slotKeyCode(ks[1]); raidKey(kq,false,null); keys[kq]=false;
       if(!p.hand||p.hand.k!=='medkit') bad.push('THREE: key '+slotKeyName(ks[1])+' left '+(p.hand?p.hand.k:'nothing')+' in hand, not the medkit');
       if(cnt('medkit')<n0||p.prep) bad.push('THREE: the key spent the medkit at once');
       if(p.hand&&p.hand.k==='medkit'){
         p.hand.t=0; mouse.down=false; handTick(p,0.016); mouse.down=true; handTick(p,0.016); mouse.down=false;
         if(!(cnt('medkit')<n0)&&!p.prep) bad.push('THREE: the trigger did not use the medkit');
       }
       p.hand=null; p.prep=null; p.healQ=0; mouse.down=false;
       // FOUR: a click on the medkit key takes it out too, and spends nothing
       __frame(0.016); cells=g.hotCells||[]; cellOf=function(ix){ var q; for(q=0;q<cells.length;q++) if(cells[q].i===ix) return cells[q]; return null; };
       c=cellOf(ks[2]); cm=cellOf(ks[1]);
       if(!c||!cm) throw new Error('the belt drew no cell for key '+slotKeyName(ks[2])+' or '+slotKeyName(ks[1]));
       n0=cnt('medkit');
       mouse.x=cm.x+cm.w/2; mouse.y=cm.y+cm.h/2;
       cv.dispatchEvent(new MouseEvent('mousedown',{button:0,bubbles:true}));
       window.dispatchEvent(new MouseEvent('mouseup',{button:0,bubbles:true}));
       if(!p.hand||p.hand.k!=='medkit') bad.push('FOUR: a click on key '+slotKeyName(ks[1])+' left '+(p.hand?p.hand.k:'nothing')+' in hand, not the medkit');
       if(cnt('medkit')<n0||p.prep) bad.push('FOUR: the click spent the medkit');
       p.hand=null; g.drag=null; mouse.down=false;
       // FIVE: the bandage dragged off the wheel onto the free key is bound there and still carried
       mouse.x=W/2; mouse.y=H/2; keys.KeyQ=true; raidKey('KeyQ',false,null); w=g.wheel;
       if(!w) throw new Error('Q opened no wheel');
       m=w.list.length; bi=idx('bandage'); if(bi<0) throw new Error('no bandage slot on the wheel');
       an=-Math.PI/2+bi*(Math.PI*2/m); mouse.x=w.mx+Math.cos(an)*220; mouse.y=w.my+Math.sin(an)*220; updatePlayer(0.016);
       if(!g.wheel||g.wheel.sel!==bi) throw new Error('staging: the wheel read segment '+(g.wheel&&g.wheel.sel)+', not the bandage '+bi);
       cv.dispatchEvent(new MouseEvent('mousedown',{button:0,bubbles:true}));
       if(!g.drag||g.drag.key!=='bandage') bad.push('FIVE: a press on the bandage picked up '+(g.drag?g.drag.key:'nothing'));
       mouse.x=c.x+c.w/2; mouse.y=c.y+c.h/2; updatePlayer(0.016);
       if(g.wheel&&g.wheel.sel!==bi) bad.push('FIVE: the wheel moved to segment '+g.wheel.sel+' while the bandage was held');
       window.dispatchEvent(new MouseEvent('mouseup',{button:0,bubbles:true}));
       if((g.hotAssign||{})[ks[2]]!=='bandage') bad.push('FIVE: key '+slotKeyName(ks[2])+' holds '+((g.hotAssign||{})[ks[2]]||'nothing')+' after the drop');
       if(cnt('bandage')!==1) bad.push('FIVE: the drop spent or dropped the bandage');
       keys.KeyQ=false; updatePlayer(0.016);
       if(p.hand) bad.push('FIVE: letting go of Q after the drop took out '+p.hand.k);
       if(g.wheel) bad.push('FIVE: the wheel stayed open after the drop');
       // control: a plain wheel pick still takes the item out
       p.hand=null; mouse.x=W/2; mouse.y=H/2; keys.KeyQ=true; raidKey('KeyQ',false,null); w=g.wheel;
       if(w){ bi=idx('frag'); m=w.list.length; an=-Math.PI/2+bi*(Math.PI*2/m); mouse.x=w.mx+Math.cos(an)*220; mouse.y=w.my+Math.sin(an)*220; updatePlayer(0.016); keys.KeyQ=false; updatePlayer(0.016);
         if(!p.hand||p.hand.k!=='frag') bad.push('control: a wheel pick of the frag left '+(p.hand?p.hand.k:'nothing')+' in hand'); }
       else bad.push('control: Q opened no wheel the second time');
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{
       try{ if(G){ G.drag=null; G.wheel=null; if(G.player) G.player.hand=null; } mouse.down=false; }catch(_d){}
       try{ if(pauseOpen) togglePauseBox(false); }catch(_p){}
       try{ var K2=__keys(); for(var q2 in K2) delete K2[q2]; }catch(_k){}
       try{ if(state==='raid'&&G&&!G.over) __endRaid('abandon'); }catch(_e){}
       try{ __topClear(); __cleanProfile(); }catch(_c){}
     }
     return bad.length?bad.join('; '):null; }},
  {v:'35.24',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
