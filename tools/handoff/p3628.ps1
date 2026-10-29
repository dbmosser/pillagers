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

# SLOWER GUN SWITCHES (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
var DRAWT={pistol:0.25,magnum:0.35,smg:0.4,carbine:0.5,rifle:0.55,shotgun:0.6,sniper:0.85,lmg:1.0,lance:1.0,rocket:1.0};
'@ @'
// v28.xx (cw-cx-slowerswitch), HIS WORDS 10-29: "make it take longer to switch guns". Half again as long; pistol rounded to 0.38 s.
var DRAWT={pistol:0.38,magnum:0.525,smg:0.6,carbine:0.75,rifle:0.825,shotgun:0.9,sniper:1.275,lmg:1.5,lance:1.5,rocket:1.5};
'@

SubRx @'
  return Object.prototype.hasOwnProperty.call(DRAWT,w.id)?DRAWT[w.id]:0.5;
'@ @'
  return Object.prototype.hasOwnProperty.call(DRAWT,w.id)?DRAWT[w.id]:0.75;
'@

SubRx @'
  else if((G.t-(p.swapT===undefined?-9:p.swapT))<0.45) parts.push('SWITCHING GUNS');
'@ @'
  else if(p.drawT>0) parts.push('SWITCHING GUNS');   // v28.xx (cw-cx-slowerswitch): the status follows the real draw clock.
'@

SubRx @'
// pistol in a quarter of a second, an SMG 0.4, a rifle 0.55, a shotgun 0.6, a marksman rifle 0.7, a sniper 0.85, the machine gun and the lance a
// full second. The time is the gun's CLASS, so a Forge upgrade (MK II, MK III, an element) does not change it. drawTick, run every frame from
'@ @'
// v28.xx (cw-cx-slowerswitch): the original times below were increased by half at his request; see DRAWT for the current seconds.
// The time is the gun's CLASS, so a Forge upgrade (MK II, MK III, an element) does not change it. drawTick, run every frame from
'@

SubRx @'
var VER='36.27';
'@ @'
var VER='36.28';
'@

$pat = "(?m)^  now:'v36\.27:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v36.28: switching guns takes half again as long Check 36.28 fails on v36.27',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
