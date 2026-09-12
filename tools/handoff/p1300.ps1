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

# FINDING 13 OF THE 2026-09-11 AUDIT, and EVERY PLAYER PAYS IT, not just this machine.
# The watcher is armed unconditionally; only the click that opens the editor is gated.
#
# WHAT IT COSTS. The whole game is one file, and the style block and the entire program
# live INSIDE the element this walker is pointed at. To a text-node walker with no
# filter they are simply two more text nodes, each of them megabytes long. So every
# mutation under that element rewrites the labels on screen AND runs, over the whole
# program text: a whitespace-stripped copy to decide whether it is blank, a regular
# expression across the lot to pull out every number in the file, another full copy
# built from the pieces, and that multi-megabyte string used as a lookup key.
#
# WHEN. Every toast in the Undercroft, every time Credits or XP move, and every panel
# rebuild: packing, tagging junk, selling, dropping. The Undercroft is the screen he
# has called the ship blocker, and this is a hitch on almost every click in it.
#
# THE FEATURE IS FOR LABELS. A stylesheet and a program are not labels and can never
# be edited, so the walk should never have been looking at them. With the filter the
# cost tracks what is on screen instead of the size of the file.
#
# THE SWEEP AT THE OTHER END OF THIS FILE ALREADY KNOWS THE RULE: the font sweep skips
# SCRIPT, STYLE and CANVAS by name. This is the same rule in the place that needed it.
SubRx @'
  var w=document.createTreeWalker(root,NodeFilter.SHOW_TEXT,null,false), n, list=[], i;
'@ @'
  // v13.00, audit finding 13: NOT THE PROGRAM AND NOT THE STYLESHEET. The whole game
  // is one file and both of those live inside this element, so an unfiltered text-node
  // walk handed the whole program to the rewriter on every mutation: a full-source
  // whitespace strip, a full-source regular expression, another full copy, and a
  // multi-megabyte lookup key, on every toast, every credit and XP change and every
  // panel rebuild. They are not labels and can never be edited. The font sweep at the
  // other end of this file has skipped SCRIPT, STYLE and CANVAS by name for builds;
  // this is the same rule where it was actually costing something.
  var TXSKIP={SCRIPT:1,STYLE:1,NOSCRIPT:1,CANVAS:1,TEMPLATE:1};
  var w=document.createTreeWalker(root,NodeFilter.SHOW_TEXT,{
    acceptNode:function(nd){
      var pn=nd&&nd.parentNode;
      return (pn&&TXSKIP[pn.nodeName])?NodeFilter.FILTER_REJECT:NodeFilter.FILTER_ACCEPT;
    }
  },false), n, list=[], i;
'@

# NEW IN.
SubRx @'
  'ESC OUT OF AN EDIT BOX CLOSES THE EDIT BOX.
'@ @'
  'THE UNDERCROFT STOPS HITCHING ON EVERY CLICK. The pass that lets text be rewritten was reading the entire game as if it were a label, on every toast, every credit change and every panel rebuild, because the whole game is one file. It reads what is on screen now. Nothing you can see has changed.',
  'ESC OUT OF AN EDIT BOX CLOSES THE EDIT BOX.
'@

# STAMPS.
SubRx @'
var VER='12.99';
'@ @'
var VER='13.00';
'@
SubRx @'
var WHATSNEW_VER='12.99';
'@ @'
var WHATSNEW_VER='13.00';
'@
$cnt=([regex]::Matches($s,"now:'v12\.99:[^']*'")).Count
if($cnt -ne 1){ throw "DEVNOW v12.99 matched $cnt times" }
$s=[regex]::Replace($s,"now:'v12\.99:[^']*'",{ param($m) "now:'v13.00: finding 13 of the 2026-09-11 audit, and every player pays it rather than just this machine, because the watcher is armed unconditionally and only the click that opens the editor is gated. The whole game is one file, and the style block and the entire program live INSIDE the element the text walker is pointed at, so to a walker with no filter they are simply two more text nodes, each of them megabytes long; every mutation under that element rewrote the labels on screen AND ran, over the whole program text, a whitespace-stripped copy to decide whether it was blank, a regular expression across the lot to pull out every number in the file, another full copy built from the pieces, and that multi-megabyte string used as a lookup key. It fires on every toast in the Undercroft, every time Credits or XP move, and every panel rebuild, packing, tagging junk, selling and dropping, which is the screen he has called the ship blocker, so it is a hitch on almost every click in it. The feature is for labels: a stylesheet and a program are not labels and can never be edited, so the walk should never have been looking at them, and with the filter the cost tracks what is on screen instead of the size of the file. The sweep at the other end of the same file already knew the rule, skipping SCRIPT, STYLE and CANVAS by name; this is that rule in the place where it was costing something. Check 13.00 counts the text nodes the rewriter visits and requires none of them to belong to the program or the stylesheet, requires the total visited to be a screenful rather than a fileful, and controls that a real label on screen is still visited and still rewritten, so the filter has not blinded the feature it protects; fails on v12.99.'" })
$n++

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count + 1
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
