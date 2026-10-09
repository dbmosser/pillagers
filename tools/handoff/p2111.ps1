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

# THE BOSS PLATE GROWS AT 4K (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
  y=Math.round((LH(96)+LH(17))*(HUDZ.msg||1)*hudRes()*hudUserZ('msg'))+LH(4)+LH(16);   // v20.55 (H38): the plate starts under the message plate, at every screen size and message size
  ctx.save();
'@ @'
  y=Math.round((LH(96)+LH(17))*(HUDZ.msg||1)*hudRes()*hudUserZ('msg'))+LH(4)+LH(16);   // v20.55 (H38): the plate starts under the message plate, at every screen size and message size
  // v21.11, seen on the 4K screenshot (2026-10-08): THE BOSS PLATE GROWS WITH THE SCREEN. The message plate above it is drawn at
  // the screen's scale, but this plate kept its 1080p size, so at 4K the name of THE OVERSEER was small print under a big message
  // and its bar a thin line. It is now drawn at the same scale, grown about its top centre, so it still starts where it did.
  var _br=Math.max(1,(typeof hudRes==='function')?hudRes():1), _bt=y-LH(16);
  w=Math.min(520,W*0.4/_br); x=W/2-w/2;
  ctx.save();
  if(_br>1){ ctx.translate(W/2,_bt); ctx.scale(_br,_br); ctx.translate(-W/2,-_bt); }
'@

SubRx @'
  HUDBOSSB=y+10;   // v20.55 (H38): the bottom of the boss plate, for the offer line and the controller word
'@ @'
  HUDBOSSB=Math.round(_bt+(y+10-_bt)*_br);   // the bottom of the boss plate in screen pixels, for the offer line and the controller word (v20.55), grown with it
'@

SubRx @'
var VER='21.10';
'@ @'
var VER='21.11';
'@

$pat = "(?m)^  now:'v21\.10:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v21.11: At 4K the boss name and health bar are drawn as big as the message above them. Check 21.11 fails on v21.10',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
