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

# LEADERBOARD IN THE UNDERCROFT PAUSE BOX (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
<button id="pausesetbtn" style="padding:8px 22px">Settings</button>
'@ @'
<button id="pausesetbtn" style="padding:8px 22px">Settings</button>
    <!-- v27.NN (cboard4), HIS ORDER (2026-10-15): the CAREER LEADERBOARD, on the Undercroft floor only (a raid has its own run card) -->
    <button id="lbbtn" style="padding:8px 22px">LEADERBOARD</button>
'@

SubRx @'
#root #pausebox #fbbtn, #root #pausebox #wnbtn{
'@ @'
#root #pausebox #fbbtn, #root #pausebox #wnbtn, #root #pausebox #lbbtn{
'@

SubRx @'
<div class="outcome" id="outcome">
'@ @'
<!-- v27.NN (cboard4), HIS ORDER (2026-10-15): THE LEADERBOARD WINDOW, over the pause box on the Undercroft floor: the board the run card ends on (careerBoardView), with no run highlighted. -->
<div class="modal" id="lbmodal" style="align-items:center;justify-content:center;text-align:center">
  <div id="lbhost" style="width:min(860px,92%);max-height:70vh;overflow:auto;margin:6px 0 10px"></div>
  <button id="lbclose" data-esc="1" style="padding:8px 22px">CLOSE</button>
</div>
<div class="outcome" id="outcome">
'@

SubRx @'
document.getElementById('wnclose').onclick=function(){ wnClose(); };
'@ @'
document.getElementById('wnclose').onclick=function(){ wnClose(); };
function lbOpen(){
  var m=document.getElementById('lbmodal'), h=document.getElementById('lbhost');
  if(!m||!h) return false;
  careerBoardView(h,{});
  m.classList.add('on');
  try{ sndUi('open'); }catch(_su){}
  return true;
}
function lbClose(){
  var m=document.getElementById('lbmodal'), h=document.getElementById('lbhost');
  if(m) m.classList.remove('on');
  if(h) h.textContent='';
  return true;
}
document.getElementById('lbbtn').onclick=function(){ lbOpen(); };
document.getElementById('lbclose').onclick=function(){ lbClose(); };
'@

SubRx @'
if(_cs&&_arcP) _cs.style.display='none';
'@ @'
if(_cs&&_arcP) _cs.style.display='none';
    var _lbb=document.getElementById('lbbtn'); if(_lbb) _lbb.style.display=(_inRaid||_bleed||_arcP)?'none':'';   // v27.NN (cboard4): the LEADERBOARD button is the floor's
'@

SubRx @'
var VER='28.07';
'@ @'
var VER='28.08';
'@

$pat = "(?m)^  now:'v28\.07:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v28.08: The Undercroft pause box has a LEADERBOARD button. Check 28.08 fails on v28.07',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
