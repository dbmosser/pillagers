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

# A TEAMMATE WHO HIRED A MAN KEEPS HIM THROUGH A PARTY RAID HE NEVER WENT ON (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
  NET.status='Your party ascended together.'; NET.err='';
'@ @'
  G.netUp=1;   // v17.22, co-op hunt 2026-09-28: this raid was built from the host word, with the host hire; this window own hire did not go up
  NET.status='Your party ascended together.'; NET.err='';
'@

SubRx @'
  if(P.merc&&!G.sim){
'@ @'
  // v17.22, co-op hunt 2026-09-28: not on a party raid this window joined (G.netUp). That raid carried the host hire; P.merc here is
  // this window own hire, put back by netUpStart for a later raid, and settling it spent his fee on a man who never went up.
  if(P.merc&&!G.sim&&!G.netUp){
'@

SubRx @'
var VER='17.21';
'@ @'
var VER='17.22';
'@

$pat = "(?m)^  now:'v17\.21:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v17.22: Co-op hunt 2026-09-28, hire: netUpStart builds a linked window copy of the party raid with the host hire in P.merc and then puts the teammate own hire back, as it does for the Data Core, but endRaid in that window settled whatever P.merc held and cleared it, so the teammate own paid hire was spent on a raid it never went on, and the settle read the host man in his world (a cut, a death benefit, or left out there, written to his own man standing). netUpStart now marks the raid G.netUp once it is built from the host word, and the endRaid settle skips a raid so marked, leaving his hire as netUpStart put it back. The hire spent at the lift (v16.xx hire-refresh) already skips a party guest build. No number moved and no new words. Check 17.22 fails on v17.21',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
