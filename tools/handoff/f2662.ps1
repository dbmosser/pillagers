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

if ($s.Contains("  {v:'26.62',what:")) { throw "check 26.62 is in the fixture already" }

SubRx @'
  {v:'26.61',what:
'@ @'
  {v:'26.62',what:'his yes (suggestion 22): sustained fire past a hostile pillager pins him: he stops advancing for a while, ducks, and the state rides the network flags; a pillager under no fire still closes in',
   run:function(){
     if(!(window.__deploy&&window.__state&&window.__endRaid&&window.__sim)||typeof render2D!=='function'||typeof mkRaider!=='function'||typeof WEAPONS==='undefined') return 'SKIP: no raid here';
     var bad=[], g=null, p=null, all=null, a, k, sx, sy, rFree, rPin, f, mode, oD, ex, cf;
     function setup(r){
       var q=mkRaider(sx,sy,undefined,true), j;
       q.elite=0; q.prole='rush'; q.hostile=true; q.wep=WEAPONS.smg; q.dmg=WEAPONS.smg.dmg; q.rng=WEAPONS.smg.rng*.72; q.hp=q.maxhp; q.bag=[];
       q.x=p.x+Math.cos(a)*240; q.y=p.y+Math.sin(a)*240; q.face=Math.atan2(p.y-q.y,p.x-q.x); q.state='chase'; q.alert=3; q.tx=p.x; q.ty=p.y; q.cd=0; q.windup=null; q.flank=1; q.pinT=0; q.supp=0; q.suppT=0;
       g.ents=[q]; g.bullets.length=0; for(j in keys) keys[j]=false;
       return q;
     }
     function go(q,fire){
       var j, ux, uy, nx, ny, d, minD=1e9, pins=0, fin;
       for(j=0;j<150;j++){
         q.alert=3; p.hp=100000;
         if(fire&&j%6===0){
           d=dist(q,p); ux=(q.x-p.x)/d; uy=(q.y-p.y)/d; nx=-uy; ny=ux;
           g.bullets.push({x:p.x+ux*20+nx*35,y:p.y+uy*20+ny*35,vx:ux*1180,vy:uy*1180,dmg:1,life:0.4,player:true,owner:p,tint:'#ffd48a',el:'',thru:0});
         }
         __sim(1/60); updateBullets(1/60);
         d=dist(q,p); if(d<minD) minD=d;
         if(q.pinT>0) pins++;
       }
       fin=dist(q,p);
       return {fin:fin,min:minD,pins:pins};
     }
     try{
       if(typeof suppHit!=='function') return 'a pillager cannot be suppressed';
       __topClear(); __runPrep(); __resetCfg(); __pinDefaults(0); __cleanProfile(); __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       g=__state(); if(!g||g.over) return 'SKIP: no live raid';
       p=g.player; p.iv=99; p.hp=100000; p.downed=false; all=g.ents.slice();
       for(k=0;k<24;k++){ a=k/24*6.2832; if(losClear(p.x,p.y,p.x+Math.cos(a)*240,p.y+Math.sin(a)*240,G.vseg)) break; }
       if(k>=24) return 'SKIP: no open ground beside the player';
       sx=p.x+Math.cos(a)*240; sy=p.y+Math.sin(a)*240; p.face=Math.atan2(sy-p.y,sx-p.x);
       rFree=go(setup(),false);
       if(rFree.pins>0) bad.push('a pillager under no fire was pinned');
       if(!(rFree.fin<=170)) bad.push('with no fire a rusher at 240 closed to only '+Math.round(rFree.fin)+' in 2.5 s (the control should close in)');
       rPin=go(setup(),true);
       if(!(rPin.pins>0)) bad.push('ten rounds a second past a pillager never pinned him');
       if(!(rPin.min>=210)) bad.push('a pinned rusher still came to '+Math.round(rPin.min)+' from the player (he should hold near 240)');
       ex=setup(); ex.pinT=0; ex.supp=0; ex.suppT=0;
       for(k=0;k<3;k++) suppHit(ex);
       if(ex.pinT>0) bad.push('three rounds were enough to pin a man (four are needed)');
       suppHit(ex); if(!(ex.pinT>0)) bad.push('four rounds past a man did not pin him');
       ex.hostile=false; ex.pinT=0; ex.supp=0; for(k=0;k<6;k++) suppHit(ex);
       if(ex.pinT>0) bad.push('a peaceful pillager was pinned');
       ex.hostile=true; ex.pinT=0.7; cf=netEntFlags(ex);
       if(!(cf&268435456)) bad.push('a pinned pillager sends no pinned flag to the party');
       ex.pinT=0; if(netEntFlags(ex)&268435456) bad.push('a free pillager sends the pinned flag');
       cf=netEntFlags(Object.assign({},ex,{pinT:0.7})); ex={kind:'raider',x:0,y:0,state:'chase',hp:50,maxhp:50}; netEntFlagsApply(ex,cf);
       if(!(ex.pinT>0)) bad.push('a linked window does not read the pinned flag');
       g.ents=all.slice(); all=g.ents.slice();
       for(k=0;k<24;k++){ a=k/24*6.2832; if(losClear(p.x,p.y,p.x+Math.cos(a)*90,p.y+Math.sin(a)*90,G.vseg)) break; }
       if(k<24){
         sx=p.x+Math.cos(a)*90; sy=p.y+Math.sin(a)*90; p.face=Math.atan2(sy-p.y,sx-p.x);
         ex=mkRaider(sx,sy,undefined,true); ex.elite=0; ex.hostile=true; ex.state='loot'; ex.goal=null; ex.downed=0; ex.hp=ex.maxhp; ex.face=Math.atan2(p.y-sy,p.x-sx);
         g.ents=[ex]; oD=drawOp;
         drawOp=function(){ var s=arguments[9]; if(s&&s.own===ex) mode=arguments[7]; return oD.apply(this,arguments); };
         try{ ex.pinT=1; mode=null; render2D(0.016); if(mode!=='crouch') bad.push('a pinned pillager in view is drawn "'+mode+'", not crouched'); ex.pinT=0; mode=null; render2D(0.016); if(mode==='crouch') bad.push('a free pillager is drawn crouched'); }
         finally { drawOp=oD; }
       }
     }catch(x){ bad.push('threw: '+(x&&x.message||x)); }
     finally{
       try{ if(typeof oD==='function') drawOp=oD; }catch(_e1){}
       try{ if(g&&all){ g.ents=all; g.bullets.length=0; } var g2=__state(); if(g2&&!g2.over){ g2.player.iv=0; g2.player.hp=100; g2.player.downed=false; __endRaid('abandon'); } }catch(_e3){}
       __topClear();
     }
     return bad.length?bad.join('; '):null; }},
  {v:'26.61',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
