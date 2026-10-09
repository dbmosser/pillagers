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

# THE RUN CARD HEADINGS ARE READABLE (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
  <div style="font-size:10.5px;color:var(--ash);letter-spacing:.2em;margin-top:16px">HOW DID THAT RUN FEEL</div>
'@ @'
  <!-- v21.37, from the whole-game bug hunt of 2026-10-08 (W-E2), seen on the 4K run card screenshots: THE RUN CARD HEADINGS ARE
       READABLE. HOW DID THAT RUN FEEL was 10.5 px, the smallest text on the card and smaller than the tags it heads, so from the
       couch it was hard to read. It is 12.5 px now, a touch under the tags so it still reads as their heading, and HOW IT WENT
       on a death card matches it. -->
  <div style="font-size:12.5px;color:var(--ash);letter-spacing:.2em;margin-top:16px">HOW DID THAT RUN FEEL</div>
'@

SubRx @'
            '<div style="font-size:10.5px;letter-spacing:.2em;color:var(--ash);margin-bottom:6px">HOW IT WENT</div>'+
'@ @'
            '<div style="font-size:12.5px;letter-spacing:.2em;color:var(--ash);margin-bottom:6px">HOW IT WENT</div>'+   // v21.37 (W-E2): the same size as HOW DID THAT RUN FEEL
'@

SubRx @'
var VER='21.36';
'@ @'
var VER='21.37';
'@

$pat = "(?m)^  now:'v21\.36:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v21.37: The headings on the death and extract card are bigger and easier to read. Check 21.37 fails on v21.36',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
