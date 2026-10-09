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

# F9 ON THE TITLE RECORDS NOTHING (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
  if(REC.on) return false;
'@ @'
  if(REC.on) return false;
  // v21.49: NOT ON THE TITLE. The title is page elements over an empty canvas, so F9 there recorded a black clip, and that clip then
  // became the one the title plays when nobody is playing. It says where to press it instead.
  if(typeof attTitleUp==='function'&&attTitleUp()){
    var _rt=document.getElementById('recmark'); recMark(true);
    if(REC.mark){ REC.mark.innerHTML='Press F9 in a raid or the Undercroft to record'; setTimeout(function(){ if(!REC.on){ recMark(false); REC.mark.innerHTML='&#9679; REC'; } },2600); }
    return false;
  }
'@

SubRx @'
var VER='21.48';
'@ @'
var VER='21.49';
'@

$pat = "(?m)^  now:'v21\.48:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v21.49: F9 on the title screen tells you to press it in a raid or the Undercroft instead of recording a black clip. Check 21.49 fails on v21.48',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
