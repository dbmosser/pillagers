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

# WHAT IS NEW IS A PAUSE MENU BUTTON (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
    <button id="fbbtn" style="padding:8px 22px">FEEDBACK</button>
'@ @'
    <button id="fbbtn" style="padding:8px 22px">FEEDBACK</button>
    <!-- v27.xx (wnbutton), HIS ANSWER 37 (2026-10-13): the What's New card leaves the floor and is a button here -->
    <button id="wnbtn" style="padding:8px 22px">WHAT'S NEW</button>
'@

SubRx @'
#root #pausebox #fbbtn{
'@ @'
#root #pausebox #fbbtn, #root #pausebox #wnbtn{
'@

SubRx @'
<div class="outcome" id="outcome">
'@ @'
<!-- v27.xx (wnbutton), HIS ANSWER 37 (2026-10-13): THE WHAT'S NEW WINDOW, over the pause box. It lists the newest notes the card used to show on the Undercroft floor. -->
<div class="modal" id="wnmodal" style="align-items:center;justify-content:center;text-align:center">
  <h3>WHAT'S NEW</h3>
  <div class="msub" id="wnsub"></div>
  <div id="wnlist" style="max-width:min(900px,92%);max-height:56vh;overflow:auto;text-align:left;font-size:14px;line-height:1.6;color:var(--tx-1);margin:8px 0"></div>
  <button id="wnclose" data-esc="1" style="padding:8px 22px">CLOSE</button>
</div>
<div class="outcome" id="outcome">
'@

SubRx @'
var WNSEEN=0;
'@ @'
var WNSEEN=1;   // v27.xx (wnbutton), HIS ANSWER 37: the card no longer shows by itself on the floor (it was 0 until you walked off it); WHAT'S NEW in the pause box shows the notes. Left at 0 by a check, the old card still draws.
'@

SubRx @'
document.getElementById('fbbtn').onclick=function(){ fbOpen(); };
'@ @'
// v27.xx (wnbutton), HIS ANSWER 37 (2026-10-13): the What's New card leaves the title and the floor and becomes a WHAT'S NEW button on the pause menu. The window lists
// the newest notes (wnShort, his words through TX), eight of them, newest first; CLOSE or ESC shuts it. The card stamp (WHATSNEW_VER) and the list are unchanged.
function wnOpen(){
  var m=document.getElementById('wnmodal'), L=document.getElementById('wnlist'), S=document.getElementById('wnsub'), i, n, d;
  if(!m||!L) return false;
  L.textContent='';
  n=Math.min(8,WHATSNEW.length);
  for(i=0;i<n;i++){ d=document.createElement('div'); d.style.cssText='margin:0 0 .7em'; d.textContent=TX((i+1)+'. '+wnShort(WHATSNEW[i])); L.appendChild(d); }
  if(S) S.textContent='NEW IN '+verShown(WHATSNEW_VER,1);
  m.classList.add('on');
  try{ sndUi('open'); }catch(_su){}
  return true;
}
function wnClose(){
  var m=document.getElementById('wnmodal');
  if(m) m.classList.remove('on');
  return true;
}
document.getElementById('wnbtn').onclick=function(){ wnOpen(); };
document.getElementById('wnclose').onclick=function(){ wnClose(); };
document.getElementById('fbbtn').onclick=function(){ fbOpen(); };
'@

SubRx @'
var VER='27.92';
'@ @'
var VER='27.93';
'@

$pat = "(?m)^  now:'v27\.92:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v27.93: The What is New card is now a button on the pause menu, and no longer pops up by itself. Check 27.93 fails on v27.92',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
