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

# CAREER OFFERS EASY AFTER THREE DEATHS (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
function easyDmgMul(){ return (typeof ARCADE==='object'&&ARCADE&&ARCADE.easy&&G&&G.arcade)?EASY_MUL:1; }
'@ @'
function easyDmgMul(){ return ((typeof ARCADE==='object'&&ARCADE&&ARCADE.easy&&G&&G.arcade)||(G&&G.easyC&&!G.arcade))?EASY_MUL:1; }   // v28.xx (cw-easycareer): and a career raid where he said yes to the offer
'@

SubRx @'
function easyLive(){ return !!(typeof ARCADE==='object'&&ARCADE&&ARCADE.on&&ARCADE.easyAsk&&G&&G.arcade&&!G.over&&!G.sim); }
'@ @'
function easyLive(){ return !!(typeof ARCADE==='object'&&ARCADE&&ARCADE.easyAsk&&G&&!G.over&&!G.sim&&((ARCADE.on&&G.arcade)||(G.carAsk&&!G.arcade))); }   // v28.xx (cw-easycareer): the card also lives in a career raid that asked
'@

SubRx @'
    ARCADE.easy=1; try{ say('Easy mode on','info'); }catch(_es){}

'@ @'
    if(G&&G.carAsk&&!G.arcade) G.easyC=1; else ARCADE.easy=1;   // v28.xx (cw-easycareer): a career yes lives on this raid, the demo yes on the run
    try{ say('Easy mode on','info'); }catch(_es){}
'@

SubRx @'
function easyAnswer(yes){

'@ @'
// v28.xx (cw-easycareer), HIS ANSWER (2026-10-18, 2.90 b): "Career offers Forgiving on a card after a few deaths, the same offer as the demo." The profile counts deaths in a row
// (P.dieRun, an extraction clears it); on the third the next career raid puts the same yes or no card up (Y or A, N or B), asked once per streak.
// Yes is the same 30 percent less damage and free medkit for that raid. Not asked in the demo, and not when Forgiving is already on in Settings.
function easyCareerNote(how){
  if(!P||(typeof ARCADE==='object'&&ARCADE&&ARCADE.on)) return;
  P.dieRun=(how==='dead')?((P.dieRun|0)+1):((how==='extract')?0:(P.dieRun|0));
}
function easyCareerAsk(g){
  if(!g||g.sim||g.arcade||!P||(typeof ARCADE==='object'&&ARCADE&&ARCADE.on)||typeof ARCADE!=='object'||!ARCADE) return false;
  if((P.dieRun|0)<3||!(CFG.eDmg>=1)) return false;
  P.dieRun=0; g.carAsk=1; ARCADE.easyAsk={at:Date.now()};
  return true;
}
function easyAnswer(yes){

'@

SubRx @'
  G.over=how;
  if(NET.on&&!G.sim){ try{ netScoreSend
'@ @'
  G.over=how;
  if(!G.sim){ try{ easyCareerNote(how); }catch(_ecn){} }   // v28.xx (cw-easycareer): deaths in a row, for the career easy offer
  if(NET.on&&!G.sim){ try{ netScoreSend
'@

SubRx @'
  else if(G&&!G.sim&&CAREER_ON) careerPostBuild(G);   // v24.xx (feat0h1): every other raid from the Undercroft is a CAREER raid   // v23.21 (arcade2): an arcade raid is this same build made endless, with a random kit (the arcade section)
'@ @'
  else if(G&&!G.sim&&CAREER_ON) careerPostBuild(G);   // v24.xx (feat0h1): every other raid from the Undercroft is a CAREER raid   // v23.21 (arcade2): an arcade raid is this same build made endless, with a random kit (the arcade section)
  if(G&&!G.sim&&!G.arcade){ try{ easyCareerAsk(G); }catch(_eca){} }   // v28.xx (cw-easycareer): the career easy offer after a few deaths
'@

SubRx @'
    if(typeof ARCADE==='object'&&ARCADE&&ARCADE.on){ try{ arcadeKeyAtt(e); }catch(_ak){} return; }   // v23.24 (arcade5): in the arcade a press drops the host in
'@ @'
    if(typeof G!=='undefined'&&G&&G.carAsk&&easyLive()){ try{ if(easyKey(e)) return; }catch(_eck){} }   // v28.xx (cw-easycareer): Y or N answers the career easy card
    if(typeof ARCADE==='object'&&ARCADE&&ARCADE.on){ try{ arcadeKeyAtt(e); }catch(_ak){} return; }   // v23.24 (arcade5): in the arcade a press drops the host in
'@

SubRx @'
  if(typeof ARCADE==='object'&&ARCADE&&ARCADE.on&&easyLive()){

'@ @'
  if(typeof ARCADE==='object'&&ARCADE&&easyLive()){   // v28.xx (cw-easycareer): the demo and a career raid that asked

'@

SubRx @'
  if(G.arcade){ try{ arcadeHud(); }catch(_ahd){} }   // v23.23 (arcade4): the arcade layer, the EXTRACTED! banner
'@ @'
  if(G.arcade){ try{ arcadeHud(); }catch(_ahd){} }   // v23.23 (arcade4): the arcade layer, the EXTRACTED! banner
  if(G.carAsk&&!G.arcade){ try{ easyHud(); }catch(_ehc){} }   // v28.xx (cw-easycareer): the career easy card
'@

SubRx @'
var VER='32.22';
'@ @'
var VER='32.23';
'@

$pat = "(?m)^  now:'v32\.22:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v32.23: Three deaths in a row in Career, then the next raid shows the easy yes or no card. Yes gives 30 percent less damage and a free medkit for that raid. Check 32.23 fails on v32.22',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
