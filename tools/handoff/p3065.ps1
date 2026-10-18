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

# TITLE: LET THE WORLD SHOW (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
linear-gradient(90deg, rgba(17,19,21,.8) 0%, rgba(17,19,21,.9) 26%, rgba(17,19,21,.9) 74%, rgba(17,19,21,.8) 100%);
    -webkit-backdrop-filter:blur(4px); backdrop-filter:blur(4px); }
'@ @'
linear-gradient(90deg, rgba(17,19,21,.7) 0%, rgba(17,19,21,.58) 26%, rgba(17,19,21,.58) 74%, rgba(17,19,21,.7) 100%);
    -webkit-backdrop-filter:blur(3px); backdrop-filter:blur(3px); }   /* v28.xx (cw-title-scrim), the critic (3 of 5, P2): the backdrop was so dark it read flat. Centre column scrim .9 to .58, sides .8 to .7, blur 4 to 3px, so the live world shows (Q52). */
'@

SubRx @'
var VER='30.64';
'@ @'
var VER='30.65';
'@

$pat = "(?m)^  now:'v30\.64:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v30.65: The title backdrop is brighter. Check 30.65 fails on v30.64',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
