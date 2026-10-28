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

# ACTIVE RELOAD STACKS (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
var AR_A=0.42, AR_B=0.60, AR_BONUS=1.15;
'@ @'
var AR_A=0.42, AR_B=0.60, AR_BONUS=1.15;
// v35.xx (cw-reloadstack), HIS ORDER (2026-10-27): "make the active reload stack but it gets harder each time". THE ACTIVE RELOAD STACKS. Each active reload in a row adds AR_STEP
// to the bonus of the next magazine (x1.15, x1.25, x1.35, x1.45, then x1.55 from AR_STK_MAX on), and each one narrows the next sweet spot around its middle by AR_NARROW (18, 13.5,
// 10.1, 7.6, then 5.7 percent of the reload). A press outside the sweet spot, or a reload left to run out on its own, starts the chain over and the spot is wide again; a swap that
// cuts a reload short keeps it. The chain lives on the player (p.arStk), so in co-op each pillager has their own; the ring, the bar and X on a pad all read arLo and arHi. Live play only.
var AR_STEP=0.10, AR_STK_MAX=5, AR_NARROW=0.75;
function arLo(p){ var k=Math.min((p&&p.arStk)||0,AR_STK_MAX-1); return (k>0)?(AR_A+AR_B)/2-(AR_B-AR_A)/2*Math.pow(AR_NARROW,k):AR_A; }
function arHi(p){ var k=Math.min((p&&p.arStk)||0,AR_STK_MAX-1); return (k>0)?(AR_A+AR_B)/2+(AR_B-AR_A)/2*Math.pow(AR_NARROW,k):AR_B; }
'@

SubRx @'
if(f<AR_A||f>AR_B){ try{ blip('arMiss'); }catch(_am){} return false; }
'@ @'
if(f<arLo(p)||f>arHi(p)){ p.arStk=0; try{ blip('arMiss'); }catch(_am){} return false; }   // v35.xx (cw-reloadstack): the spot narrows with the chain, and a miss starts it over
'@

SubRx @'
p.arBonus=1; p.arGun=p.wep;
'@ @'
p.arStk=Math.min((p.arStk||0)+1,AR_STK_MAX); p.arMul=AR_BONUS+AR_STEP*(p.arStk-1); p.arBonus=1; p.arGun=p.wep;   // v35.xx (cw-reloadstack): one more in the chain, a bigger bonus
'@

SubRx @'
p.reloading=1; tickReload(0.002);
'@ @'
p.reloading=1; p.arHot=1; tickReload(0.002);   // v35.xx (cw-reloadstack): arHot tells tickReload this reload ended on an active reload
'@

SubRx @'
label(p.x,p.y-34,'ACTIVE RELOAD','#9fe8b0',0,true);
'@ @'
label(p.x,p.y-34,(p.arStk>1)?'ACTIVE RELOAD x'+p.arStk:'ACTIVE RELOAD','#9fe8b0',0,true);   /* v35.xx (cw-reloadstack): the chain count from the second one on */
'@

SubRx @'
p.ammo+=take; p.reserve-=take*rktCost(p.wep);   // v28.xx (cw-rocket): a rocket costs 30
'@ @'
p.ammo+=take; p.reserve-=take*rktCost(p.wep);   // v28.xx (cw-rocket): a rocket costs 30
      if(!G.sim){ if(!p.arHot) p.arStk=0; p.arHot=0; }   // v35.xx (cw-reloadstack): a reload left to run out on its own (no active reload) starts the chain over
'@

SubRx @'
G.player.arBonus>0)?AR_BONUS:1)
'@ @'
G.player.arBonus>0)?(G.player.arMul||AR_BONUS):1)
'@

SubRx @'
zx=Math.round(x0+BW*AR_A), zw=Math.round(BW*(AR_B-AR_A));
'@ @'
lo=arLo(p), hi=arHi(p), zx=Math.round(x0+BW*lo), zw=Math.round(BW*(hi-lo));   // v35.xx (cw-reloadstack): the red zone narrows with the chain
'@

SubRx @'
var inz=(f>=AR_A&&f<=AR_B), miss=(f>AR_B),
'@ @'
var inz=(f>=lo&&f<=hi), miss=(f>hi),
'@

SubRx @'
ctx.strokeStyle=(_rlf>AR_B)?'rgba(255,69,56,.40)':((_rlf>=AR_A)?'rgb(255,150,138)':'rgb(232,58,44)'); ctx.lineWidth=((_rlf>=AR_A&&_rlf<=AR_B)?6.8:5.4)*_wz;
'@ @'
var _arA=arLo(p), _arB=arHi(p); /* v35.xx (cw-reloadstack): the sweet spot narrows with the chain */ ctx.strokeStyle=(_rlf>_arB)?'rgba(255,69,56,.40)':((_rlf>=_arA)?'rgb(255,150,138)':'rgb(232,58,44)'); ctx.lineWidth=((_rlf>=_arA&&_rlf<=_arB)?6.8:5.4)*_wz;
'@

SubRx @'
if(_rlf>=AR_A&&_rlf<=AR_B){ ctx.shadowColor='rgba(255,90,70,.95)'; ctx.shadowBlur=9*_wz; }
'@ @'
if(_rlf>=_arA&&_rlf<=_arB){ ctx.shadowColor='rgba(255,90,70,.95)'; ctx.shadowBlur=9*_wz; }
'@

SubRx @'
ctx.arc(rx0,ry0,_rlr,-1.5708+6.2832*AR_A,-1.5708+6.2832*AR_B);
'@ @'
ctx.arc(rx0,ry0,_rlr,-1.5708+6.2832*_arA,-1.5708+6.2832*_arB);
'@

SubRx @'
ctx.strokeStyle=(_rlf>AR_B)?'rgba(255,69,56,.45)':((_rlf>=AR_A)?'rgb(255,255,255)':'rgb(255,69,56)');
'@ @'
ctx.strokeStyle=(_rlf>_arB)?'rgba(255,69,56,.45)':((_rlf>=_arA)?'rgb(255,255,255)':'rgb(255,69,56)');
'@

SubRx @'
var _rqa=-1.5708+6.2832*(_rq?AR_B:AR_A)
'@ @'
var _rqa=-1.5708+6.2832*(_rq?_arB:_arA)
'@

SubRx @'
if(_arf>=AR_A&&_arf<=AR_B) PAD.xMode='KeyR';
'@ @'
if(_arf>=arLo(_rp)&&_arf<=arHi(_rp)) PAD.xMode='KeyR'; /* v35.xx (cw-reloadstack): the spot of this chain */
'@

SubRx @'
var VER='35.26';
'@ @'
var VER='35.27';
'@

$pat = "(?m)^  now:'v35\.26:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v35.27: active reload stacks, the sweet spot shrinks each time Check 35.27 fails on v35.26',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
