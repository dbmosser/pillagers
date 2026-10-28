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

# FINAL RUSH IN THE TWO PLAYER DEMO (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
function arcadeWaveTick(dt){
'@ @'
// v28.xx (cw-cx-finalrush), his 10-28 decision #3: "1.05". The final 90 seconds belong to the two player demo only.
function arcadeRushOn(){
  return !!(G&&G.arcade&&!G.sim&&!G.over&&!ARCADE.solo&&Number.isFinite(G.timeLeft)&&G.timeLeft>0&&G.timeLeft<=90);
}
function arcadeRushTick(){
  if(!arcadeRushOn()||G.arcRushSaid) return 0;
  G.arcRushSaid=1;
  say('final rush','warn',{sub:'kills x1.05 sp',key:'finalrush'});
  return 1;
}
function arcadeWaveTick(dt){
'@

SubRx @'
  if((G.arcade&&ARCADE.role==='p2'&&!G.netWasJoin)||netEntsPeer()) return 0;   // v23.52 (arcade28): a player 2 that took the raid over runs the waves
'@ @'
  arcadeRushTick();   // v28.xx (cw-cx-finalrush): before the authority guard, so the linked window gets the same callout.
  if((G.arcade&&ARCADE.role==='p2'&&!G.netWasJoin)||netEntsPeer()) return 0;   // v23.52 (arcade28): a player 2 that took the raid over runs the waves
'@

SubRx @'
      pack=Math.min(6,2+Math.floor(tier/2)), men, live, q, c, n, i, e, s, kd, kinds, made=0;
'@ @'
      pack=Math.min(6,2+Math.floor(tier/2)), men, live, q, c, n, i, e, s, kd, kinds, made=0;
  // v28.xx (cw-cx-finalrush): faster waves and one extra machine; breathers, safe spawn positions and called rings still hold.
  var rush=arcadeRushOn();
  if(rush){ iv*=0.8; cap+=2; pack++; }
'@

SubRx @'
    s=arcadeWaveBody(men,q,c); kd=kinds[Math.floor(Math.random()*kinds.length)];
'@ @'
    s=arcadeWaveBody(men,q,c); kd=kinds[Math.floor(Math.random()*kinds.length)];
    if(rush&&i===n-1) kd=(Math.random()<0.5)?'crawler':'sentry';   // v28.xx (cw-cx-finalrush): the extra body is always a machine.
'@

SubRx @'
  if(hot) n=Math.round(n*HOT_KILLX);
  try{ arcadeBmKill(s.n,x,y); }catch(_bmk){}   // v23.xx (his answer 20): the best streak and the longest shot
'@ @'
  if(hot) n=Math.round(n*HOT_KILLX);
  if(arcadeRushOn()) n=Math.round(n*1.05);   // v28.xx (cw-cx-finalrush): kill SP only, after streak and hot ground, in either window.
  try{ arcadeBmKill(s.n,x,y); }catch(_bmk){}   // v23.xx (his answer 20): the best streak and the longest shot
'@

SubRx @'
var VER='35.82';
'@ @'
var VER='35.83';
'@

$pat = "(?m)^  now:'v35\.82:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v35.83: At 90 seconds the two player demo calls final rush. Kills pay 1.05x SP; wave intervals shorten 20 percent and each pack gains one machine with two more nearby slots. Solo demo and career keep their pacing. Playtest watch: both windows should announce once at 1:30 and a fresh sentry kill should pay 105 sp; breathers and called extraction rings must still hold the waves. Check 35.83 fails on v35.82',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
