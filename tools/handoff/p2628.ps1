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

# THE ITEM WHEEL ON A CONTROLLER (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
  if(G&&G.arcade&&!bagNav&&pressed(13)&&!PAD.prev[13]&&typeof arcadeQuickHeal==='function'){ try{ arcadeQuickHeal(); }catch(_aqh){} }   // v23.46 (arcade23): D-DOWN is the quick heal in the arcade
'@ @'
  // v26.xx (wheel5pad), HIS ORDER 2026-10-14: THE ITEM WHEEL ON A CONTROLLER. HOLD D-DOWN opens it (the button that was the arcade quick heal and the self-revive
  // hold; while he is down it still revives), the RIGHT STICK picks a segment (a push past half its travel; the stick centred cancels) and letting go of
  // D-DOWN takes the item out. LB and RB still walk the guns, and RT is the trigger that uses the item in hand. The arcade quick heal is gone: the
  // wheel is the only way to a heal.
  (function(){
    var _wdd=!!(pressed(13)&&!bagNav&&G&&!G.over&&!G.paused&&!G.mapOpen&&G.player&&!G.player.downed&&!G.player.dying);
    if(_wdd&&!PAD.prev[13]&&!G.wheel){ if(typeof wheelOpen==='function'&&wheelOpen()&&G.wheel) G.wheel.pad=1; }
    if(G&&G.wheel&&G.wheel.pad){
      G.wheel.vx=rx; G.wheel.vy=ry;
      if(!_wdd){ if(typeof wheelRelease==='function') wheelRelease(); }
    }
  })();
'@

SubRx @'
  if(G&&!G.over&&(rx||ry)){
'@ @'
  if(G&&!G.over&&!G.wheel&&(rx||ry)){   // wheel5pad: and not while the item wheel is open
'@

SubRx @'
KeyT:'RB',KeyG:'RT',KeyQ:'LB',
'@ @'
KeyT:'RB',KeyG:'RT',KeyQ:'D-DOWN',
'@

SubRx @'
  if(!w.pad&&!keys['KeyQ']){ wheelRelease(); return; }
'@ @'
  if(!w.pad&&!keys['KeyQ']){ wheelRelease(); return; }
  if(w.pad&&typeof PAD==='object'&&PAD&&!PAD.on){ G.wheel=null; return; }   // wheel5pad: the pad went away with the wheel open
'@

SubRx @'
['D-DOWN','revive when down']
'@ @'
['D-DOWN','item wheel (hold), revive when down']
'@

SubRx @'
var VER='26.27';
'@ @'
var VER='26.28';
'@

$pat = "(?m)^  now:'v26\.27:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v26.28: On a controller, hold D-DOWN and push the right stick to open and use the item wheel. Check 26.28 fails on v26.27',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
