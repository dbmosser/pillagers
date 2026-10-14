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

if ($s.Contains("  {v:'26.58',what:")) { throw "check 26.58 is in the fixture already" }

SubRx @'
  {v:'26.57',what:
'@ @'
  {v:'26.58',what:'his yes (suggestion 20), attack telegraphs: a Sentry or Warden winding up a shot has an aim lane on the ground that fills over the windup and stops at the first wall, it is drawn in the world, and a Howler shell fills its landing circle',
   run:function(){
     if(!(window.__deploy&&window.__state&&window.__endRaid)||typeof render2D!=='function'||typeof mkSentry!=='function'||typeof wc==='undefined') return 'SKIP: no raid here';
     var bad=[], g=null, p=null, s=null, L, i, k, a, sx, sy, wl, ws, OWN=Object.prototype.hasOwnProperty, hS, hF, oS, oF, nLane=0, nRing=0, a0, r0, sh=null, shells0, dx, dy;
     function spyOn(){
       hS=OWN.call(wc,'stroke'); oS=wc.stroke; hF=OWN.call(wc,'fill'); oF=wc.fill;
       wc.stroke=function(){ if(/255,\s*36,\s*28/.test(String(this.strokeStyle))) nLane++; return oS.apply(this,arguments); };
       wc.fill=function(){ if(/255,\s*70,\s*40/.test(String(this.fillStyle))) nRing++; return oF.apply(this,arguments); };
     }
     function spyOff(){ if(oS){ if(hS) wc.stroke=oS; else delete wc.stroke; } if(oF){ if(hF) wc.fill=oF; else delete wc.fill; } oS=null; oF=null; }
     try{
       if(typeof telegraphLane!=='function') return 'there is no telegraph lane for a machine in its windup';
       __topClear(); __runPrep(); __resetCfg(); __pinDefaults(0); __cleanProfile(); __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       g=__state(); if(!g||g.over) return 'SKIP: no live raid';
       p=g.player; p.iv=99; p.downed=false;
       for(k=0;k<24&&!s;k++){
         a=k/24*6.2832; sx=p.x+Math.cos(a)*90; sy=p.y+Math.sin(a)*90;
         if(losClear(p.x,p.y,sx,sy,G.vseg)) s=mkSentry(sx,sy);
       }
       if(!s) return 'SKIP: no open ground beside the player';
       s.elite=0; s.state='chase'; s.cd=9; s.face=Math.atan2(p.y-s.y,p.x-s.x); s.windup=0.2; g.ents.push(s);
       p.face=Math.atan2(s.y-p.y,s.x-p.x);
       L=telegraphLane(s);
       if(!L) bad.push('a Sentry in its windup has no lane');
       else {
         if(Math.abs(L.f-0.5)>0.02) bad.push('half way through a 0.4 windup the lane is '+L.f.toFixed(2)+' full');
         dx=L.x2-L.x1; dy=L.y2-L.y1;
         if((dx*Math.cos(s.face)+dy*Math.sin(s.face))<=0) bad.push('the lane does not run the way the Sentry faces');
         if(L.len>s.rng*1.15+1) bad.push('the lane is longer than the reach of the shot');
       }
       s.windup=0.35; L=telegraphLane(s); if(!L||Math.abs(L.f-0.125)>0.02) bad.push('a Sentry at windup 0.35 of 0.4 reads '+(L?L.f.toFixed(2):'none')+' full, not about 0.13');
       s.windup=null; if(telegraphLane(s)) bad.push('a Sentry that is not winding up has a lane');
       s.windup=0.35; ws={kind:'warden',hp:500,x:s.x,y:s.y,r:30,rng:620,face:s.face,windup:0.35};
       L=telegraphLane(ws); if(!L||Math.abs(L.f-0.5)>0.02) bad.push('a Warden at windup 0.35 of 0.7 reads '+(L?L.f.toFixed(2):'none')+' full');
       ws.kind='crawler'; if(telegraphLane(ws)) bad.push('a crawler has a lane');
       ws.kind='sentry'; ws.hp=0; if(telegraphLane(ws)) bad.push('a dead machine has a lane');
       wl=null; k=g.map.walls||[];
       for(i=0;i<k.length&&!wl;i++){ if(k[i]&&!k[i].win&&!k[i].ledge&&k[i].w>=60&&k[i].h>=60&&k[i].x>150) wl=k[i]; }
       if(wl){
         ws={kind:'sentry',hp:50,x:wl.x-70,y:wl.y+wl.h/2,r:22,rng:340,face:0,windup:0.2};
         L=telegraphLane(ws);
         if(!L||L.len>110) bad.push('a lane that meets a wall runs on for '+(L?Math.round(L.len):'none')+' units instead of stopping at it');
       }
       s.windup=0.2;
       spyOn(); try{ render2D(0.016); } finally { spyOff(); }
       if(nLane<1) bad.push('a Sentry in its windup, in view, draws no aim lane in the world');
       a0=nLane; s.windup=null;
       spyOn(); try{ render2D(0.016); } finally { spyOff(); }
       if(nLane>a0) bad.push('a Sentry that is not winding up still draws an aim lane');
       r0=nRing; shells0=g.shells.length;
       sh={mortar:1,fx:1,x0:s.x,y0:s.y,tx:p.x+30,ty:p.y,t:1,air:2.1,dmg:0}; g.shells.push(sh);
       spyOn(); try{ render2D(0.016); } finally { spyOff(); }
       if(nRing<=r0) bad.push('a Howler shell in the air does not fill its landing circle');
     }catch(x){ bad.push('threw: '+(x&&x.message||x)); }
     finally{
       try{ spyOff(); }catch(_e0){}
       try{ if(g){ var j2=g.shells.indexOf(sh); if(j2>=0) g.shells.splice(j2,1); var j3=g.ents.indexOf(s); if(j3>=0) g.ents.splice(j3,1); } }catch(_e1){}
       try{ var g2=__state(); if(g2&&!g2.over){ g2.player.iv=0; __endRaid('abandon'); } }catch(_e3){}
       __topClear();
     }
     return bad.length?bad.join('; '):null; }},
  {v:'26.57',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
