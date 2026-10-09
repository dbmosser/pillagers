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

# THE ATTRACT TITLES READ OVER THE FOOTAGE (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
#attract .attpress{position:absolute;left:0;right:0;bottom:8%;
'@ @'
#attract .attpress{position:absolute;left:0;right:0;bottom:15%;padding:.28em 0;background:linear-gradient(90deg,transparent,rgba(0,0,0,.72) 22%,rgba(0,0,0,.72) 78%,transparent);
'@

SubRx @'
#attract .attname{position:absolute;left:0;right:0;top:6%;
'@ @'
#attract .attname{position:absolute;left:0;right:0;top:9%;padding:.18em 0;background:linear-gradient(90deg,transparent,rgba(0,0,0,.62) 22%,rgba(0,0,0,.62) 78%,transparent);
'@

SubRx @'
function attEl(){
'@ @'
// v21.53, seen on the first real attract clip (2026-10-09): PRESS ANY KEY sat on the recorded belt caption and PILLAGERS on the recorded clock,
// both hard to read over the footage. Each now sits on a soft dark band, and PRESS ANY KEY is raised clear of the belt row in the clip.
function attEl(){
'@

SubRx @'
var VER='21.52';
'@ @'
var VER='21.53';
'@

$pat = "(?m)^  now:'v21\.52:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v21.53: On the title gameplay clip, PILLAGERS and PRESS ANY KEY now read clearly over the footage. Check 21.53 fails on v21.52',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
