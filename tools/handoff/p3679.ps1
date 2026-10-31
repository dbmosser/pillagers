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

# THE INBOUND LINE GIVES THE RING LETTER ROOM (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
    var _exS=holding?extractNowLine(_exL,G.shipHold):('EXTRACT '+_exL+' INBOUND  '+Math.ceil(G.beaconT)+'s');

'@ @'
    var _exS=holding?extractNowLine(_exL,G.shipHold):('EXTRACT  '+_exL+'  INBOUND  '+Math.ceil(G.beaconT)+'s');   // v36.xx (cw-xcountplate3): two spaces either side of the ring letter, as the landed line has, so its badge has room (the critic read 'extract(b)inbound')
'@

SubRx @'
    try{ var _exPre=TX(holding?'EXTRACT IN PROGRESS!  ':'EXTRACT '),
'@ @'
    try{ var _exPre=TX(holding?'EXTRACT IN PROGRESS!  ':'EXTRACT  '),
'@

SubRx @'
var VER='36.78';
'@ @'
var VER='36.79';
'@

$pat = "(?m)^  now:'v36\.78:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v36.79: The inbound extraction line has room around the ring letter badge. Check 36.79 fails on v36.78',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
