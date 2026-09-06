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

# HIS NOTE, 2026-09-06: "you should have to hold the craft button for just a
# moment (1s?) to craft the item and the button itself should act like a status
# bar that fills up". The hold is a whole second of commitment on a button that
# spends materials, and the button is its own bar so there is nothing new on
# screen to read. The clock is advanced by the frame loop rather than by wall
# time, so it is the same clock everything else in the game runs on and a check
# can step it.

# 1. THE HOLD ITSELF, beside the panel that draws the button.
SubRx @'
function renderCraftDetail(rows){
'@ @'
// v11.75, HIS NOTE: hold the button for a moment, and the button is the bar.
// One second of commitment before anything is spent, and a fill he can watch
// so the wait is legible rather than a dead press. Stepped by the frame loop,
// not by wall time.
var CRAFT_HOLD=1.0;
var craftHold=null;
function craftHoldPaint(b,f){
  if(!b) return;
  var pct=Math.round(clamp(f,0,1)*100);
  // Only the image, so the button keeps its own colour underneath and an
  // untouched button looks exactly as it did.
  b.style.backgroundImage=pct?('linear-gradient(to right, rgba(255,192,74,.55) '+pct+'%, rgba(0,0,0,0) '+pct+'%)'):'';
}
function craftHoldCancel(){
  if(!craftHold) return;
  craftHoldPaint(craftHold.b,0);
  craftHold=null;
}
function craftHoldStart(b,fire){
  if(!b||b.disabled) return;
  craftHold={b:b,fire:fire,t:0};
  craftHoldPaint(b,0);
}
function craftHoldStep(dt){
  if(!craftHold) return;
  var b=craftHold.b;
  // The panel redraws itself on every change, so a button that has left the
  // page or gone dead takes its hold with it.
  if(!b||b.disabled||(b.isConnected===false)){ craftHoldCancel(); return; }
  craftHold.t+=dt;
  craftHoldPaint(b,craftHold.t/CRAFT_HOLD);
  if(craftHold.t>=CRAFT_HOLD){
    var f=craftHold.fire;
    craftHoldCancel();
    if(f) f();
  }
}
// Letting go anywhere at all cancels, not only on the button, or a release off
// the edge would leave it filling to a purchase he did not make.
try{ window.addEventListener('mouseup',function(){ craftHoldCancel(); }); }catch(_chm){}
function renderCraftDetail(rows){
'@

# 2. THE BUTTON. A press starts the hold; the craft happens when it completes.
SubRx @'
  if(btn&&!btn.disabled) b.onclick=function(){ btn.click(); };
'@ @'
  if(btn&&!btn.disabled){
    // v11.75, HIS NOTE: a click no longer spends anything. The hold does.
    b.onmousedown=function(e){ if(e&&e.button!==undefined&&e.button!==0) return; craftHoldStart(b,function(){ btn.click(); }); };
    b.onmouseleave=function(){ craftHoldCancel(); };
    b.title=((kind==='repair')?'Hold to service':'Hold to craft')+' (1 second)';
  }
'@

# 3. THE CLOCK. The same frame loop the rest of the game runs on.
SubRx @'
  if(state==='hub'){
    if(HB&&wc&&W>0){
'@ @'
  if(state==='hub'){
    try{ craftHoldStep(dt); }catch(_ch){}   // v11.75: the craft hold fills here
    if(HB&&wc&&W>0){
'@

# STAMPS.
SubRx @'
var VER='11.74';
'@ @'
var VER='11.75';
'@
SubRx @'
var WHATSNEW_VER='11.74';
'@ @'
var WHATSNEW_VER='11.75';
'@
SubRx @'
  'THIS IS AN ALPHA. Things will break. When something does, the game writes it into your run report and tells you so; that report is how it gets fixed.',
'@ @'
  'THIS IS AN ALPHA. Things will break. When something does, the game writes it into your run report and tells you so; that report is how it gets fixed.',
  'HOLD THE CRAFT BUTTON FOR A SECOND. The button fills as you hold it and the work happens when it is full. Let go early and nothing is spent. The same goes for the service button, which is the same control.',
'@
$cnt=([regex]::Matches($s,"now:'v11\.74:[^']*'")).Count
if($cnt -ne 1){ throw "DEVNOW v11.74 matched $cnt times" }
$s=[regex]::Replace($s,"now:'v11\.74:[^']*'",{ param($m) "now:'v11.75: HIS NOTE of 2026-09-06, holding the craft button for about a second to craft, with the button itself filling like a status bar. CRAFT_HOLD is 1.0 s, the hold is stepped by the frame loop rather than wall time so it runs on the same clock as everything else, the fill is a gradient painted onto the button so an untouched button looks unchanged, releasing anywhere cancels, and a plain click no longer spends anything. The service button is the same control and behaves the same way. Check 11.75 starts a hold on a stub button, steps it to just under a second and requires nothing fired and the bar partly filled, steps past and requires exactly one firing, cancels mid-hold and requires nothing fired, and controls that the real panel wires the hold and no longer crafts on a click.'" })
$n++

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count + 1
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
