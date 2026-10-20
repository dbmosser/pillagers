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

# ALERT MARK CLEARS TOP EDGE NAME (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
function spriteTop(e){
'@ @'
// v28.xx (cw-cx-alerttop): his 2026-10-09 order: the alert mark sits clear over the name. When its HUD baseline is clamped down, move the whole nameplate down by the same screen distance.
function alertTopShift(e){
  if(e.state!=='investigate'&&e.state!=='chase'&&e.state!=='alarm') return 0;
  if(e.kind==='snitch'&&e.state==='alarm'&&e.wind!==undefined&&e.wind!==null) return 0;
  var z=ZOOM(), ph=Math.ceil(msgPx(FS(TYPE.micro))*1.35);
  var s=w2s(e.x,(spriteTop(e)+8+ph-3)*z+LH(4)*Math.max(1,hudRes()),e.y);
  return Math.max(0,Math.round(msgPx(hudFS(TYPE.head))+LH(2))-s.y);
}
function spriteTop(e){
'@

SubRx @'
    var lift=spriteTop(ne)+8;
'@ @'
    var lift=spriteTop(ne)+8-alertTopShift(ne)/ZOOM();   // v28.xx (cw-cx-alerttop): the plate, crew block and health pip step down together only at the top edge
'@

SubRx @'
var VER='33.11';
'@ @'
var VER='33.12';
'@

$pat = "(?m)^  now:'v33\.11:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v33.12: At the top edge the bot nameplate steps down with its alert mark. Away from the edge their positions stay the same. Check 33.12 fails on v33.11',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
