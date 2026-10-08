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

# BLOTTER COMES ON GRADUALLY (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
var BUZZRND=[0.37,0.71,0.13,0.59,0.83,0.29,0.47,0.91];   // v10.31: eight numbers rolled fresh with every Blotter dose
'@ @'
var BUZZRND=[0.37,0.71,0.13,0.59,0.83,0.29,0.47,0.91];   // v10.31: eight numbers rolled fresh with every Blotter dose
// v18.93, his report (2026-10-07): "blotter visual effects should happen more gradually, they hit all at once". Every
// Blotter dose still rolls fresh numbers, but a second dose no longer swaps the whole melt in one frame. The roll that
// was on screen is kept in BUZZRNDP and buzzWarp fades it out while the new roll fades in, over BUZZRNDFADE seconds of
// the trip clock from BUZZRNDAT. BUZZRNDTO is the roll that fade is heading for, so anything that writes BUZZRND
// directly (a check) simply gets its roll at once, with no fade.
var BUZZRNDP=null, BUZZRNDTO=null, BUZZRNDAT=0, BUZZRNDFADE=8;
'@

SubRx @'
function buzzWarp(c2,cnv,t,dr,ac){
'@ @'
function buzzWarp(c2,cnv,t,dr,ac,k){
  // v18.93, his report (2026-10-07): k is the one Blotter onset, 0 to 1, worked out once in drawBuzzFx from the world's
  // strength and handed to both layers, so the HUD comes up with the world instead of ahead of it. Each Blotter pass
  // below is multiplied by it once. At k=1 (one dose at its peak, and anything stronger) nothing here changes, and the
  // Liquor passes never read it.
  if(k===undefined) k=1;
'@

SubRx @'
  if(ac>0){
    // the whole world through a spinning hue, harder and faster per tab
    c2.globalAlpha=Math.min(0.28+0.055*ac,0.85);
'@ @'
  if(ac>0&&k>0){
    // the whole world through a spinning hue, harder and faster per tab
    // v18.93, his report (2026-10-07): the tinted copy rises from nothing with k instead of starting at 28 percent.
    c2.globalAlpha=Math.min(0.28+0.055*ac,0.85)*k;
'@

SubRx @'
        c2.globalAlpha=Math.min(0.05+0.018*ac,0.2);
'@ @'
        c2.globalAlpha=Math.min(0.05+0.018*ac,0.2)*Math.min(1,(ac-2)/0.1);   // v18.93, his report (2026-10-07): the fringe fades in over the first tenth past 2 instead of switching on at 9 percent in one frame; every peak that fringes (world 2.98 and up, HUD 2.13 and up) is past 2.1
'@

SubRx @'
    var brA=1+Math.sin(t*(0.7+0.08*ac))*0.006*Math.min(ac,10);
    c2.globalAlpha=0.5;
'@ @'
    var brA=1+Math.sin(t*(0.7+0.08*ac))*0.006*Math.min(ac,10);
    c2.globalAlpha=0.5*k;   // v18.93, his report (2026-10-07): the half-strength breathing copy comes up with k, not at 0.5 at once
'@

SubRx @'
      c2.drawImage(cnv,vx*vb,0,vb,RH,vx*vb,Math.sin(t*1.1+vx*0.9)*(2.5+2.0*ac),vb,RH);
'@ @'
      c2.drawImage(cnv,vx*vb,0,vb,RH,vx*vb,Math.sin(t*1.1+vx*0.9)*(2.5+2.0*ac)*k,vb,RH);   // v18.93, his report (2026-10-07): the strips start straight and bend with k, not 2.5 px at once
'@

SubRx @'
    var R=(BUZZRND&&BUZZRND.length>=8)?BUZZRND:[0.5,0.5,0.5,0.5,0.5,0.5,0.5,0.5];
    var pour=0.5+0.5*Math.sin(t*(0.23+0.3*R[0])+R[1]*6.2832)*Math.sin(t*(0.11+0.2*R[2])+R[3]*6.2832);
    var cols=5+((R[4]*5)|0), cw=Math.ceil(RW/cols);
    for(var mc=0;mc<cols;mc++){
      var ph=R[(mc+5)%8]*6.2832, sp=0.6+R[(mc+2)%8]*1.4;
      var stretch=1+pour*(0.02+0.012*ac)*(0.4+Math.abs(Math.sin(t*sp+ph)));
      var sway=Math.sin(t*(0.9+0.5*R[(mc+3)%8])+ph)*(3+2.5*ac)*pour;
      c2.globalAlpha=0.55+0.3*pour;
      c2.drawImage(cnv,mc*cw,0,cw,RH,mc*cw+sway,-RH*(stretch-1)*R[(mc+1)%8],cw,RH*stretch);
    }
'@ @'
    var R=(BUZZRND&&BUZZRND.length>=8)?BUZZRND:[0.5,0.5,0.5,0.5,0.5,0.5,0.5,0.5];
    // v18.93, his report (2026-10-07): the columns slide and lift by k, so the melt starts still and pours as the trip comes
    // up. And a new dose no longer swaps the whole pattern in one frame: for BUZZRNDFADE s of the trip clock after a roll,
    // the previous roll is drawn first, fading out, then the new one over it, fading in. Each share is drawn at
    // 1-(1-a)^w, so the two together cover as much as one full pass. Outside that window this is the single pass it
    // always was, with the same arithmetic in the same order.
    var R0=BUZZRNDP, mw=1;
    if(R0&&R0.length>=8&&R0!==R&&BUZZRNDTO===BUZZRND){ mw=(BUZZT-BUZZRNDAT)/BUZZRNDFADE; mw=(mw>=0&&mw<1)?mw*mw*(3-2*mw):1; }
    for(var mp=(mw<1?0:1);mp<2;mp++){
      var RR=mp?R:R0, mA=mp?mw:1-mw;
      var pour=0.5+0.5*Math.sin(t*(0.23+0.3*RR[0])+RR[1]*6.2832)*Math.sin(t*(0.11+0.2*RR[2])+RR[3]*6.2832);
      var cols=5+((RR[4]*5)|0), cw=Math.ceil(RW/cols);
      for(var mc=0;mc<cols;mc++){
        var ph=RR[(mc+5)%8]*6.2832, sp=0.6+RR[(mc+2)%8]*1.4;
        var stretch=1+pour*(0.02+0.012*ac)*(0.4+Math.abs(Math.sin(t*sp+ph)))*k;
        var sway=Math.sin(t*(0.9+0.5*RR[(mc+3)%8])+ph)*(3+2.5*ac)*pour*k;
        c2.globalAlpha=(mA>=1)?0.55+0.3*pour:1-Math.pow(0.45-0.3*pour,mA);
        c2.drawImage(cnv,mc*cw,0,cw,RH,mc*cw+sway,-RH*(stretch-1)*RR[(mc+1)%8],cw,RH*stretch);
      }
    }
'@

SubRx @'
        c2.drawImage(cnv,0,sy,RW,sh,Math.sin(t*11.3+sl*2.7)*(18+8*ac),sy,RW,sh);
'@ @'
        c2.drawImage(cnv,0,sy,RW,sh,Math.sin(t*11.3+sl*2.7)*(18+8*ac)*k,sy,RW,sh);   // v18.93, his report (2026-10-07): the tears widen with k instead of starting 18 px wide
'@

SubRx @'
        c2.globalAlpha=0.55; c2.filter='invert(1) hue-rotate('+Math.round((t*90)%360)+'deg)';
'@ @'
        c2.globalAlpha=0.55*Math.min(1,(ac-3)/0.1); c2.filter='invert(1) hue-rotate('+Math.round((t*90)%360)+'deg)';   // v18.93, his report (2026-10-07): the inside-out flash fades in over the first tenth past 3 (three peaked doses are 3.77) instead of arriving at 55 percent
'@

SubRx @'
if(!tr) tr='skewX('+(Math.sin(t*0.8)*ac*0.35).toFixed(2)+'deg)';
'@ @'
/* v18.93, his report (2026-10-07): under Liquor the panel lean used to vanish in one frame as a glass took hold and return in one frame as it wore off; it now hands over across dr 0.05 to 0.6 */ var _sk=(dr>0.05)?Math.max(0,1-(dr-0.05)/0.55):1; if(_sk>0) tr+=(tr?' ':'')+'skewX('+(Math.sin(t*0.8)*ac*0.35*_sk).toFixed(2)+'deg)';
'@

SubRx @'
  buzzMenuFx(dr,ac);   // v16.39, his note: Liquor and Blotter reach the menu screens too
  if(dr<0.05&&ac<0.05) return;
'@ @'
  // v18.93, his report (2026-10-07): "blotter visual effects should happen more gradually, they hit all at once". They did.
  // Nothing was drawn until the strength reached 0.05, about 8 s into a dose, and then every pass came on in one frame at
  // most of its full size, because each had a fixed floor: a 28 percent tinted copy, 2.5 px of drift, the melt sliding
  // 3 px, 18 px tears, trails and three colour washes at 10 percent, on the HUD as much as on the world. With Liquor in him
  // it was the frame after he drank. k is now the one onset that scales all of them: 0 at strength 0.01 (about 3 s in),
  // half at about 0.35 (half a minute), exactly 1 from 0.9 up. One dose peaks at 0.96, so from there up, and for two or
  // more doses, every pass is what it was, and one hit is still half of two. It runs the same way down, so a trip fades
  // out instead of cutting off 8 s before the dose ends. The menu panels take the same k so they stay in step.
  var _kx=(ac-0.01)/0.89; _kx=(_kx>0)?Math.min(1,_kx):0;
  var k=_kx*(1.5-0.5*_kx*_kx);
  buzzMenuFx(dr,ac*k);   // v16.39, his note: Liquor and Blotter reach the menu screens too
  if(dr<0.05&&ac<0.01) return;
'@

SubRx @'
    wc.globalAlpha=Math.min(0.10+0.05*ac,0.6);
'@ @'
    wc.globalAlpha=Math.min(0.10+0.05*ac,0.6)*k;   // v18.93, his report (2026-10-07): the trails grow with k instead of starting at 10 percent, so the stale buffer a new trip starts from is drawn at about 0
'@

SubRx @'
  buzzWarp(wc,wcv,t,dr,ac);
  buzzWarp(ctx,ocv,t*1.13+0.7,dr*0.5,ac*0.4);
'@ @'
  buzzWarp(wc,wcv,t,dr,ac,k);
  buzzWarp(ctx,ocv,t*1.13+0.7,dr*0.5,ac*0.4,k);   // v18.93, his report (2026-10-07): the HUD takes the world's k, so it no longer gets its full floors on the first frame
'@

SubRx @'
  if(ac>0){
    ctx.globalCompositeOperation='overlay';
'@ @'
  if(ac>0&&k>0){
    ctx.globalCompositeOperation='overlay';
'@

SubRx @'
      g2.addColorStop(0,'hsla('+hue+',100%,60%,'+Math.min(0.10+0.028*ac,0.42).toFixed(2)+')');
'@ @'
      // v18.93, his report (2026-10-07): the washes rise with k, and each extra patch a stronger trip adds fades in over a
      // quarter step of strength instead of appearing whole. Every dose count's peak sits at least 0.39 past a whole
      // number, or at the cap of seven patches, so at full strength the strings are what they were.
      g2.addColorStop(0,'hsla('+hue+',100%,60%,'+(Math.min(0.10+0.028*ac,0.42)*k*Math.min(1,(nb-tb)/0.25)).toFixed(2)+')');
'@

SubRx @'
      if(B2.tag==='lsd'){ BUZZRND=[]; for(var _br=0;_br<8;_br++) BUZZRND.push(Math.random()); }
'@ @'
      // v18.93, his report (2026-10-07): still a fresh roll with every dose (v10.31), but the roll on screen is kept as the
      // one to fade out of, and buzzWarp crossfades the melt over BUZZRNDFADE s. If an earlier fade is still mostly on its
      // old roll, that old roll stays the one fading out, so doses bought in quick succession do not snap it either.
      if(B2.tag==='lsd'){ var _bw=(BUZZRNDP&&BUZZRNDTO===BUZZRND)?(BUZZT-BUZZRNDAT)/BUZZRNDFADE:1; if(!(_bw>=0&&_bw<0.5)) BUZZRNDP=BUZZRND; BUZZRNDAT=BUZZT; BUZZRND=[]; for(var _br=0;_br<8;_br++) BUZZRND.push(Math.random()); BUZZRNDTO=BUZZRND; }
'@

SubRx @'
var VER='18.92';
'@ @'
var VER='18.93';
'@

$pat = "(?m)^  now:'v18\.92:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v18.93: Blotter effects come on smoothly over the first minute of a dose instead of all at once. Check 18.93 fails on v18.92',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
