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

# THE BUILD TILES SHOW YOU IN EACH BUILD (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
  if(c.kind==='fit'||c.kind==='tattoo'||c.kind==='face'||c.kind==='hat'||c.kind==='beard'||c.kind==='cut'){   // v18.82: the piece on you (not BUILD: a build is not drawn from the rack in this view, so its previews were all alike)
'@ @'
  if(c.kind==='fit'||c.kind==='tattoo'||c.kind==='face'||c.kind==='hat'||c.kind==='beard'||c.kind==='cut'||c.kind==='build'){   // v18.82: the piece on you; v20.04: and BUILD, now that a build changes the body (v20.01)
'@

SubRx @'
var VER='20.03';
'@ @'
var VER='20.04';
'@

$pat = "(?m)^  now:'v20\.03:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v20.04: The FASHION BUILD tiles show you in Lean, Broad and Curved. Check 20.04 fails on v20.03',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
