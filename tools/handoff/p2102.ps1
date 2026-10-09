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

# CONTRACT ROWS ARE ONE HEIGHT (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
  .crow .cp b{ color:var(--amber); font-weight:500; }
'@ @'
  .crow .cp b{ color:var(--amber); font-weight:500; }
  /* v21.02, from the 4K visual pass of 2026-10-08 (V-C7): A FINISHED CONTRACT IS AS TALL AS THE REST. Its CLAIM button was a full
     size button sitting in the small progress line, so that one row stood about a third taller than the others and the list lost
     its rhythm. Here the button is slimmer and overhangs its line a little into the row padding, so every row is the same height. */
  #root .crow .cp button{ min-height:0; padding:5px 16px; margin:-6px 0; }
'@

SubRx @'
var VER='21.01';
'@ @'
var VER='21.02';
'@

$pat = "(?m)^  now:'v21\.01:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v21.02: On the CONTRACTS list a finished contract with its CLAIM button is now the same height as the others. Check 21.02 fails on v21.01',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
