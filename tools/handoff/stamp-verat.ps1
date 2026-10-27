# stamp-verat.ps1 : his order 10-27 (cw-verdate): every version number the game shows carries the date and time of that build, US Eastern.
# ship.sh start runs this right after the p-file. It sets var VER_AT to now (Eastern), and var WHATSNEW_AT too when the
# var WHATSNEW_VER line differs from the previous build's (a card ship). A build without the VER_AT line is left alone.
param([string]$Game='dark_raiders.html',[string]$Prev='')
$ErrorActionPreference='Stop'
$s=[IO.File]::ReadAllText($Game)
$now=[TimeZoneInfo]::ConvertTimeBySystemTimeZoneId([DateTime]::UtcNow,'Eastern Standard Time').ToString('yyyy-MM-dd HH:mm')
$rx="(?m)^var VER_AT='[^']*';"
$n=([regex]::Matches($s,$rx)).Count
if($n -eq 0){ Write-Output 'stamp-verat: no VER_AT line, left alone'; exit 0 }
if($n -ne 1){ throw "stamp-verat: VER_AT matched $n times" }
$s=[regex]::Replace($s,$rx,"var VER_AT='$now';")
$said="VER_AT $now"
if($Prev -and (Test-Path $Prev)){
  $wr="(?m)^var WHATSNEW_VER='[^']*';"
  $a=[regex]::Match($s,$wr).Value; $b=[regex]::Match([IO.File]::ReadAllText($Prev),$wr).Value
  $ar="(?m)^var WHATSNEW_AT='[^']*';"
  if($a -and $a -ne $b -and ([regex]::Matches($s,$ar)).Count -eq 1){ $s=[regex]::Replace($s,$ar,"var WHATSNEW_AT='$now';"); $said+=", WHATSNEW_AT $now" }
}
[IO.File]::WriteAllText($Game,$s,(New-Object Text.UTF8Encoding $false))
Write-Output "stamp-verat: $said"
