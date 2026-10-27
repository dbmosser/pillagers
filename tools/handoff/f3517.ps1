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

if ($s.Contains("  {v:'35.17',what:")) { throw "check 35.17 is in the fixture already" }

SubRx @'
  {v:'35.16',what:
'@ @'
  {v:'35.17',what:'FOG OF WAR FIXES: turning in Superhot opens the live view and marks ground, ground in view counts as in sight facing any way, wall hits and smoke in plain view show, pixel blasts out of sight stay hidden',
   run:function(){
     var bad=[], p, keep=CFG.fogWar, keepPix=CFG.xfPix, face0, segs, i, a, rr, x, y, ft, turn=null, pb=null, poly, A, R, nE=0, nOff=0, calls=[], _pfs=pixFxSquare, _pfi=pixFxImage, Z, vx0, vy0, vx1, vy1;
     try{
       __topClear(); __runPrep(); __pinDPR(1); __forceSize(1920,1080); __resetCfg(); __pinDefaults(0); __cleanProfile();
       CFG.fogWar=1;
       __deploy({kit:['gun_carbine'],mapIx:0,seed:4242});
       if(state!=='raid'||!G||!G.player) return 'no raid';
       G.mapFirst=false; G.mapOpen=false; p=G.player; face0=p.face; G.ents.length=0; if(!G.vseg) G.vseg=G.map.segs; segs=G.vseg;
       __frame(0);
       Z=ZOOM(); vx0=VX-200; vy0=VY-100; vx1=VX+W/Z+200; vy1=VY+H/Z+250;
       A=Math.max(70,AMBR()); R=VF();
       // a spot behind him he cannot see now, but would see if he turned to it
       for(a=0;a<25&&!turn;a++){ for(rr=A+60;rr<=Math.min(R*0.75,700)&&!turn;rr+=40){
         x=p.x+Math.cos(face0+Math.PI+(a-12)*0.08)*rr; y=p.y+Math.sin(face0+Math.PI+(a-12)*0.08)*rr; ft=Math.atan2(y-p.y,x-p.x);
         if(x>30&&y>30&&x<WORLD_W-30&&y<WORLD_H-30&&!canSee(p.x,p.y,face0,x,y,segs)&&canSee(p.x,p.y,ft,x,y,segs)) turn={x:x,y:y,f:ft}; } }
       if(!turn) bad.push('staging: no spot to turn to');
       else {
         // (1) Superhot: G.t stands still while he turns
         G._fwlE=null;
         if(fowLive(turn.x,turn.y)) bad.push('staging: the spot behind him counts as in sight before he turns');
         p.face=turn.f;
         if(!fowLive(turn.x,turn.y)) bad.push('turning with the clock stopped (Superhot) did not open the live view there');
         p.face=face0;
         // (3) explored ground is marked as he turns with the clock stopped
         fowEnsure(); for(i=0;i<G.fow.length;i++) G.fow[i]=0; G._fowT=-99; fowMark();
         if(fowAt(turn.x,turn.y)) bad.push('staging: the spot behind him was marked explored before he turned');
         p.face=turn.f; fowMark();
         if(!fowAt(turn.x,turn.y)) bad.push('turning with the clock stopped (Superhot) did not mark the ground he looked at');
         p.face=face0;
       }
       // (2) every wall edge of his sight shape counts as in sight (impact puffs and sparks start there)
       G._fwlE=null; poly=buildVisPoly(p.x,p.y,p.face,segs);
       for(i=0;i<poly.length;i++){ var q1=poly[i], q2=poly[(i+1)%poly.length];
         if(Math.hypot(q1.x-p.x,q1.y-p.y)<1||Math.hypot(q2.x-p.x,q2.y-p.y)<1) continue;
         var mx=(q1.x+q2.x)/2, my=(q1.y+q2.y)/2, md=Math.hypot(mx-p.x,my-p.y);
         if(md<A+10||md>R-10) continue;
         nE++; if(!fowLive(mx,my)) nOff++; }
       if(nE<4) bad.push('staging: only '+nE+' wall edges in his sight');
       else if(nOff) bad.push(nOff+' of '+nE+' wall edge points in his sight count as out of sight');
       // (6) ground in plain view counts as in sight whichever way he faces (the sight shape folds over itself facing west)
       var nDir=0, nDirOff=[], dI;
       for(dI=0;dI<8;dI++){ ft=dI*Math.PI/4+0.05; var hit=null;
         for(rr=A+40;rr<=Math.min(R*0.7,600)&&!hit;rr+=20){ x=p.x+Math.cos(ft)*rr; y=p.y+Math.sin(ft)*rr; if(x>30&&y>30&&x<WORLD_W-30&&y<WORLD_H-30&&canSee(p.x,p.y,ft,x,y,segs)) hit={x:x,y:y}; else break; }
         if(!hit) continue; nDir++; p.face=ft; G._fwlE=null; if(!fowLive(hit.x,hit.y)) nDirOff.push(Math.round(ft*57.3)+' deg'); }
       p.face=face0; G._fwlE=null;
       if(nDir<3) bad.push('staging: only '+nDir+' clear facings');
       else if(nDirOff.length) bad.push('ground in plain view counts as out of sight facing '+nDirOff.join(', '));
       // (5) a smoke cloud in plain view, past the near circle, is drawn (smoke blocks sight, so its middle is never in the sight shape)
       var smk=null, arcs=[];
       for(a=0;a<36&&!smk;a++){ ft=face0+a*0.1745; for(rr=A+130;rr<=Math.min(R*0.8,720)&&!smk;rr+=30){ x=p.x+Math.cos(ft)*rr; y=p.y+Math.sin(ft)*rr;
         if(x>120&&y>120&&x<WORLD_W-120&&y<WORLD_H-120&&canSee(p.x,p.y,ft,x,y,G.map.segs)&&canSee(p.x,p.y,ft,x-Math.cos(ft)*90,y-Math.sin(ft)*90,G.map.segs)) smk={x:x,y:y,r:80,t:1,life:12,f:ft}; } }
       if(!smk) bad.push('staging: no clear spot ahead for a smoke cloud');
       else {
         p.face=smk.f; var smokeDrawn=function(){ arcs.length=0; G.smokes.length=0; G.smokes.push(smk); G.vseg=G.map.segs.concat(smokeSegs()); G._fwlE=null; __frame(0); var n=arcs.length; G.smokes.length=0; G.vseg=G.map.segs; return n; };
         wc.arc=function(ax,ay){ if(Math.abs(ax-smk.x)<smk.r&&Math.abs(ay-(smk.y-12))<12) arcs.push(1); return CanvasRenderingContext2D.prototype.arc.apply(this,arguments); };
         if(!smokeDrawn()) bad.push('a smoke cloud in plain view was not drawn with fog of war on');
         CFG.fogWar=0; if(!smokeDrawn()) bad.push('control: the smoke cloud was not drawn with fog of war off either'); CFG.fogWar=1;
         try{ delete wc.arc; }catch(_d){}
         p.face=face0;
       }
       // (4) the pixel look blast out of sight is not drawn
       for(a=0;a<25&&!pb;a++){ for(rr=A+60;rr<=700&&!pb;rr+=40){
         x=p.x+Math.cos(face0+Math.PI+(a-12)*0.08)*rr; y=p.y+Math.sin(face0+Math.PI+(a-12)*0.08)*rr;
         if(x>vx0&&x<vx1&&y>vy0&&y<vy1&&!canSee(p.x,p.y,face0,x,y,segs)) pb={x:x,y:y}; } }
       if(!pb) bad.push('staging: no spot out of sight on screen');
       else {
         CFG.xfPix=1;
         pixFxSquare=function(c,x2,y2){ if(Math.abs(x2-pb.x)<220&&Math.abs(y2-pb.y)<220) calls.push(1); return _pfs.apply(this,arguments); };
         pixFxImage=function(k,x2,y2){ if(Math.abs(x2-pb.x)<220&&Math.abs(y2-pb.y)<220) calls.push(1); return false; };
         var boom=function(){ BOOMS.length=0; BOOMS.push({g:G,x:pb.x,y:pb.y,s:1,s0:1,dmgR:60,kind:'',t0:(G.t||0)-0.1,deb:[{ux:1,uy:0,sp:60,vz:120,tl:0.46,r:4,c:'#38322b'},{ux:0,uy:1,sp:60,vz:120,tl:0.46,r:4,c:'#38322b'}],smoke:[]}); calls.length=0; G._fwlE=null; gfxBoomDraw(); return calls.length; };
         if(boom()) bad.push('a pixel look blast out of sight was drawn with fog of war on');
         CFG.fogWar=0; if(!boom()) bad.push('control: the pixel look blast was not drawn with fog of war off either'); CFG.fogWar=1;
       }
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{
       try{ delete wc.arc; }catch(_w){}
       try{ if(G){ G.smokes.length=0; if(G.map) G.vseg=G.map.segs; } }catch(_m){}
       try{ pixFxSquare=_pfs; }catch(_a){}
       try{ pixFxImage=_pfi; }catch(_b){}
       try{ CFG.fogWar=keep; }catch(_f){}
       try{ CFG.xfPix=keepPix; }catch(_x){}
       try{ BOOMS.length=0; }catch(_o){}
       try{ if(G&&G.player&&face0!==undefined) G.player.face=face0; if(G) G._fwlE=null; }catch(_p){}
       try{ var sm=document.getElementById('sectormodal'); if(sm) sm.classList.remove('on'); }catch(_s){}
       try{ if(pauseOpen) togglePauseBox(false); }catch(_q){}
       try{ var K2=__keys(); for(var q2 in K2) delete K2[q2]; }catch(_k){}
       try{ if(state==='raid'&&G&&!G.over) __endRaid('abandon'); }catch(_e){}
       try{ __topClear(); __cleanProfile(); }catch(_c){}
     }
     return bad.length?bad.join('; '):null; }},
  {v:'35.16',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
