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

# THE STASH BELT KEYS SHARE ONE ROW (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
  #hub[data-slayout="10"] [data-plan], #hub[data-slayout="6"] [data-plan], #hub[data-slayout="7"] [data-plan]{ width:76px !important; height:76px !important; }
'@ @'
  #hub[data-slayout="10"] [data-plan], #hub[data-slayout="6"] [data-plan], #hub[data-slayout="7"] [data-plan]{ width:76px !important; height:76px !important; }
  /* v18.98, seen on the 4K stash screenshot (2026-10-07): the tactical belt on the stash screen wrapped, keys 1 to 8 in a row and key 9 alone on a second line. The nine keys now always share one row, each shrinking to fit (never past its layout size) and staying square. */
  #hub #hotplanwrap > div > div{ flex-wrap:nowrap !important; }
  #hub #hotplanwrap [data-plan]{ flex:1 1 0 !important; min-width:0 !important; max-width:76px; height:auto !important; aspect-ratio:1/1; }
'@

SubRx @'
var VER='18.97';
'@ @'
var VER='18.98';
'@

$pat = "(?m)^  now:'v18\.97:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v18.98: The stash screen tactical belt always shows keys 1 to 9 in one row. Check 18.98 fails on v18.97',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
