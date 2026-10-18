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

# THE TWO PARTY ARCADE SEATS ARE PLAYER 1 AND PLAYER 2 IN BOTH WINDOWS (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
function netSeatName(s){
  var r=NET.roster||[], i;
  for(i=0;i<r.length;i++) if(r[i].seat===s) return r[i].name;
  return null;
}

'@ @'
function netSeatName(s){
  var r=NET.roster||[], i;
  // v30.xx (cw-p1p2), HIS ORDER (2026-10-18): "there seem to be a lot of inconsistencies between p1 and p2 games, please coordinate them better". The roster
  // keeps the name each save had when the two windows linked, before the party arcade renamed them, so over a head, on the team bar and in the feed one
  // window read a save name or Pillager where the other read Player 2. In the party arcade the two seats are Player 1 and Player 2 in both windows.
  for(i=0;i<r.length;i++) if(r[i].seat===s) return (typeof ARCADE==='object'&&ARCADE&&ARCADE.on&&!ARCADE.solo&&(s===0||s===1))?('Player '+(s+1)):r[i].name;
  return null;
}

'@

SubRx @'
var VER='30.87';
'@ @'
var VER='30.88';
'@

$pat = "(?m)^  now:'v30\.87:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v30.88: In the party arcade demo both windows now call the two players Player 1 and Player 2 over the heads, on the team bar and in the feed. Check 30.88 fails on v30.87',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
