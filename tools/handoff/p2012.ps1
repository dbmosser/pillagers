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

# PILLAGERS WEAR THEIR OWN LOOK (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
pack:pick('pack'),patch:pick('patch'),tattoo:pick('tattoo')};
'@ @'
pack:pick('pack'),patch:pick('patch'),tattoo:pick('tattoo'),build:pick('build')};   // v20.12: and a build, picked last so every other pick is as before
'@

SubRx @'
patch:_look.patch, tattoo:_look.tattoo,
'@ @'
patch:_look.patch, tattoo:_look.tattoo, build:_look.build,
'@

SubRx @'
e.tattoo=lk.tattoo; }
'@ @'
e.tattoo=lk.tattoo; e.build=lk.build; }
'@

SubRx @'
          {own:e2,moving:!!e2.moving,sprint:e2.state==='extract',ads:e2.state==='chase',hurt:e2.hitT,bulk:e2.bulk||0});
'@ @'
          {own:e2,moving:!!e2.moving,sprint:e2.state==='extract',ads:e2.state==='chase',hurt:e2.hitT,bulk:e2.bulk||0,
           // v20.12, found by the build design review (2026-10-08): his answer 20 (v10.18) gives every pillager a look from the racks,
           // stored on him at spawn, but drawOp reads a look from this object and never from own, so every pillager was drawn in the
           // default look. It is passed through now, with the build he rolled.
           hair:e2.hair,cut:e2.cut,hat:e2.hat,skin:e2.skin,beard:e2.beard,eyes:e2.eyes,faceMark:e2.faceMark,boots:e2.boots,
           gloves:e2.gloves,pack:e2.pack,patch:e2.patch,tattoo:e2.tattoo,build:e2.build});
'@

SubRx @'
var VER='20.11';
'@ @'
var VER='20.12';
'@

$pat = "(?m)^  now:'v20\.11:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v20.12: Rival pillagers show their own hair, skin, hats and builds. Check 20.12 fails on v20.11',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
