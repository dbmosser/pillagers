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

# THE EMOTE STRIP SITS ABOVE THE BELT (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
function drawUseBar(){
'@ @'
// v22.14, from the whole-game bug hunt of 2026-10-08 (K25): THE EMOTE STRIP SITS ABOVE THE BELT. It was placed a fixed height from
// the bottom of the screen (H-LH(112)), while the belt grows with the screen, so at 1440p and 4K the strip was painted over the top of
// the belt keys and their numbers, and at 1080p over the belt caption. Its top is now worked out from the belt as drawn this frame:
// above the caption strip (v19.34) with a small gap, and above the extraction lines while they show, as the wind-up bar already goes
// (v19.10). The wind-up bar keeps the same distance above the strip it had.
function emoteStripY(){
  var c=(G&&G.hotCells&&G.hotCells.length)?G.hotCells[0]:null, hy=c?c.y:H-LH(70), bw=c?c.w:LH(60), p=G&&G.player, y;
  var cap=parseFloat(((/([\d.]+)px/).exec(String(beltCapFS(bw)))||[0,11])[1])||11;
  y=Math.round(hy-LH(6)-cap*0.95-LH(6)-LH(30));
  try{ if(p&&((G.beaconT!==null&&!G.over)||(G.active&&dist(p,G.active)<G.active.r))) y=Math.min(y,Math.round(hy-(LH(48)+LH(34))*Math.max(1,(typeof hudRes==='function')?hudRes():1)-LH(30))); }catch(_ex){}
  return y;
}
function drawUseBar(){
'@

SubRx @'
  if(G.emoteBar) y=Math.min(y,Math.round(H-LH(112)-LH(30)-h));
'@ @'
  if(G.emoteBar) y=Math.min(y,emoteStripY()-LH(30)-h);   // v22.14 (K25): above the strip, wherever the strip sits now
'@

SubRx @'
    var ex0=Math.round(W/2-etw/2),ey0=H-LH(112);
'@ @'
    var ex0=Math.round(W/2-etw/2),ey0=emoteStripY();   // v22.14 (K25): above the belt and its caption as drawn this frame, not a fixed height
'@

SubRx @'
var VER='22.13';
'@ @'
var VER='22.14';
'@

$pat = "(?m)^  now:'v22\.13:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v22.14: The emote strip (V) now sits above the belt at every screen size instead of over the belt keys. Check 22.14 fails on v22.13',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
