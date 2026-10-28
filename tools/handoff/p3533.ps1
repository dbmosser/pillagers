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

# THE QUIET HUD, DETAILS THAT MATTER STAY (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
{sub:'Equip your own gun at The Stash.'}
'@ @'
{sub:'Equip your own gun at The Stash.',key:'loanstash'}
'@

SubRx @'
{sub:'GOLD GLOW MARKS THE BOX'}
'@ @'
{sub:'GOLD GLOW MARKS THE BOX',key:'needhint'}
'@

SubRx @'
{sub:'Bandage, Medkit or Armour Plate.'}
'@ @'
{sub:'Bandage, Medkit or Armour Plate.',key:'selheal'}
'@

SubRx @'
{sub:'Player 2 is still out'}
'@ @'
{sub:'Player 2 is still out',key:'arcxout'}
'@

SubRx @'
    if(!G.sim&&G.player&&G.spawnGun&&(P.stash||[]).some(
'@ @'
    // v35.xx (cw-quietkeep), HIS ORDER (2026-10-27): "build the quiet hud, all 5 changes". With the grey rows retired the left feed is the one place a raid
    // line shows, and a feed line drops a detail of five words or more (cw-feedcalm). Four lines whose detail tells him something now carry a key, which keeps
    // the detail at any length (cw-quietpause): this one (his own gun waits at The Stash), CONTRACT ITEM NEARBY, SELECT A HEAL and the 2 player Extracted line.
    if(!G.sim&&G.player&&G.spawnGun&&(P.stash||[]).some(
'@

SubRx @'
var VER='35.32';
'@ @'
var VER='35.33';
'@

$pat = "(?m)^  now:'v35\.32:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v35.33: quiet hud: the feed keeps the details that matter (your gun waits at the stash, player 2 still out) Check 35.33 fails on v35.32',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
