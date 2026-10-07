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

# BARE HANDS STOWED SHOW NO AMMO (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
    var _cornStow='STOWED  '+p.sec.name+'  '+p.secAmmo;
'@ @'
    var _cornStow='STOWED  '+p.sec.name+((p.sec.mag>0)?'  '+p.secAmmo:'');   // v18.61, seen on the raid screenshot (2026-10-07): bare hands read STOWED Bare Hands 0; a weapon with no magazine shows no count, as the held line says MELEE
'@

SubRx @'
var VER='18.60';
'@ @'
var VER='18.61';
'@

$pat = "(?m)^  now:'v18\.60:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v18.61: The weapon panel reads STOWED  Bare Hands, without a stray 0. Check 18.61 fails on v18.60',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
