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

# PUNCHY HITS ON CONFIRM AND ON THE SCORE COUNT (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
ok:{ty:'triangle',f1:520,f2:780,d:0.09,v:0.05},
'@ @'
ok:{ty:'triangle',f1:520,f2:780,d:0.09,v:0.05,body:{f1:140,f2:68,d:0.11,v:0.07}},
'@

SubRx @'
close:{ty:'sine',f1:840,f2:420,d:0.1,v:0.035}};
'@ @'
close:{ty:'sine',f1:840,f2:420,d:0.1,v:0.035},
  hit:{ty:'triangle',f1:760,f2:720,d:0.035,v:0.026},land:{ty:'triangle',f1:300,f2:150,d:0.16,v:0.06,body:{f1:110,f2:52,d:0.18,v:0.075}}};   // v32.xx (cw-scorehits): the score count's step hit and its landing
'@

SubRx @'
function uiSndPick(kind,t,lastAt,n){
'@ @'
function uiSndPick(kind,t,lastAt,n,pp){
'@

SubRx @'
gap=(kind==='move')?0.04:0.03;
'@ @'
gap=(kind==='move')?0.04:((kind==='hit'||kind==='land')?0:0.03);   // v32.xx (cw-scorehits): the score hits are paced by sndScoreHit, not by this guard
'@

SubRx @'
v=(kind==='move')?(n%4):0; p=(kind==='move')?UI_TICK_P[v]:1;
'@ @'
v=(kind==='move')?(n%4):0; p=(kind==='move')?UI_TICK_P[v]:1; if(pp>0) p=pp;
'@

SubRx @'
return {kind:kind,ty:K.ty,f1:K.f1*p,f2:K.f2*p,d:K.d,v:K.v,variant:v,pitch:p};
'@ @'
return {kind:kind,ty:K.ty,f1:K.f1*p,f2:K.f2*p,d:K.d,v:K.v,variant:v,pitch:p,body:K.body||null};   // v32.xx (cw-scorehits): body is the low thump layer under the click
'@

SubRx @'
function sndUi(kind){
'@ @'
function sndUi(kind,pp){
'@

SubRx @'
  a=ac(); if(!a) return false;
  out=sndBus('ui'); if(!out) return false;
  t=a.currentTime;
  K=uiSndPick(kind,t,SND_UI_AT,SND_UI_N); if(!K) return false;
'@ @'
  a=ac(); out=a?sndBus('ui'):null;
  if((!a||!out)&&kind!=='hit'&&kind!=='land') return false;   // v32.xx (cw-scorehits): the score hits are logged even with no audio, so they can be tested
  t=a?a.currentTime:0;
  K=uiSndPick(kind,t,SND_UI_AT,SND_UI_N,pp); if(!K) return false;
'@

SubRx @'
if(SND_UI_LOG.length>200) SND_UI_LOG.shift(); }catch(_ul){}
'@ @'
if(SND_UI_LOG.length>200) SND_UI_LOG.shift(); }catch(_ul){}
  if(!a||!out) return false;
'@

SubRx @'
o.connect(g); g.connect(out); o.start(t); o.stop(t+K.d+0.02);
'@ @'
o.connect(g); g.connect(out); o.start(t); o.stop(t+K.d+0.02);
    if(K.body){ var o2=a.createOscillator(), g2=a.createGain(); o2.type='sine'; o2.frequency.setValueAtTime(K.body.f1,t); o2.frequency.exponentialRampToValueAtTime(K.body.f2,t+K.body.d);
      g2.gain.setValueAtTime(0.0001,t); g2.gain.exponentialRampToValueAtTime(K.body.v,t+0.006); g2.gain.exponentialRampToValueAtTime(0.0001,t+K.body.d);
      o2.connect(g2); g2.connect(out); o2.start(t); o2.stop(t+K.body.d+0.02); }   // v32.xx (cw-scorehits): a short low thump under the click so a press lands
'@

SubRx @'
try{ document.addEventListener('click',sndUiClick,true); }catch(_uc){}
'@ @'
try{ document.addEventListener('click',sndUiClick,true); }catch(_uc){}
// v32.xx (cw-scorehits), HIS ANSWER Q48 ("soft ticks, punchy hits on confirm and score"): a score figure that counts up plays one short hit per changed step
// (at most one every 70 ms, the pitch climbing a little as it goes), then one heavier landing hit when it reaches the final figure. st is the owner's own
// {done,v} (the run over card keeps it on ARCADE.over, a ledger figure on its element), so a rebuilt card never restarts or doubles them. A figure of 0 is silent.
// Sound only: no seeded draw, no game state.
var SCORE_HIT_AT=0, SCORE_LAND_AT=0;
function sndScoreHit(st,k,v,to){
  var now=Date.now();
  if(!st||!(to>0)) return false;
  if(k<1){
    if(!(v>0)||v===st.v||now-SCORE_HIT_AT<70) return false;
    st.v=v; SCORE_HIT_AT=now;
    return sndUi('hit',1+0.5*k);
  }
  if(st.done) return false;
  st.done=1;
  if(now-SCORE_LAND_AT<120) return false;   // several figures landing together make one landing
  SCORE_LAND_AT=now;
  return sndUi('land');
}
'@

SubRx @'
  el._lbIv=setInterval(function(){
    var k=clamp((Date.now()-t0)/(durMs||900),0,1);
    if(!el.isConnected){ clearInterval(el._lbIv); return; }
    el.textContent=pre+lbFmt(el,Math.round((to|0)*(1-Math.pow(1-k,3))));
    if(k>=1) clearInterval(el._lbIv);
  },40);
'@ @'
  el._lbSt={done:0,v:0};   // v32.xx (cw-scorehits): this figure's own hit state
  el._lbIv=setInterval(function(){
    var k=clamp((Date.now()-t0)/(durMs||900),0,1), v=Math.round((to|0)*(1-Math.pow(1-k,3)));
    if(!el.isConnected){ clearInterval(el._lbIv); return; }
    el.textContent=pre+lbFmt(el,v);
    if(Date.now()>=t0){ try{ sndScoreHit(el._lbSt,k,v,to|0); }catch(_sh){} }   // v32.xx (cw-scorehits): a hit a step, a landing at the end
    if(k>=1) clearInterval(el._lbIv);
  },40);
'@

SubRx @'
for(i=0;i<els.length;i++){ el=els[i]; if(el._lbIv) clearInterval(el._lbIv); el.textContent=(el.getAttribute('data-pre')||'')+lbFmt(el,+el.getAttribute('data-to')||0); }
'@ @'
for(i=0;i<els.length;i++){ el=els[i]; if(el._lbIv) clearInterval(el._lbIv); el.textContent=(el.getAttribute('data-pre')||'')+lbFmt(el,+el.getAttribute('data-to')||0);
    if(el._lbSt&&!el._lbSt.done){ try{ sndScoreHit(el._lbSt,1,+el.getAttribute('data-to')||0,+el.getAttribute('data-to')||0); }catch(_sh){} } }   // v32.xx (cw-scorehits): a press that skips plays only the landing hit
'@

SubRx @'
  c.setAttribute('data-cu',k<1?'1':'0');
'@ @'
  c.setAttribute('data-cu',k<1?'1':'0');
  try{ if(!o.shSt) o.shSt={done:0,v:0}; sndScoreHit(o.shSt,k,v,+o.team||0); }catch(_sh){}   // v32.xx (cw-scorehits): tied to ARCADE.over.at like the count itself, so a rebuilt card never restarts the hits
'@

SubRx @'
var VER='32.72';
'@ @'
var VER='32.73';
'@

$pat = "(?m)^  now:'v32\.72:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v32.73: A press lands with a thump, and a score counts up with hits and lands with a heavier one. Check 32.73 fails on v32.72',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
