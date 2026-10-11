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

# ARCADE: POPUPS AND STREAKS (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
// A kill this window credited to its own player. Returns the points.
function arcadeKill(k,el,boss){
  if(!ARCADE.on||!G||!G.arcade||G.sim||G.over) return 0;
  var n=arcadeKillPts(k,el,boss);
  if(!(n>0)) return 0;
  ARCADE.mine=(ARCADE.mine|0)+n; ARCADE.kills=(ARCADE.kills|0)+1;
'@ @'
// v23.38, HIS ORDER (2026-10-11), build 15 of 20 (arcade15): POPUPS AND STREAKS. A walk-up player should see every kill pay. Each
// credited kill now puts its points (+50, +100...) up as a popup over the body, and kills less than 4 s apart (game time) chain
// into a streak that multiplies the award: 2 in a row x2 (DOUBLE KILL), 3 x3 (TRIPLE KILL), 4 x3 (MULTI KILL), 5 to 7 x4
// (RAMPAGE), 8 and up x5 (UNSTOPPABLE). The callout is said once as the chain reaches its row, in the ext lane (the alert slot),
// with the multiplier as its detail. An elite still counts twice before the multiplier. While a streak of 2 or more is live its
// multiplier shows as a badge beside TEAM SCORE. The streak belongs to this window and starts again with every arcade drop.
// Only arcade raids reach arcadeKill, so a normal raid is unchanged.
var ARCADE_STREAK_GAP=4;
var ARCADE_STREAK=[[8,5,'UNSTOPPABLE'],[5,4,'RAMPAGE'],[4,3,'MULTI KILL'],[3,3,'TRIPLE KILL'],[2,2,'DOUBLE KILL']];
function arcadeStreakX(n){ var i; for(i=0;i<ARCADE_STREAK.length;i++) if(n>=ARCADE_STREAK[i][0]) return ARCADE_STREAK[i][1]; return 1; }
function arcadeStreakCall(n){ var i; for(i=0;i<ARCADE_STREAK.length;i++) if(n===ARCADE_STREAK[i][0]) return ARCADE_STREAK[i][2]; return ''; }
// the multiplier the badge shows now: 1 when no streak of 2 or more is live
function arcadeStreakLive(){
  var s=ARCADE.streak, t=(G&&+G.t)||0;
  if(!s||!(s.n>=2)||!(t-s.t<ARCADE_STREAK_GAP)||t<s.t) return 1;
  return arcadeStreakX(s.n);
}
// A kill this window credited to its own player. Returns the points. x, y: where the body fell, for the popup.
function arcadeKill(k,el,boss,x,y){
  if(!ARCADE.on||!G||!G.arcade||G.sim||G.over) return 0;
  var n=arcadeKillPts(k,el,boss), s, t=+G.t||0, mx, c;
  if(!(n>0)) return 0;
  s=ARCADE.streak;   // v23.38 (arcade15): the chain, the multiplier, the popup and the callout
  if(!s||!(t-s.t<ARCADE_STREAK_GAP)||t<s.t) s=ARCADE.streak={n:0,t:t};
  s.n++; s.t=t; mx=arcadeStreakX(s.n); n*=mx;
  if(isFinite(x)&&isFinite(y)){ try{ label(x,y-20,'+'+arcadeN(n),'#ffc04a',0,true); }catch(_alb){} }
  c=arcadeStreakCall(s.n);
  if(c){ try{ say(c,'ext',{sub:'x'+mx}); }catch(_asc){} }
  ARCADE.mine=(ARCADE.mine|0)+n; ARCADE.kills=(ARCADE.kills|0)+1;
'@

SubRx @'
  ARCADE.waveT=0; ARCADE.waveN=0;   // v23.37 (arcade14): the wave clock and count start again
'@ @'
  ARCADE.waveT=0; ARCADE.waveN=0;   // v23.37 (arcade14): the wave clock and count start again
  ARCADE.streak=null;   // v23.38 (arcade15): the kill streak starts again
'@

SubRx @'
        if(G.arcade) arcadeKill(e.kind,e.elite,e.boss);   // v23.29 (arcade8): the arcade score, by kind
'@ @'
        if(G.arcade) arcadeKill(e.kind,e.elite,e.boss,e.x,e.y);   // v23.29 (arcade8): the arcade score, by kind; v23.38 (arcade15): with the popup where he fell
'@

SubRx @'
  if(G.arcade) arcadeKill(k,!!(m.el||(e&&e.elite)),!!(e&&(e.boss||e.name===BOSS_NAME)));   // v23.29 (arcade8): the arcade score of player 2
'@ @'
  if(G.arcade) arcadeKill(k,!!(m.el||(e&&e.elite)),!!(e&&(e.boss||e.name===BOSS_NAME)),e?e.x:NaN,e?e.y:NaN);   // v23.29 (arcade8): the arcade score of player 2; v23.38 (arcade15): with the popup where he fell
'@

SubRx @'
  hudText((ARCADE.role==='p2'?'P1 ':'P2 ')+arcadeN(mate),gx,Math.round(y+h*0.15));
'@ @'
  hudText((ARCADE.role==='p2'?'P1 ':'P2 ')+arcadeN(mate),gx,Math.round(y+h*0.15));
  var _sx=arcadeStreakLive();   // v23.38 (arcade15): the live streak multiplier, left of the score
  if(_sx>1){ ctx.font=fb; ctx.textAlign='right'; ctx.fillStyle='#ffc04a'; hudText('x'+_sx,Math.round(cx-w/2-10*z),y); }
'@

SubRx @'
var VER='23.37';
'@ @'
var VER='23.38';
'@

$pat = "(?m)^  now:'v23\.37:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v23.38: In the arcade every kill pops its points over the body, and kills less than 4 seconds apart chain into a streak from DOUBLE KILL at x2 up to UNSTOPPABLE at x5, shown beside the team score. Check 23.38 fails on v23.37',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
