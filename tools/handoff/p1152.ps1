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

# HIS NOTE, 2026-09-05: "credits and xp should be shown at all times in the
# upper right hand corner ... including in raids and in the undercroft."
# Today credits are a big amber figure on the stash screen's top row, XP is a
# small line at its top left, the floor prints both in grey micro text at the
# top LEFT, and a raid shows neither. One fixed element now sits in the upper
# right of the window, above every screen and window and below the item menu
# and the drag ghost, in the band above the raid's CONDITIONS box (which starts
# at LH(30)). It is written only when a figure changes: from saveProfile, which
# every path that moves credits or XP already calls, and from the frame loop.
# The stash screen's own credits figure is retired (one readout, one corner)
# and its top row keeps clear of the corner so CLOSE stays reachable.

# 1. STYLE.
SubRx @'
  .credits small{ font-size:10.5px; color:var(--ash); letter-spacing:.28em; display:block; font-weight:400; }
'@ @'
  .credits small{ font-size:10.5px; color:var(--ash); letter-spacing:.28em; display:block; font-weight:400; }
  /* v11.52, HIS NOTE: credits and XP in the upper right, at all times. z 9000 puts
     it above every screen (10), pause box (35), card (40) and window (60), and
     below the item menu (12000) and the drag ghost (9999). 24px tall at top 4px,
     inside the band above the raid's CONDITIONS box, which starts at LH(30). */
  #topright{ position:fixed; top:4px; right:16px; height:24px; line-height:24px; z-index:9000; pointer-events:none;
    font-family:'Rubik',system-ui,sans-serif; font-weight:800; font-size:15px; color:var(--amber); white-space:nowrap; text-align:right; }
  #topright small{ font-size:9.5px; color:var(--ash); letter-spacing:.24em; font-weight:400; margin-left:5px; margin-right:14px; }
  #topright small:last-child{ margin-right:0; }
  .toprow{ padding-right:270px; }   /* v11.52: the stash screen's top row keeps clear of the corner readout, so CLOSE stays reachable */
  #credits{ display:none; }         /* v11.52: the corner readout replaces the stash screen's own credits figure */
'@

# 2. THE ELEMENT, outside every screen so no screen's display state hides it.
SubRx @'
<div class="screen" id="hub">
  <div class="toprow">
'@ @'
<div id="topright"></div>
<div class="screen" id="hub">
  <div class="toprow">
'@

# 3. THE WRITER, and the save hook.
SubRx @'
function saveProfile(){ P.cfg=CFG; P.cfgv=17; storeSet(JSON.stringify(P));
  var _mOpen=document.querySelector('.modal.on');
'@ @'
// v11.52, HIS NOTE: credits and XP shown at all times in the upper right, in
// the Undercroft and in a raid. One element, rewritten only when a figure
// changes, so the frame loop can call it for free.
var _trLast='';
function syncTopRight(){
  var el=document.getElementById('topright'); if(!el) return;
  var c=(P.credits||0).toLocaleString(), x=(P.xp||0).toLocaleString(), s=c+'|'+x;
  if(s===_trLast) return;
  _trLast=s;
  el.innerHTML=c+' <small>CREDITS</small> '+x+' <small>XP</small>';   // spaces, so the text reads right when copied
}
function saveProfile(){ P.cfg=CFG; P.cfgv=17; storeSet(JSON.stringify(P));
  try{ syncTopRight(); }catch(_tr){}   // v11.52: every path that moves credits or XP saves
  var _mOpen=document.querySelector('.modal.on');
'@

# 4. THE FRAME LOOP, for anything that moves a figure without saving, and for boot.
SubRx @'
function loop(ts){
  requestAnimationFrame(loop);
'@ @'
function loop(ts){
  requestAnimationFrame(loop);
  try{ syncTopRight(); }catch(_tr2){}   // v11.52: a string compare per frame, a DOM write only on change
'@

# STAMPS.
SubRx @'
var VER='11.51';
'@ @'
var VER='11.52';
'@
SubRx @'
var WHATSNEW_VER='11.51';
'@ @'
var WHATSNEW_VER='11.52';
'@
SubRx @'
  'THIS IS AN ALPHA. Things will break. When something does, the game writes it into your run report and tells you so; that report is how it gets fixed.',
'@ @'
  'THIS IS AN ALPHA. Things will break. When something does, the game writes it into your run report and tells you so; that report is how it gets fixed.',
  'YOUR CREDITS AND XP ARE IN THE TOP RIGHT CORNER, ALWAYS. In the Undercroft, in a raid, under every window. The stash screen no longer prints its own credits figure; the corner has it.',
'@
$cnt=([regex]::Matches($s,"now:'v11\.51:[^']*'")).Count
if($cnt -ne 1){ throw "DEVNOW v11.51 matched $cnt times" }
$s=[regex]::Replace($s,"now:'v11\.51:[^']*'",{ param($m) "now:'v11.52: HIS NOTE of 2026-09-05, credits and XP shown at all times in the upper right, in the Undercroft and in a raid. One fixed element (#topright, z 9000) in the band above the CONDITIONS box, written from saveProfile and the frame loop only when a figure changes; the stash screen retires its own credits figure and its top row keeps clear of the corner. Check 11.52 reads the element in the Undercroft and in a raid, requires position, size, both figures and both labels, clearance from the CONDITIONS box in screen space, and that a changed credit figure is shown.'" })
$n++

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count + 1
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
