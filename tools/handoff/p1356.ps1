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

# END-OF-RAID AUDIT OF 2026-09-14, finding 4: A CONTRACT FINISHED MID-RAID VANISHED FROM THE
# RUN LOG ON A DEATH OR ABANDON. A kill, open or district card completes during the raid
# and is noted in the run telemetry (contractsMid), but it is only copied into the logged
# contract list inside contractExtract, which runs on an extraction alone. Die after
# finishing one and the log row and the exported report show no contracts, while the card
# can still be claimed and paid at the Mainframe, so credits arrive that no run record
# explains. The log row now falls back to the mid-raid contracts when nothing was banked.
SubRx @'
    contractsBanked:(G.tel&&G.tel.contractsBanked)||null,
'@ @'
    // v13.56, end-of-raid audit: on a death or abandon contractExtract never runs, so the
    // cards finished during the raid are read straight from the raid's own record.
    contractsBanked:(G.tel&&(G.tel.contractsBanked||((G.tel.contractsMid&&G.tel.contractsMid.length)?G.tel.contractsMid.map(function(m){ return m.label; }):null)))||null,
'@
SubRx @'
var VER='13.55';
'@ @'
var VER='13.56';
'@

$pat = "(?m)^  now:'v13\.55:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v13.56: A CONTRACT FINISHED MID-RAID STAYS IN THE RUN LOG ON A DEATH. End-of-raid audit of 2026-09-14, finding 4: kill, open and district cards finished during the raid are noted in contractsMid, but only contractExtract copied them into the logged list, and it runs on an extraction alone, so dying after finishing one left the log row and the report with no contracts while the card still paid at the Mainframe. The log row now falls back to the mid-raid contracts when nothing was banked. Check 13.56 stages a mid-raid kill contract, dies, and requires it in the newest log row, with an extraction as the control; it fails on v13.55',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
