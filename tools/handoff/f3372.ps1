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

if ($s.Contains("  {v:'33.72',what:")) { throw "check 33.72 is in the fixture already" }

SubRx @'
  {v:'33.71',what:
'@ @'
  {v:'33.72',what:'cw-cx-pixpose: the pixel torso bobs by one art pixel at the existing phases, and the actual drawn muzzle stays within one world unit of the vector muzzle for every gun at all 32 standing aim steps',
   run:function(){
     if(typeof pxBob!=='function') return 'no one pixel pose bob';
     var bad=[], oldPix=CFG.xfPix, g, oldGun=pxGun, oldBlit=pxBlit, shot=null, rec=[], spr=null, mode='', st, id, step, ang, base, phases=[0,Math.PI/6,Math.PI/2,Math.PI,Math.PI*1.5,Math.PI*2], i, moving, target, saved=false, oldW, keepTime;
     try{
       __runPrep(); __topClear(); __resetCfg(); __pinDefaults(0); __cleanProfile(); CFG.xfPix=1;
       __deploy({kit:['gun_rifle'],safe:null,mapIx:0,seed:4242}); keys={}; mouse.down=false; g=__state();
       if(!g||!g.player||g.over) return 'SKIP: no raid';
       oldW=g.player.wep; keepTime=g.t;
       st={hero:1,own:g.player,team:'ally',moving:false,sprint:false,ads:false,hurt:0,bulk:0,rl:0};
       wc.save(); saved=true; wc.setTransform(1,0,0,1,0,0);
       // Warm both body layers, then record their actual world placements through the normal drawOp route.
       for(i=0;i<24;i++){ pixFrame(); drawOp(600,500,0,0,'#242832',0,0,'none',0,st); }
       pxBlit=function(s,x,y,m){ rec.push({s:s,x:x,y:y}); if(s===spr) shot={x:x+s.mx,y:y+s.my}; return oldBlit.apply(this,arguments); };
       for(moving=0;moving<=1;moving++){
         st.moving=!!moving;
         for(i=0;i<16;i++){ pixFrame(); drawOp(600,500,0,0,'#242832',0,0,'none',0,st); }
         for(i=0;i<phases.length;i++){
           target=Math.round(moving?Math.abs(Math.sin(phases[i])):(Math.sin(phases[i]*0.35)+1)*0.5);
           if(pxBob(phases[i],!!moving)!==target) bad.push('bob phase '+i+' changed its timing');
           rec=[]; pixFrame(); drawOp(600,500,0,phases[i],'#242832',0,0,'none',0,st);
           if(rec.length!==2) bad.push('body did not use its two pixel layers');
           else {
             if(rec[0].y!==500) bad.push('the foot layer moved away from the entity point');
             if(rec[1].y!==500-target) bad.push('the drawn torso bob was '+(500-rec[1].y)+', wanted '+target);
           }
         }
       }
       st.moving=false;
       // Use the real rotated gun painter; stub only the cache lookup so all 32 exact poses are available in this one check.
       pxGun=function(){ return spr; };
       g.player.x=600; g.player.y=500;
       for(id in GUNDEF){
         g.player.wep={id:id,q:'common'};
         for(step=0;step<32;step++){
           ang=step*Math.PI/16;
           spr=pxBuildGun(id,0,'','',step,Math.cos(ang)<0?-1:1,PXB_RAMP.scav.coat[1],PIXRAMPS.skins.fair[1],GUNDEF[id].pist?2:0,0);
           shot=null;
           for(i=0;i<12&&!shot;i++){ pixFrame(); drawOp(600,500,ang,0,'#242832',0,0,'',0,st); }
           base=gunMuzzleAt(g.player,g.player.wep,ang);
           if(!shot) bad.push(id+' step '+step+' drew no pixel gun');
           else if(!base||Math.hypot(shot.x-base.x,shot.y-base.y)>1.001) bad.push(id+' step '+step+' drawn muzzle is '+(base?Math.hypot(shot.x-base.x,shot.y-base.y).toFixed(3):'missing')+' away');
         }
       }
       return bad.length?bad.slice(0,12).join('; '):null;
     } finally {
       pxGun=oldGun; pxBlit=oldBlit;
       if(saved) wc.restore();
       if(g&&g.player){ g.player.wep=oldW; g.t=keepTime; }
       try{ if(__state()&&!__state().over) __endRaid('abandon'); }catch(_e){}
       keys={}; __resetCfg(); __topClear(); __cleanProfile(); CFG.xfPix=oldPix;
     } }},
  {v:'33.71',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
