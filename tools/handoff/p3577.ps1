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

# HOT GROUND KILLS PAY FIVE PERCENT MORE (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
function scoreKill(st,k,el,boss,x,y){
  var n=arcadeKillPts(k,el,boss), s, t=+G.t||0, mx, c;
  if(!(n>0)||!st) return 0;
  s=st.streak;
  if(!s||!(t-s.t<ARCADE_STREAK_GAP)||t<s.t) s=st.streak={n:0,t:t};
  s.n++; s.t=t; mx=arcadeStreakX(s.n); n*=mx;
  if(isFinite(x)&&isFinite(y)){ try{ label(x,y-20,'+'+arcadeCr(n),'#ffc04a',0,true); }catch(_alb){} }
  c=arcadeStreakCall(s.n);
  if(c){ try{ say(c,'ext',{sub:'x'+mx}); }catch(_asc){} try{ if(ANN_STREAK[c]) blip('medal'+(SPK_MEDALS[c]||1)); }catch(_avc){} }   // v27.94 (snd3): the streak is a medal pop that climbs, DOUBLE KILL medal1 to UNSTOPPABLE medal5
  try{ chainTickPlay(s.n); }catch(_ctk){}   // v28.xx (cw-chaintick): a rising tick for each kill in the chain
  return n;
}
'@ @'
// v28.xx (cw-cx-hotkill): his 10-28 decision replaces the proposed 1.5 with 1.05.
var HOT_KILLX=1.05;
function scoreKill(st,k,el,boss,x,y){
  var n=arcadeKillPts(k,el,boss), s, t=+G.t||0, mx, c;
  if(!(n>0)||!st) return 0;
  s=st.streak;
  if(!s||!(t-s.t<ARCADE_STREAK_GAP)||t<s.t) s=st.streak={n:0,t:t};
  s.n++; s.t=t; mx=arcadeStreakX(s.n); n*=mx;
  // v28.xx (cw-cx-hotkill): his 10-28 decision, "should just be 1.05", after the streak in either window.
  var hot=G.hotZone&&Number.isFinite(x)&&Number.isFinite(y)&&Math.hypot(x-G.hotZone.x,y-G.hotZone.y)<=G.hotZone.r;
  if(hot) n=Math.round(n*HOT_KILLX);
  if(isFinite(x)&&isFinite(y)){ try{ label(x,y-20,'+'+arcadeCr(n)+(hot?' hot':''),'#ffc04a',0,true); }catch(_alb){} }
  c=arcadeStreakCall(s.n);
  if(c){ try{ say(c,'ext',{sub:'x'+mx}); }catch(_asc){} try{ if(ANN_STREAK[c]) blip('medal'+(SPK_MEDALS[c]||1)); }catch(_avc){} }   // v27.94 (snd3): the streak is a medal pop that climbs, DOUBLE KILL medal1 to UNSTOPPABLE medal5
  try{ chainTickPlay(s.n); }catch(_ctk){}   // v28.xx (cw-chaintick): a rising tick for each kill in the chain
  return n;
}
'@

SubRx @'
function arcadeKill(k,el,boss,x,y,ke){
  if(!ARCADE.on||!G||!G.arcade||G.sim||G.over) return 0;
  try{ flowKill(k,el,boss); }catch(_fk1){}   // v26.xx (flow3): the run goals count what died
  var n=arcadeKillPts(k,el,boss), s, t=+G.t||0, mx, c;
  if(!(n>0)) return 0;
  s=ARCADE.streak;   // v23.38 (arcade15): the chain, the multiplier, the popup and the callout
  if(!s||!(t-s.t<ARCADE_STREAK_GAP)||t<s.t) s=ARCADE.streak={n:0,t:t};
  s.n++; s.t=t; mx=arcadeStreakX(s.n); n*=mx;
  try{ arcadeBmKill(s.n,x,y); }catch(_bmk){}   // v23.xx (his answer 20): the best streak and the longest shot
  if(isFinite(x)&&isFinite(y)){ try{ label(x,y-20,'+'+arcadeCr(n),'#ffc04a',0,true); }catch(_alb){} }   // v23.56 (arcade31): +$50
  c=arcadeStreakCall(s.n);
  if(c){ try{ say(c,'ext',{sub:'x'+mx}); }catch(_asc){} try{ if(ANN_STREAK[c]) blip('medal'+(SPK_MEDALS[c]||1)); }catch(_avc){} }   // v27.94 (snd3): the streak plays a medal pop that climbs (it was a chime ladder)
  try{ chainTickPlay(s.n); }catch(_ctk){}   // v28.xx (cw-chaintick): a rising tick for each kill in the chain
  ARCADE.mine=(ARCADE.mine|0)+n; ARCADE.kills=(ARCADE.kills|0)+1;
  try{ styleKill(k,el,boss,x,y,ke); }catch(_sk){}   // v26.xx (party1): the style bonuses and medals
  try{ pwrKill(k,el,boss,x,y,ke); }catch(_pk){}   // v26.xx (party2): a kill may drop a power-up
  try{ teamKill(x,y); }catch(_tk){}   // v26.xx (party4): a kill within 2 s and a short way of the partner's builds the TEAM combo
  arcadeKillPerks();   // v23.31 (arcade10): half a magazine back, a Bandage every 3rd kill
  arcadeScSend();
  return n;
}
'@ @'
function arcadeKill(k,el,boss,x,y,ke){
  if(!ARCADE.on||!G||!G.arcade||G.sim||G.over) return 0;
  try{ flowKill(k,el,boss); }catch(_fk1){}   // v26.xx (flow3): the run goals count what died
  var n=arcadeKillPts(k,el,boss), s, t=+G.t||0, mx, c;
  if(!(n>0)) return 0;
  s=ARCADE.streak;   // v23.38 (arcade15): the chain, the multiplier, the popup and the callout
  if(!s||!(t-s.t<ARCADE_STREAK_GAP)||t<s.t) s=ARCADE.streak={n:0,t:t};
  s.n++; s.t=t; mx=arcadeStreakX(s.n); n*=mx;
  // v28.xx (cw-cx-hotkill): his 10-28 decision, "should just be 1.05", after the streak in either window.
  var hot=G.hotZone&&Number.isFinite(x)&&Number.isFinite(y)&&Math.hypot(x-G.hotZone.x,y-G.hotZone.y)<=G.hotZone.r;
  if(hot) n=Math.round(n*HOT_KILLX);
  try{ arcadeBmKill(s.n,x,y); }catch(_bmk){}   // v23.xx (his answer 20): the best streak and the longest shot
  if(isFinite(x)&&isFinite(y)){ try{ label(x,y-20,'+'+arcadeCr(n)+(hot?' hot':''),'#ffc04a',0,true); }catch(_alb){} }   // v23.56 (arcade31): +$50
  c=arcadeStreakCall(s.n);
  if(c){ try{ say(c,'ext',{sub:'x'+mx}); }catch(_asc){} try{ if(ANN_STREAK[c]) blip('medal'+(SPK_MEDALS[c]||1)); }catch(_avc){} }   // v27.94 (snd3): the streak plays a medal pop that climbs (it was a chime ladder)
  try{ chainTickPlay(s.n); }catch(_ctk){}   // v28.xx (cw-chaintick): a rising tick for each kill in the chain
  ARCADE.mine=(ARCADE.mine|0)+n; ARCADE.kills=(ARCADE.kills|0)+1;
  try{ styleKill(k,el,boss,x,y,ke); }catch(_sk){}   // v26.xx (party1): the style bonuses and medals
  try{ pwrKill(k,el,boss,x,y,ke); }catch(_pk){}   // v26.xx (party2): a kill may drop a power-up
  try{ teamKill(x,y); }catch(_tk){}   // v26.xx (party4): a kill within 2 s and a short way of the partner's builds the TEAM combo
  arcadeKillPerks();   // v23.31 (arcade10): half a magazine back, a Bandage every 3rd kill
  arcadeScSend();
  return n;
}
'@

SubRx @'
var VER='35.76';
'@ @'
var VER='35.77';
'@

$pat = "(?m)^  now:'v35\.76:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v35.77: A kill inside hot ground pays 1.05x sp after its streak bonus in career and demo, in either window. Its popup adds hot. Watch in play: is hot ground worth its two extra machines; watch demo sp totals on the board. Check 35.77 fails on v35.76',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
