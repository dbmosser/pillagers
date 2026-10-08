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

# THE TITLE STEP CARDS ARE SOLID (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
     background:linear-gradient(180deg,rgba(127,146,216,.10),rgba(0,0,0,.32)); box-shadow:0 10px 30px rgba(0,0,0,.25), inset 0 1px 0 rgba(255,255,255,.06); }
'@ @'
     background:linear-gradient(180deg,rgba(30,38,72,.92),rgba(9,13,28,.92)); box-shadow:0 10px 30px rgba(0,0,0,.25), inset 0 1px 0 rgba(255,255,255,.06); }   /* v18.73, seen on the 4K title screenshot (2026-10-07): the Undercroft behind the title showed through the three step cards, a head inside 2 PILLAGE; solid like the mode rows (v18.67) */
'@

SubRx @'
var VER='18.72';
'@ @'
var VER='18.73';
'@

$pat = "(?m)^  now:'v18\.72:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v18.73: The three step cards on the title are solid. Check 18.73 fails on v18.72',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
