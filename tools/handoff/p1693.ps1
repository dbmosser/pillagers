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

# ESC OR TAB THAT SHUTS THE PAUSE BOX IN THE PLAYER 2 WINDOW NO LONGER PAUSES PLAYER 1 (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
  if(_pb&&_pb.classList.contains('on')){
    ev.stopPropagation(); ev.preventDefault();
'@ @'
  if(_pb&&_pb.classList.contains('on')){
    ev.stopPropagation(); ev.preventDefault();
    // v16.93, co-op hunt 2026-09-28: THE KEY THAT SHUTS THE BOX IS SPENT HERE. stopPropagation does not stop the later capture
    // listeners on this same window, so in the player 2 window netKeyFwd still handed this ESC or TAB to player 1, and one
    // press shut this box and paused player 1 (or shut his map or backpack) in his window too.
    if(ev.stopImmediatePropagation) ev.stopImmediatePropagation();
'@

SubRx @'
var VER='16.92';
'@ @'
var VER='16.93';
'@

$pat = "(?m)^  now:'v16\.92:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v16.93: Co-op hunt 2026-09-28, finding 12: the window capture listener that shuts the pause box on ESC or TAB called only stopPropagation, which does not stop later listeners on the same window. netKeyFwd, the v16.89 capture listener that hands every key in the player 2 window to player 1, is registered after it and still posted the same ESC or TAB, and the player 1 window played it as its own: RAID PAUSED opened there (wiping his held keys and trigger), or his open map or backpack shut, or on the floor his box toggled. The pause box listener now also calls stopImmediatePropagation next to its stopPropagation, so the key is spent on the box it shut. The only later capture listeners on window are netKeyFwd and the push to talk Y, neither of which needs ESC or TAB with the box open. The keyup is still handed on, which only clears a key on the host. No number and no player text moved. Check 16.93 fails on v16.92',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
