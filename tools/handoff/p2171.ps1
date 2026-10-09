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

# NO GIFTS INTO A COPY OF THE HOST HIRE (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
    if(!dropped&&G&&!G.over&&d&&d.key){
'@ @'
    // v21.71, from the whole-game bug hunt of 2026-10-08 (K3): NOT ON A LINKED WINDOW. Up top in co-op the hire on player 2 window
    // is only his copy of the host hire, which the host runs, so a gift put the item into a bag nobody else ever sees: it left the
    // backpack, but it was never in the real hire pack, his cut or his body, and it was gone from both saves. The pick-up of a
    // downed pillager and the Survivor hand-over have the same guard (v17.28). There the release now falls through to the drop
    // below, so the item becomes a pile the host makes and the whole party can search.
    if(!dropped&&G&&!G.over&&d&&d.key&&!netEntsPeer()){
'@

SubRx @'
var VER='21.70';
'@ @'
var VER='21.71';
'@

$pat = "(?m)^  now:'v21\.70:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v21.71: In co-op, an item player 2 lets go over the host hire drops at his feet instead of vanishing. Check 21.71 fails on v21.70',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
