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
      if(dist(p,z)<1400){ blip('clank');
        say('Extraction left without you. Hold E to call for another, '+fmtMS(CFG.extractWait)+' out.'); }
'@ @'
      // v15.33, extraction audit finding: A MISSED EXTRACTION OFFERS ANOTHER CALL ONLY WHEN ONE CAN ARRIVE. This line told him to
      // hold E and call for another on every missed window, and two of those calls cannot work. A window the raid clock clamped
      // above ends with less than extractWait left, so a new call would arrive after the timer has ended the raid, which the call
      // line itself already warns of. And a point past its closing time stays open only while it is called: the call is cleared
      // just above, so the close loop below shuts it in this same tick and queues its closed line, and holding E there is refused
      // as CLOSED. Past the closing time the line now stops at its first sentence and leaves the news to that queued line; with
      // too little clock left it says a call cannot beat the clock; every other miss still offers the call and its wait.
      if(dist(p,z)<1400){ blip('clank');
        say('Extraction left without you.'+((z.closeAt!==undefined&&G.timeLeft<=z.closeAt)?'':((raidClockOn()&&G.timeLeft<CFG.extractWait)?' Another call cannot beat the raid clock.':(' Hold E to call for another, '+fmtMS(CFG.extractWait)+' out.')))); }
'@
SubRx @'
var VER='15.32';
'@ @'
var VER='15.33';
'@

$pat = "(?m)^  now:'v15\.32:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v15.33: A MISSED EXTRACTION OFFERS ANOTHER CALL ONLY WHEN ONE CAN ARRIVE. When a landed window ran out the line always said to hold E and call for another, even when the raid clock would end the raid before a new call could arrive, or the point was past its closing time and shut in that same moment. With too little clock left it now says a call cannot beat the raid clock, past the closing time it leaves the news to the point closed line, and every other miss still offers the call. Check 15.33 runs a staged window out at 200 s, at half an extraction wait and just past a closing time; it fails on v15.32',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
