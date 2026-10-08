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

# A CONTRACT COUNT NEVER SITS ALONE ON A LINE (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
txt:_cdTxt+'  '+CD.prog+'/'+CD.n});
'@ @'
txt:_cdTxt+'\u00a0\u00a0'+CD.prog+'/'+CD.n});   // v18.72, seen on the 4K raid screenshot (2026-10-07): the count is glued to the last word with non-breaking spaces, so the panel wrap never leaves 0/1 alone on a line
'@

SubRx @'
var VER='18.71';
'@ @'
var VER='18.72';
'@

$pat = "(?m)^  now:'v18\.71:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v18.72: In the raid contracts panel each count stays on the line with its contract. Check 18.72 fails on v18.71',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
