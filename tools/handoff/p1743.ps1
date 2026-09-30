$ErrorActionPreference = 'Stop'
trap { Write-Output "FAILED: $_"; exit 1 }
$p = 'C:\claudecode\dark raiders\dark_raiders.html'
$s = [IO.File]::ReadAllText($p)
$n = 0
function SubRx([string]$old, [string]$new) {
  $pat = ($old -split "`n" | ForEach-Object { [regex]::Escape($_.TrimEnd("`r")) }) -join "\r?\n"
  $c = ([regex]::Matches($script:s, $pat)).Count
  if ($c -ne 1) { throw "regex matched $c times: $($old.Substring(0,[Math]::Min(70,$old.Length)))" }
  $new = $new.Replace("`r`n", "`n")
  $script:s = [regex]::Replace($script:s, $pat, { param($m) $new })
  $script:n++
}

# GRAPHICS OPTIONS (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
function resize(){
'@ @'
// v17.43, HIS PICK 28 (2026-09-30): GRAPHICS OPTIONS. Three Settings rows: Render resolution (CFG.gfxScale, the share of the
// screen's pixels the canvases draw; lower is softer and faster), Frame cap (CFG.fpsCap, frames a second; a skipped frame
// still counts its time in the next one) and Effects (CFG.fxLevel 0 draws about a third of the sparks). A new resolution
// applies at once: the frame loop calls resize() when the setting moves. The defaults are the game as it was.
var RES_APPLIED, CAP_LAST=0;
function gfxScaleNow(){ var s=+CFG.gfxScale; return (s>0&&s<=1)?s:1; }
function frameCapSkip(ts){ var c=+CFG.fpsCap; if(!(c>0)) return false; if(ts-CAP_LAST<1000/c-2) return true; CAP_LAST=ts; return false; }function resize(){
'@

SubRx @'
  DPR=Math.min(window.devicePixelRatio||1,2);
'@ @'
  DPR=Math.min(window.devicePixelRatio||1,2)*gfxScaleNow(); RES_APPLIED=CFG.gfxScale;   // v17.43: his pick 28, the render resolution
'@

SubRx @'
  if(ctxLost){ lastTs=ts; return; }
'@ @'
  if(ctxLost){ lastTs=ts; return; }
  if(CFG.gfxScale!==RES_APPLIED){ try{ resize(); }catch(_rz){} }   // v17.43: his pick 28, a new render resolution applies at once
  if(frameCapSkip(ts)) return;   // v17.43: his pick 28, the frame cap
'@

SubRx @'
function spark(x,y,col,n,spread){
  if(G.sim) return;
'@ @'
function spark(x,y,col,n,spread){
  if(G.sim) return;
  if(CFG.fxLevel===0) n=Math.ceil(n/3);   // v17.43: his pick 28, reduced effects
'@

SubRx @'
  {k:'rumble', label:'Controller rumble',
'@ @'
  {k:'gfxScale', label:'Render resolution',
   hint:'How many pixels the game draws. Lower is softer but runs faster on a slower PC.',
   opts:[
     {n:'Full',   cfg:{gfxScale:1}},
     {n:'High',   cfg:{gfxScale:0.85}},
     {n:'Medium', cfg:{gfxScale:0.7}},
     {n:'Low',    cfg:{gfxScale:0.5}}
   ], def:0},
  {k:'fpsCap', label:'Frame cap',
   hint:'The most frames drawn each second. A cap keeps the PC cooler and quieter.',
   opts:[
     {n:'Off', cfg:{fpsCap:0}},
     {n:'60',  cfg:{fpsCap:60}},
     {n:'30',  cfg:{fpsCap:30}}
   ], def:0},
  {k:'fxLevel', label:'Effects',
   hint:'Sparks and particles. Reduced draws about a third of them.',
   opts:[
     {n:'Full',    cfg:{fxLevel:1}},
     {n:'Reduced', cfg:{fxLevel:0}}
   ], def:0},
  {k:'rumble', label:'Controller rumble',
'@

SubRx @'
var VER='17.42';
'@ @'
var VER='17.43';
'@

$pat = "(?m)^  now:'v17\.42:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v17.43: GRAPHICS OPTIONS, his pick from the feature list: Settings rows for Render resolution (Full, High, Medium, Low, applied at once), Frame cap (Off, 60, 30) and Effects (Full or Reduced, about a third of the sparks). The defaults keep the game as it was. Check 17.43 fails on v17.42',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
