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

# NEW MACHINES LAND FAR FROM BOTH PLAYERS (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
      var rsp=null,rtry=0;
      do{ rsp=freeSpot(G.map,30); rtry++; }while(dist(rsp,p)<800&&rtry<40);
      if(dist(rsp,p)>=800){
'@ @'
      // v20.36, from the whole-game bug hunt of 2026-10-08 (H9): far from EVERY player, as the pillager waves (v15.80) and the
      // siege (v17.32) already are. Only the host was measured, so in co-op a new sentry or crawler could land in player 2's face
      // (about one raid in seven within 300 of him), and with the host out it was measured from his body. Solo is unchanged: the
      // same draws, the same distance.
      var rsp=null,rtry=0, _rd=function(q){ return NET.on?netNearDist(q):dist(q,p); };
      do{ rsp=freeSpot(G.map,30); rtry++; }while(_rd(rsp)<800&&rtry<40);
      if(_rd(rsp)>=800){
'@

SubRx @'
var VER='20.35';
'@ @'
var VER='20.36';
'@

$pat = "(?m)^  now:'v20\.35:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v20.36: In co-op, replacement machines no longer appear on top of player 2. Check 20.36 fails on v20.35',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
