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

# THE LAST RESORT WAS SILENT.
#
# On itch the game runs in an iframe. v13.20 stopped the report claiming a file
# download there and pointed the player at Copy report. Copy report on the
# outcome card has handled a refused clipboard honestly since v11.32: when both
# copy routes fail it says "Could not copy. The report is under Settings,
# Recorder." That sentence sends him HERE, to the Recorder Copy button.
#
# AND THIS BUTTON SAID NOTHING, EVER. It selected the text, called the async
# clipboard with no rejection handler, and returned. Copied, blocked, refused:
# the button looked identical in all three. So the one place a failed copy
# directs a player is the one place that cannot tell him whether it worked.
#
# THE LEGACY COPY GOES FIRST, WHILE THE CLICK IS STILL LIVE. A copy command needs
# the user's gesture, and the gesture is gone by the time an async clipboard
# promise has rejected, so a fallback that waits for the rejection is the least
# likely moment for it to work. The text is already selected; the command runs
# immediately; the async clipboard is only the second try.
#
# AND WHEN BOTH FAIL, THE TEXT STAYS SELECTED AND HE IS TOLD TO PRESS CTRL+C. A
# selected textarea can always be copied by hand inside any frame, so that is a
# path that cannot be blocked, which is the point of a last resort.
SubRx @'
document.getElementById('copybtn').onclick=function(){
  var ta=document.getElementById('exporttext');
  ta.select();
  if(navigator.clipboard&&navigator.clipboard.writeText) navigator.clipboard.writeText(ta.value);
  else document.execCommand('copy');
};
'@ @'
// v13.21: THE LAST RESORT SPEAKS. The outcome card sends a failed copy here by
// name, and this button used to answer copied, blocked and refused identically,
// with nothing. The legacy command runs first while the click is still a live
// gesture; the async clipboard is the second try; and when both are refused the
// report stays selected and he is told to press Ctrl+C, which no frame can block.
document.getElementById('copybtn').onclick=function(){
  var ta=document.getElementById('exporttext'), b=document.getElementById('copybtn'), was='Copy to clipboard';
  function show(t,ms){ b.textContent=t; setTimeout(function(){ b.textContent=was; },ms); }
  function done(){ show('Copied. Paste it to Daniel.',2600); }
  function failed(){ try{ ta.focus(); ta.select(); }catch(_f){} show('Copy blocked here. The report is selected: press Ctrl+C.',6000); }
  try{ ta.focus(); ta.select(); if(ta.setSelectionRange) ta.setSelectionRange(0,ta.value.length); }catch(_s){}
  var ok=false;
  try{ ok=!!document.execCommand('copy'); }catch(_e){ ok=false; }
  if(ok){ done(); return; }
  try{
    if(navigator.clipboard&&navigator.clipboard.writeText) navigator.clipboard.writeText(ta.value).then(done,failed);
    else failed();
  }catch(_c){ failed(); }
};
'@

SubRx @'
var VER='13.20';
'@ @'
var VER='13.21';
'@

$pat = "(?m)^  now:'v13\.20:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v13.21: THE LAST RESORT WAS SILENT. On itch the game runs in an iframe, v13.20 stopped the report claiming a file download there and pointed the player at Copy report, and the outcome card Copy report has handled a refused clipboard honestly since v11.32, saying when both routes fail that the report is under Settings, Recorder. That sentence sends him to the Recorder Copy button, and THAT BUTTON SAID NOTHING, EVER: it selected the text, called the async clipboard with no rejection handler and returned, so copied, blocked and refused all looked identical, and the one place a failed copy directs a player was the one place that could not tell him whether it worked. The legacy copy command now runs FIRST, while the click is still a live gesture, because a copy command needs the gesture and the gesture is gone by the time an async clipboard promise has rejected, so a fallback that waits for the rejection runs at the moment least likely to work; the async clipboard is the second try. When both fail, the report stays selected and he is told to press Ctrl+C, because a selected textarea can be copied by hand inside any frame, which makes it a path nothing can block, and that is what a last resort is for. Reproduced with the instrument check 11.32 already uses, the clipboard hidden and the copy command stubbed so the check stays synchronous: on v13.20 the button text does not change whether the copy succeeds or is refused. NOT BUILT, RECORDED: the outcome card itself still tries the async clipboard before the legacy command, so on itch its own fallback also runs after the gesture has expired; that cannot be reproduced without a real click inside a real cross-origin frame, and it is guarded by checks 11.32 and 11.65, so it waits for evidence rather than a theory',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
