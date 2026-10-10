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

if ($s.Contains("  {v:'21.83',what:")) { throw "check 21.83 is in the fixture already" }

SubRx @'
  {v:'21.82',what:
'@ @'
  {v:'21.83',what:'the four-gun belt, build 2: a gun keeps its key when drawn or stowed (rifle on key 1, SMG on key 2, a shotgun found onto a belt key and drawn there: key 1 still shows the rifle in the backpack and key 2 the SMG; key 1 draws the rifle back and the shotgun keeps its key; guard: dragging key 1 off the belt still stows the gun it shows)',
   run:function(){
     if(!window.__deploy||!window.__endRaid||!window.__frame||typeof grantLoot!=='function'||typeof setHot!=='function'||typeof hotbarSlots!=='function') return 'SKIP: no belt here';
     if(!WEAPONS.rifle||!WEAPONS.smg||!WEAPONS.shotgun||!ITEMS.gun_rifle||!ITEMS.gun_smg||!ITEMS.gun_shotgun) return 'SKIP: no rifle, smg or shotgun here';
     if(typeof cv==='undefined'||typeof mouse==='undefined') return 'SKIP: no canvas or mouse in this build';
     var bad=[], g=null, p, i, ks=-1, w0=(P.weapons||[]).slice(), e0=P.equipped, s0=P.equippedSec, st0=(P.stash||[]).slice(), kt0=(P.kit||[]).slice(), ha0=JSON.parse(JSON.stringify(P.hotAssign||{}));
     function cell(ix){ return hotbarSlots()[ix]||{}; }
     function gid(c){ return String(c.icon||'').replace(/^gun_/,''); }
     function desc(c){ return (gid(c)||'nothing')+(c.vacant?' (vacant)':(c.inHand?' in hand':' out of hand')); }
     try{
       __topClear(); __runPrep(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       P.weapons=['rifle','smg']; P.equipped='rifle'; P.equippedSec='smg'; P.hotAssign={};
       __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       g=__state(); p=g&&g.player; if(!g||g.over||!p) return 'SKIP: no live raid';
       if(!(p.wep&&p.wep.id==='rifle'&&p.sec&&p.sec.id==='smg')) return 'SKIP: staging: did not deploy with the rifle up and the SMG stowed ('+(p.wep&&p.wep.id)+' / '+(p.sec&&p.sec.id)+')';
       p.wepIssued=false; p.secIssued=false; p.wepFromArmory=false; p.secFromArmory=false; p.roll=0; p.downed=false; p.dying=false;
       g.paused=false; g.bagOpen=false; g.mapOpen=false; g.drag=null;
       g.bag=g.bag.filter(function(k){ return !/^gun_/.test(k); });
       var c0=cell(0), c1=cell(1);
       if(gid(c0)!=='rifle'||!c0.inHand||gid(c1)!=='smg'||c1.inHand) return 'SKIP: staging: keys 1 and 2 do not start on the rifle and the SMG ('+desc(c0)+' / '+desc(c1)+')';
       grantLoot({x:p.x,y:p.y,loot:[],dropped:0},['gun_shotgun'],0);
       if(g.bag.indexOf('gun_shotgun')<0) return 'SKIP: the shotgun did not go into the backpack';
       var sl=hotbarSlots();
       for(i=0;i<sl.length;i++) if(sl[i]&&sl[i].itemKey==='gun_shotgun'){ ks=i; break; }
       if(ks<0) return 'SKIP: the shotgun went onto no belt key';
       setHot(ks);
       if(!(p.wep&&p.wep.id==='shotgun')) return 'SKIP: key '+(ks+1)+' did not draw the shotgun (in hand: '+(p.wep&&p.wep.id)+')';
       var a=cell(ks); c0=cell(0); c1=cell(1);
       if(gid(a)!=='shotgun'||!a.inHand) bad.push('key '+(ks+1)+' shows '+desc(a)+', not the shotgun in hand');
       if(gid(c0)!=='rifle'||c0.inHand) bad.push('with the shotgun drawn key 1 shows '+desc(c0)+', not the rifle in the backpack');
       if(g.bag.indexOf('gun_rifle')<0) bad.push('the rifle the shotgun replaced is not in the backpack');
       if(gid(c1)!=='smg'||c1.inHand) bad.push('with the shotgun drawn key 2 shows '+desc(c1)+', not the stowed SMG');
       if(g.hot!==ks) bad.push('the highlight is on key '+(g.hot+1)+', not on key '+(ks+1)+' he pressed');
       setHot(0);
       c0=cell(0); a=cell(ks); c1=cell(1);
       if(!(p.wep&&p.wep.id==='rifle')) bad.push('key 1 did not draw the rifle back (in hand: '+(p.wep&&p.wep.id)+')');
       if(gid(c0)!=='rifle'||!c0.inHand) bad.push('after key 1 key 1 shows '+desc(c0)+', not the rifle in hand');
       if(gid(a)!=='shotgun'||a.inHand) bad.push('after key 1 key '+(ks+1)+' shows '+desc(a)+', not the shotgun out of hand');
       if(gid(c1)!=='smg') bad.push('after key 1 key 2 shows '+desc(c1)+', not the SMG');
       // GUARD (both builds): a real drag of key 1 off the belt still puts the gun it shows into the backpack (v11.97).
       g.drag=null; __frame(0.016); __frame(0.016);
       var hc=null, cs=g.hotCells||[];
       for(i=0;i<cs.length;i++) if(cs[i]&&cs[i].i===0){ hc=cs[i]; break; }
       if(!hc&&cs[0]) hc=cs[0];
       var cg=cell(0), gun0=gid(cg);
       if(!hc) bad.push('control: the belt drew no key 1 to press');
       else if(!cg.inHand||!gun0||gun0==='fists') bad.push('control: key 1 shows '+desc(cg)+' before the drag, not a gun in hand');
       else {
         mouse.x=hc.x+hc.w/2; mouse.y=hc.y+hc.h/2;
         cv.dispatchEvent(new MouseEvent('mousedown',{button:0,bubbles:true}));
         if(!g.drag||!g.drag.gunSlot) bad.push('pressing key 1 started no gun drag'+(g.drag?' (drag: '+JSON.stringify(g.drag).slice(0,60)+')':''));
         mouse.x=Math.max(20,hc.x-200); mouse.y=Math.max(20,hc.y-260);
         window.dispatchEvent(new MouseEvent('mouseup',{button:0,bubbles:true}));
         if(p.wep&&p.wep.id===gun0) bad.push('the gun on key 1 is still in hand after a drag off the belt');
         if(g.bag.indexOf('gun_'+gun0)<0) bad.push('the gun dragged off key 1 is not in the backpack');
       }
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{
       try{ if(g){ g.drag=null; g.bagOpen=false; } mouse.down=false; }catch(_c){}
       try{ var g2=__state(); if(g2&&!g2.over){ g2.player.downed=false; __endRaid('abandon'); } }catch(_e){}
       P.weapons=w0; P.equipped=e0; P.equippedSec=s0; P.stash=st0; P.kit=kt0; P.hotAssign=ha0;
       try{ saveProfile(); }catch(_s){}
       __topClear(); __cleanProfile();
     }
     return bad.length?bad.join('; '):null; }},
  {v:'21.82',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
