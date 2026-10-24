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

# SETTINGS PANE HINT ENDS CLEANLY (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
function setHintShort(t){ var s=String(t||'').split(/[:;]|\. | \(/)[0].trim(); if(s.length>56){ s=s.slice(0,56); s=s.slice(0,Math.max(s.lastIndexOf(' '),1)); } return s; }
'@ @'
function setHintShort(t){ var s=String(t||'').split(/[:;]|\. | \(/)[0].trim(); if(s.length>90){ s=s.slice(0,88); s=s.slice(0,Math.max(s.lastIndexOf(' '),1))+'\u2026'; } return s; }   // v34.37 (cw-setscroll3): critic on Settings 18 (P0): the pane text stopped mid-sentence with no mark. The first clause stays whole up to 90 characters, longer ones end in an ellipsis.
'@

SubRx @'
var VER='34.37';
'@ @'
var VER='34.38';
'@

$pat = "(?m)^  now:'v34\.37:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v34.38: The Settings pane hint never stops mid-sentence. Check 34.38 fails on v34.37',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
