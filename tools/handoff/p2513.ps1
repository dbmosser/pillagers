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

# CAREER RAIDS: THE KILL SCORE (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
if(G.arcade) arcadeKill(e.kind,e.elite,e.boss,e.x,e.y);
'@ @'
if(G.arcade) arcadeKill(e.kind,e.elite,e.boss,e.x,e.y); else if(G.career) careerKill(e.kind,e.elite,e.boss,e.x,e.y);   /* v24.xx (feat0h2): the CAREER score */
'@

SubRx @'
if(G.arcade) arcadeKill(k,!!(m.el||(e&&e.elite)),!!(e&&(e.boss||e.name===BOSS_NAME)),e?e.x:NaN,e?e.y:NaN);
'@ @'
if(G.arcade||G.career) (G.arcade?arcadeKill:careerKill)(k,!!(m.el||(e&&e.elite)),!!(e&&(e.boss||e.name===BOSS_NAME)),e?e.x:NaN,e?e.y:NaN);   /* v24.xx (feat0h2): and the CAREER score of a co-op partner */
'@

SubRx @'
function arcadeKill(k,el,boss,x,y){
  if(!ARCADE.on||!G||!G.arcade||G.sim||G.over) return 0;
  var n=arcadeKillPts(k,el,boss), s, t=+G.t||0, mx, c;
  if(!(n>0)) return 0;
'@ @'
// v24.xx (feat0h2), HIS MODE DESIGN AND HIS RULE (2026-10-12): "high score is still an objective" in CAREER, and the scoring is "EXACTLY
// THE SAME IN DEMO AND CAREER". THE KILL SCORE IN A CAREER RAID. The DEMO points table, streak and multiplier, +$ popup where
// the body fell and streak callout (as arcadeKill does them) are scoreKill over a CAREER score store, G.cs, in a CAREER raid
// (careerKill, from the same kill credit as the DEMO, the host and a co-op partner each scoring their own player). The DEMO newcomer
// perks (half a magazine back, a Bandage every 3rd kill) stay in the DEMO: CAREER is his own kit. The score reads at the clock as in
// the DEMO: SCORE over the figure, the streak multiplier beside it and the 10 minute clock under it.
function scoreKill(st,k,el,boss,x,y){
  var n=arcadeKillPts(k,el,boss), s, t=+G.t||0, mx, c;
  if(!(n>0)||!st) return 0;
  s=st.streak;
  if(!s||!(t-s.t<ARCADE_STREAK_GAP)||t<s.t) s=st.streak={n:0,t:t};
  s.n++; s.t=t; mx=arcadeStreakX(s.n); n*=mx;
  if(isFinite(x)&&isFinite(y)){ try{ label(x,y-20,'+'+arcadeCr(n),'#ffc04a',0,true); }catch(_alb){} }
  c=arcadeStreakCall(s.n);
  if(c){ try{ say(c,'ext',{sub:'x'+mx}); }catch(_asc){} try{ if(VOX_STREAK[c]) voxCall(VOX_STREAK[c]); }catch(_avc){} }
  return n;
}
function careerKill(k,el,boss,x,y){
  if(!G||!G.career||!G.cs||G.sim||G.over) return 0;
  var n=scoreKill(G.cs,k,el,boss,x,y);
  if(!(n>0)) return 0;
  G.cs.s=(G.cs.s|0)+n; G.cs.k=(G.cs.k|0)+1;
  return n;
}
function arcadeKill(k,el,boss,x,y){
  if(!ARCADE.on||!G||!G.arcade||G.sim||G.over) return 0;
  var n=arcadeKillPts(k,el,boss), s, t=+G.t||0, mx, c;
  if(!(n>0)) return 0;
'@

SubRx @'
  var s=ARCADE.streak, t=(G&&+G.t)||0;
'@ @'
  var s=(G&&G.career&&G.cs)?G.cs.streak:ARCADE.streak, t=(G&&+G.t)||0;   // v24.xx (feat0h2): a CAREER raid keeps its own streak
'@

SubRx @'
function arcadeScoreHud(y,z){
  if(!G||!G.arcade||!ctx) return;
  var cx=Math.round(W/2), mine=Math.max(0,ARCADE.mine|0), mate=Math.max(0,ARCADE.mate|0), nm=arcadeCr(mine+mate);
'@ @'
function arcadeScoreHud(y,z){
  if(!G||!(G.arcade||G.career)||!ctx) return;
  var cr=!G.arcade, solo=cr||!!ARCADE.solo;   // v24.xx (feat0h2): a CAREER raid reads its own score, one player to a window
  var cx=Math.round(W/2), mine=Math.max(0,cr?((G.cs&&G.cs.s)|0):(ARCADE.mine|0)), mate=cr?0:Math.max(0,ARCADE.mate|0), nm=arcadeCr(mine+mate);
'@

SubRx @'
hudText(ARCADE.solo?'SCORE':'TEAM SCORE',
'@ @'
hudText(solo?'SCORE':'TEAM SCORE',
'@

SubRx @'
  if(!ARCADE.solo){   // v23.54 (arcade30): no YOU and P2 split
'@ @'
  if(!solo){   // v23.54 (arcade30): no YOU and P2 split
'@

SubRx @'
if(G.arcade) arcadeScoreHud(_yClk,_tz); else {
'@ @'
if(G.arcade||G.career) arcadeScoreHud(_yClk,_tz); else {
'@

SubRx @'
var VER='25.12';
'@ @'
var VER='25.13';
'@

$pat = "(?m)^  now:'v25\.12:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v25.13: Kills in CAREER raids score points, with streaks, shown above the clock. Check 25.13 fails on v25.12',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
