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

# AUTO RESOLUTION CHASES YOUR FRAME CAP (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
// v28.xx (cw-cx-laddersteady): his 2.43 a: a fast cap is no reason to shed above 60 fps. A deliberately slower cap keeps its own budget.
'@ @'
/* v28.xx (cw-drscap), HIS ANSWER (2026-10-25): "Yes picture quality should reduce to chase a higher cap" and "Eg dynamic resolution" (this reverses his 2.43 a, a fast cap is no reason to shed above 60 fps). A cap above 60 is now a target (drsChase), never faster than the screen shows. Cap off still aims at 60, and a slower cap keeps its own budget. */
'@

SubRx @'
var budget=Math.max(16.7,(CFG.fpsCap>0)?1000/CFG.fpsCap:16.7), w=DRS.win||(DRS.win=[]);
'@ @'
var budget=Math.max(16.7,(CFG.fpsCap>0)?1000/CFG.fpsCap:16.7), w=DRS.win||(DRS.win=[]), chase=drsChase();
'@

SubRx @'
var slow=DRS.gap95>20*budget/16.7, clear=DRS.gap95<17.5*budget/16.7&&DRS.work95<10;
'@ @'
var slow=DRS.gap95>20*budget/16.7, clear=DRS.gap95<17.5*budget/16.7&&DRS.work95<10; DRS.chase=chase; if(chase>0){ DRS.gapT=drsTrim(gaps); slow=slow||DRS.gapT>chase*1.1; clear=clear&&DRS.gapT<chase*1.04&&DRS.work95<10*chase/16.7; }   /* v28.xx (cw-drscap): the 60 rules still hold, and a chased cap also steps down when the frames fall a tenth short of it and only climbs back with the same headroom the 60 rule asks (own work under 0.6 of a frame) */
'@

SubRx @'
function drsTick(gapMs,now){
'@ @'
var VSYNC={last:0,ms:0,g:[],n:0};   /* v28.xx (cw-drscap): the screen rate. Browser frames come one screen refresh apart at the fastest, so the low tenth of the last 120 gaps is the refresh time; a spell of slow frames moves it up only slowly (2 percent of the way every 30 frames), so heavy fighting never reads as a slower screen, while a move to a slower screen is followed within about a minute. */ function vsyncNote(ts){ var g=ts-VSYNC.last, s, p; VSYNC.last=ts; if(!(g>1.5&&g<60)) return false; VSYNC.g.push(g); if(VSYNC.g.length>120) VSYNC.g.shift(); if(VSYNC.g.length<30||(++VSYNC.n)%30) return false; s=VSYNC.g.slice().sort(function(a,b){ return a-b; }); p=s[Math.floor(s.length*0.1)]; VSYNC.ms=(VSYNC.ms>0&&p>VSYNC.ms)?VSYNC.ms+(p-VSYNC.ms)*0.02:p; return true; } function drsChase(){ var c=+CFG.fpsCap, v=+VSYNC.ms, t; if(!(c>60)||!(v>0)) return 0; t=Math.max(1000/c,v); return t<16.2?t:0; }   /* the frame time a cap above 60 asks for, never faster than the screen; 0 keeps the 60 rule (cap off, a slower cap, no measure yet, or a screen at 60 Hz or slower) */ function drsTrim(s){ var k=Math.max(1,Math.floor(s.length*0.95)), i, a=0; for(i=0;i<k&&i<s.length;i++) a+=s[i]; return s.length?a/Math.min(k,s.length):0; }   /* mean of the sorted gaps without the slowest twentieth, so one hitch is not a slow spell */ function drsTick(gapMs,now){
'@

SubRx @'
if(frameCapSkip(ts)) return;   // v17.43: his pick 28, the frame cap
'@ @'
try{ vsyncNote(ts); }catch(_vn){} if(frameCapSkip(ts)) return;   // v17.43: his pick 28, the frame cap; v28.xx (cw-drscap): every browser frame measures the screen rate first
'@

SubRx @'
var VER='34.82';
'@ @'
var VER='34.83';
'@

$pat = "(?m)^  now:'v34\.82:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v34.83: Pick a frame cap above 60 in settings, display: when the PC falls short of it in a raid, the picture softens a step at a time (effects first, then sharpness, never under 75 percent) until the cap holds, and sharpens again when there is room. Auto resolution off keeps the picture sharp at any cap. Watch for: a softer picture at 120 to 240, and quality stepping up and down in a long fight. Check 34.83 fails on v34.82',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
