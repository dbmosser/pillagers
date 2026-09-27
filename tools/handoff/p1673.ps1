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

# KID MODE GOES DOWN TO 1/20 (his order 2026-09-27, during his co-op session).

SubRx @'
var KID_OPTS=[[1,'OFF'],[0.5,'1/2'],[0.25,'1/4'],[0.2,'1/5'],[0.1,'1/10']];
'@ @'
var KID_OPTS=[[1,'OFF'],[0.5,'1/2'],[0.25,'1/4'],[0.2,'1/5'],[0.1,'1/10'],[0.05,'1/20']];   // v16.73, his order: and 1/20
'@

SubRx @'
var VER='16.72';
'@ @'
var VER='16.73';
'@

$pat = "(?m)^  now:'v16\.72:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v16.73: KID MODE GOES DOWN TO 1/20. His order during his co-op session: the kid mode row in Settings now offers 1/20 after 1/10, so player 2 takes a twentieth of every hit. Check 16.73 fails on v16.72',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
