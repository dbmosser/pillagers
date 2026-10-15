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

# THE CAREER LEADERBOARD ON THE RUN CARD (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
<div class="manifest" id="oc_party" style="display:none;margin-top:12px"></div>
'@ @'
<div class="manifest" id="oc_party" style="display:none;margin-top:12px"></div>
  <div id="oc_board"></div>
'@

SubRx @'
if(how==='extract'&&!G.sim){ try{ haulRevealStart(); }catch(_hrv){} }
'@ @'
try{ ocLbStart(how); }catch(_lbs){}   // v27.NN (cboard3): a CAREER card ends on the LEADERBOARD step
  if(how==='extract'&&!G.sim){ try{ haulRevealStart(); }catch(_hrv){} }
'@

SubRx @'
if(_oce&&_oce.classList.contains('on')&&haulRevealSkip()){ if(ev) ev.preventDefault(); return; }
'@ @'
if(_oce&&_oce.classList.contains('on')&&(haulRevealSkip()||ocLbNext())){ if(ev) ev.preventDefault(); return; }   // v27.NN (cboard3): the press after the haul reveal opens the LEADERBOARD step
'@

SubRx @'
PAD.aSpent=1; if(md.id==='outcome'&&haulRevealSkip()){} else if(!stashPadAct(PAD.focus)) PAD.focus.click();
'@ @'
PAD.aSpent=1; if(md.id==='outcome'&&haulRevealSkip()){} else if(md.id==='outcome'&&PAD.focus.id==='oc_btn'&&ocLbNext()){} else if(!stashPadAct(PAD.focus)) PAD.focus.click();
'@

SubRx @'
if(md.id==='outcome'&&haulRevealSkip()){} else if(back) back.click(); else md.classList.remove('on');
'@ @'
if(md.id==='outcome'&&haulRevealSkip()){} else if(md.id==='outcome'&&document.getElementById('oc_btn')) document.getElementById('oc_btn').click(); else if(back) back.click(); else md.classList.remove('on');   // v27.NN (cboard3): B on the card is the continue control whatever it reads now
'@

SubRx @'
document.getElementById('oc_btn').onclick=function(){
  HAUL_REV=null;
'@ @'
document.getElementById('oc_btn').onclick=function(){
  HAUL_REV=null; try{ ocLbEnd(); }catch(_lbe){}
'@

SubRx @'
function buildTags(){
'@ @'
// v27.NN (cboard3), HIS ORDER (2026-10-15): "career mode should still have a leaderboard that is shown after every match". THE LEADERBOARD STEP. After a CAREER extraction
// or death the run card has a second step in the same card (no second window): the ledger, then the haul reveal, then the LEADERBOARD. The continue control reads
// LEADERBOARD on the first step; a click on it, ENTER or the pad A advances (the first press while the tally or the reveal runs only lands it, as before), and on the
// board it is LOG RUN AND RETURN again. ESC, TAB and the pad B still close the card at once and log the run, from either step. The step shows the same board as the
// Undercroft (careerBoardView): this run teal and climbing into its rank, RANK #N OF M, NEW PERSONAL BEST for a number one, a pinned row for a run outside the top 20.
// Ranked by RAID SCORE. An abandon is not a run here and has no step. Each window shows its own save.
var OCLB=null;
function ocLbStart(how){
  var oc=document.getElementById('outcome'), b=document.getElementById('oc_btn'), host=document.getElementById('oc_board');
  OCLB=null;
  if(oc) oc.classList.remove('lbs');
  if(host) host.textContent='';
  if(b) b.textContent='Log run and return';
  if(!G||!G.career||G.sim||!G.careerLb||!(how==='extract'||how==='dead')) return false;
  OCLB={step:0,R:G.careerLb};
  if(b) b.textContent='Leaderboard';
  return true;
}
function ocLbEnd(){
  var oc=document.getElementById('outcome'), b=document.getElementById('oc_btn'), host=document.getElementById('oc_board');
  OCLB=null;
  if(oc) oc.classList.remove('lbs');
  if(host){ lbCountEnd(host); host.textContent=''; }
  if(b) b.textContent='Log run and return';
}
function ocLbNext(){
  var o=OCLB, oc=document.getElementById('outcome'), b=document.getElementById('oc_btn'), host=document.getElementById('oc_board'), win;
  if(!o||o.step||!oc||!host||!oc.classList.contains('on')) return false;
  o.step=1;
  careerBoardView(host,{row:o.R.row,rank:o.R.rank,inTop:o.R.inTop,best:o.R.best,anim:1});
  oc.classList.add('lbs');
  if(b) b.textContent='Log run and return';
  win=oc.querySelector('.ocwin'); if(win) win.scrollTop=0;
  try{ sndUi('ok'); }catch(_su){}
  return true;
}
(function(){
  var oc=document.getElementById('outcome');
  if(oc) oc.addEventListener('click',function(ev){
    var b=document.getElementById('oc_btn');
    if(ev.defaultPrevented||!ev.isTrusted||!OCLB||OCLB.step||!b||!(ev.target===b||b.contains(ev.target))) return;
    ev.preventDefault(); ev.stopPropagation(); ocLbNext();   // a real click on the continue control opens the board; the presses the game makes itself (ESC, pad B) close the card
  },true);
})();
careerStyle('ocbcss',
  '#outcome #oc_board{display:none;width:100%;margin-top:8px}'+
  '#outcome.lbs #oc_board{display:block}'+
  '#outcome.lbs .ocwin>*:not(#oc_title):not(#oc_sub):not(#oc_board):not(.ocacts){display:none}'+
  '#outcome.lbs #oc_copy{display:none}');
function buildTags(){
'@

SubRx @'
var VER='28.04';
'@ @'
var VER='28.05';
'@

$pat = "(?m)^  now:'v28\.04:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v28.05: A career run card now ends on your leaderboard, with the run you just played climbing into its rank. Check 28.05 fails on v28.04',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
