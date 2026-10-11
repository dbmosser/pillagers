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

# ARCADE: BOTH PLAYERS ON PADS (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
function arcadeEnter(role){
  role=(role==='p2')?'p2':'host';
'@ @'
// v23.28, HIS ORDER (2026-10-11), build 7 of 20 (arcade7): BOTH PLAYERS ON PADS. His design: controller 1 is player 1, controller 2 is
// player 2. Entering the arcade puts this window on its arcade pad IN MEMORY (the host on the first controller, player 2 on the
// second) and tells the other window (netPadPost), so player 1 plays fully on a pad while the keyboard and mouse still drive him.
// It never writes the kept pick (netPadSet writes salvagerun:samepad:*), and leaving the arcade loads his kept pick back
// (netPadLoad) and tells the other window again. A new pick starts the kept sides over, as netPadSet does.
function arcadePadsIn(role){
  var ix=(role==='p2')?1:0;
  if(NET.padIx!==ix){ NET.padIx=ix; NET.padWas=null; }
  netPadPost();
  return NET.padIx;
}
function arcadePadsOut(){
  var was=NET.padIx;
  netPadLoad();
  if(NET.padIx!==was) NET.padWas=null;
  netPadPost();
  return NET.padIx;
}
function arcadeEnter(role){
  role=(role==='p2')?'p2':'host';
'@

SubRx @'
  arcadeCfgIn();
  ARCADE.wantIn=0; ARCADE.p2Busy=0;   // v23.26 (arcfixa)
'@ @'
  arcadeCfgIn();
  ARCADE.wantIn=0; ARCADE.p2Busy=0;   // v23.26 (arcfixa)
  arcadePadsIn(ARCADE.role);   // v23.28 (arcade7): controller 1 is player 1, controller 2 is player 2, in memory only
'@

SubRx @'
  NET.arcPick=0; NET.arcBoot=0; ARCADE.wantIn=0;
'@ @'
  NET.arcPick=0; NET.arcBoot=0; ARCADE.wantIn=0;
  arcadePadsOut();   // v23.28 (arcade7): his kept controller pick back
'@

SubRx @'
var VER='23.27';
'@ @'
var VER='23.28';
'@

$pat = "(?m)^  now:'v23\.27:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v23.28: In the arcade controller 1 plays player 1 and controller 2 plays player 2, and his kept controller picks come back on leaving. Check 23.28 fails on v23.27',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
