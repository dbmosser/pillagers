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

# THE DEATH CARD SHOWS WHAT YOU LOST BIGGER (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
lines.push(iconImgHTML(_lk2,24)+
'@ @'
lines.push(iconImgHTML(_lk2,32)+
'@

SubRx @'
        lines.push((ITEMS['gun_'+gone[j].id]?iconImgHTML('gun_'+gone[j].id,24)
'@ @'
        lines.push((ITEMS['gun_'+gone[j].id]?iconImgHTML('gun_'+gone[j].id,32)
'@

SubRx @'
      else lines.push((ITEMS['gun_'+gone[j].id]?iconImgHTML('gun_'+gone[j].id,24)
'@ @'
      else lines.push((ITEMS['gun_'+gone[j].id]?iconImgHTML('gun_'+gone[j].id,32)
'@

SubRx @'
var VER='20.20';
'@ @'
var VER='20.21';
'@

$pat = "(?m)^  now:'v20\.20:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v20.21: The death card pictures of what you lost are bigger. Check 20.21 fails on v20.20',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
