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

# A SPECTATING HOST HAS NO BODY IN THE RAID (stability pass before his co-op session, 2026-09-27).

SubRx @'
          if(!_mOwn&&dist(b,p)<p.r+3){
'@ @'
          // v16.56, stability (co-op review): a host who left the raid and is spectating (v16.14) has no body in it. His
          // player stayed where he fell or extracted and still stopped enemy rounds, so a teammate saw red numbers on empty
          // ground, a round meant for him stopped short, and the host window played the grunts.
          if(!_mOwn&&!p.specOut&&dist(b,p)<p.r+3){
'@

SubRx @'
var VER='16.55';
'@ @'
var VER='16.56';
'@

$pat = "(?m)^  now:'v16\.55:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v16.56: A SPECTATING HOST HAS NO BODY IN THE RAID. Stability pass before a co-op session. When the host died or extracted and stayed on to watch the party, his player was left where he stood and still stopped enemy rounds: red numbers on empty ground for his teammate and rounds that stopped short. Rounds now pass where he stood. Check 16.56 fails on v16.55',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
