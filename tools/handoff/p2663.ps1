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

# CLOSE CALL (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
function scoreKill(st,k,el,boss,x,y){
'@ @'
// v26.xx (feel15), HIS ORDER (2026-10-14): a style bonus that is not a kill. scoreBonus(n,x,y,text) adds n to the run score the same way in a DEMO run
// (ARCADE.mine, sent to the other window) and in a CAREER run (G.cs.s), and pops the text with the figure where it happened. In a raid that has
// neither it adds nothing and returns 0. Live play only; no seeded draw.
function scoreBonus(n,x,y,txt){
  if(!G||G.sim||G.over||!(n>0)) return 0;
  if(G.arcade&&typeof ARCADE==='object'&&ARCADE&&ARCADE.on){ ARCADE.mine=(ARCADE.mine|0)+n; try{ arcadeScSend(); }catch(_e){} }
  else if(G.career&&G.cs){ G.cs.s=(G.cs.s|0)+n; }
  else return 0;
  try{ label(x,y,txt+' +'+arcadeCr(n),'#ffc04a',0,true); }catch(_l){}
  return n;
}
function scoreKill(st,k,el,boss,x,y){
'@

SubRx @'
function updateBullets(dt){
'@ @'
// v26.xx (feel15), HIS ORDER (2026-10-14): "dodge-through reward ok". ROLL THROUGH A ROUND AND IT PAYS. A round that reaches you inside the roll's
// invulnerable window (the roll is on and the i-frames are still running) refunds the stamina the roll cost (ROLLSTAM), adds CC_PTS to the run score
// and calls CLOSE CALL, once per roll (CC_GAP is longer than the roll cooldown). The round is still stopped by the i-frames exactly as before, so
// nothing about the damage you take changes. Live play only, and no seeded draw.
var CC_PTS=25, CC_GAP=0.9;
function closeCall(b){
  var p=G&&G.player, sc;
  if(!p||G.sim||G.over||!(p.roll>0)||!(p.iv>0)) return false;
  if(p.ccT!==undefined&&G.t-p.ccT<CC_GAP) return false;
  p.ccT=G.t;
  p.stam=Math.min(100,(+p.stam||0)+ROLLSTAM);
  sc=scoreBonus(CC_PTS,p.x,p.y-32,'CLOSE CALL');
  if(!sc){ try{ label(p.x,p.y-32,'CLOSE CALL','#ffc04a',0,true); }catch(_l){} }
  try{ blip('whizz',undefined,0); spark(p.x,p.y-12,'#ffe6a8',10,240); }catch(_s){}
  return true;
}
function updateBullets(dt){
'@

SubRx @'
if(!_mOwn&&!p.specOut&&dist(b,p)<p.r+3){ damagePlayer(b.dmg,b.owner.kind,b.owner.name,b.x-b.vx*0.05,b.y-b.vy*0.05); hit=true; }
'@ @'
if(!_mOwn&&!p.specOut&&dist(b,p)<p.r+3){ closeCall(b); damagePlayer(b.dmg,b.owner.kind,b.owner.name,b.x-b.vx*0.05,b.y-b.vy*0.05); hit=true; }
'@

SubRx @'
var VER='26.62';
'@ @'
var VER='26.63';
'@

$pat = "(?m)^  now:'v26\.62:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v26.63: Rolling through a round gives back the roll stamina and scores a CLOSE CALL. Check 26.63 fails on v26.62',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
