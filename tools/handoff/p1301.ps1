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

# MY OWN DEFECT, FROM LAST NIGHT, FOUND BY SWEEPING HIS BAKED EDITS AGAINST THE GAME.
#
# HE REWROTE THE BAR BLURB. His text for it is four words, and it is in the baked map
# keyed on the sentence the game printed. The replacement is looked up on the WHOLE
# rendered string, exact match.
#
# v12.98 CHANGED THAT SENTENCE. I added two words to it and appended a live total to
# the end of the same string. Both were right on their own terms, and together they
# stopped the lookup matching, so his wording silently vanished off that screen. He
# would have found it by walking up to the bar and seeing the game's words where his
# had been.
#
# THE RULE THIS BREAKS, and it is worth writing down: A LINE HE HAS EDITED IS A KEY.
# Nothing may be concatenated onto it. A live number belongs in its own string, in its
# own element, where changing it cannot cost him a sentence.
#
# So the blurb goes back to the exact sentence he keyed on, word for word, and the
# live total moves to its own line under it. "Ten of anything" was a clarification
# rather than a correction, since the gate already counts ten of anything after
# v12.98; the sentence was true as it stood and is restored as it stood.
SubRx @'
    'No tab, no credit. Every dose stacks on the last, and the bar cuts you off at ten of anything. While a dose is in your blood, every XP a raid pays you is '+(Math.round(buzzXpPer()*1000)/10)+'% more per dose.'+
    // v12.98: the live total, once, from the function that pays it. It used to be
    // printed per drink on each row, where two rows read as a sum nothing honours.
    (buzzTotal()?('  IN YOUR BLOOD NOW: '+buzzTotal()+' dose'+(buzzTotal()===1?'':'s')+', RAID XP +'+buzzXpPct()+'%.'):'');
'@ @'
    // v13.01: WORD FOR WORD AS HE EDITED IT. This sentence is a key in his baked text
    // map, matched whole, so the two words v12.98 added to it and the total v12.98
    // appended to it both broke the lookup and took his wording off the screen. The
    // gate counts ten of anything now, so the sentence was true as it stood.
    'No tab, no credit. Every dose stacks on the last, and the bar cuts you off at ten. While a dose is in your blood, every XP a raid pays you is '+(Math.round(buzzXpPer()*1000)/10)+'% more per dose.';
  // v13.01: THE LIVE TOTAL IS ITS OWN STRING, in its own element, because a number
  // that moves must never be concatenated onto a line he has edited.
  var _bnow=document.getElementById('bar_now');
  if(_bnow) _bnow.textContent=buzzTotal()
    ? ('In your blood now: '+buzzTotal()+' dose'+(buzzTotal()===1?'':'s')+', RAID XP +'+buzzXpPct()+'%.')
    : '';
'@

SubRx @'
  <div class="msub" id="bar_line"></div>
'@ @'
  <div class="msub" id="bar_line"></div>
  <div class="msub" id="bar_now" style="color:#d98aff;font-weight:700"></div>
'@

# NEW IN.
SubRx @'
  'THE UNDERCROFT STOPS HITCHING ON EVERY CLICK.
'@ @'
  'THE WORDS YOU WROTE FOR THE BAR ARE BACK. The line you rewrote is matched whole, and the build before this one added two words to it and put a live total on the end of the same line, so your wording silently stopped appearing. The sentence is back exactly as you edited it and the total is its own line underneath.',
  'THE UNDERCROFT STOPS HITCHING ON EVERY CLICK.
'@

# STAMPS.
SubRx @'
var VER='13.00';
'@ @'
var VER='13.01';
'@
SubRx @'
var WHATSNEW_VER='13.00';
'@ @'
var WHATSNEW_VER='13.01';
'@
$cnt=([regex]::Matches($s,"now:'v13\.00:[^']*'")).Count
if($cnt -ne 1){ throw "DEVNOW v13.00 matched $cnt times" }
$s=[regex]::Replace($s,"now:'v13\.00:[^']*'",{ param($m) "now:'v13.01: my own defect, from the build before this one, found by sweeping his baked text edits against what the game actually renders. He rewrote the bar blurb; his text for it is four words, and it sits in the baked map keyed on the sentence the game printed, with the replacement looked up on the WHOLE rendered string by exact match. v12.98 changed that sentence: it added two words to it and appended a live total to the end of the same string, both right on their own terms, and together they stopped the lookup matching, so his wording silently vanished off that screen and he would have found it by walking up to the bar and seeing the game words where his had been. The rule this breaks is worth writing down: A LINE HE HAS EDITED IS A KEY, nothing may be concatenated onto it, and a live number belongs in its own string in its own element where changing it cannot cost him a sentence. The blurb goes back to the exact sentence he keyed on, word for word, and the live total moves to its own line under it; ten of anything was a clarification rather than a correction, since the gate already counts ten of anything after v12.98, so the sentence was true as it stood and is restored as it stood. Check 13.01 takes every key in his baked map that names a line this game still draws, renders that screen and requires his words to be what appears, and it names the bar line specifically; the control is that the live total is still shown and still correct, so restoring his sentence did not cost the number v12.98 added. Fails on v13.00.'" })
$n++

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count + 1
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
