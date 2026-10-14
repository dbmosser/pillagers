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

if ($s.Contains("  {v:'26.33',what:")) { throw "check 26.33 is in the fixture already" }

SubRx @'
  {v:'26.32',what:
'@ @'
  {v:'26.33',what:'wheelfixed, his order: the item wheel is always the same eight slots in the same places, clockwise from the top (medkit, frag, smoke, decoy, plate, tripwire, stim, bandage), whatever is carried; what you carry fills its slot by itself, a carried smoke is picked at RIGHT, a type with none stays in its slot dimmed with a 0 and letting go on it takes nothing out, and DEMO and CAREER lay it out the same',
   run:function(){
     if(!(window.__deploy&&window.__state&&window.__endRaid&&window.__frame)) return 'SKIP: no raid or frame here';
     if(window.__vpAlive&&!__vpAlive()) return 'SKIP: the pane has no layout, so nothing can be drawn';
     if(typeof drawWheel!=='function'||typeof wheelOpen!=='function'||typeof wheelAt!=='function'||typeof updatePlayer!=='function'||typeof raidKey!=='function'||typeof drawIconSprite!=='function') return 'SKIP: no wheel here';
     if(typeof G!=='undefined'&&G&&(G.sim||!G.over)) return 'SKIP: a raid or a sim is live';
     var ORDER='medkit,frag,smoke,decoy,plate,trip,stim,bandage', bad=[], g=null, p=null, proto=CanvasRenderingContext2D.prototype, oFT=proto.fillText, oDW=drawWheel, oDI=drawIconSprite, realSay=say, inW=false, icons=[], texts=[], said=[], j, w0, sh, ia, ib, pc, c0, a0, lay=[];
     function cl(q){ var o={}, f; for(f in WEAPONS[q]) o[f]=WEAPONS[q][f]; o.q='field'; o.qRank=1; return o; }
     function keysOf8(){ return g.wheel.list.map(function(q){ return q.k; }).join(','); }
     function stageAll(){ g.bag=['bandage','medkit','stim','plate']; g.pouch.frag=2; g.pouch.smoke=1; g.pouch.decoy=1; g.pouch.trip=1; p.hand=null; }
     function stageSmoke(){ g.bag=[]; g.pouch.frag=0; g.pouch.smoke=1; g.pouch.decoy=0; g.pouch.trip=0; p.hand=null; }
     function open(){ g.wheel=null; mouse.x=W/2; mouse.y=H/2; keys['KeyQ']=true; raidKey('KeyQ',false,null); return g.wheel; }
     function at(dx,dy){ mouse.x=W/2+dx; mouse.y=H/2+dy; updatePlayer(0.016); }
     function letgo(){ keys['KeyQ']=false; wheelRelease(); }
     function frame(){
       icons=[]; texts=[];
       drawWheel=function(){ inW=true; try{ return oDW.apply(this,arguments); } finally { inW=false; } };
       drawIconSprite=function(c,k){ if(inW) icons.push([k,c.globalAlpha]); return oDI.apply(this,arguments); };
       proto.fillText=function(s){ if(inW) texts.push([String(s),this.globalAlpha]); return oFT.apply(this,arguments); };
       try{ __frame(0); __frame(0); } finally { drawWheel=oDW; drawIconSprite=oDI; proto.fillText=oFT; }
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
       say=function(s){ said.push(String(s)); };
       // ONE: the same eight slots in the same order whatever is carried, and the counts are the carried amounts
       stageAll(); if(!open()) return 'ONE: the wheel did not open with everything carried';
       if(keysOf8()!==ORDER) bad.push('ONE: carrying everything, the slots read '+keysOf8()+', not '+ORDER);
       if(g.wheel.list.map(function(q){ return q.n; }).join(',')!=='1,2,1,1,1,1,1,1'&&g.wheel.list.length===8) bad.push('ONE: the counts read '+g.wheel.list.map(function(q){ return q.n; }).join(',')+', not 1,2,1,1,1,1,1,1');
       letgo();
       stageSmoke(); if(!open()) return 'ONE: the wheel did not open with a smoke carried';
       if(keysOf8()!==ORDER) bad.push('ONE: carrying one smoke, the slots read '+keysOf8()+', not '+ORDER);
       // TWO: the eight directions are fixed: top, top-right, right, bottom-right, bottom, bottom-left, left, top-left
       lay=[wheelAt(8,0,-1),wheelAt(8,1,-1),wheelAt(8,1,0),wheelAt(8,1,1),wheelAt(8,0,1),wheelAt(8,-1,1),wheelAt(8,-1,0),wheelAt(8,-1,-1)];
       if(lay.join(',')!=='0,1,2,3,4,5,6,7') bad.push('TWO: the compass reads '+lay.join(','));
       at(Math.round(sh*0.24),0);
       if(g.wheel.sel!==2||g.wheel.list[2].k!=='smoke') bad.push('THREE: the mouse at RIGHT read slot '+g.wheel.sel+' ('+(g.wheel.list[2]&&g.wheel.list[2].k)+'), not the smoke');
       letgo();
       if(!p.hand||p.hand.k!=='smoke') bad.push('THREE: letting go at RIGHT took '+(p.hand?p.hand.k:'nothing')+' out, not the smoke');
       p.hand=null;
       // FOUR: a type with none stays in its slot, dim, with a 0, and cannot be picked
       stageSmoke(); said=[]; open(); at(Math.round(sh*0.14),-Math.round(sh*0.14));
       if(g.wheel.sel!==1||g.wheel.list[1].k!=='frag'||g.wheel.list[1].n!==0) bad.push('FOUR: top-right read slot '+g.wheel.sel+' '+g.wheel.list[1].k+' x'+g.wheel.list[1].n);
       g.wheel.t=Math.max(g.wheel.t,0.2);
       frame();
       ia=-1; ib=-1; icons.forEach(function(q){ if(q[0]==='frag') ia=q[1]; if(q[0]==='smoke') ib=q[1]; });
       if(!(ia>=0&&ia<0.5)) bad.push('FOUR: the empty frag slot is drawn at alpha '+ia+', not dim');
       if(!(ib>=0.9)) bad.push('FOUR: the carried smoke slot is drawn at alpha '+ib+', not clear');
       pc=texts.filter(function(q){ return q[0]==='x0'; });
       if(!pc.length) bad.push('FOUR: the empty slots drew no 0 count');
       else if(pc.some(function(q){ return q[1]>0.8; })) bad.push('FOUR: the 0 count is drawn at full strength');
       letgo();
       if(p.hand) bad.push('FOUR: letting go on an empty slot took '+p.hand.k+' out');
       if(!said.some(function(s){ return /^NO /.test(s); })) bad.push('FOUR: letting go on an empty slot gave no cue ('+said.join('|')+')');
       // FIVE: DEMO and CAREER lay it out the same
       stageAll(); c0=g.career; a0=g.arcade;
       [{career:true,arcade:false},{career:false,arcade:true}].forEach(function(f){ g.career=f.career; g.arcade=f.arcade; if(open()&&keysOf8()!==ORDER) bad.push('FIVE: with career '+f.career+' and arcade '+f.arcade+' the slots read '+keysOf8()); letgo(); p.hand=null; });
       g.career=c0; g.arcade=a0;
       if(/career|demo|arcade/i.test(String(wheelList)+String(wheelOpen))) bad.push('FIVE: the wheel list or opener looks at the mode');
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{
       try{ drawWheel=oDW; drawIconSprite=oDI; proto.fillText=oFT; say=realSay; }catch(_f){}
       try{ mouse.down=false; keys={}; var g2=__state(); if(g2){ g2.wheel=null; if(!g2.over){ g2.player.iv=0; g2.player.hand=null; __endRaid('abandon'); } } }catch(_e){}
       __topClear(); __resetCfg(); __cleanProfile();
     }
     return bad.length?bad.join('; '):null; }},
  {v:'26.32',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
