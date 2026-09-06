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

# THE BEAT TO REACT WAS A FLOOR, NOT A BEAT. The line meant to give a pillager one
# beat before his first shot ran on EVERY frame he could see the player and was not
# in chase, re-flooring his cooldown to react each time. A man in a state that
# persists while he sees you (extract) therefore never reached the cd<=0 the fire
# gate needs and never shot: measured, a hostile pillager parked 200 units away in
# clear view fired ZERO rounds in sixty steps. His 2026-08-26 note. The beat is
# now edge-triggered: it fires once when sight is acquired and again only after
# sight is lost and regained.
SubRx @'
    var sees=canSee(e.x,e.y,e.face,p.x,p.y,G.vseg,_fSee,e.cone,_aSee);
'@ @'
    var sees=canSee(e.x,e.y,e.face,p.x,p.y,G.vseg,_fSee,e.cone,_aSee);
    if(!sees) e.beat=0;   // v11.46: losing sight re-arms the one-time reaction beat below
'@
SubRx @'
      if(e.kind==='raider'&&e.state!=='chase') e.cd=Math.max(e.cd,e.react||0.5);
'@ @'
      // v11.46: ONCE per acquisition, not every frame. Re-flooring each frame kept
      // a man in extract from ever reaching cd 0, so he never fired at all.
      if(e.kind==='raider'&&e.state!=='chase'&&!e.beat){ e.cd=Math.max(e.cd,e.react||0.5); e.beat=1; }
'@

# STAMPS.
SubRx @'
var VER='11.45';
'@ @'
var VER='11.46';
'@
SubRx @'
var WHATSNEW_VER='11.45';
'@ @'
var WHATSNEW_VER='11.46';
'@
SubRx @'
  'THE TITLE SCREEN NO LONGER ANSWERS THE FLOOR KEYS. Pressing P or ESC on the title screen used to open the pause box over it, and ENTER to start could quietly dismiss the NEW IN card before you saw it. The title keeps its own keys now: ENTER or SPACE starts, nothing else.',
'@ @'
  'A PILLAGER WHO SEES YOU NOW ACTUALLY SHOOTS. A pillager heading for extraction who had you in clear sight would stand there and never fire: the one-beat pause meant to give you a fair moment was being reapplied every frame, so his trigger never came free. He gets his one beat, then he fires.',
  'THE TITLE SCREEN NO LONGER ANSWERS THE FLOOR KEYS. Pressing P or ESC on the title screen used to open the pause box over it, and ENTER to start could quietly dismiss the NEW IN card before you saw it. The title keeps its own keys now: ENTER or SPACE starts, nothing else.',
'@
SubRx @'
  now:'v11.45: the floor keys answered on the title screen. state is hub from boot and the title is on via its HTML class (showScreen(title) is never called), so the hub keydown branch was live over the title: P or ESC opened the pause box over it, and ENTER stamped WNSEEN in the same press the title listener used to start. The earlier not-reproduced verdict was the probe calling __showScreen(title), which sets state=title and disarms the branch. Reproduced on the boot title with one KeyP on window. A _titleUp guard on both branches; the title keeps its own ENTER/Space start. Closes the STILL OPEN title-keys line.',
'@ @'
  now:'v11.46: the beat to react was a floor, not a beat. The line giving a pillager one beat before his first shot ran every frame he saw the player outside chase, re-flooring cd to react each time, so a man in extract (a state that persists while he sees you) never reached the cd<=0 the fire gate needs and never fired; measured zero rounds in sixty steps at 200 units in clear view. Now edge-triggered on a per-pillager beat flag, re-armed when sight is lost. Proven with an open-ground line-of-sight harness (both parked off-map, facing, hostile, extract): rounds after one beat, and none when he faces away. His 2026-08-26 note; closes the last STILL OPEN combat line.',
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
