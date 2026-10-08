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

# WHAT IS NEW LINES END AT A WHOLE SENTENCE (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
  cut=rest.slice(0,WN_TAIL).replace(/\s+\S*$/,'');
'@ @'
  // v19.85, seen on the 4K What's New screenshot (2026-10-08): a line was cut mid-sentence (In co-op your teammate...) even when a
  // whole sentence fitted. When one does, the line ends at that full stop; otherwise it is cut at a word as before.
  cut=rest.slice(0,WN_TAIL);
  if(cut.lastIndexOf('. ')>=WN_TAIL*0.4) return head+' '+rest.slice(0,cut.lastIndexOf('. ')+1);
  cut=cut.replace(/\s+\S*$/,'');
'@

SubRx @'
var VER='19.84';
'@ @'
var VER='19.85';
'@

$pat = "(?m)^  now:'v19\.84:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v19.85: Lines on the What is New card end at a full sentence where they can. Check 19.85 fails on v19.84',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
