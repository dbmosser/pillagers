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

# THE FPS PLATE SAYS WHERE A 60 HZ BROWSER COMES FROM (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
var VSYNC={last:0,ms:0,g:[],n:0};
'@ @'
var VSYNC={last:0,ms:0,g:[],n:0,best:0};
'@

SubRx @'
VSYNC.ms=(VSYNC.ms>0&&p>VSYNC.ms)?VSYNC.ms+(p-VSYNC.ms)*0.02:p; return true; }
'@ @'
VSYNC.ms=(VSYNC.ms>0&&p>VSYNC.ms)?VSYNC.ms+(p-VSYNC.ms)*0.02:p; if(!(VSYNC.best>0)||p<VSYNC.best) VSYNC.best=p; return true; }   /* v35.xx (cw-fpshz): VSYNC.best, the fastest screen rate the browser has given this page since it loaded */
'@

SubRx @'
function fpsTick(ts){
  var el, s;

'@ @'
// v35.xx (cw-fpshz), HIS ORDER (2026-10-28, a picture of Settings with frame cap 144 and the plate reading 60 fps | screen 60): "i have the game on 144
// frame cap but its effectively capping at 60 -- can we fix this?". The game draws only when the browser hands it a frame (requestAnimationFrame); the cap
// can only skip frames, never add one, and his browser was handing over 60 a second. The plate said screen 60 but not where to change it, so while the
// browser has never once given this page frames faster than that (VSYNC.best) a small second line names the three places a 60 Hz browser comes from.
// Not during live raid play (it shows on the floor, in menus and on the pause screen), and never when the page has seen faster frames, because then the
// 60 is the game's own load, not the browser.
function fpsHzHint(){ var b=+VSYNC.best; if(!(b>0)||!(VSYNC.ms>0)||!(CFG.fpsCap>1000/b+5)) return ''; if(state==='raid'&&G&&!G.over&&!pauseOpen) return ''; return 'browser gives '+Math.round(1000/VSYNC.ms)+' hz\ncheck windows refresh rate, main display, hardware acceleration'; }
function fpsTick(ts){
  var el, s, h, hs;

'@

SubRx @'
    s=FPSV.fps+' fps'; if(VSYNC.ms>0&&CFG.fpsCap>1000/VSYNC.ms+5) s+=' | screen '+Math.round(1000/VSYNC.ms);
    if(el.textContent!==s) el.textContent=s; if(el.className!=='on') el.className='on';

'@ @'
    s=FPSV.fps+' fps'; h=''; if(VSYNC.ms>0&&CFG.fpsCap>1000/VSYNC.ms+5){ s+=' | screen '+Math.round(1000/VSYNC.ms); h=fpsHzHint(); }
    if(el.textContent!==s+h){ el.textContent=s; if(h){ hs=document.createElement('span'); hs.className='fpshz'; hs.textContent=h; el.appendChild(hs); } }   // v35.xx (cw-fpshz): the browser line under the plate
    if(el.className!=='on') el.className='on';

'@

SubRx @'
  #fpsbox.on{ display:block; }

'@ @'
  #fpsbox.on{ display:block; }
  #fpsbox .fpshz{ display:block; white-space:pre; margin-top:2px; color:var(--tx-2); font-family:var(--f-cond); font-size:13px; font-weight:600; letter-spacing:.04em; line-height:1.25; }   /* v35.xx (cw-fpshz): the browser rate line */

'@

SubRx @'
var VER='35.75';
'@ @'
var VER='35.76';
'@

$pat = "(?m)^  now:'v35\.75:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v35.76: With the fps plate on and a cap above what the browser gives, a small line under the plate says browser gives 60 hz and names windows refresh rate, main display and hardware acceleration; it stays off in live raid play and when the page has seen faster frames. Check 35.76 fails on v35.75',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
