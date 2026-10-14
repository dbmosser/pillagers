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

if ($s.Contains("  {v:'26.32',what:")) { throw "check 26.32 is in the fixture already" }

SubRx @'
  {v:'26.31',what:
'@ @'
  {v:'26.32',what:'wheelcenter, his note: the item wheel is drawn in the middle of the screen and large, not over the player: the ring is centred on the viewport, its radius is a third of the shorter side, the names grow with it, the backdrop is a light vignette, and the mouse picks by its direction from the screen centre (up-right of it is the up-right segment, the hub cancels, a tap of Q with the cursor off to one side picks nothing)',
   run:function(){
     if(!(window.__deploy&&window.__state&&window.__endRaid&&window.__frame)) return 'SKIP: no raid or frame here';
     if(window.__vpAlive&&!__vpAlive()) return 'SKIP: the pane has no layout, so nothing can be drawn';
     if(typeof drawWheel!=='function'||typeof wheelOpen!=='function'||typeof updatePlayer!=='function'||typeof raidKey!=='function') return 'SKIP: no wheel here';
     if(typeof G!=='undefined'&&G&&(G.sim||!G.over)) return 'SKIP: a raid or a sim is live';
     var bad=[], g=null, p=null, proto=CanvasRenderingContext2D.prototype, oArc=proto.arc, oFT=proto.fillText, oACS=CanvasGradient.prototype.addColorStop, oDW=drawWheel, inW=false, arcs=[], fonts=[], cols=[], j, m, an, len, sh, w0, big, mx, off, nf, px, mxa;
     function cl(q){ var o={}, f; for(f in WEAPONS[q]) o[f]=WEAPONS[q][f]; o.q='field'; o.qRank=1; return o; }
     function open(){ keys['KeyQ']=true; raidKey('KeyQ',false,null); return g.wheel; }
     function at(dx,dy){ mouse.x=W/2+dx; mouse.y=H/2+dy; updatePlayer(0.016); }
     function frame(){
       arcs=[]; fonts=[]; cols=[];
       drawWheel=function(){ inW=true; try{ return oDW.apply(this,arguments); } finally { inW=false; } };
       proto.arc=function(x,y,r){ if(inW) arcs.push([x,y,r]); return oArc.apply(this,arguments); };
       proto.fillText=function(s){ if(inW) fonts.push([String(s),String(this.font)]); return oFT.apply(this,arguments); };
       CanvasGradient.prototype.addColorStop=function(o,c){ if(inW) cols.push(String(c)); return oACS.apply(this,arguments); };
       try{ __frame(0); __frame(0); } finally { drawWheel=oDW; proto.arc=oArc; proto.fillText=oFT; CanvasGradient.prototype.addColorStop=oACS; }
     }
     try{
       __topClear(); __runPrep(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       try{ __pinDPR(1); }catch(_d){}
       __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       g=__state(); if(!g||!g.player||g.over) return 'SKIP: staging: no raid';
       p=g.player; p.iv=99; p.maxhp=100; g.ents.length=0; g.bagOpen=false; g.mapOpen=false; g.paused=false; g.trade=null; keys={}; mouse.down=false;
       w0=cl('rifle'); p.wep=w0; p.ammo=w0.mag; p.reserve=60; p.swapped=false; g.hot=0;
       g.bag=['bandage','medkit','stim','plate']; g.pouch.frag=2; g.pouch.smoke=1; g.pouch.decoy=1; g.pouch.trip=1;
       for(j=0;j<40;j++) updatePlayer(0.02);
       sh=Math.min(W,H);
       // ONE: Q goes down with the cursor resting off to the right: a tap picks nothing until the mouse moves
       mouse.x=W/2+Math.round(sh*0.4); mouse.y=H/2-Math.round(sh*0.14);
       if(!open()) return 'ONE: the wheel did not open';
       m=g.wheel.list.length;
       if(m!==8) return 'SKIP: staging: the wheel lists '+m+' types, not the 8 staged';
       updatePlayer(0.016);
       if(g.wheel.sel!==-1) bad.push('ONE: before the mouse moved, the cursor resting off to the side read segment '+g.wheel.sel);
       // TWO: the mouse is read from the SCREEN CENTRE, not from where it was: up-right of the centre is segment 1 (up-right)
       at(Math.round(sh*0.14),-Math.round(sh*0.14));
       if(g.wheel.sel!==1) bad.push('TWO: the mouse up-right of the screen centre read segment '+g.wheel.sel+', not 1');
       for(j=0;j<m;j++){ an=-Math.PI/2+j*(Math.PI*2/m); len=Math.round(sh*0.24); at(Math.round(Math.cos(an)*len),Math.round(Math.sin(an)*len)); if(g.wheel.sel!==j) bad.push('TWO: from the screen centre, direction '+j+' read segment '+g.wheel.sel); }
       at(8,-8); if(g.wheel.sel!==-1) bad.push('TWO: the mouse on the hub did not cancel (segment '+g.wheel.sel+')');
       // THREE: drawn on the screen centre, large, with large names, on a light backdrop
       at(Math.round(sh*0.24),0); g.wheel.t=Math.max(g.wheel.t,0.2);
       frame();
       big=arcs.filter(function(a){ return a[2]>=sh*0.2; }); mx=0; off=0;
       if(big.length<m) bad.push('THREE: the open wheel drew '+big.length+' ring arcs, fewer than its '+m+' segments');
       big.forEach(function(a){ if(a[2]>mx) mx=a[2]; off=Math.max(off,Math.abs(a[0]-W/2),Math.abs(a[1]-H/2)); });
       if(big.length&&off>3) bad.push('THREE: the ring is '+Math.round(off)+' px off the screen centre');
       if(big.length&&!(mx>=sh*0.30)) bad.push('THREE: the ring radius is '+Math.round(mx)+' px, under 30 percent of the shorter side ('+sh+')');
       if(big.length&&!(mx<=sh*0.48)) bad.push('THREE: the ring radius is '+Math.round(mx)+' px, over 48 percent of the shorter side ('+sh+')');
       nf=fonts.filter(function(f){ return f[0]==='BANDAGE'||f[0]==='MEDKIT'; });
       if(!nf.length) bad.push('THREE: the open wheel drew no item names');
       nf.forEach(function(f){ px=parseFloat((/([\d.]+)px/.exec(f[1])||[0,0])[1]); if(!(px>=sh*0.0175)) bad.push('THREE: the name '+f[0]+' is drawn at '+px+' px, small for a screen '+sh+' high'); });
       mxa=0; cols.forEach(function(c){ var q=/^rgba\(\s*5\s*,\s*7\s*,\s*9\s*,\s*([\d.]+)\s*\)$/.exec(c.replace(/\s/g,'')); if(q&&parseFloat(q[1])>mxa) mxa=parseFloat(q[1]); });
       if(!(mxa<=0.4)) bad.push('THREE: the backdrop darkens the world to '+mxa+' opaque, it should stay light');
       if(typeof wheelGeom==='function'){ var gm=wheelGeom(); if(Math.abs(gm.cx-W/2)>3||Math.abs(gm.cy-H/2)>3||!(gm.R>=sh*0.30)) bad.push('THREE: wheelGeom says centre '+gm.cx+','+gm.cy+' radius '+gm.R); }
       else bad.push('THREE: no wheelGeom');
       keys['KeyQ']=false; wheelRelease(); p.hand=null;
       // FOUR: a tap of Q with the cursor resting up-right of the centre picks nothing
       mouse.x=W/2+Math.round(sh*0.14); mouse.y=H/2-Math.round(sh*0.14);
       open(); updatePlayer(0.016); keys['KeyQ']=false; wheelRelease();
       if(p.hand) bad.push('FOUR: a tap of Q with the cursor resting up-right took '+p.hand.k+' out');
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{
       try{ drawWheel=oDW; proto.arc=oArc; proto.fillText=oFT; CanvasGradient.prototype.addColorStop=oACS; }catch(_f){}
       try{ mouse.down=false; keys={}; var g2=__state(); if(g2){ g2.wheel=null; if(!g2.over){ g2.player.iv=0; g2.player.hand=null; __endRaid('abandon'); } } }catch(_e){}
       __topClear(); __resetCfg(); __cleanProfile();
     }
     return bad.length?bad.join('; '):null; }},
  {v:'26.31',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
