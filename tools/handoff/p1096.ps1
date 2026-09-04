$ErrorActionPreference = 'Stop'
trap { Write-Output "FAILED: $_"; exit 1 }
$p = 'C:\claudecode\dark raiders\dark_raiders.html'
$s = [IO.File]::ReadAllText($p)
$n = 0
function SubRx([string]$old, [string]$new) {
  $pat = ($old -split "`n" | ForEach-Object { [regex]::Escape($_.TrimEnd("`r")) }) -join "\r?\n"
  $c = ([regex]::Matches($script:s, $pat)).Count
  if ($c -ne 1) { throw "regex matched $c times: $($old.Substring(0,[Math]::Min(70,$old.Length)))" }
  $script:s = [regex]::Replace($script:s, $pat, { param($m) $new })
  $script:n++
}

# ============ HIS NOTE 13: THE TWO CHOICES ON THE UNDERCROFT PAUSE SCREEN.
# ============
# ============ "pausing at the undercroft screen should give an option to
# ============ 'RETURN TO CHARACTER SELECTION' that takes the player back to the
# ============ title screen", then, correcting himself: "actually 'RETURN TO THE
# ============ UNDERCROFT' AND 'RETURN TO CHARACTER SELECTION' should be the 2
# ============ choices". 2026-09-04.
# ============
# ============ REPRODUCED with the box open on the floor: ONE button, reading
# ============ "Back to the Undercroft". There is no route from a running game
# ============ back to the character screen at all; the only ways to it are
# ============ booting the tab and switching save, which reloads the page.
# ============
# ============ THE FIX. The floor gets his two buttons, in his words. The first
# ============ is the resume button relabelled, because closing the box IS
# ============ returning to the Undercroft and a second button that did the same
# ============ thing would be a lie. The second puts the character screen back
# ============ up over the room, which is exactly what booting does in reverse,
# ============ so no reload and nothing is lost.
# ============
# ============ AND THE FRONT DOOR IS REFRESHED ON THE WAY BACK. It is written at
# ============ boot from the profile as it was then, so after a raid the name
# ============ line and the save list would both be stale. Rather than a second
# ============ copy of that wording, the boot code hands its own two refreshers
# ============ out through one file-scope hook.

# ---- 1. his second button
SubRx @'
    <button id="resumebtn" style="padding:8px 22px">Resume run</button>
'@ @'
    <button id="resumebtn" style="padding:8px 22px">Resume run</button>
    <!-- v10.96, HIS NOTE: the second of his two choices, shown on the floor and
         never in a raid. -->
    <button id="charselbtn" style="padding:8px 22px;display:none">RETURN TO CHARACTER SELECTION</button>
'@

# ---- 2. the hook the front door hangs its own refreshers on
SubRx @'
function togglePauseBox(on){
'@ @'
// v10.96: the character screen is written at boot, from the profile as it was
// then. Anything that shows it again later has to be able to bring it up to
// date, and the code that knows how is the boot code, so the boot code hands it
// out here rather than a second copy being written somewhere else.
var titleRefresh=null;
function togglePauseBox(on){
'@

# ---- 3. the two buttons, on the floor
SubRx @'
    var _rb=document.getElementById('resumebtn');
    if(_rb) _rb.textContent=_inRaid?'Resume run':'Back to the Undercroft';
'@ @'
    // v10.96, HIS NOTE: his two choices, in his words. Closing the box IS
    // returning to the Undercroft, so the resume button carries the first one; a
    // separate button that only closed the box would be two controls for one act.
    var _rb=document.getElementById('resumebtn');
    if(_rb) _rb.textContent=_inRaid?'Resume run':'RETURN TO THE UNDERCROFT';
    var _cs=document.getElementById('charselbtn');
    if(_cs) _cs.style.display=(_inRaid||_bleed)?'none':'';
'@

# ---- 4. what the second button does
SubRx @'
document.getElementById('resumebtn').onclick=function(){
'@ @'
// v10.96, HIS NOTE: back to the character screen without losing the character.
// The screen is an overlay over the room, which is how boot works in reverse, so
// there is no reload and nothing in memory is thrown away. The profile is
// written first so the save list on that screen, which reads storage rather than
// memory, shows what he has just earned.
document.getElementById('charselbtn').onclick=function(){
  if(G) return;                       // never from inside a raid
  var _pn=document.getElementById('pausenote');
  if(_pn) _pn.value='';               // a note on the floor has no raid to attach to
  try{ saveProfile(); }catch(_sp){}
  togglePauseBox(false);
  var _t=document.getElementById('title');
  if(_t) _t.classList.add('on');
  if(titleRefresh) try{ titleRefresh(); }catch(_tr){}
};
document.getElementById('resumebtn').onclick=function(){
'@

# ---- 5. the boot code hands out its refreshers. The name line becomes a
# ---- function so the pause box and the boot share one wording.
SubRx @'
    var sub=document.getElementById('titlesub');
    if(sub) sub.textContent=(P.runs>0)
      ? (P.pname+'  \u00b7  '+P.runs+' raid'+(P.runs===1?'':'s')+' logged  \u00b7  '+'$'+P.credits.toLocaleString()+' banked')
      : 'First time out. The Undercroft will walk you through it.';
'@ @'
    function subSync(){
      var sub=document.getElementById('titlesub');
      if(sub) sub.textContent=(P.runs>0)
        ? (P.pname+'  \u00b7  '+P.runs+' raid'+(P.runs===1?'':'s')+' logged  \u00b7  '+'$'+P.credits.toLocaleString()+' banked')
        : 'First time out. The Undercroft will walk you through it.';
    }
    subSync();
'@
SubRx @'
    document.getElementById('titlestart').onclick=go;
'@ @'
    document.getElementById('titlestart').onclick=go;
    // v10.96: everything this screen shows, brought up to date in one call.
    titleRefresh=function(){ subSync(); renderSlots(); };
'@

SubRx @'
var VER='10.95';
'@ @'
var VER='10.96';
'@
SubRx @'
  now:'v10.95: the loot pop font, your note. Traced every text draw in a raid, its HUD and the Undercroft: all of it was already the game font in one of five roles, except the world labels and the faint district numbers on the ground, which were set in Titan One, the title wordmark face. At fifteen pixels that reads as a slab, not a word. It was never the weight, it was a second typeface.',
'@ @'
  now:'v10.96: your two choices on the Undercroft pause screen. It had one button, Back to the Undercroft, and no route back to the character screen at all short of reloading the tab. It now reads RETURN TO THE UNDERCROFT and RETURN TO CHARACTER SELECTION, and the second one puts the character screen back up over the room with the name line and the save list brought up to date.',
'@
SubRx @'
  'THIS IS AN ALPHA. Things will break. When something does, the game writes it into your run report and tells you so; that report is how it gets fixed.',
'@ @'
  'THIS IS AN ALPHA. Things will break. When something does, the game writes it into your run report and tells you so; that report is how it gets fixed.',
  'PAUSING IN THE UNDERCROFT OFFERS TWO CHOICES: RETURN TO THE UNDERCROFT and RETURN TO CHARACTER SELECTION. The second takes you back to the front door without a reload and without losing anything, and the name line and save list there are brought up to date on the way. A raid pause is unchanged.',
'@
SubRx @'
var WHATSNEW_VER='10.95';
'@ @'
var WHATSNEW_VER='10.96';
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
