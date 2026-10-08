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

# THE BLOTTER COLOURS TURN AT THE DOSE SPEED (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
function buzzWarp(c2,cnv,t,dr,ac,k){
'@ @'
// v18.94, after his report (2026-10-07) and the Blotter review: THE COLOURS TURN AT THE DOSE'S SPEED, NOT THE CLOCK'S. The hue was
// clock*rate, with the clock the time since the page loaded (BUZZT), so while a dose came on the turning sped up by clock*change of
// rate: after an hour of play the colours whirled round about once a second for the whole first minute of a dose and then calmed
// all at once at the peak, and spun backwards as it wore off. The phases now add up rate*time frame by frame (BUZZPH), so the
// turning speed simply follows the strength. One phase for the world pass, one for the HUD pass, one for the colour washes.
var BUZZPH={lt:null,w:0,h:0,wash:0};
function buzzWarp(c2,cnv,t,dr,ac,k,hp){
'@

SubRx @'
      c2.filter='hue-rotate('+Math.round((t*(30+22*ac))%360)+'deg) saturate('+(1.4+0.22*ac).toFixed(2)+')';
'@ @'
      c2.filter='hue-rotate('+Math.round(((hp===undefined)?(t*(30+22*ac)):hp)%360)+'deg) saturate('+(1.4+0.22*ac).toFixed(2)+')';   // v18.94: the phase as added up (BUZZPH), not clock times rate
'@

SubRx @'
  buzzWarp(wc,wcv,t,dr,ac,k);
'@ @'
  (function(){ var dtp=(BUZZPH.lt===null)?0:Math.max(0,Math.min(0.25,t-BUZZPH.lt)); BUZZPH.lt=t;   // v18.94: the phases add up the rate frame by frame
    BUZZPH.w=(BUZZPH.w+dtp*(30+22*ac))%360; BUZZPH.h=(BUZZPH.h+dtp*1.13*(30+22*ac*0.4))%360; BUZZPH.wash=(BUZZPH.wash+dtp*(50+8*ac))%360; })();
  buzzWarp(wc,wcv,t,dr,ac,k,BUZZPH.w);
'@

SubRx @'
  buzzWarp(ctx,ocv,t*1.13+0.7,dr*0.5,ac*0.4,k);
'@ @'
  buzzWarp(ctx,ocv,t*1.13+0.7,dr*0.5,ac*0.4,k,BUZZPH.h);
'@

SubRx @'
      var hue=Math.round((t*(50+8*ac)+tb*77)%360);
'@ @'
      var hue=Math.round((BUZZPH.wash+tb*77)%360);   // v18.94: the wash phase as added up, not clock times rate
'@

SubRx @'
var VER='18.93';
'@ @'
var VER='18.94';
'@

$pat = "(?m)^  now:'v18\.93:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v18.94: Blotter colours drift smoothly however long you have been playing. Check 18.94 fails on v18.93',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
