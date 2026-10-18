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

# THE TEAMMATE HEARS THE SPIN-UP AND THE LANCE CHARGE (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
function netFxNoise(type,x,y,wid){
'@ @'
function netSynth(r,p,w){ if(p&&typeof NET==='object'&&NET&&NET.on&&!NET.fxIn&&G&&!G.sim) netFxNoise('f:'+r,p.x,p.y,w); }   // v28.xx (cw-windup), CLOUD HUNT 2026-10-15: a wind-up made by a synth (not a foley clip) goes to the party as f:~name, played there by synthAt
function netFxNoise(type,x,y,wid){
'@

SubRx @'
  if(want&&was<=0&&p.spin>0) lmgWhirr();
'@ @'
  if(want&&was<=0&&p.spin>0){ lmgWhirr(); netSynth('~whirr',p,''); }   // v28.xx (cw-windup), CLOUD HUNT 2026-10-15: the teammate hears the spin-up where you stand
'@

SubRx @'
else if(!want&&LMGSPIN.hum){ lmgWhirrStop();
'@ @'
else if(!want&&LMGSPIN.hum){ lmgWhirrStop(); netSynth('~whirrx',p,'');   /* v28.xx (cw-windup), CLOUD HUNT 2026-10-15: and it is cut in his window when you let go */
'@

SubRx @'
  var h=RLFX.hum, a, t;
'@ @'
  var h=RLFX.hum, a, t;
  if(RLFX.hum&&RLFX.p) netSynth('~whinex',RLFX.p,'');   // v28.xx (cw-windup), CLOUD HUNT 2026-10-15: a Lance whine cut short is cut in the teammate window too
'@

SubRx @'
    if(s.r==='~whine') rlfxWhine(Math.max(0.1,RLFX.tot*(1-s.f)/1000));
'@ @'
    if(s.r==='~whine'){ rlfxWhine(Math.max(0.1,RLFX.tot*(1-s.f)/1000)); netSynth('~whine',RLFX.p,Math.max(0.1,RLFX.tot*(1-s.f)/1000).toFixed(2)); }   // v28.xx (cw-windup), CLOUD HUNT 2026-10-15: the teammate hears the Lance charge (v25.52 promised it)
'@

SubRx @'
    else if(s.r==='~ping') rlfxPing(o.at||0);
'@ @'
    else if(s.r==='~ping'){ rlfxPing(o.at||0); netSynth('~ping',RLFX.p,''); }
'@

SubRx @'
function rlfxWhine(sec){
'@ @'
function rlfxWhine(sec,far){ var v=(far&&far.v>0)?+far.v:1;   // v28.xx (cw-windup), CLOUD HUNT 2026-10-15: far {v}: a teammate whine, faded by distance, never his own reload sound
'@

SubRx @'
g.gain.linearRampToValueAtTime(0.035,t+Math.min(0.2,sec*0.5)); g.gain.linearRampToValueAtTime(0.06,t+sec);
'@ @'
g.gain.linearRampToValueAtTime(0.035*v,t+Math.min(0.2,sec*0.5)); g.gain.linearRampToValueAtTime(0.06*v,t+sec);
'@

SubRx @'
    RLFX.hum={o:o,g:g};
'@ @'
    if(!far) RLFX.hum={o:o,g:g}; else { synthCut(RLFX.far); RLFX.far={o:o,g:g}; }   // v28.xx (cw-windup), CLOUD HUNT 2026-10-15: one teammate whine at a time
'@

SubRx @'
function rlfxPing(at){
'@ @'
function rlfxPing(at,far){ var v=(far&&far.v>0)?+far.v:1;   // v28.xx (cw-windup), CLOUD HUNT 2026-10-15: far {v}: a teammate ping, faded by distance
'@

SubRx @'
g.gain.linearRampToValueAtTime(0.09,t+0.005);
'@ @'
g.gain.linearRampToValueAtTime(0.09*v,t+0.005);
'@

SubRx @'
function sfx(type,wx,wy,wid){
'@ @'
function synthAt(r,x,y,w){   // v28.xx (cw-windup), CLOUD HUNT 2026-10-15: a teammate whirr, whine or ping, where he stands, with the fade every world sound has
  var E, vol, h=null;
  if(r==='whirrx'){ synthCut(LMGSPIN.far); LMGSPIN.far=null; return true; }
  if(r==='whinex'){ synthCut(RLFX.far); RLFX.far=null; return true; }
  if(!G||G.sim||!G.player||!isFinite(x)||!isFinite(y)) return false;
  E=earsOf(x,y); vol=E.d<=450?1-E.d/900:Math.max(0,0.5*(900-E.d)/450); if(vol<=0.02) return false;
  if(r==='whirr'){ synthCut(LMGSPIN.far); try{ h=spkPlay('lmgSpinUp',{vol:vol,wid:0}); }catch(_w){ h=null; } LMGSPIN.far=h||null; }
  else if(r==='whine') rlfxWhine(clamp(+w||1,0.1,5),{v:vol});
  else if(r==='ping') rlfxPing(0,{v:vol});
  else return false;
  return true;
}
function synthCut(h){   // v28.xx (cw-windup), CLOUD HUNT 2026-10-15: a teammate whirr or whine cut on a 50 ms fade, as lmgWhirrStop cuts yours
  var a, t;
  if(!h) return;
  try{ a=ac(); t=a?a.currentTime:0; h.g.gain.cancelScheduledValues(t); h.g.gain.setValueAtTime(h.g.gain.value,t); h.g.gain.linearRampToValueAtTime(0.0001,t+0.05); h.o.stop(t+0.07); }catch(e){}
}
function sfx(type,wx,wy,wid){
'@

SubRx @'
  if(typeof type==='string'&&type.charAt(0)==='f'&&type.charAt(1)===':'){ if(typeof foley==='function') foley(type.slice(2),wx,wy,{local:1}); return; }
'@ @'
  if(typeof type==='string'&&type.charAt(0)==='f'&&type.charAt(1)===':'&&type.charAt(2)==='~'){ synthAt(type.slice(3),wx,wy,wid); return; }   // v28.xx (cw-windup), CLOUD HUNT 2026-10-15: a teammate synth wind-up
  if(typeof type==='string'&&type.charAt(0)==='f'&&type.charAt(1)===':'){ if(typeof foley==='function') foley(type.slice(2),wx,wy,{local:1}); return; }
'@

SubRx @'
var VER='28.98';
'@ @'
var VER='28.99';
'@

$pat = "(?m)^  now:'v28\.98:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v28.99: Your teammate now hears your Support MG spin up and your Meridian Lance charge and ping where you stand. Check 28.99 fails on v28.98',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
