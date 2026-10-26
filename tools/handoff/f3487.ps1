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

if ($s.Contains("  {v:'34.87',what:")) { throw "check 34.87 is in the fixture already" }

SubRx @'
  {v:'34.86',what:
'@ @'
  {v:'34.87',what:'cw-elemseen, found by the job 127 glow pictures: in a live raid frame, a burning, shocked and frozen machine behind a wall draws no flames, no element effects and no glow source (it showed as floating flames in the fog), while the same three statuses on a machine in plain sight still draw their flames and all three glow sources',
   run:function(){
     if(!(window.__deploy&&window.__state&&window.__endRaid&&window.__frame)) return 'SKIP: this fixture cannot draw a live raid frame';
     if(typeof drawElemFx!=='function'||typeof elemFlame!=='function'||typeof gfxEmit!=='function'||typeof mkSentry!=='function'||typeof losClear!=='function'||typeof canSee!=='function') return 'SKIP: no element effects to stage in this build';
     var bad=[], g=null, p=null, E0=null, A=null, B=null, i, d, ang, x, y, gb, kF=elemFlame, kE=gfxEmit, kD=drawElemFx, kSS=CFG.sharedSight, wrapped=false, fl={A:0,B:0}, em={A:0,B:0}, nD=[];
     function who(x,y){ var da=Math.hypot(x-A.x,y-A.y), db=Math.hypot(x-B.x,y-B.y); if(da<60&&da<=db) return 'A'; if(db<60) return 'B'; return null; }
     function clear(x,y){ return Math.hypot(x-p.x,y-p.y)>120&&(!g.forge||Math.hypot(x-g.forge.x,y-g.forge.y)>220); }
     function hot(e){ e.state='patrol'; e.alert=0; e.burnT=9; e.stunT=9; e.frozenT=9; e.chillT=0; e.corrT=0; e.burnDps=0; e.panicT=0; e.downed=false; e.finished=false; e.gone=false; if(!(e.hp>0)) e.hp=e.maxhp=150; }
     try{
       __topClear(); __runPrep(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       g=__state(); p=g&&g.player; if(!g||g.over||!p||!g.ents||!g.vseg||!isFinite(p.face)) return 'SKIP: no live raid';
       g.paused=false; g.mapFirst=0; g.mapOpen=false; g.bagOpen=false; g.arcs=[]; p.downed=false;
       E0=g.ents; CFG.sharedSight=0;
       // A: in plain sight ahead of him; B: behind a wall, at a range the screen shows
       for(i=0;i<9&&!A;i++){ ang=p.face+(i-4)*0.12; for(d=150;d<=210&&!A;d+=30){ x=p.x+Math.cos(ang)*d; y=p.y+Math.sin(ang)*d; if(clear(x,y)&&losClear(p.x,p.y,x,y,g.vseg)&&losClear(x,y,p.x,p.y,g.vseg)&&canSee(p.x,p.y,p.face,x,y,g.vseg)) A=mkSentry(x,y); } }
       if(!A) return 'SKIP: staging: no open spot 150 to 210 ahead of him on this map';
       for(i=0;i<32&&!B;i++){ ang=i*Math.PI/16; for(d=160;d<=340&&!B;d+=30){ x=p.x+Math.cos(ang)*d; y=p.y+Math.sin(ang)*d; if(clear(x,y)&&Math.hypot(x-A.x,y-A.y)>150&&!losClear(p.x,p.y,x,y,g.vseg)&&!canSee(p.x,p.y,p.face,x,y,g.vseg)) B=mkSentry(x,y); } }
       if(!B) return 'SKIP: staging: no spot behind a wall 160 to 340 from him on this map';
       hot(A); hot(B); g.ents=[A,B];
       elemFlame=function(x,y){ var k=who(x,y); if(k) fl[k]++; return kF.apply(this,arguments); };
       gfxEmit=function(x,y){ var k=who(x,y); if(k) em[k]++; return kE.apply(this,arguments); };
       drawElemFx=function(){ var r=kD.apply(this,arguments); nD.push(r); return r; };
       wrapped=true;
       __frame(0.016);
       if(!nD.length) return 'staging: one raid frame never reached the element effects';
       if(!A.seen) return 'staging: the machine in plain sight '+Math.round(Math.hypot(A.x-p.x,A.y-p.y))+' ahead of him is not seen this frame';
       if(B.seen) return 'staging: the machine behind a wall is seen this frame, so it proves nothing';
       if(fl.A<8||em.A<3) bad.push('control: the burning, shocked and frozen machine in plain sight drew '+fl.A+' flames and '+em.A+' glow sources (8 and 3 expected)');
       if(fl.B||em.B) bad.push('the burning, shocked and frozen machine behind a wall drew '+fl.B+' flames and '+em.B+' glow sources through the wall and fog');
       if(nD[0]!==3) bad.push('the element effects counted '+nD[0]+' effects this frame, not the 3 on the machine in sight');
     }catch(x){ bad.push('threw: '+(x&&x.message||x)); }
     finally{
       try{ if(wrapped){ elemFlame=kF; gfxEmit=kE; drawElemFx=kD; } }catch(_w){}
       try{ CFG.sharedSight=kSS; }catch(_c){}
       try{ gb=__state(); if(gb){ if(E0) gb.ents=E0; gb.arcs=[]; if(!gb.over){ gb.player.iv=0; __endRaid('abandon'); } } }catch(_e){}
       __topClear();
     }
     return bad.length?bad.join('; '):null; }},
  {v:'34.86',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
