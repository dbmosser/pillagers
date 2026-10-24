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

# PROMPT PULSE STAYS BRIGHT (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
@keyframes attpulse{0%,100%{opacity:1}50%{opacity:.6}}';
'@ @'
@keyframes attpulse{0%,100%{opacity:1}50%{opacity:.85}}';   // v34.xx (cw-endpulse), the critic on 52 and 55: "press any key is small and dim grey" (the shot caught the pulse at .6): the faint end is .85 now
'@

SubRx @'
var VER='34.41';
'@ @'
var VER='34.42';
'@

$pat = "(?m)^  now:'v34\.41:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v34.42: The press any key prompt on end cards stays bright through its pulse. Check 34.42 fails on v34.41',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
