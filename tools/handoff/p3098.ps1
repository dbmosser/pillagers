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

# PLAYER 2 GETS THE RUN OVER CARD TOO (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
      return arcadeEndTake();

'@ @'
      try{ arcadeOverMirror(m); }catch(_aom){}   // v30.xx (cw-p1p2), HIS ORDER (2026-10-18): "there seem to be a lot of inconsistencies between p1 and p2 games, please coordinate them better". The RUN OVER card with the team score is player 1 alone; player 2 gets it too
      return arcadeEndTake();

'@

SubRx @'
// Player 2 takes the host run end, from arcend or the marked out word, whichever comes first.

'@ @'
// v30.xx (cw-p1p2), HIS ORDER (2026-10-18): "there seem to be a lot of inconsistencies between p1 and p2 games, please coordinate them better". The host built
// the RUN OVER card (TEAM SCORE, a row each, KIA -50% or EXTRACTED x2, the best moments) in arcadeRunEnd and player 2 only tore its raid down, so at the end of
// every run one TV showed the result and the other showed the attract. Player 2 now builds the same card from its own score and the host score it was sent,
// after the x2 or the half has been applied to both, the same way round (player 1 on top). Nothing is saved or sent: the board row, the music and the
// initials stay the host job, and the initials card still arrives by arcinis.
function arcadeOverMirror(m){
  var me, mt;
  if(!ARCADE.on||ARCADE.role!=='p2'||ARCADE.solo) return null;
  me={s:Math.max(0,ARCADE.mine|0),k:ARCADE.kills|0,x:ARCADE.ext|0,d:ARCADE.deaths|0};
  mt=((ARCADE.mate|0)>0||(ARCADE.mateK|0)>0)?{s:Math.max(0,ARCADE.mate|0),k:ARCADE.mateK|0,x:ARCADE.mateX|0,d:-1}:null;
  ARCADE.over={at:Date.now(),why:(m&&m.x2)?'extract':((m&&m.ko)?'dead':''),team:arcadeTeam(),p1:mt,p2:me};
  try{ ARCADE.over.bm=arcadeBmFinal(); }catch(_bmf){}
  return ARCADE.over;
}
// Player 2 takes the host run end, from arcend or the marked out word, whichever comes first.

'@

SubRx @'
var VER='30.97';
'@ @'
var VER='30.98';
'@

$pat = "(?m)^  now:'v30\.97:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v30.98: At the end of a party arcade run the player 2 window now shows the same Run over card as player 1, with the team score and a row for each player. Check 30.98 fails on v30.97',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
