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

if ($s.Contains("  {v:'33.90',what:")) { throw "check 33.90 is in the fixture already" }

SubRx @'
  {v:'33.89',what:
'@ @'
  {v:'33.90',what:'cw-cx-pixfight (86g): invulnerable and see-through pillagers use cached silhouettes; a warmed real gunfight with six bots, an elite and a golden bot draws no vector pillager body',
   run:function(){
     if(!(window.__deploy&&window.__state&&window.__frame&&window.__endRaid)) return 'SKIP: no raid fixture';
     var g, cfg0=CFG.xfPix, o0=drawOp0, ob=pxBlit, od=drawOp, oSee=canSee, saved=false, faults, vectors=0, calls=0, tint=0, ghost=0, i, j, p, bots, st, before, al, cast=[0,0,0,0,0,0,0,0,0];
     try{
       __runPrep(); __topClear(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       CFG.xfPix=1;
       __deploy({kit:['gun_rifle'],safe:null,mapIx:0,seed:4242}); g=__state();
       if(!g||g.over||!g.player) return 'SKIP: no staged raid';
       P.cosOutfit='outnone'; p=g.player; p.rig=null; p.hp=100; p.iv=0.3; p.hitFlash=0; p.roll=0;
       keys={}; mouse.down=false; g.bagOpen=false; g.mapOpen=false; g.paused=false;
       faults=pixFaults();
       st={hero:1,own:p,team:'ally',moving:false,sprint:false,ads:false,hurt:0,bulk:0,rl:0};
       wc.save(); saved=true; wc.setTransform(1,0,0,1,0,0);
       for(j=0;j<24;j++){ pixFrame(); drawOp(600,500,0,0,'#242832',0,0,'',p.iv,st); }
       drawOp0=function(){ vectors++; return o0.apply(this,arguments); };
       pxBlit=function(s,x,y,m){
         if(pxTintTargets.indexOf(s)>=0) { tint++; if(Math.abs(wc.globalAlpha-0.55*0.35)<0.002) ghost++; }
         return ob.apply(this,arguments);
       };
       // v28.xx (cw-cx-pixfight): inspect the actual cached silhouette and its inherited alpha.
       var pxTintTargets=[];
       PIXSTORE.m.actors.forEach(function(s){ if(s.tn&&s.tn['#2a6a5e']) pxTintTargets.push(s.tn['#2a6a5e']); });
       if(!pxTintTargets.length) return 'invulnerable body did not cache its teal silhouette';
       al=wc.globalAlpha; wc.globalAlpha=0.55; before=PIX.bodies;
       pixFrame(); drawOp(600,500,0,0,'#242832',0,0,'',p.iv,st);
       if(PIX.bodies!==before+1||vectors) return 'wall ghost used a vector pillager body';
       if(!tint||!ghost) return 'wall ghost did not inherit 0.55 alpha on its cached teal mask';
       if(Math.abs(wc.globalAlpha-0.55)>0.002) return 'wall ghost changed the caller alpha';
       wc.globalAlpha=al; pxBlit=ob; wc.restore(); saved=false;
       // v28.xx (cw-cx-pixfight): fixture defaults may spawn fewer than eight; create the staged cast with the real factory and no identity-history writes.
       bots=[];
       for(i=0;i<8;i++) bots.push(mkRaider(p.x+(i%4-1.5)*72,p.y-95+Math.floor(i/4)*160,IDENTITIES[i%IDENTITIES.length],true));
       g.ents=bots;
       for(i=0;i<8;i++){
         var e=bots[i]; e.x=p.x+(i%4-1.5)*72; e.y=p.y-95+Math.floor(i/4)*160;
         e.hp=100; e.seen=true; e.dead=false; e.downed=false; e.state='chase'; e.roll=0; e.pinT=0; e.hitT=(i===0)?0.4:0;
         e.bulk=1+i%3; e.elite=i===6; e.affix=null; e.golden=i===7; e.outfit='outnone'; e.hostile=true; e.friendly=false; e.merc=0;
       }
       drawOp0=o0;
       // v28.xx (cw-cx-pixfight): this is an art draw, so expose the staged cast through the fixture only; render2D otherwise recomputes seen from map occlusion.
       canSee=function(){ return true; };
       for(j=0;j<80;j++) __frame(0);
       vectors=0; calls=0;
       drawOp0=function(){ if(figOn()) vectors++; return o0.apply(this,arguments); };
       drawOp=function(){
         if(figOn()){
           calls++;
           var s=arguments[9], own=s&&s.own, n=bots.indexOf(own);
           if(own===p) cast[0]++; else if(n>=0) cast[n+1]++;
         }
         return od.apply(this,arguments);
       };
       for(j=0;j<3;j++) __frame(0);
       for(i=0;i<cast.length;i++) if(cast[i]<3) return 'fight actor '+i+' drew '+cast[i]+' times in three frames (cast '+cast.join(',')+'; '+calls+' calls)';
       if(vectors) return 'staged gunfight drew '+vectors+' vector pillager bodies';
       if(pixFaults()!==faults) return 'staged gunfight logged a pixel render fault';
       return null;
     } finally {
       drawOp0=o0; drawOp=od; pxBlit=ob; canSee=oSee;
       if(saved) wc.restore();
       try{ __endRaid('abandon'); }catch(_e){}
       __topClear(); __resetCfg(); __cleanProfile(); CFG.xfPix=cfg0;
     }
   }},
  {v:'33.89',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
