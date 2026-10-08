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

# THE PAUSE BOX SPEAKS CONTROLLER ON A CONTROLLER (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
function keysLegendHtml(){
  var n=keyName, s=function(c){ return '<b style="color:var(--bone)">'+n(keysOf(c))+'</b>'; };
'@ @'
function keysLegendHtml(){
  var n=keyName, s=function(c){ return '<b style="color:var(--bone)">'+n(keysOf(c))+'</b>'; };
  // v19.71, seen on the 4K controller screenshot (2026-10-08): on a controller (player 2 in co-op) the pause box listed MOUSE aim,
  // LMB fire and WASD move, keys the pad player does not have. With a pad on it lists the pad layout, from the same table as the
  // full controls panel (LEGEND_PAD), so the two never disagree.
  if(PAD&&PAD.on&&typeof LEGEND_PAD!=='undefined'&&LEGEND_PAD) return LEGEND_PAD.map(function(sec){ return sec[1].map(function(r){ return '<b style="color:var(--bone)">'+r[0]+'</b> '+r[1]; }).join(' &nbsp; '); }).join(' &nbsp; ');
'@

SubRx @'
  pauseOpen=on;
'@ @'
  pauseOpen=on;
  if(on){ try{ keysLegendApply(); }catch(_pk){} }   // v19.71: the key line matches the device in hand when the box opens
'@

SubRx @'
var VER='19.70';
'@ @'
var VER='19.71';
'@

$pat = "(?m)^  now:'v19\.70:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v19.71: On a controller the pause box lists the controller buttons. Check 19.71 fails on v19.70',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
