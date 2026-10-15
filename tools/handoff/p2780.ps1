$ErrorActionPreference = 'Stop'
trap { Write-Output "FAILED: $_"; exit 1 }
$p = 'C:\claudecode\dark raiders\dark_raiders.html'
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

# THE BLOOM RESETS WITH A SNAP (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
var BLM_UNITS=1.3;
'@ @'
var BLM_UNITS=1.3;
// v27.xx (feel2b), HIS YES (2026-10-14), the pacing half of the Reach bloom: THE RING SNAPS TIGHT THE MOMENT THE BLOOM IS FULLY CLOSED. A Reach player learns the cadence from the
// reticle; here the ring on the cursor does it: when the bloom a round (or a held burst) opened has fully closed again (the gun is back to its pinpoint round and the ring has
// settled) the ring flares white and a thin ring contracts onto it with four ticks for BLM_RST seconds, and a quiet click plays, once per reset. It only happens after a bloom of a
// quarter or more has been closed, so a lone round in a quiet moment says nothing, and with REDUCED FLASHING the contracting ring is left out (the ticks and the click stay).
var BLM_RST=0.30;
function bloomResetTick(p){
  if(!G||G.sim||!p) return false;
  try{ if(typeof foley==='function'&&(p.bloomPk||0)>=0.45) foley('boltLatch',null,null,{g:0.4,rate:1.6,dur:0.05,vary:0.03,gap:0.1,local:1}); }catch(_br){}
  p.bloomPk=0;
  return true;
}
'@

SubRx @'
  if(p.bloomPend>0){ p.bloomK=Math.min(1,(p.bloomK||0)+p.bloomPend); p.bloomPend=0; p.bloomQ=0; }   // the rounds since the last step open the bloom
'@ @'
  if(p.bloomPend>0){ p.bloomK=Math.min(1,(p.bloomK||0)+p.bloomPend); p.bloomPend=0; p.bloomQ=0; if(p.bloomK>=0.25) p.bloomArm=1; if(p.bloomK>(p.bloomPk||0)) p.bloomPk=p.bloomK; }   // the rounds since the last step open the bloom (and arm the reset flash)
'@

SubRx @'
  p.bloom=b0+(tgt-b0)*Math.min(1,dt*((tgt>b0)?8:4));
  return p.bloom;
'@ @'
  p.bloom=b0+(tgt-b0)*Math.min(1,dt*((tgt>b0)?8:4));
  if(p.rstT>0) p.rstT=Math.max(0,p.rstT-dt);
  if(p.bloomArm&&(p.bloomK||0)<=0&&Math.abs(p.bloom-base)<0.25){ p.bloomArm=0; p.rstT=BLM_RST; p.rstN=(p.rstN||0)+1; bloomResetTick(p); }   // v27.xx (feel2b): fully closed
  return p.bloom;
'@

SubRx @'
      var _ma=Math.min(1,(_loud?(0.48+0.42*(1-_mf)):(0.22+0.55*(1-_mf)))+_kick*0.4+_lowPulse);
'@ @'
      var _rf=(p.rstT>0)?clamp(p.rstT/BLM_RST,0,1):0;   // v27.xx (feel2b): the ring snaps tight when the bloom is fully closed
      var _ma=Math.min(1,(_loud?(0.48+0.42*(1-_mf)):(0.22+0.55*(1-_mf)))+_kick*0.4+_lowPulse+_rf*0.45);
'@

SubRx @'
        ctx.beginPath(); ctx.arc(rx0,ry0,_mr,-1.5708,-1.5708+6.2832*_mf); ctx.stroke();
      }
      ctx.lineCap='butt';

'@ @'
        ctx.beginPath(); ctx.arc(rx0,ry0,_mr,-1.5708,-1.5708+6.2832*_mf); ctx.stroke();
      }
      if(_rf>0){   // v27.xx (feel2b): fully closed: a thin ring contracts onto the magazine ring and four ticks click into place, white, over BLM_RST seconds
        ctx.lineCap='butt';
        if(CFG.flashRed!==1){
          ctx.strokeStyle='rgba(255,255,255,'+(0.8*_rf).toFixed(3)+')'; ctx.lineWidth=(1.4+1.2*_rf)*_wz;
          ctx.beginPath(); ctx.arc(rx0,ry0,_mr+(2+9*_rf)*_wz,0,6.2832); ctx.stroke();
        }
        ctx.strokeStyle='rgba(255,255,255,'+(0.95*_rf).toFixed(3)+')'; ctx.lineWidth=2.2*_wz;
        for(var _ri=0;_ri<4;_ri++){
          var _rca=Math.cos(_ri*1.5708), _rsa=Math.sin(_ri*1.5708);
          ctx.beginPath(); ctx.moveTo(rx0+_rca*(_mr+1*_wz),ry0+_rsa*(_mr+1*_wz)); ctx.lineTo(rx0+_rca*(_mr-(3+4*_rf)*_wz),ry0+_rsa*(_mr-(3+4*_rf)*_wz)); ctx.stroke();
        }
      }
      ctx.lineCap='butt';

'@

SubRx @'
var VER='27.79';
'@ @'
var VER='27.80';
'@

$pat = "(?m)^  now:'v27\.79:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v27.80: The ring on the cursor snaps tight with a pulse and a quiet click the moment a gun bloom has fully closed, so you can hear and see when to fire. Check 27.80 fails on v27.79',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
