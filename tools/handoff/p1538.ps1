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
    // v13.73, downed audit: and the stall shuts. Its only closer is on the standing path, so
    // it stayed open and trading over the DOWN screen for the whole bleed-out.
    if(G.trade){ G.trade=null; G.pedLock=1; }
'@ @'
    // v13.73, downed audit: and the stall shuts. Its only closer is on the standing path, so
    // it stayed open and trading over the DOWN screen for the whole bleed-out.
    if(G.trade){ G.trade=null; G.pedLock=1; }
    // v15.38, peddler audit finding 10: DOWNED AT THE STALL, THE PEDDLER PLATE STOPS OFFERING A DEAL. The plate over him reads
    // G.nearPed and G.pedBlocked, and both are written only on the standing path of updatePlayer, which the downed branch
    // returns before. So shot to the floor beside the Peddler, they kept the last standing frame and the plate went on saying
    // [E] DEAL (the pad button on a controller) for the whole bleed-out and after he crawled away, while E on the floor only
    // reaches the extraction and nothing could open. v14.08 cleared the door prompt below for the same frozen-prompt reason and
    // this pair was missed. Cleared here, the plate reads plain THE PEDDLER while he is down, and the first standing frame after
    // a revive finds the stall and offers the deal again. No player text, no number and no seeded draw moved.
    G.nearPed=null; G.pedBlocked=0;
'@
SubRx @'
var VER='15.37';
'@ @'
var VER='15.38';
'@

$pat = "(?m)^  now:'v15\.37:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v15.38: DOWNED AT THE STALL, THE PEDDLER PLATE STOPS OFFERING A DEAL. Shot to the floor beside the Peddler, the plate over him kept the last standing frame and went on reading [E] DEAL for the whole bleed-out and after he crawled away, while E on the floor could open nothing. Going down now clears what the plate reads, so it says only THE PEDDLER until he stands and the deal is offered again. Check 15.38 downs him 40 units from the Peddler, presses E on the floor and reads the drawn plate before, while down and after a self-revive; it fails on v15.37',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
