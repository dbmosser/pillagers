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

# SHORT EXTRACTION SIREN (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
var XALARM_GAP=1.8;   // v27.xx (xalarm): seconds between throbs of the extraction alarm
'@ @'
var XALARM_GAP=1.8;   // v27.xx (xalarm): seconds between throbs of the extraction alarm
var XALARM_LEN=4;   // v33.35 (cw-xalarmshort), HIS ORDER (2026-10-20): "extraction siren is intrusive, it doesn't need to go off the entire time, just for maybe 4 seconds when the extraction is first called, and 4 seconds before the extraction actually starts". Seconds of siren at each end of the wait; replaces the whole-time loop of answer 41
'@

SubRx @'
if(z.beaconT===null||z.beaconT===undefined){ z.alarmT=undefined; continue; }
'@ @'
if(z.beaconT===null||z.beaconT===undefined){ z.alarmT=undefined; z.alarmAge=0; continue; }
'@

SubRx @'
if(z.alarmT===undefined) z.alarmT=XALARM_GAP;
'@ @'
z.alarmAge=(z.alarmAge||0)+dt;   // v33.35 (cw-xalarmshort): siren only in the first XALARM_LEN s after the call and the last XALARM_LEN s before the ship arrives (beaconT 0); none while the ship holds
      var _xaOn=(z.beaconT>0&&(z.alarmAge<=XALARM_LEN||z.beaconT<=XALARM_LEN));
      if(z.alarmT===undefined||!_xaOn) z.alarmT=XALARM_GAP;
'@

SubRx @'
if(z.alarmT>=XALARM_GAP){ z.alarmT=0; blip('xalarm'); }
'@ @'
if(_xaOn&&z.alarmT>=XALARM_GAP){ z.alarmT=0; blip('xalarm'); }
'@

SubRx @'
var VER='33.34';
'@ @'
var VER='33.35';
'@

$pat = "(?m)^  now:'v33\.34:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v33.35: The extraction siren sounds for 4 seconds after the call and the last 4 seconds before the ship arrives, then stops. Check 33.35 fails on v33.34',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
