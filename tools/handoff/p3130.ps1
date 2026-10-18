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

# THE DOWNED BLOCK SITS ON ONE PLATE AND THE TIMER IS THE BIG NUMBER (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
function downBarDraw(cx,yb,p){

'@ @'
// v28.xx (cw-downplate), critic on screen 34 (P0): "put a scrim plate behind the whole block, make the timer the hero". The downed words (down, bar,
// timer, self-revive, surrender, the extraction line) sat straight on the red wash and the busy world. They now sit on one shared panel (uiPanel,
// Panel P), sized from the same row math the block uses, and the timer is the big type of the word down. DP_DRAWS counts the plates for the check.
var DP_DRAWS=0;
function downPlateRect(cx,dy,hH,hD,revived,giveOn,hasPull,dv,barOn){
  var yb=dy-hH-4, top=barOn?(yb-14-3-16):(dy-hH-12), rowY=dy+Math.round(hH*0.42)+10+Math.round(hD*1.15);
  if(hasPull) rowY+=Math.round(hD*1.35)+Math.round(hD*0.4)+10;
  if(revived&&giveOn) rowY+=Math.round(hD*1.25);
  if(dv){ if(dv.msg) rowY+=Math.round(hD*1.5)+Math.round(hH*0.30); if(dv.sub) rowY+=Math.round(hD*1.35); }
  return {x:Math.round(cx-260),y:top,w:520,h:rowY+16-top};
}
function downPlateDraw(r){ DP_DRAWS++; uiPanel(ctx,r.x,r.y,r.w,r.h); }
function downBarDraw(cx,yb,p){

'@

SubRx @'
    ctx.fillStyle='#ff5a4a'; ctx.fillText('DOWN',W/2,_dy);

'@ @'
    try{ downPlateDraw(downPlateRect(W/2,_dy,_hH,_hD,!!p.revived,CFG.giveUp!==0,!!(padZ&&padZ.open&&((padZ.pullT||0)>0||(padZ.callT||0)>0)),downedVerb(),p.dbOn===1)); }catch(_dpl){}   // v28.xx (cw-downplate)
    ctx.fillStyle='#ff5a4a'; ctx.fillText('DOWN',W/2,_dy);

'@

SubRx @'
    ctx.font=_fD; ctx.fillStyle=(p.dbGainT>DB_POP*0.5)?'#9fe8b0':'#ffb0a0'; ctx.textAlign='left';

'@ @'
    ctx.font=_fH; ctx.fillStyle=(p.dbGainT>DB_POP*0.5)?'#9fe8b0':'#ffb0a0'; ctx.textAlign='left';   // v28.xx (cw-downplate): the timer is the hero, as big as the word down

'@

SubRx @'
var VER='31.29';
'@ @'
var VER='31.30';
'@

$pat = "(?m)^  now:'v31\.29:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v31.30: When you are down, the down word, the bar, the timer and the prompts now sit on one dark panel, and the timer is big. Check 31.30 fails on v31.29',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
