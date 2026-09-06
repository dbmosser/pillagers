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

# v11.97 CHECK, inserted before the v11.96 entry. With the backpack CLOSED the
# hand cell is pressed through the real canvas press and released well off
# the belt: the gun must be in the backpack and out of the hand. Then a key
# holding a pistol is pressed and released on another key: the pistol must
# have moved to that key.
SubRx @'
  {v:'11.96',what:'a belt key on a stack packs half the stack and the plan cell shows the count; a single item packs one; a count already packed is kept (his order of 2026-09-06)',
'@ @'
  {v:'11.97',what:'with the backpack closed, a click on the hand cell still only selects, a real drag off the belt puts the gun in the backpack, and a key holding a gun drags to another key like any item (his notes of 2026-09-06)',
   run:function(){
     if(!(window.__deploy&&window.__state&&window.__frame&&window.__runPrep)) return 'SKIP: this fixture cannot deploy and draw';
     if(typeof cv==='undefined'||typeof mouse==='undefined') return 'SKIP: no canvas or mouse in this build';
     if(!window.innerWidth||!window.innerHeight) return 'SKIP: the pane is 0x0, nothing here can be measured';
     var bad=[], g=null, i, P2=__P(), keepStash=(P2.stash||[]).slice(), keepW=(P2.weapons||[]).slice(), keepEq=P2.equipped;
     try{
       __topClear(); __runPrep(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       g=__state(); var p=g.player;
       if(!p.wep||p.wep.id==='fists'||p.wep.mag===0) return 'SKIP: the deploy put no gun in hand';
       var gunId=p.wep.id;
       p.wepIssued=false; p.wepFromArmory=false; p.downed=false; p.roll=0;
       g.bag=[]; g.hotAssign={}; g.bagOpen=false; g.drag=null; g.mapOpen=false; g.paused=false;
       __frame(0.016); __frame(0.016);
       var sl=hotbarSlots(), ai=-1;
       for(i=0;i<sl.length;i++) if(sl[i]&&sl[i].k==='gunA'){ ai=i; break; }
       var cell=(ai>=0&&g.hotCells)?g.hotCells[ai]:null;
       if(!cell) bad.push('control: the belt drew no hand cell to press');
       else {
         // ZERO: a click on the hand cell, press and release on the spot, is still a click.
         mouse.x=cell.x+cell.w/2; mouse.y=cell.y+cell.h/2;
         cv.dispatchEvent(new MouseEvent('mousedown',{button:0,bubbles:true}));
         window.dispatchEvent(new MouseEvent('mouseup',{button:0,bubbles:true}));
         if(!p.wep||p.wep.id!==gunId) bad.push('a click on the hand cell stowed the gun (in hand: '+(p.wep&&p.wep.id)+')');
         g.drag=null;
         // ONE: the hand cell, backpack closed, released well off the belt.
         mouse.x=cell.x+cell.w/2; mouse.y=cell.y+cell.h/2;
         cv.dispatchEvent(new MouseEvent('mousedown',{button:0,bubbles:true}));
         if(!g.drag||!g.drag.gunSlot) bad.push('pressing the hand cell with the backpack closed started no drag'+(g.drag?' (drag: '+JSON.stringify(g.drag).slice(0,60)+')':''));
         mouse.x=Math.max(20,cell.x-200); mouse.y=Math.max(20,cell.y-260);
         window.dispatchEvent(new MouseEvent('mouseup',{button:0,bubbles:true}));
         if(g.bag.indexOf('gun_'+gunId)<0) bad.push('the gun released off the belt did not go into the backpack (bag '+g.bag.join(',')+')');
         if(p.wep&&p.wep.id===gunId) bad.push('the gun is still in hand after the drop');
       }
       // TWO: a key holding a pistol drags to another key.
       g.bag=['gun_pistol']; g.hotAssign={3:'gun_pistol'}; g.drag=null; g.bagOpen=false;
       __frame(0.016); __frame(0.016);
       var c3=g.hotCells?g.hotCells[3]:null, c5=g.hotCells?g.hotCells[5]:null;
       if(!c3||!c5) bad.push('control: the belt drew no cells 4 and 6');
       else {
         mouse.x=c3.x+c3.w/2; mouse.y=c3.y+c3.h/2;
         cv.dispatchEvent(new MouseEvent('mousedown',{button:0,bubbles:true}));
         if(!g.drag||g.drag.key!=='gun_pistol') bad.push('pressing the pistol key started no drag'+(g.drag?' (drag: '+JSON.stringify(g.drag).slice(0,60)+')':''));
         mouse.x=c5.x+c5.w/2; mouse.y=c5.y+c5.h/2;
         window.dispatchEvent(new MouseEvent('mouseup',{button:0,bubbles:true}));
         if(g.hotAssign[5]!=='gun_pistol') bad.push('the pistol did not move to key 6 (plan '+JSON.stringify(g.hotAssign)+')');
       }
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{ try{ if(g){ g.bagOpen=false; g.drag=null; } mouse.down=false; }catch(_c){} try{ var g2=__state(); if(g2&&!g2.over){ g2.player.downed=false; __endRaid('extract'); } }catch(_e){} P2.stash=keepStash; P2.weapons=keepW; P2.equipped=keepEq; try{ saveProfile(); }catch(_s){} __topClear(); __cleanProfile(); }
     return bad.length?bad.join('; '):null; }},
  {v:'11.96',what:'a belt key on a stack packs half the stack and the plan cell shows the count; a single item packs one; a count already packed is kept (his order of 2026-09-06)',
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
