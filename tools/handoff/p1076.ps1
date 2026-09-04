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

# ============ HIS TEN STASH LAYOUTS LOST THE BUTTON THAT PICKS THEM.
# ============
# ============ v7.66 was his order: "ten layouts and a button". v7.72 he chose 6
# ============ as the default. v9.98 tidied the stash screen down to five things
# ============ and the LAYOUT button went with the row it lived in, and its own
# ============ comment says so: "the arrangement stays at the default and the
# ============ other nine rules in the CSS are inert."
# ============
# ============ So nine of his ten layouts have been unreachable ever since, and
# ============ what he is left with is the widest arrangement in the file.
# ============
# ============ MEASURED ON THE REAL GAME at 1920x1080 with a sixty item stash:
# ============ layout 6 asks for columns at least 230 css pixels wide holding a
# ============ 56 pixel icon, the stash grid runs 2,322 pixels of content in a
# ============ 477 pixel box, and THREE CELLS ARE FULLY VISIBLE AT A TIME. The
# ============ only buttons on the screen are CLOSE, Sell all salvage and TAKE
# ============ THE FREEBIE KIT. There is no laybtn in the document at all.
# ============
# ============ The big cells are HIS PICK and they stay. What comes back is the
# ============ choice. It goes in Settings beside Text size rather than back onto
# ============ the stash screen he deliberately simplified, because it is a
# ============ display option and that is where the other one lives.
SubRx @'
    '<div class="row"><div style="flex:1"><b>Music</b><div class="hint">A faint 16-bit loop, five pieces, one picked at random each time you come back down. UNDERCROFT plays it, OFF is silence. The surface is deliberately silent either way.</div></div>'+
'@ @'
    // v10.76: his ten layouts got their picker back. v7.66 was "ten layouts and
    // a button"; v9.98 took the stash screen down to five things and the button
    // went with the row it sat in, leaving nine arrangements as dead CSS. This
    // is a display option, so it sits beside Text size rather than back on the
    // screen he simplified.
    '<div class="row"><div style="flex:1"><b>Stash layout</b><div class="hint">Ten arrangements of the stash and backpack grids. Lower numbers are roomier cells and fewer of them; higher numbers pack more items on screen. 6 is the default.</div></div>'+
    '<button id="set_layout" style="padding:6px 12px;min-width:110px">'+clamp(P.stashLayout||6,1,10)+' of 10</button></div>'+
    '<div class="row"><div style="flex:1"><b>Music</b><div class="hint">A faint 16-bit loop, five pieces, one picked at random each time you come back down. UNDERCROFT plays it, OFF is silence. The surface is deliberately silent either way.</div></div>'+
'@

SubRx @'
  document.getElementById('set_text').onclick=function(){
'@ @'
  // v10.76: cycles 1 to 10 and wraps, the same shape as the text size button
  // above it. applyStashLayout is the one writer of the attribute, so the stash
  // screen cannot disagree with what this says.
  var _sl=document.getElementById('set_layout');
  if(_sl) _sl.onclick=function(){
    P.stashLayout=(clamp(P.stashLayout||6,1,10)%10)+1;
    saveProfile();
    try{ applyStashLayout(); }catch(_e){}
    try{ renderHub(); }catch(_e2){}
    renderSettings();
  };
  document.getElementById('set_text').onclick=function(){
'@

SubRx @'
var VER='10.75';
'@ @'
var VER='10.76';
'@
SubRx @'
  now:'v10.75: the two warnings about an extraction point closing call it by the same letter the map does. They said "Extraction 3" while the map beside them drew EXTRACT A, B and C, so the one message that makes you change your plan named something that was not on the map.',
'@ @'
  now:'v10.76: your ten stash layouts have their picker back, in Settings beside the text size. The button that chose them was removed with the row it lived in, so for the last while nine of the ten were unreachable and the stash showed three items at a time.',
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
