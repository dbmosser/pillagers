$ErrorActionPreference = 'Stop'
trap { Write-Output "FAILED: $_"; exit 1 }
$p = 'C:\claudecode\dark raiders\dark_raiders.html'
$s = [IO.File]::ReadAllText($p)
$n = 0
function SubRx([string]$old, [string]$new) {
  $pat = ($old -split "`n" | ForEach-Object { [regex]::Escape($_.TrimEnd("`r")) }) -join "\r?\n"
  $c = ([regex]::Matches($script:s, $pat)).Count
  if ($c -ne 1) { throw "regex matched $c times: $($old.Substring(0,[Math]::Min(70,$old.Length)))" }
  $script:s = [regex]::Replace($script:s, $pat, { param($m) $new })
  $script:n++
}

SubRx @'
  if((code==='KeyI'||code==='KeyB')&&G&&!G.over&&!repeat){
'@ @'
  // v14.57, backpack audit finding 2: THE BACKPACK DOES NOT OPEN WHILE HE IS DOWN. v14.07 closes it on going down, and B or I
  // opened it again at once, so a tile could be held through the bleed-out into the death fade and past the end of the raid.
  // An open backpack can still be closed.
  if((code==='KeyI'||code==='KeyB')&&G&&!G.over&&!repeat&&(G.bagOpen||!(G.player&&(G.player.downed||G.player.dying)))){
'@
SubRx @'
  if(G&&!G.over&&G.bagOpen&&G.bagCells){
'@ @'
  if(G&&!G.over&&G.bagOpen&&G.bagCells&&!(G.player&&(G.player.downed||G.player.dying))){   // v14.57: not while down
'@
SubRx @'
var VER='14.56';
'@ @'
var VER='14.57';
'@

$pat = "(?m)^  now:'v14\.56:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v14.57: THE BACKPACK DOES NOT OPEN WHILE HE IS DOWN. Going down closed the backpack, but B or I opened it again at once, and a tile could be picked up and held through the bleed-out into the end of the raid. B and I now only close it while he is down or dying, and a tile cannot be picked up then. Check 14.57 presses I standing and downed in a live raid; it fails on v14.56',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
