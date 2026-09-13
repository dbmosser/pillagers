$ErrorActionPreference = 'Stop'
trap { Write-Output "FAILED: $_"; exit 1 }
$p = 'C:\claudecode\dark raiders\dark_raiders.html'
$s = [IO.File]::ReadAllText($p)
$n = 0
function SubRx([string]$old, [string]$new) {
  $pat = ($old -split "`n" | ForEach-Object { [regex]::Escape($_.TrimEnd("`r")) }) -join "\r?\n"
  $c = ([regex]::Matches($script:s, $pat)).Count
  if ($c -ne 1) { throw "regex matched $c times: $($old.Substring(0,[Math]::Min(70,$old.Length)))" }
  $script:s = [regex]::Replace($script:s, $pat, { param($m) $new })
  $script:n++
}

# v13.30 is a HARNESS build: nothing in the game changes. The corpus runner takes a
# slice so it can run in parallel across separate-origin fixture servers.
SubRx @'
var VER='13.29';
'@ @'
var VER='13.30';
'@

$pat = "(?m)^  now:'v13\.29:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v13.30: A HARNESS BUILD, nothing in the game changes. His order of 2026-09-13 is to use the whole machine while he is away, and the corpus runner stepped all of its checks on one JavaScript thread in one hidden tab, about one of his sixteen threads for twenty-five minutes, with total CPU reading zero percent at the end. The runner now takes an optional slice of the list, and four more fixture servers run on ports 8803 to 8806, each its own origin so each shard has its own storage and none can inherit another shard profile, which is the contamination that made two tabs on one origin drift. Called with no arguments the runner is the same runner over the whole list, so every existing call and the loop step that makes it are unchanged. Adoption is gated on evidence: the union of four sharded runs must report the same checks, the same failures and the same skips as one ordinary run of the same build',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
