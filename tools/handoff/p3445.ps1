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

# INITIALS IN THE FOCUS COLOUR (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
#attract .arcover .aoi{color:#7fe3d4;margin-top:.55em}
'@ @'
#attract .arcover .aoi{color:var(--tx-2);margin-top:.55em}
'@

SubRx @'
span.cur{color:#ffc04a;border-bottom-color:#ffc04a}
'@ @'
span.cur{color:var(--acc);border-bottom-color:var(--acc)}
'@

SubRx @'
// The pad on the card: nw is the buttons newly pressed this poll
'@ @'
// v34.xx (cw-iniacc), the critic on 53 54 55 (3 of 5, 10-24): "the active initial is amber, not the lime accent" and a teal heading beside it. The active letter and its underline are the lime focus colour and the heading is tx-2 (guide: one accent, lime is focus). Restyle only; the words are job 96 and unchanged.
// The pad on the card: nw is the buttons newly pressed this poll
'@

SubRx @'
var VER='34.44';
'@ @'
var VER='34.45';
'@

$pat = "(?m)^  now:'v34\.44:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v34.45: The active initial letter is lime and the heading is grey, not amber and teal. Check 34.45 fails on v34.44',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
