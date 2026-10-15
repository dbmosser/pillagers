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

# THE COMBO RING IS BOLD AND ALIVE (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
  if(s&&s.n>=2&&t>=s.t&&t-s.t<ARCADE_STREAK_GAP){
    f=1-(t-s.t)/ARCADE_STREAK_GAP; mx=arcadeStreakX(s.n);
    col=(mx>=4)?'255,96,58':((mx>=3)?'255,150,60':'255,192,74');
    c.lineCap='round'; c.lineWidth=3.2*z;
    c.strokeStyle='rgba('+col+',.2)'; c.beginPath(); c.arc(rx,ry,r,0,6.2832); c.stroke();
    c.strokeStyle='rgba('+col+',.95)'; c.beginPath(); c.arc(rx,ry,r,-1.5708,-1.5708+6.2832*f); c.stroke();
    c.font=hudFS(TYPE.micro); c.textAlign='left'; c.fillStyle='rgba('+col+',1)';
    hudText('x'+mx,Math.round(rx+r+((typeof ARCADE==='object'&&ARCADE&&G.arcade&&!ARCADE.solo&&ARCADE.team&&Date.now()-ARCADE.team.at<TEAM.win*1000)?18:7)*z),Math.round(ry+4*z));   // v26.xx (party7): clear of the TEAM ring
  }
'@ @'
  if(s&&s.n>=2&&t>=s.t&&t-s.t<ARCADE_STREAK_GAP){
    f=1-(t-s.t)/ARCADE_STREAK_GAP; mx=arcadeStreakX(s.n);
    // v28.21 (partyp3): the ring is bold, it carries its multiplier on a plate, it pulses when the chain grows and hurries when it is about to run out
    var gp=Math.max(0,1-(t-s.t)/STYR.pulse), lo=(f<STYR.low), fl=lo?(0.6+0.4*Math.sin(t*STYR.hz)):1, hot=lo?Math.min(1,(STYR.low-f)/STYR.low):0, cb, cs, tm, bx, bh, bw, bs, tn, big=(mx>=4);
    cb=(mx>=4)?[255,96,58]:((mx>=3)?[255,150,60]:[255,192,74]);
    cs='255,'+Math.round(cb[1]+(70-cb[1])*hot)+','+Math.round(cb[2]+(56-cb[2])*hot);
    c.lineCap='round';
    c.lineWidth=(STYR.w+3.6)*z; c.strokeStyle='rgba(6,8,10,.5)'; c.beginPath(); c.arc(rx,ry,r,0,6.2832); c.stroke();
    c.lineWidth=STYR.w*z; c.strokeStyle='rgba('+cs+',.26)'; c.beginPath(); c.arc(rx,ry,r,0,6.2832); c.stroke();
    if(gp>0){
      c.globalCompositeOperation='lighter'; c.lineWidth=(2+5*gp)*z; c.strokeStyle='rgba(255,240,200,'+(0.85*gp).toFixed(3)+')';
      c.beginPath(); c.arc(rx,ry,r+(1-gp)*STYR.flash*z,0,6.2832); c.stroke(); c.globalCompositeOperation='source-over';
    }
    c.globalCompositeOperation='lighter'; c.lineWidth=(STYR.w+5)*z; c.strokeStyle='rgba('+cs+','+(0.2*fl).toFixed(3)+')';
    c.beginPath(); c.arc(rx,ry,r,-1.5708,-1.5708+6.2832*f); c.stroke(); c.globalCompositeOperation='source-over';
    c.font=hudFS(big?TYPE.huge:TYPE.title); c.textAlign='left'; c.textBaseline='alphabetic';
    tn='x'+mx; bh=Math.round((big?42:34)*z); bw=Math.round(c.measureText(tn).width+20*z);
    tm=(typeof ARCADE==='object'&&ARCADE&&G.arcade&&!ARCADE.solo&&ARCADE.team&&Date.now()-ARCADE.team.at<TEAM.win*1000);
    bx=Math.round(rx+r+(tm?30:14)*z); bs=1+STYR.bump*gp+(lo?0.07*Math.sin(t*STYR.hz):0);
    c.save(); c.translate(bx+bw/2,ry); c.scale(bs,bs); c.translate(-(bx+bw/2),-ry);
    hudPlate(bx,Math.round(ry-bh/2),bw,bh,'rgb('+cs+')','rgba(8,10,13,.86)');
    c.fillStyle='rgb('+cs+')'; hudText(tn,bx+Math.round(11*z),Math.round(ry+(big?14:9.5)*z));
    c.restore();
    c.lineWidth=STYR.w*z; c.strokeStyle='rgba('+cs+','+(0.98*fl).toFixed(3)+')'; c.beginPath(); c.arc(rx,ry,r,-1.5708,-1.5708+6.2832*f); c.stroke();
  }
'@

SubRx @'
// the ring at the cursor (the medals are the row at the left edge now, styMedalDraw)
function styleDraw(c,p,rx,ry){
'@ @'
// v28.21 (partyp3), HIS WORDS on the combo ring (2026-10-14, the party playtest): "i didn't notice it at all, so not sure". It must be noticeable without clutter.
// The ring is bolder (STYR.w, a dark underlay behind it so it reads on a bright floor and a glow on its sweep), its multiplier is a number on a plate of its
// own (twice the old print; the x4 and x5 bigger again) beside it, and it MOVES: when the chain grows the ring flashes outward and the number pops (STYR.pulse,
// 0.4 s), and in the last 30 percent of the chain (STYR.low) the sweep shifts toward red and flickers (STYR.hz) while the number shivers, so he sees it is about to
// run out. The sweep is still the last arc drawn at the cursor. Cosmetic only.
var STYR={w:5.2,low:0.3,hz:18,pulse:0.4,flash:14,bump:0.32};
// the ring at the cursor (the medals are the row at the left edge now, styMedalDraw)
function styleDraw(c,p,rx,ry){
'@

SubRx @'
var VER='28.20';
'@ @'
var VER='28.21';
'@

$pat = "(?m)^  now:'v28\.20:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v28.21: The combo ring is bold with a big multiplier, flashes when the chain grows and flickers red when it is about to run out. Check 28.21 fails on v28.20',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
