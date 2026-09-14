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

SubRx @'
  if(lampsOnly){
    hint.textContent=nm+(isDay()
'@ @'
  if(lampsOnly){
    // v14.66, ascent audit finding 2: UNDER BLACKOUT PROTOCOL THE HINT PROMISES NO BONUS. Since v14.28 lamp-killing weather under
    // the term is never hard weather, because the term places no lamps, but this hint still said the XP pays 1.1x at night and
    // that daylight depended on the hour. It says there is no bonus.
    if(typeof hasTerm==='function'&&hasTerm('blackout')){ hint.textContent=nm+'. No bonus: under Blackout Protocol there are no lamps to kill.'; return; }
    hint.textContent=nm+(isDay()
'@
SubRx @'
var VER='14.65';
'@ @'
var VER='14.66';
'@

$pat = "(?m)^  now:'v14\.65:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v14.66: THE WEATHER HINT DOES NOT PROMISE A BONUS BLACKOUT PROTOCOL CANCELS. Since v14.28 blackout weather under the term pays no hard weather XP, because the term places no lamps, but the sector page still promised 1.1x at night. With the term signed the hint now says there is no bonus. Check 14.66 reads the hint for blackout weather at night with and without the term; it fails on v14.65',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
