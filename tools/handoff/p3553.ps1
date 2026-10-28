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

# HUD TEXT AT A READABLE SIZE (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
function feedRect(){
'@ @'
// v35.xx (cw-hudsize), HIS ASK (2026-10-27 ~21:40): "Everything about this game needs to be AAA and right now all the messaging on the hud is a clusterfuck", built
// to the research of that night (reports/Player alerts and HUD messaging.md, job 9, the Xbox accessibility floors at 1080p). TEXT AT A READABLE SIZE: the left
// feed was 15.6 px and is at least 20 (its zone is 28 percent of the width, was 24, so a long line still fits whole), the answer line is at least 20 (cw-answerline),
// the opened controls list was 16 and is 18, and the danger slot headline was 26 and is 30. Every size still grows with the screen and the text size setting.
// CONTRAST: every raid line sits on the one HUD plate (88 percent graphite), so it was read against that plate laid over the lightest ground (white) and the darkest
// (black); words on it need 4.5 to 1. The cream, the grey, the teal and the amber pass both; the red of a shut exit on the pill did not over white (3.2), so text
// in red on a plate is the lighter HUDTXT_RED (4.8). hudCR and hudOver are the reader the check uses.
var FEEDPX=20, LEGCK=1.125, ALERTPX=30, HUDTXT_RED='#ff6a55';
function feedFont(){ var f=hudFS(TYPE.label), r=Math.max(1,hudRes()), px=msgPx(f); return (px<FEEDPX*r)?f.replace(/[\d.]+px/,(FEEDPX*r).toFixed(1)+'px'):f; }
function hudLum(c){
  var s=String(c), m, r, gg, b;
  function lin(v){ v/=255; return (v<=0.03928)?v/12.92:Math.pow((v+0.055)/1.055,2.4); }
  if(s.charAt(0)==='#'){ if(s.length===4) s='#'+s[1]+s[1]+s[2]+s[2]+s[3]+s[3]; r=parseInt(s.substr(1,2),16); gg=parseInt(s.substr(3,2),16); b=parseInt(s.substr(5,2),16); }
  else { m=/rgba?\(([^)]*)\)/.exec(s); if(!m) return 0; m=m[1].split(','); r=+m[0]; gg=+m[1]; b=+m[2]; }
  return 0.2126*lin(r)+0.7152*lin(gg)+0.0722*lin(b);
}
function hudOver(fill,ground){ var m=/rgba?\(([^)]*)\)/.exec(String(fill)), p, a; if(!m) return fill; p=m[1].split(','); a=(p[3]===undefined)?1:+p[3]; return 'rgb('+Math.round(+p[0]*a+ground*(1-a))+','+Math.round(+p[1]*a+ground*(1-a))+','+Math.round(+p[2]*a+ground*(1-a))+')'; }
function hudCR(fg,bg){ var a=hudLum(fg), b=hudLum(bg); return (Math.max(a,b)+0.05)/(Math.min(a,b)+0.05); }
function feedRect(){
'@

SubRx @'
  var rs=Math.max(1,hudRes()), fp=msgPx(hudFS(TYPE.label)), rh=Math.round(fp*1.38),
'@ @'
  var rs=Math.max(1,hudRes()), fp=msgPx(feedFont()), rh=Math.round(fp*1.38),   /* v35.xx (cw-hudsize): 20 px */
'@

SubRx @'
  rs=Math.max(1,hudRes()); fL=hudFS(TYPE.label); pad=Math.round(LH(7)*rs);
'@ @'
  rs=Math.max(1,hudRes()); fL=feedFont(); pad=Math.round(LH(7)*rs);   /* v35.xx (cw-hudsize): 20 px */
'@

SubRx @'
  return {x:Math.round(LH(9)*rs),y:bot-h,w:Math.round(W*0.24),h:h,rh:rh,gap:gap,fp:fp};
'@ @'
  return {x:Math.round(LH(9)*rs),y:bot-h,w:Math.round(W*0.28),h:h,rh:rh,gap:gap,fp:fp};   // v35.xx (cw-hudsize): 28 percent, so a 20 px line fits whole
'@

SubRx @'
    var _q=1/(HUDZ.legend||1), Q=function(n){ return n*_q; }, _lf=uiFont('label',_q),
'@ @'
    var _q=LEGCK/(HUDZ.legend||1), Q=function(n){ return n*_q; }, _lf=uiFont('label',_q),   /* v35.xx (cw-hudsize): 18 px at 1080p, was 16; the panel grows with its rows */
'@

SubRx @'
  hf=FS(TYPE.title); lf=FS(TYPE.label); hp=msgPx(hf); lp=msgPx(lf); gs=Math.round(hp*0.9);
'@ @'
  hf=FS(TYPE.title); if(msgPx(hf)<ALERTPX) hf=hf.replace(/[\d.]+px/,ALERTPX+'px');   // v35.xx (cw-hudsize): the danger headline is 30 px at 1080p (was 26), still under the message scale
  lf=FS(TYPE.label); hp=msgPx(hf); lp=msgPx(lf); gs=Math.round(hp*0.9);
'@

SubRx @'
  if(z.open===false){ o.st='closed'; o.col=HUDC.danger;
'@ @'
  if(z.open===false){ o.st='closed'; o.col=HUDTXT_RED;   /* v35.xx (cw-hudsize): 4.8 to 1 on the plate over white, was 3.2 */
'@

SubRx @'
var VER='35.52';
'@ @'
var VER='35.53';
'@

$pat = "(?m)^  now:'v35\.52:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v35.53: the feed, the answer line, the controls list and the danger line are bigger and easier to read Check 35.53 fails on v35.52',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
