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

# CALLING AN EXTRACTION FOLDS THE CONTROLS LIST (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
  if(!G||G.legendAutoDone||sec<30) return false;

'@ @'
  // v32.xx (cw-extlegend), the critic on screen 37: the controls list sat across the extract countdown. The compact list folds the moment an extraction is called (once; F1 opens it again).
  if(G&&!G.legendExtDone&&G.beaconT!==null&&G.beaconT!==undefined){ G.legendExtDone=true; G.legendAutoDone=true; if(G.legendOn===1){ G.legendOn=0; return true; } return false; }
  if(!G||G.legendAutoDone||sec<30) return false;

'@

SubRx @'
var VER='32.38';
'@ @'
var VER='32.39';
'@

$pat = "(?m)^  now:'v32\.38:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v32.39: The compact controls list folds once when an extraction is called. Check 32.39 fails on v32.38',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
