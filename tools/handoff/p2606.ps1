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

# A BIGGER CROWBAR SWING (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
function meleeStrike(){
'@ @'
// v26.xx (meleebig), HIS NOTE 2026-10-13: "melee swing animation needs to be larger, more prominent". THE CROWBAR LANDS: a short pale
// flash and a puff at the struck point, two bursts of sparks and a small kick of the screen (the existing shake, 1.8, far under a gun
// shot). Drawn on the cosmetic stream (spark uses fxn), live play only, and nothing a blow reads: the damage, reach and cooldown are
// the bare hands strike as before.
function meleeImpact(sx,sy,ex,ey,er){
  if(!G||G.sim) return false;
  var a=Math.atan2(ey-sy,ex-sx), r=(+er>0)?+er:12, ix=ex-Math.cos(a)*r*0.5, iy=ey-Math.sin(a)*r*0.5;
  if(!isFinite(ix)||!isFinite(iy)) return false;
  flash(ix,iy,170,'#eef6fb',0.12);
  G.puffs.push({x:ix,y:iy,t:0,life:0.14,c:'#f4faff',r:30});
  spark(ix,iy,'#ffffff',12,320); spark(ix,iy,'#ffd89a',8,260);
  G.shake=Math.max(G.shake||0,1.8);
  return true;
}
function meleeStrike(){
'@

SubRx @'
if(!G.sim){ spark(_me.x,_me.y,'#cdd6dd',10,200); sfx('clank',_me.x,_me.y); if(G.barT>0) meleeFoley('hit',_me.x,_me.y); }
'@ @'
if(!G.sim){ spark(_me.x,_me.y,'#cdd6dd',10,200); sfx('clank',_me.x,_me.y); if(G.barT>0){ meleeFoley('hit',_me.x,_me.y); meleeImpact(sh.x,sh.y,_me.x,_me.y,_me.r); } }   // v26.xx (meleebig): and the crowbar lands with a flash, sparks and a small kick
'@

SubRx @'
  var leanX=sprint?fl*1.6:(moving?fl*.7:0);
  var ty=y-bobY+lift;
'@ @'
  var leanX=sprint?fl*1.6:(moving?fl*.7:0);
  var ty=y-bobY+lift;
  // v26.xx (meleebig): THE BODY LEANS INTO THE CROWBAR. For the 0.22 s of the swing the upper body shifts toward the aim, out and back
  // (3.4 at the most when facing across, 1 when facing up or down), the way a sprint leans it. Only the crowbar swing (mode fist with
  // G.barT running) does this; the legs stay planted and nothing a fight reads moves.
  if(mode==='fist'&&typeof G!=='undefined'&&G&&G.barT>0) leanX+=(Math.cos(face)*2.4+fl*1.0)*Math.sin(3.1416*(1-Math.max(0,Math.min(1,G.barT/0.22))));
'@

SubRx @'
      var _cbP=1-Math.max(0,Math.min(1,G.barT/0.22)), _cbT=-0.95+1.9*_cbP;
      wc.fillStyle=_HANDC; wc.fillRect(2+ext,-1.6,5,3.2);
      wc.strokeStyle='rgba(205,214,221,.38)'; wc.lineWidth=1.6; wc.beginPath(); wc.arc(6+ext,0,17,-0.95,_cbT); wc.stroke();
      wc.save(); wc.translate(6+ext,0); wc.rotate(_cbT);
'@ @'
      // v26.xx (meleebig), HIS NOTE 2026-10-13: "melee swing animation needs to be larger, more prominent". The swing now sweeps 140
      // degrees across the aim (70 each side, it was 109), quick out and a short follow-through, with the bar drawn 1.6 times as long and
      // as thick, and a bold SWOOSH: a pale crescent smear at the bar's reach, widest at the tip and ending in a point, four overlapping
      // layers that trail 0.04 to 0.15 s behind the tip so it is brightest at the tip and gone 0.15 s back, with a white leading edge.
      // Cosmetic only: no draw from the raid stream, the blow, reach and cooldown are unchanged.
      var _cbP=1-Math.max(0,Math.min(1,G.barT/0.22)), _cbA=1.2217, _cbQ=Math.min(1,_cbP/0.85), _cbT=-_cbA+2*_cbA*_cbQ*(2-_cbQ);
      var _cbF=_cbP<0.8?1:Math.max(0,(1-_cbP)/0.2), _cbR=52, _cbL, _cbU, _cbV, _cbS, _cbK, _cbW, _cbD;
      wc.fillStyle=_HANDC; wc.fillRect(2+ext,-1.6,7,3.2);
      for(_cbL=3;_cbL>=0;_cbL--){
        _cbU=Math.max(0,_cbP-0.15*(_cbL+1)/4/0.22); _cbV=Math.min(1,_cbU/0.85); _cbS=-_cbA+2*_cbA*_cbV*(2-_cbV);
        if(_cbT-_cbS<0.03||_cbF<=0) continue;
        wc.fillStyle='rgba(238,246,252,'+(0.26*_cbF).toFixed(3)+')';
        wc.beginPath(); wc.arc(6+ext,0,_cbR,_cbS,_cbT);
        for(_cbK=6;_cbK>=0;_cbK--){ _cbW=_cbK/6; _cbD=_cbR-18*Math.pow(_cbW,1.2); wc.lineTo(6+ext+Math.cos(_cbS+(_cbT-_cbS)*_cbW)*_cbD,Math.sin(_cbS+(_cbT-_cbS)*_cbW)*_cbD); }
        wc.closePath(); wc.fill();
        if(_cbL===0){ wc.strokeStyle='rgba(255,255,255,'+(0.8*_cbF).toFixed(3)+')'; wc.lineWidth=1.8; wc.beginPath(); wc.arc(6+ext,0,_cbR-0.9,_cbS,_cbT); wc.stroke(); }
      }
      wc.save(); wc.translate(6+ext,0); wc.rotate(_cbT); wc.scale(1.6,1.6);
'@

SubRx @'
var VER='26.05';
'@ @'
var VER='26.06';
'@

$pat = "(?m)^  now:'v26\.05:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v26.06: The crowbar swing is bigger and bolder: a longer bar, a wide pale swoosh, a flash and sparks where it lands, and a lean into the blow. Check 26.06 fails on v26.05',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
