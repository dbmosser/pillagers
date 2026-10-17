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

# THE HEAVY HELMET LOSES ITS NEON BAR (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
      wc.fillStyle=INK;       rrF(hx2-2.2,ty-50.2,4.4,10.2,1.6);
      wc.fillStyle=_SCH?_SCH.a:'#d8903a'; rrF(hx2-1.4,ty-49.6,2.8,9.0,1.2);

'@ @'
      // v28.xx (cw-helmbar), art build step (char-art-build-brief): "Fix in passing: the neon green bar on the Heavy helmet that reads like a glitch."
      // The crest was a tall bar in the raw scheme accent (neon green on Toxic) standing above the dome. It is a low steel ridge now, and the accent
      // sits only in a small lens on the brow (ink housing, glint), the glowing accent lens the gear-heavy look asks for.
      wc.fillStyle=INK;       rrF(hx2-1.9,ty-48.8,3.8,6.2,1.4);
      wc.fillStyle='#6d7882'; rrF(hx2-1.3,ty-48.3,2.6,5.2,1.0);
      wc.fillStyle='#9aa5b0'; wc.fillRect(hx2-1.3,ty-48.0,1.0,2.2);
      wc.fillStyle=INK;       rrF(hx2+fl*2.6-2.6,ty-40.2,5.2,3.4,1.2);
      wc.fillStyle=_SCH?_SCH.a:'#d8903a'; rrF(hx2+fl*2.6-1.8,ty-39.6,3.6,2.2,0.9);
      wc.fillStyle='#ffffff'; wc.fillRect(hx2+fl*2.6-1.4,ty-39.4,1.0,0.8);

'@

SubRx @'
var VER='28.78';
'@ @'
var VER='28.79';
'@

$pat = "(?m)^  now:'v28\.78:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v28.79: The Heavy Helmet has a steel crest and a small glowing lens instead of a tall neon bar. Check 28.79 fails on v28.78',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
