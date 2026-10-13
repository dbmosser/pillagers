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

# THE KEY LISTS SAY THE NEW BELT (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
['GEAR',[['1-9','select tactical belt slot'],['FIRE','use selected slot'],['G','quick throw'],['U','switch throwable'],['H','quick heal'],
'@ @'
['GEAR',[['1-4','guns'],['5-6','throwables'],['7-8','medical'],['9','armour plate'],['FIRE','use selected key'],['G','throw the chosen grenade'],['U','switch which grenade'],['H','tap heal, hold plate'],
'@

SubRx @'
  ['Q','melee'],['F','next gun'],['G','throw'],['H','heal'],['M','map'],
'@ @'
  ['Q','melee'],['F','next gun'],['G','throw'],['H','heal'],['U','switch throw'],
'@

SubRx @'
  ['1-9','tactical belt'],['B / I','backpack'],
'@ @'
  ['1-4','guns'],['B / I','backpack'],['5-9','throw, heal, plate'],['M','map'],
'@

SubRx @'
  ['TACTICAL BELT','1-9 selects, FIRE uses it.'],
'@ @'
  ['TACTICAL BELT','1-4 guns, 5-6 throw,'],
  ['','7-8 medical, 9 armour.'],
  ['','FIRE uses the key.'],
'@

SubRx @'
'+k('1-9')+' tactical belt &nbsp; '
'@ @'
'+k('1-4')+' guns &nbsp; '+k('5-6')+' throwables &nbsp; '+k('7-8')+' medical &nbsp; '+k('9')+' armour &nbsp; '
'@

SubRx @'
H quick heal &nbsp; 1-9 tactical belt &nbsp; B / I backpack
'@ @'
H quick heal &nbsp; 1-4 guns &nbsp; 5-6 throwables &nbsp; 7-8 medical &nbsp; 9 armour &nbsp; B / I backpack
'@

SubRx @'
var VER='25.99';
'@ @'
var VER='26.00';
'@

$pat = "(?m)^  now:'v25\.99:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v26.00: The key lists now say 1-4 guns, 5-6 throwables, 7-8 medical and 9 armour. Check 26.00 fails on v25.99',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
