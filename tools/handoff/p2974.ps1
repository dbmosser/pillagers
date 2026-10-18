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

# Run over card: the column is centred (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
body #attract[style*="block"]:has(.arcover[style*="block"]) .arcover{ position:relative;
'@ @'
/* v28.xx (cw-party-over4): the recorded clip element stays in the page flow and pushed the column to the bottom (seen in the picture of v29.73); it goes behind. */
body #attract[style*="block"]:has(.arcover[style*="block"]) > video{ position:absolute; left:0; top:0; }
body #attract[style*="block"]:has(.arcover[style*="block"]) .arcover{ position:relative;
'@

SubRx @'
var VER='29.73';
'@ @'
var VER='29.74';
'@

$pat = "(?m)^  now:'v29\.73:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v29.74: The run over screen is centred. Check 29.74 fails on v29.73',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
