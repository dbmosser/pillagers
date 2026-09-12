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

# HIS NOTE, 2026-09-12: "need to be able to search bodies inside an extraction point
# without calling for extract."
#
# IT WAS A DELIBERATE RULE AND HE HAS OVERTURNED IT. The code refused to even LOOK for
# a container while he stood in a ring, and said why: "Standing inside an extraction
# ring, the BEACON owns E. A crate is never the more important thing to be doing while
# you are stood on the way out." So the prompt never appeared, and E always called.
# A man killed on the pad in front of him was unlootable and the game never said so.
#
# HIS CHOICE OF FIX, asked and answered: the beacon keeps E, and searching gets its own
# key. He raised a switch key first; Q is taken, it cycles throwables every raid, and a
# mode to be caught in during a thirty second boarding window is the wrong thing to add
# to the most time-pressured moment in the game. A second key costs nothing and is
# never surprising.
#
# X, BECAUSE IT IS THE ONLY THING FREE AND IT IS UNDER THAT HAND. Grep says zero uses.
# It searches ANYWHERE, not only on the pad, so the rule is one sentence rather than a
# special case: X searches what you are standing on, and E does too except on the way
# out, where E is the way out.
SubRx @'
  var near=null,nd=1e9;
  // Standing inside an extraction ring, the BEACON owns E. A crate is never the
  // more important thing to be doing while you are stood on the way out.
  var onPad=false;
  for(var zc=0;zc<G.zones.length;zc++) if(dist(p,G.zones[zc])<G.zones[zc].r){ onPad=true; break; }
  for(var c=0;c<G.containers.length&&!onPad;c++){
'@ @'
  var near=null,nd=1e9;
  // Standing inside an extraction ring, the BEACON owns E, and that has not changed.
  // v13.10, HIS NOTE: what HAS changed is that the ring no longer hides what is lying
  // in it. This scan used to stop dead on the pad, so nothing was found, no prompt was
  // drawn, and a man killed in front of him was unlootable with nothing on screen
  // saying why. The body is found now and says which key takes it; E still belongs to
  // the way out.
  var onPad=false;
  for(var zc=0;zc<G.zones.length;zc++) if(dist(p,G.zones[zc])<G.zones[zc].r){ onPad=true; break; }
  for(var c=0;c<G.containers.length;c++){
'@

SubRx @'
  G.nearContainer=near;
  if(near&&keys['KeyE']){
'@ @'
  G.nearContainer=near;
  // v13.10: X searches, anywhere. E searches too, except on the way out, where E is
  // the way out. One sentence, no mode, and nothing to be caught in.
  G.nearPad=onPad;
  if(near&&(keys['KeyX']||(keys['KeyE']&&!onPad))){
'@

SubRx @'
        var _ft='['+keyLabel('KeyE','E')+'] SEARCH '+nc2.fallen.toUpperCase();
'@ @'
        var _ft='['+keyLabel(G.nearPad?'KeyX':'KeyE',G.nearPad?'X':'E')+'] SEARCH '+nc2.fallen.toUpperCase();
'@

SubRx @'
else if(nc2.tag) ctx.fillText('['+keyLabel('KeyE','E')+'] SEARCH '+String(nc2.tag).toUpperCase(),s.x,s.y);
      else ctx.fillText('['+keyLabel('KeyE','E')+'] SEARCH '+(nc2.mercSrc?(String(nc2.mercSrc.name).toUpperCase()+"'S BACKPACK"):((nc2.type==='safe'&&nc2.camp)?'STRONGBOX':nc2.type.toUpperCase())),s.x,s.y);
'@ @'
else if(nc2.tag) ctx.fillText('['+keyLabel(G.nearPad?'KeyX':'KeyE',G.nearPad?'X':'E')+'] SEARCH '+String(nc2.tag).toUpperCase(),s.x,s.y);
      else ctx.fillText('['+keyLabel(G.nearPad?'KeyX':'KeyE',G.nearPad?'X':'E')+'] SEARCH '+(nc2.mercSrc?(String(nc2.mercSrc.name).toUpperCase()+"'S BACKPACK"):((nc2.type==='safe'&&nc2.camp)?'STRONGBOX':nc2.type.toUpperCase())),s.x,s.y);
'@

# The browser must not act on it, the same as every other raid key.
SubRx @'
  if(['Tab','Space','KeyE','KeyR','KeyF','KeyG','KeyQ','KeyI','KeyM','KeyP','KeyH','KeyV','KeyC','Backspace','ControlLeft','ShiftLeft'].indexOf(code)>=0) if(ev) ev.preventDefault();
'@ @'
  if(['Tab','Space','KeyE','KeyR','KeyF','KeyG','KeyQ','KeyI','KeyM','KeyP','KeyH','KeyV','KeyC','KeyX','Backspace','ControlLeft','ShiftLeft'].indexOf(code)>=0) if(ev) ev.preventDefault();
'@

# And the list he reads under H says so.
SubRx @'
['WORLD',[['E','search / call for extraction'],['M','map'],['H','cycle this list'],['P','pause']]],
'@ @'
['WORLD',[['E','search / call for extraction'],['X','search, even on the way out'],['M','map'],['H','cycle this list'],['P','pause']]],
'@

# NEW IN.
SubRx @'
  'YOU ARE NOT CARRYING A GUN AROUND THE UNDERCROFT.
'@ @'
  'X SEARCHES A BODY LYING IN AN EXTRACTION POINT. Standing on the way out, the game refused to even look for what was lying there: no prompt, and E always called the beacon, so a man killed in front of you was unlootable and nothing said why. E is still the way out. X searches whatever you are standing on, anywhere, and the prompt names the key it will take.',
  'YOU ARE NOT CARRYING A GUN AROUND THE UNDERCROFT.
'@

# STAMPS.
SubRx @'
var VER='13.08';
'@ @'
var VER='13.10';
'@
SubRx @'
var WHATSNEW_VER='13.08';
'@ @'
var WHATSNEW_VER='13.10';
'@
$cnt=([regex]::Matches($s,"now:'v13\.08:[^']*'")).Count
if($cnt -ne 1){ throw "DEVNOW v13.08 matched $cnt times" }
$s=[regex]::Replace($s,"now:'v13\.08:[^']*'",{ param($m) "now:'v13.10: his note of 2026-09-12, need to be able to search bodies inside an extraction point without calling for extract. It was a deliberate rule and he has overturned it: the code refused to even LOOK for a container while he stood in a ring, and said why, that standing inside an extraction ring the BEACON owns E and a crate is never the more important thing to be doing while you are stood on the way out. So the prompt never appeared and E always called, and a man killed on the pad in front of him was unlootable with nothing on screen saying why. His choice of fix, asked and answered: the beacon keeps E and searching gets its own key. He raised a switch key first, and Q is taken because it cycles throwables every raid, and a mode to be caught in during a thirty second boarding window is the wrong thing to add to the most time-pressured moment in the game, while a second key costs nothing and is never surprising. X, because it is the only thing free and it is under that hand: grep says zero uses. It searches ANYWHERE rather than only on the pad, so the rule is one sentence rather than a special case: X searches what you are standing on, and E does too except on the way out, where E is the way out. The prompt names the key it will take, so there is nothing to remember. Check 13.10 stands the player on a ring with a searchable body under him and requires the body to be found and the prompt to name X, requires X to start the search and E not to, and controls that off the pad E still searches and that E on the pad still calls the beacon; fails on v13.08 where the ring hides the body entirely.'" })
$n++

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count + 1
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
