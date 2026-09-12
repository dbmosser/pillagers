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

# THE GUARD FOR WHAT v13.01 CAUGHT BY HAND. Nothing in this build changes the game;
# it gives the harness one thing it did not have, which is the ability to see his
# edits.
#
# THE PROBLEM. His wording is applied by exact match on a whole rendered sentence.
# Reword that sentence anywhere and his version stops appearing, silently: no error,
# no log line, nothing red. v12.98 did it and only a hand sweep found it at v13.01.
#
# WHY A SOURCE SEARCH CANNOT DO THIS. Most of these lines are assembled at run time
# out of pieces, so the finished sentence exists only once a panel has been drawn. The
# only honest instrument is to draw the panels and read them.
#
# WHAT THE HARNESS NEEDED. Opening a panel means finding its element, adding the class
# and calling its own renderer, and the renderers live inside the closure where a check
# can reach them but nothing else can. This is a list of the panels that can be drawn
# without a raid, with the renderer for each, so a check can walk them. It draws
# nothing on its own; it is a table.
SubRx @'
var TXBUSY=0, TXOBS=null;
'@ @'
// v13.02: THE PANELS A CHECK CAN DRAW WITHOUT A RAID, so his own wording can be swept
// against what the game actually renders. Added because v12.98 reworded a line he had
// edited and deleted his version of it without a sound, and only a hand sweep at
// v13.01 found it. Each entry is a panel element and the function that fills it; the
// table draws nothing by itself.
var TXPANELS=[
  {id:'barmodal',      fn:function(){ renderBar(); }},
  {id:'settingsmodal', fn:function(){ renderSettings(); }},
  {id:'tradermodal',   fn:function(){ renderShop(); }},
  {id:'termsmodal',    fn:function(){ renderTerms(); }},
  {id:'carrymodal',    fn:function(){ renderCarry(); }},
  {id:'gamblemodal',   fn:function(){ renderGamble(); }}
];
var TXBUSY=0, TXOBS=null;
'@

# NEW IN.
SubRx @'
  'THE WORDS YOU WROTE FOR THE BAR ARE BACK.
'@ @'
  'THE GAME NOW CHECKS THAT THE WORDS YOU WROTE STILL APPEAR. Your wording is matched against a whole sentence, so rewording that sentence anywhere used to delete your version with no warning at all. Six screens are now swept every build, and any screen showing the original of a line you rewrote is a failure.',
  'THE WORDS YOU WROTE FOR THE BAR ARE BACK.
'@

# STAMPS.
SubRx @'
var VER='13.01';
'@ @'
var VER='13.02';
'@
SubRx @'
var WHATSNEW_VER='13.01';
'@ @'
var WHATSNEW_VER='13.02';
'@
$cnt=([regex]::Matches($s,"now:'v13\.01:[^']*'")).Count
if($cnt -ne 1){ throw "DEVNOW v13.01 matched $cnt times" }
$s=[regex]::Replace($s,"now:'v13\.01:[^']*'",{ param($m) "now:'v13.02: the guard for what v13.01 caught by hand, and nothing in this build changes the game. His wording is applied by exact match on a whole rendered sentence, so rewording that sentence anywhere stops his version appearing, silently: no error, no log line, nothing red. v12.98 did exactly that and only a hand sweep found it at v13.01. A source search cannot do this job, because most of these lines are assembled at run time out of pieces, so the finished sentence exists only once a panel has been drawn, and the only honest instrument is to draw the panels and read them. Opening a panel means finding its element, adding the class and calling its own renderer, and the renderers live inside the closure where a check can reach them and nothing else can, so this build adds one table naming the panels that can be drawn without a raid and the renderer for each; the table draws nothing by itself. Check 13.02 walks that table, draws each panel, drives the pass that applies his wording, and requires that no screen shows the ORIGINAL of a line he has rewritten while his replacement is absent from it, which is the defect stated without naming any line: a key visible in the raw is an edit that is not landing. The control is that the sweep really does see his words, by requiring at least one of his replacements to be found across those screens, so a sweep that rendered nothing would fail rather than pass silently; fails on v13.01, where the table it walks does not exist.'" })
$n++

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count + 1
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
