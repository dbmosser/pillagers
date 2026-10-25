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

# PIXEL RELOAD AND FORGED GUNS (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
if(fk||rl>0) gv=1;   // a forged gun (its shine) and a reload (the arm to the magazine) keep the vector gun on the pixel body
'@ @'
var rd=0, rq=0;   // v28.xx (cw-pixreload) I1: a reload tips the PIXEL gun down by the vector timings (rd) and the far hand goes to the magazine well in four steps (rq); a forged gun stays pixel too (was: both flipped the gun to the smooth vector art)
    if(rl>0){ if(rl<.35) rd=(rl/.35)*.55; else if(rl<.78){ rd=.55; rq=Math.ceil((rl-.35)/.43*4); } else rd=.55*(1-(rl-.78)/.22); }
    if(false) gv=1;
'@

SubRx @'
low=!!sprint; ext=(D.pist?2:0)+(ads?2:(low?-2:0)); ang=face+fl*(low?0.45:0);
'@ @'
low=!!sprint&&!(rl>0); ext=(D.pist?2:0)+(ads?2:(low?-2:0)); ang=face+fl*(rd+(low?0.45:0));   // v28.xx (cw-pixreload) I1: the reload angle is just another aim step
'@

SubRx @'
gn=pxGun(id,fk,el,rc,step,fl,C.coat[1],sk[1],ext,low?1:0); if(!gn) return false;
'@ @'
gn=pxGun(id,fk,el,rc,step,fl,C.coat[1],sk[1],ext,low?1:0,rq); if(!gn) return false;
'@

SubRx @'
if(lw) opLowDrops(x,y,fl);
'@ @'
if(lw) opLowDrops(x,y,fl);
  if(hold&&gn&&!gv&&((fk&&GFXQ.particles)||(rl>0&&rl<.4))) pxGunLive(px,py,step*Math.PI/16,fl,D,ext,fk,el,rl);   // v28.xx (cw-pixreload) I1: the forge shine and the falling magazine over the pixel gun; the shine sheds on the first quality rung
'@

SubRx @'
function pxBuildGun(id,fk,el,rc,step,fl,sl,hd,ext,low){
'@ @'
function pxBuildGun(id,fk,el,rc,step,fl,sl,hd,ext,low,rq){
'@

SubRx @'
sx=D.pist?(D.grip+ext+0.4):(D.fg+ext);
'@ @'
rq=rq|0; sx=rq>0?(D.well[0]+ext):(D.pist?(D.grip+ext+0.4):(D.fg+ext));   // v28.xx (cw-pixreload) I1: the far arm reaches for the magazine well
'@

SubRx @'
if(!low){ tx=D.pist?(D.grip+ext+0.2):(D.fg+ext-1.7); c.fillStyle=PIX_INK; c.fillRect(tx-0.5,D.pist?0.9:-0.3,4.4,4.4); c.fillStyle=hd; c.fillRect(tx,D.pist?1.4:0.2,3.4,3.4); }
'@ @'
if(rq>0){ var rch=rq/4, ty2=D.well[1]+(1-rch)*7; tx=D.well[0]+ext-1.7;   // v28.xx (cw-pixreload) I1: the fresh magazine and the hand at the well, the vector reach in four steps
    c.fillStyle=PIX_INK; c.fillRect(tx-0.1,ty2+1.4,3.6,5.2); c.fillStyle=GUNMAT.l; c.fillRect(tx+0.3,ty2+1.8,2.8,4.4);
    c.fillStyle=PIX_INK; c.fillRect(tx-0.5,ty2-0.5,4.4,4.4); c.fillStyle=hd; c.fillRect(tx,ty2,3.4,3.4); }
  else if(!low){ tx=D.pist?(D.grip+ext+0.2):(D.fg+ext-1.7); c.fillStyle=PIX_INK; c.fillRect(tx-0.5,D.pist?0.9:-0.3,4.4,4.4); c.fillStyle=hd; c.fillRect(tx,D.pist?1.4:0.2,3.4,3.4); }
'@

SubRx @'
function pxGun(id,fk,el,rc,step,fl,sl,hd,ext,low){
'@ @'
// v28.xx (cw-pixreload) I1: the live bits over a pixel gun: the spent magazine falling from the well while reloading, and the forge shine (and the MK III element at the muzzle), as gunHeld draws them. G.t only, never the raid stream.
function pxGunLive(px,py,ang,fl,D,ext,fk,el,rl){
  var t, f, k, ec, i, mg, wx, wy, mx, my, tx, ty2;
  if(rl>0&&rl<.4){
    mg=rl/.4; wx=D.well[0]+ext; wy=(D.well[1]+2)*(fl<0?-1:1); mx=px+Math.cos(ang)*wx-Math.sin(ang)*wy; my=py+Math.sin(ang)*wx+Math.cos(ang)*wy;
    wc.globalAlpha=clamp(1-mg,0,1); wc.fillStyle=GUNMAT.l; wc.fillRect(Math.round(mx)-1,Math.round(my+mg*14)-3,3,6); wc.globalAlpha=1;
  }
  if(!fk||!GFXQ.particles) return;
  t=(typeof G!=='undefined'&&G&&isFinite(G.t))?G.t:0; f=(t%2.5)/2.5;
  wc.save(); wc.translate(px,py); wc.rotate(ang); if(fl<0) wc.scale(1,-1); wc.scale(GUNK,GUNK);
  wc.globalCompositeOperation='lighter';
  if(f<0.5){ wc.fillStyle='rgba(255,240,176,.55)'; wc.fillRect(D.rv[0]+ext+(f/0.5)*(D.rv[2]-1.4),D.rv[1],1.4,D.rv[3]); }
  if(el){
    ec=ELEM[el].c; k=0.5+0.5*Math.sin(t*4.2); tx=D.tip+ext; ty2=D.by;
    wc.globalAlpha=0.28+0.22*k; wc.fillStyle=ec; wc.beginPath(); wc.arc(tx,ty2,2.2+k*1.1,0,6.2832); wc.fill(); wc.globalAlpha=1;
    if(el==='fire'){ for(i=0;i<2;i++){ f=((t*0.9+i*0.5)%1); wc.fillStyle='rgba(255,150,60,'+(0.9*(1-f)).toFixed(3)+')'; wc.fillRect(D.br[0]+ext+4+i*5+f*2,D.by-1.6-f*5,0.9,0.9); } }
    else if(el==='shock'){ i=Math.floor(t/0.2); if(i%3!==2){ f=(i*7)%5; wc.strokeStyle=ec; wc.lineWidth=0.6; wc.beginPath(); wc.moveTo(D.br[0]+ext+2+f,D.by-0.6); wc.lineTo(D.br[0]+ext+4.5+f,D.by-2.6+(i%2)*0.8); wc.lineTo(D.br[0]+ext+7+f,D.by-0.8); wc.stroke(); } }
    else if(el==='cryo'){ wc.fillStyle='rgba(220,245,255,.22)'; wc.fillRect(D.rv[0]+ext,D.rv[1]-0.8,D.br[1]-D.rv[0],0.8); }
    else if(el==='acid'){ f=(t%1.2)/1.2; wc.globalAlpha=f<0.6?0.9:Math.max(0,0.9-(f-0.6)*2.2); wc.fillStyle=ec; wc.beginPath(); wc.arc(tx-1,ty2+1.6+(f>0.6?(f-0.6)*14:0),0.5+Math.min(f,0.6)*1.4,0,6.2832); wc.fill(); wc.globalAlpha=1; }
  }
  wc.restore();
}
function pxGun(id,fk,el,rc,step,fl,sl,hd,ext,low,rq){
'@

SubRx @'
var fam='n|'+id+'|'+fk+'|'+el+'|'+rc+'|'+fl+'|'+sl+'|'+hd+'|'+ext+'|'+low;
'@ @'
var fam='n|'+id+'|'+fk+'|'+el+'|'+rc+'|'+fl+'|'+sl+'|'+hd+'|'+ext+'|'+low+'|'+(rq|0);
'@

SubRx @'
function(){ return pxBuildGun(id,fk,el,rc,step,fl,sl,hd,ext,low); },fam,step);
'@ @'
function(){ return pxBuildGun(id,fk,el,rc,step,fl,sl,hd,ext,low,rq); },fam,step);
'@

SubRx @'
var VER='34.76';
'@ @'
var VER='34.77';
'@

$pat = "(?m)^  now:'v34\.76:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v34.77: Reloads and forged guns stay in the pixel style. Check 34.77 fails on v34.76',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
