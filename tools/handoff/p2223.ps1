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

# A SHOT PILLBOX OR WARDEN DROPS ITS MARK (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
      e.moving=false;
      continue;
    }
    if(e.kind==='warden'){
'@ @'
      // v22.23, from the whole-game bug hunt of 2026-10-08 (K34): THE PILLBOX KEEPS ITS WATCH. It is bolted down and has no hunt or
      // search, but a round, a blast, a noise (its own gun included) or the extraction call put it in 'chase' or 'investigate', and
      // nothing here ever undid it: it wore a red or yellow mark for the rest of the raid, counted among the machines coming for the
      // ring and drove the heartbeat. Set last, after its own shot. Its alert is left alone; it sets that itself when it sees you.
      if(e.state!=='patrol') e.state='patrol';
      e.moving=false;
      continue;
    }
    if(e.kind==='warden'){
'@

SubRx @'
      var wantW=e.face;
'@ @'
      // v22.23 (K34): A WARDEN THAT HAS NOT SEEN YOU IS NOT HUNTING YOU. A round, a blast or a noise put it in 'chase' or
      // 'investigate', which this branch never reads or ends, so it kept the red mark as it wandered. Where it was sent stays in
      // tx/ty for its walk. One that has seen you hunts for good, as before. THE OVERSEER runs this branch too.
      if(!e.seenYou&&e.state!=='patrol') e.state='patrol';
      var wantW=e.face;
'@

SubRx @'
var VER='22.22';
'@ @'
var VER='22.23';
'@

$pat = "(?m)^  now:'v22\.22:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v22.23: A pillbox or a Warden you hit before it saw you no longer wears a hunting mark for the rest of the raid. Check 22.23 fails on v22.22',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
