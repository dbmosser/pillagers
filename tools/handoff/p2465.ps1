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

# THE STASH ANSWER LINE SITS IN THE FOOTER (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
  body:has(#opmodal.on) #hubtoast, body:has(#settingsmodal.on) #hubtoast{ bottom:26px; }
'@ @'
  body:has(#opmodal.on) #hubtoast, body:has(#settingsmodal.on) #hubtoast{ bottom:26px; }
  /* vNN.xx, UI REDESIGN ui5q1e (his #50, from the AAA judge of the stash shot): the stash has a footer bar now (ui6), and at 38 up
     the answer line sat on its hairline, half in the footer and half over the sell panel. On the stash it sits in the footer too,
     26 up, level with CLOSE, as in every station window. */
  body:has(#hub.on) #hubtoast{ bottom:26px; }
'@

SubRx @'
var VER='24.64';
'@ @'
var VER='24.65';
'@

$pat = "(?m)^  now:'v24\.64:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v24.65: On the stash the answer line sits in the footer bar, level with CLOSE. Check 24.65 fails on v24.64',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
