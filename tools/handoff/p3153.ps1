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

# THE CAPTION OVER THE BELT IS PROMPT SIZE (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
function beltCapFS(bw){ var a=beltFS(bw,0.12), b=hudFS(TYPE.micro),
'@ @'
/* v31.xx (cw-beltcap), the critic on screen 36 (2026-10-19): the line over the belt (scav pistol, fire, use) was the smallest print on the HUD, 13 px, unreadable from a couch. It takes the label size (15.6 px rendered, the size of prompts) and the emote strip and bars above it move up with it, as they already read this function. */
function beltCapFS(bw){ var a=beltFS(bw,0.12), b=hudFS(TYPE.label),
'@

SubRx @'
var VER='31.52';
'@ @'
var VER='31.53';
'@

$pat = "(?m)^  now:'v31\.52:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v31.53: The line over the weapon belt is bigger and easier to read. Check 31.53 fails on v31.52',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
