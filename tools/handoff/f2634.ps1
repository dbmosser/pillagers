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

if ($s.Contains("  {v:'26.34',what:")) { throw "check 26.34 is in the fixture already" }

SubRx @'
  {v:'26.33',what:
'@ @'
  {v:'26.34',what:'wheelorder, his order: the item wheel reads, clockwise from the top, medkit, smoke canister, frag charge, tripwire mine, armour plate, decoy beacon, bandage, stim injector; each type sits at its own compass position for the mouse and for the right stick, is drawn there, and a carried frag is picked at RIGHT',
   run:function(){
     if(!(window.__deploy&&window.__state&&window.__endRaid&&window.__frame)) return 'SKIP: no raid or frame here';
     if(window.__vpAlive&&!__vpAlive()) return 'SKIP: the pane has no layout, so nothing can be drawn';
     if(typeof drawWheel!=='function'||typeof wheelOpen!=='function'||typeof wheelAt!=='function'||typeof wheelTick!=='function'||typeof updatePlayer!=='function'||typeof raidKey!=='function'||typeof drawIconSprite!=='function') return 'SKIP: no wheel here';
     if(typeof G!=='undefined'&&G&&(G.sim||!G.over)) return 'SKIP: a raid or a sim is live';
     var KEYS=['medkit','smoke','frag','trip','plate','decoy','bandage','stim'], NAMES=['TOP','TOP-RIGHT','RIGHT','BOTTOM-RIGHT','BOTTOM','BOTTOM-LEFT','LEFT','TOP-LEFT'], DIR=[[0,-1],[1,-1],[1,0],[1,1],[0,1],[-1,1],[-1,0],[-1,-1]];
     var bad=[], g=null, p=null, oDW=drawWheel, oDI=drawIconSprite, inW=false, icons={}, on0, j, w0, sh, an, s, ic, vx, vy, ln, cs, got;
     function cl(q){ var o={}, f; for(f in WEAPONS[q]) o[f]=WEAPONS[q][f]; o.q='field'; o.qRank=1; return o; }
     function keysOf8(){ return g.wheel.list.map(function(q){ return q.k; }).join(','); }
     function stageAll(){ g.bag=['bandage','medkit','stim','plate']; g.pouch.frag=2; g.pouch.smoke=1; g.pouch.decoy=1; g.pouch.trip=1; p.hand=null; }
     function stageFrag(){ g.bag=[]; g.pouch.frag=1; g.pouch.smoke=0; g.pouch.decoy=0; g.pouch.trip=0; p.hand=null; }
     function open(){ g.wheel=null; mouse.x=W/2; mouse.y=H/2; keys['KeyQ']=true; raidKey('KeyQ',false,null); return g.wheel; }
     function at(dx,dy){ mouse.x=W/2+dx; mouse.y=H/2+dy; updatePlayer(0.016); }
     function atDir(d){ var a=Math.atan2(d[1],d[0]), r=Math.round(sh*0.24); at(Math.round(Math.cos(a)*r),Math.round(Math.sin(a)*r)); }
     function letgo(){ keys['KeyQ']=false; wheelRelease(); }
     function who(q){ return (q>=0&&g.wheel&&g.wheel.list[q])?g.wheel.list[q].k:'nothing'; }
     function frame(){
       icons={};
       drawWheel=function(){ inW=true; try{ return oDW.apply(this,arguments); } finally { inW=false; } };
       drawIconSprite=function(c,k,x,y){ if(inW&&!icons[k]) icons[k]=[x,y]; return oDI.apply(this,arguments); };
       try{ __frame(0); __frame(0); } finally { drawWheel=oDW; drawIconSprite=oDI; }
     }
     try{
       __topClear(); __runPrep(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       try{ __pinDPR(1); }catch(_d){}
       __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       g=__state(); if(!g||!g.player||g.over) return 'SKIP: staging: no raid';
       p=g.player; p.iv=99; p.maxhp=100; g.ents.length=0; g.bagOpen=false; g.mapOpen=false; g.paused=false; g.trade=null; keys={}; mouse.down=false;
       w0=cl('rifle'); p.wep=w0; p.ammo=w0.mag; p.reserve=60; p.swapped=false; g.hot=0;
       for(j=0;j<40;j++) updatePlayer(0.02);
       sh=Math.min(W,H);
       // ONE: his order, clockwise from the top
       stageAll(); if(!open()) return 'ONE: the wheel did not open with everything carried';
       if(keysOf8()!==KEYS.join(',')) bad.push('ONE: the slots read '+keysOf8()+', not '+KEYS.join(','));
       // TWO: each type sits at its own compass position for the mouse
       for(j=0;j<8;j++){ atDir(DIR[j]); s=g.wheel.sel; if(who(s)!==KEYS[j]) bad.push('TWO: the mouse at '+NAMES[j]+' read '+who(s)+', not '+KEYS[j]); }
       // THREE: and each is drawn there
       g.wheel.t=Math.max(g.wheel.t,0.2);
       frame();
       for(j=0;j<8;j++){
         ic=icons[KEYS[j]]; if(!ic){ bad.push('THREE: no icon was drawn for '+KEYS[j]); continue; }
         vx=ic[0]-W/2; vy=ic[1]-H/2; ln=Math.sqrt(vx*vx+vy*vy)||1; an=Math.atan2(DIR[j][1],DIR[j][0]); cs=(vx*Math.cos(an)+vy*Math.sin(an))/ln;
         if(!(cs>0.95)) bad.push('THREE: the '+KEYS[j]+' is drawn off the '+NAMES[j]+' position (alignment '+cs.toFixed(2)+')');
       }
       letgo(); p.hand=null;
       // FOUR: the right stick reads the same table
       if(typeof PAD==='object'&&PAD){
         on0=PAD.on;
         try{
           PAD.on=true; stageAll(); open(); g.wheel.pad=1;
           for(j=0;j<8;j++){ g.wheel.vx=DIR[j][0]; g.wheel.vy=DIR[j][1]; wheelTick(0.016); got=g.wheel?who(g.wheel.sel):'closed'; if(got!==KEYS[j]) bad.push('FOUR: the stick at '+NAMES[j]+' read '+got+', not '+KEYS[j]); if(!g.wheel) break; }
         } finally { PAD.on=on0; keys['KeyQ']=false; g.wheel=null; p.hand=null; }
       }
       // FIVE: a carried frag is picked at RIGHT
       stageFrag(); if(!open()) return 'FIVE: the wheel did not open with a frag carried';
       at(Math.round(sh*0.24),0);
       if(g.wheel.sel!==2||who(2)!=='frag') bad.push('FIVE: the mouse at RIGHT read slot '+g.wheel.sel+' ('+who(2)+'), not the frag');
       letgo();
       if(!p.hand||p.hand.k!=='frag') bad.push('FIVE: letting go at RIGHT took '+(p.hand?p.hand.k:'nothing')+' out, not the frag');
       p.hand=null;
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{
       try{ drawWheel=oDW; drawIconSprite=oDI; }catch(_f){}
       try{ mouse.down=false; keys={}; var g2=__state(); if(g2){ g2.wheel=null; if(!g2.over){ g2.player.iv=0; g2.player.hand=null; __endRaid('abandon'); } } }catch(_e){}
       __topClear(); __resetCfg(); __cleanProfile();
     }
     return bad.length?bad.join('; '):null; }},
  {v:'26.33',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
