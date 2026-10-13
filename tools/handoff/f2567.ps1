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

if ($s.Contains("  {v:'25.67',what:")) { throw "check 25.67 is in the fixture already" }

SubRx @'
  {v:'25.66',what:
'@ @'
  {v:'25.67',what:'his key swap: E searches a box in an open ring and never calls the extraction, X calls it and boards, H is the quick heal (a Bandage stops at 85), F1 cycles the controls list and H no longer does, G throws the selected throwable, Q swings a crowbar that hurts a machine in reach and draws it, F brings up the next gun, skips an empty key and wraps round',
   run:function(){
     if(!window.__deploy||!window.__endRaid||typeof updatePlayer!=='function'||typeof mkSentry!=='function'||typeof drawOp!=='function'||typeof hotbarSlots!=='function') return 'SKIP: this fixture cannot stage the keys';
     var bad=[], g=null, p=null, z=null, ct=null, S=null, E0=null, kk, v0, n0, h0, cols, sl, w0, jj, kSay=say, nB='band'+'age', nF='fr'+'ag';
     function dn(code,key){ window.dispatchEvent(new KeyboardEvent('keydown',{code:code,key:key||code,bubbles:true,cancelable:true})); }
     function upk(code,key){ window.dispatchEvent(new KeyboardEvent('keyup',{code:code,key:key||code,bubbles:true,cancelable:true})); }
     function fr(n){ for(var j=0;j<n;j++) updatePlayer(0.05); }
     function clr(){ for(var q in keys) keys[q]=false; }
     function gw(id){ var o={}, q; for(q in WEAPONS[id]) o[q]=WEAPONS[id][q]; return o; }
     function drawCols(on){
       var c=[], of=wc.fillRect;
       wc.fillRect=function(){ c.push(String(wc.fillStyle)); return of.apply(wc,arguments); };
       try{ g.punchT=0.2; g.barT=on?0.12:0; drawOp(p.x,p.y,0,0,'#242832',0,0,'fist',0,{hero:1,own:p,team:'ally',moving:false,sprint:false,ads:false,hurt:0,bulk:armorById(p.rig).bulk,healLeft:0,healTot:0,healSec:0,rl:0}); }
       finally{ delete wc.fillRect; g.punchT=0; g.barT=0; }
       return c;
     }
     try{
       __topClear(); __runPrep(); __resetCfg(); __pinDefaults(0);
       if(typeof keysOf==='function'&&['KeyE','KeyX','KeyG','KeyH','KeyQ','KeyF','F1'].some(function(c){ return keysOf(c)!==c; })) return 'SKIP: a key is rebound in the fixture profile';
       __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       g=__state(); p=g&&g.player; if(!g||g.over||!p||!g.zones||!g.zones.length||!g.containers||!g.ents) return 'SKIP: no live raid';
       E0=g.ents; clr(); g.paused=false; p.downed=false; p.dying=false; p.roll=0; p.iv=99; g.searching=null; g.trade=null;
       // F1 cycles the controls list, H does not
       v0=g.legendOn; dn('F1','F1'); upk('F1','F1');
       if(g.legendOn!==(v0+1)%3) bad.push('F1 did not cycle the controls list ('+v0+' to '+g.legendOn+')');
       v0=g.legendOn; dn('KeyH','h'); upk('KeyH','h');
       if(g.legendOn!==v0) bad.push('H still cycles the controls list');
       // H heals: a Bandage with health missing starts the wind-up and is spent; at 90 a Bandage is refused, a Medkit is not
       g.bag.length=0; g.bag.push(nB); p.hp=50; p.healQ=0; p.prep=null; clr();
       dn('KeyH','h'); upk('KeyH','h');
       if(!p.prep||p.prep.kind!=='heal') bad.push('H with a Bandage and 50 health did not start the heal wind-up ('+JSON.stringify(p.prep)+')');
       if(g.bag.indexOf(nB)>=0) bad.push('H did not spend the Bandage');
       fr(90);
       if(!(p.hp>50||p.healQ>0)) bad.push('the Bandage H applied never raised health ('+p.hp+')');
       g.bag.length=0; g.bag.push(nB); p.hp=90; p.healQ=0; p.prep=null; clr();
       dn('KeyH','h'); upk('KeyH','h');
       if(p.prep||g.bag.indexOf(nB)<0) bad.push('H at 90 health spent a Bandage (they stop at 85)');
       if(ITEMS.medkit){ g.bag.length=0; g.bag.push('medkit'); p.hp=90; p.healQ=0; p.prep=null; clr(); dn('KeyH','h'); upk('KeyH','h'); if(!p.prep) bad.push('H at 90 health did not use a Medkit (it reaches 100)'); }
       p.prep=null; p.hp=100; p.healQ=0; g.bag.length=0;
       // G throws the selected throwable at once
       g.pouch[nF+'']=2; g.tsel=THROWKEYS.indexOf(nF); g.hot=0; n0=g.pouch[nF]; clr(); g.frags.length=0;
       dn('KeyG','g'); upk('KeyG','g');
       if(g.pouch[nF]!==n0-1) bad.push('G did not throw the selected throwable (pouch '+n0+' to '+g.pouch[nF]+')');
       g.frags.length=0; clr();
       // Q swings the crowbar: a machine in reach is hurt, the crowbar is drawn
       p.x=g.zones[0].x; p.y=g.zones[0].y; p.face=0; S=mkSentry(p.x+40,p.y); S.hp=80; h0=S.hp; g.ents=[S]; g.searching=null; p.meleeAt=undefined; p.lastShot=undefined; p.cooking=0; g.barT=0; g.punchT=0; clr();
       dn('KeyQ','q'); upk('KeyQ','q');
       if(!(S.hp<h0)) bad.push('Q did not hurt a machine 40 away in front ('+h0+' to '+S.hp+')');
       if(!(g.barT>0)) bad.push('Q started no crowbar swing');
       try{ cols=drawCols(true); if(cols.indexOf('#a8372a')<0) bad.push('the swing drew no crowbar'); cols=drawCols(false); if(cols.indexOf('#a8372a')>=0) bad.push('the plain fist punch draws a crowbar'); }catch(_dr){ bad.push('drawing the swing threw: '+(_dr&&_dr.message||_dr)); }
       g.ents=E0; clr(); g.barT=0; g.punchT=0;
       // F brings up the next gun: 1 to 2, then round past the empty keys
       p.wep=gw('pistol'); p.ammo=8; p.sec=gw('smg'); p.secAmmo=20; p.swapped=false; g.hotAssign={}; g.hotAuto={}; g.hot=0; p.reloading=0; clr();
       dn('KeyF','f'); upk('KeyF','f');
       if(p.wep.id!=='smg') bad.push('F from gun 1 did not bring up gun 2 ('+p.wep.id+')');
       dn('KeyF','f'); upk('KeyF','f');
       if(p.wep.id!=='pistol') bad.push('F from gun 2 did not wrap round to gun 1 past the empty keys ('+p.wep.id+')');
       if(ITEMS.gun_rifle){
         p.wep=gw('pistol'); p.ammo=8; p.sec=gw('smg'); p.secAmmo=20; p.swapped=false; g.bag.length=0; g.bag.push('gun_rifle'); g.hotAssign={2:'gun_rifle'}; g.hotAuto={}; g.hot=0; clr();
         sl=hotbarSlots();
         if(sl[2]&&sl[2].kind==='gun'&&!sl[2].vacant&&sl[3]&&sl[3].vacant){
           dn('KeyF','f'); upk('KeyF','f'); w0=p.wep.id;
           if(w0!=='smg') bad.push('F from gun 1 with three guns did not bring up gun 2 ('+w0+')');
           dn('KeyF','f'); upk('KeyF','f'); w0=p.wep.id;
           if(w0!=='rifle') bad.push('F from gun 2 did not bring up gun 3 ('+w0+')');
           dn('KeyF','f'); upk('KeyF','f');
           if(p.wep.id==='rifle') bad.push('F from gun 3 did not wrap round past the empty key 4');
         }
       }
       g.bag.length=0; g.hotAssign={}; g.hotAuto={}; clr();
       // the ring: E searches the box and calls nothing; X calls and searches nothing
       ct=null; for(jj=0;jj<g.containers.length;jj++){ if(!g.containers[jj].opened&&g.containers[jj].loot&&g.containers[jj].loot.length&&!g.containers[jj].mercSrc){ ct=g.containers[jj]; break; } }
       if(!ct) return bad.length?bad.join('; '):'SKIP: no container to stage a search';
       z=g.zones[0]; z.open=true; z.beaconT=null; z.hold=null; z.callT=0; z.pullT=null; g.beaconT=null; g.active=z;
       p.x=z.x; p.y=z.y; ct.x=z.x+14; ct.y=z.y; ct.opened=false; ct.time=60; ct.prog=0; ct.pulled=0; g.searching=null; clr();
       dn('KeyE','e'); fr(40); upk('KeyE','e'); clr();
       if(!(ct.prog>0)) bad.push('E in an open ring did not search the box at his feet');
       if(z.beaconT!==null||z.callT>0.01) bad.push('E in an open ring started an extraction call (callT '+z.callT+', beaconT '+z.beaconT+')');
       z.beaconT=null; z.callT=0; ct.opened=false; ct.prog=0; ct.pulled=0; g.searching=null; clr();
       dn('KeyX','x'); fr(40); upk('KeyX','x'); clr();
       if(!(z.beaconT>0)) bad.push('X in an open ring did not call the extraction (beaconT '+z.beaconT+')');
       if(ct.prog>0||ct.pulled>0||ct.opened) bad.push('X searched the box (it is the extraction key)');
       // landed: E does not take the extraction, X does
       z.beaconT=null; z.callT=0; z.hold=25; z.pullT=null; g.shipHold=null; g.active=z; g.searching=null; clr();
       dn('KeyE','e'); fr(40); upk('KeyE','e'); clr();
       if(g.over) bad.push('E in a landed ring took the extraction');
       z.pullT=null; z.hold=25;
       dn('KeyX','x'); fr(40); upk('KeyX','x'); clr();
       if(!g.over) bad.push('X in a landed ring did not take the extraction');
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{
       try{ say=kSay; }catch(_s){}
       try{ for(kk in keys) keys[kk]=false; }catch(_k){}
       try{ if(g){ g.barT=0; g.punchT=0; if(E0) g.ents=E0; } }catch(_g){}
       try{ var g2=__state(); if(g2&&!g2.over){ g2.player.iv=0; __endRaid('abandon'); } }catch(_e){}
       __topClear();
     }
     return bad.length?bad.join('; '):null; }},
  {v:'25.66',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
