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

# REDUCED FLASHING (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
  {k:'rumble', label:'Controller rumble',
'@ @'
  // v26.xx (settings9), HIS ORDER 2026-10-14 ("ok add all this stuff to settings"): REDUCED FLASHING, in ACCESSIBILITY. OFF is the game as it was. ON
  // tones down the bright flashes: the light of a blast, a shot or the Forge (smaller and shorter, flash()), the muzzle flashes drawn on the gun and the
  // machine, the lightning that lights the whole street, and half of every burst of sparks, the Forge's included. Cosmetic only: what lightning
  // shows to the machines, the damage and the sound are untouched.
  {k:'flashRed', label:'REDUCED FLASHING', sec:'ACCESSIBILITY',
   hint:'TONES DOWN THE BRIGHT FLASHES: BLASTS, MUZZLE FLASHES, LIGHTNING AND FORGE SPARKS.',
   opts:[
     {n:'OFF', cfg:{flashRed:0}},
     {n:'ON',  cfg:{flashRed:1}}
   ], def:0},
  {k:'rumble', label:'Controller rumble',
'@

SubRx @'
function shakeK(){ var s=+CFG.shake; return (isFinite(s)&&s>=0&&s<=3)?s:1; }
'@ @'
function shakeK(){ var s=+CFG.shake; return (isFinite(s)&&s>=0&&s<=3)?s:1; }
// v26.xx (settings9): REDUCED FLASHING. flashK is the factor on the brightness of a drawn flash (muzzle sprites, the lightning sheet and the fog lift it
// makes); lightningA is the alpha of the lightning sheet for a point in the bolt (lf, 0 to 1).
function flashK(){ return CFG.flashRed===1?0.45:1; }
function lightningA(lf){ return 0.40*clamp(lf,0,1)*flashK(); }
'@

SubRx @'
G.flashes.push({x:x,y:y,r:r,c:col||'#ffc27a',t:0,life:life||.14});
'@ @'
G.flashes.push({x:x,y:y,r:r*(CFG.flashRed===1?0.6:1),c:col||'#ffc27a',t:0,life:(life||.14)*(CFG.flashRed===1?0.7:1)});   // v26.xx (settings9): REDUCED FLASHING, a smaller and shorter light
'@

SubRx @'
if(CFG.fxLevel===0) n=Math.ceil(n/3);   // v17.43: his pick 28, reduced effects
'@ @'
if(CFG.fxLevel===0) n=Math.ceil(n/3);   // v17.43: his pick 28, reduced effects
  if(CFG.flashRed===1) n=Math.ceil(n*0.5);   // v26.xx (settings9): REDUCED FLASHING, half the sparks of every burst
'@

SubRx @'
var _flash=clamp((G.lightning||0)/0.34,0,1);
'@ @'
var _flash=clamp((G.lightning||0)/0.34,0,1)*flashK();   // v26.xx (settings9): REDUCED FLASHING lifts the fog less in a bolt
'@

SubRx @'
wc.fillStyle='rgba(150,170,220,'+(0.40*clamp(lf,0,1))+')';
'@ @'
wc.fillStyle='rgba(150,170,220,'+lightningA(lf)+')';
'@

SubRx @'
wc.beginPath(); wc.arc(D.tip+ext,D.by,4.5,0,6.2832); wc.fill();
'@ @'
wc.fillStyle='rgba(255,212,138,'+(0.95*flashK()).toFixed(3)+')'; wc.beginPath(); wc.arc(D.tip+ext,D.by,4.5,0,6.2832); wc.fill();   // v26.xx (settings9): REDUCED FLASHING dims the muzzle flash
'@

SubRx @'
wc.beginPath(); wc.arc(_L+_B+ext,0,4.5,0,6.2832); wc.fill();
'@ @'
wc.fillStyle='rgba(255,212,138,'+(0.95*flashK()).toFixed(3)+')'; wc.beginPath(); wc.arc(_L+_B+ext,0,4.5,0,6.2832); wc.fill();
'@

SubRx @'
wc.fillStyle='#ffc04a'; wc.globalAlpha=clamp(e.muzzle*6,0,1);
'@ @'
wc.fillStyle='#ffc04a'; wc.globalAlpha=clamp(e.muzzle*6,0,1)*flashK();
'@

SubRx @'
wc.fillStyle='#ffb070'; wc.globalAlpha=clamp(e.muzzle*6,0,1);
'@ @'
wc.fillStyle='#ffb070'; wc.globalAlpha=clamp(e.muzzle*6,0,1)*flashK();
'@

SubRx @'
wc.fillStyle='rgba(255,194,122,.95)';
'@ @'
wc.fillStyle='rgba(255,194,122,'+(0.95*flashK()).toFixed(3)+')';
'@

SubRx @'
var VER='26.49';
'@ @'
var VER='26.50';
'@

$pat = "(?m)^  now:'v26\.49:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v26.50: Accessibility has reduced flashing. Check 26.50 fails on v26.49',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
