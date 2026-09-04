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

# ============ THE ALPHA. FIRST TIME OUT is the one card that teaches the game,
# ============ and most of it is off the bottom of the screen.
# ============
# ============ Measured on the real game at 1920x1080 from an empty browser:
# ============ 18 cards, 1558 pixels of them, in a 912 pixel box. Eleven are on
# ============ screen and SEVEN ARE NOT. In the test fixture, whose box is
# ============ shorter at 664, ten are hidden. The scrollbar is 5 pixels wide and
# ============ nothing in the card says the list continues, so a new player has
# ============ no reason to think there is anything under the last line he can
# ============ see. What is down there: the Undercroft radio, the Pillbox that
# ============ never chases you, arranging the HUD, THE BULWARK AND ITS SLAB,
# ============ contracts that judge how you played, junk building the Mainframe,
# ============ and Settings being a station.
# ============
# ============ The three the card itself calls the ones that get people killed
# ============ are all above the fold, and so is calling extraction, so a friend
# ============ can still finish a raid. The Bulwark card is the one down there
# ============ worth a life.
# ============
# ============ Two columns is NOT the fix: halving the width roughly doubles each
# ============ card's height, so it buys nothing. What was missing is a way to
# ============ know. The card now counts what is below and says so, the line
# ============ scrolls the list when you click it, and the scrollbar is wide
# ============ enough to see. The count goes away when you reach the end.
SubRx @'
  .plist { overflow-y:auto; flex:1; padding:3px 0; }
  .plist::-webkit-scrollbar { width:5px; }
  .plist::-webkit-scrollbar-thumb { background:var(--steel-hi); }
'@ @'
  .plist { overflow-y:auto; flex:1; padding:3px 0; }
  .plist::-webkit-scrollbar { width:5px; }
  .plist::-webkit-scrollbar-thumb { background:var(--steel-hi); }
  /* v10.69: the briefing is the one card a new player has to finish reading, so
     its own bar is wide enough to notice and its own colour. */
  #primerlist::-webkit-scrollbar { width:12px; }
  #primerlist::-webkit-scrollbar-thumb { background:var(--amber); border-radius:6px; }
  .pmore { display:none; margin-top:6px; padding:6px 10px; cursor:pointer;
    font-size:14px; color:var(--amber); border:1px solid var(--steel-hi);
    border-radius:3px; text-align:center; }
  .pmore:hover { background:rgba(255,192,74,.08); }
  .pmore.show { display:block; }
'@

SubRx @'
  <div id="primerlist" class="plist"></div>
  <div style="display:flex;gap:10px;margin-top:10px;align-items:center">
'@ @'
  <div id="primerlist" class="plist"></div>
  <div id="primermore" class="pmore"></div>
  <div style="display:flex;gap:10px;margin-top:10px;align-items:center">
'@

SubRx @'
  host.innerHTML=html;
  var cb=document.getElementById('primernever');
  if(cb) cb.checked=!!P.primerOff;
}
function openPrimer(){
  renderPrimer();
  openModal('primermodal');
}
'@ @'
  host.innerHTML=html;
  var cb=document.getElementById('primernever');
  if(cb) cb.checked=!!P.primerOff;
  // v10.69: the list is taller than the box it sits in and a scrollbar alone is
  // not a signal, so the card says how many cards are still under the fold and
  // scrolls to them when the line is clicked.
  host.onscroll=primerCue;
  var mo=document.getElementById('primermore');
  if(mo) mo.onclick=function(){ host.scrollTop+=Math.max(120,host.clientHeight-60); primerCue(); };
}
// Counted off the rendered page rather than from the card list, because what is
// hidden depends on the height of the box and the size of the text, and both
// change with the window and with his text size dial.
function primerCue(){
  var host=document.getElementById('primerlist'), mo=document.getElementById('primermore');
  if(!host||!mo) return 0;
  var box=host.getBoundingClientRect(), n=0;
  for(var i=0;i<host.children.length;i++){
    if(host.children[i].getBoundingClientRect().top>=box.bottom-4) n++;
  }
  if(n>0){ mo.textContent=n+' more below. Click here, or scroll the list.'; mo.classList.add('show'); }
  else { mo.textContent=''; mo.classList.remove('show'); }
  return n;
}
function openPrimer(){
  renderPrimer();
  openModal('primermodal');
  // After the window is up, or every rectangle is zero and the count is a lie.
  primerCue();
}
'@

SubRx @'
var VER='10.68';
'@ @'
var VER='10.69';
'@
SubRx @'
  now:'v10.68: a gun you find in a raid goes into your empty second slot instead of shoving the gun out of your hands. With both slots full nothing changes: the gun you are holding is still the one it replaces.',
'@ @'
  now:'v10.69: FIRST TIME OUT tells you how much of it you have not read. Most of the briefing was under the fold behind a five pixel scrollbar, so a new player finished it without ever seeing the Bulwark, the Pillbox or the Mainframe.',
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
