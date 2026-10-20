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

# DEMO RUN START ASKS EASY OR NORMAL (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
  startRaid();
  return !!(G&&G.arcade);
}

'@ @'
  startRaid();
  try{ easyStartAsk(); }catch(_esa){}   // v28.xx (cw-easystart), HIS ANSWER (2026-10-18, 2.28 c): in the demo each player chooses easy or normal as a run starts
  return !!(G&&G.arcade);
}

'@

SubRx @'
function easyAnswer(yes){

'@ @'
// v28.xx (cw-easystart), HIS ANSWER (2026-10-18, 2.28 c): "in the demo only, each player chooses easy or normal before their run starts". Every new demo run starts normal and puts the
// same card up in that window (Y or A easy, N or B normal); the offer after the second death (2.90 b) stays for anyone who said no.
function easyStartAsk(){
  if(typeof ARCADE!=='object'||!ARCADE||!ARCADE.on||ARCADE.solo) return false;
  ARCADE.easy=0; ARCADE.easyAsked=0; ARCADE.easyAsk={at:Date.now()};
  return true;
}
function easyAnswer(yes){

'@

SubRx @'
var VER='32.14';
'@ @'
var VER='32.15';
'@

$pat = "(?m)^  now:'v32\.14:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v32.15: Each demo run starts with the easy or normal card in that players window. Check 32.15 fails on v32.14',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
