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
    var _rl=(typeof tod==='function'&&tod())?tod().lights:0;
    wc.strokeStyle='rgba(176,196,232,'+((0.20+_rr*0.09)*(1-0.45*_rl)).toFixed(3)+')';
'@ @'
    // v16.00, weather audit finding: RAIN AND FOG DRAW AT NIGHT STRENGTH ON EVERY NIGHT RAID. The darkness figure read here
    // was tod().lights with no isDay() gate, and tod() is the DAYLIGHT hour: pickTod rolls it on every raid, night included,
    // so the seeded stream stays in step, and at NIGHT it is a dead roll everywhere else (the cast and the dim above ask
    // isDay() first, and every lamp reads wx().lights*(isDay()?tod().lights:1), which is 1 at night). So on a NIGHT raid
    // whose hidden hour rolled 8am or noon (lights 0, two raids in five) the hairlines drew at 0.29, the full noon strength
    // v3.58 was written to cut, over the darkest scene the game has, and on an 8pm hour night the same rain drew at 0.16:
    // two night rain raids nearly twice apart in brightness with nothing on screen to explain it. At night the darkness
    // figure is 1, the figure the lamps use. By day this is byte for byte what it was. No number and no seeded draw moved.
    var _rl=isDay()?((typeof tod==='function'&&tod())?tod().lights:0):1;
    wc.strokeStyle='rgba(176,196,232,'+((0.20+_rr*0.09)*(1-0.45*_rl)).toFixed(3)+')';
'@
SubRx @'
    var _fl=(typeof tod==='function'&&tod())?tod().lights:0;
    var _fa=_fg*(1-0.40*_fl);
'@ @'
    // v16.00, weather audit finding: RAIN AND FOG DRAW AT NIGHT STRENGTH ON EVERY NIGHT RAID. The same fault as the rain
    // above: the haze read the daylight hour with no isDay() gate, so at NIGHT on an 8am or noon hour it drew at its full
    // noon strength and on an 8pm hour at 60 percent of that. At night the darkness figure is 1. By day nothing changes.
    var _fl=isDay()?((typeof tod==='function'&&tod())?tod().lights:0):1;
    var _fa=_fg*(1-0.40*_fl);
'@
SubRx @'
var VER='15.99';
'@ @'
var VER='16.00';
'@

$pat = "(?m)^  now:'v15\.99:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v16.00: RAIN AND FOG DRAW AT NIGHT STRENGTH ON EVERY NIGHT RAID. Every raid rolls a daylight hour, and at NIGHT that hour is hidden and does nothing, except that the rain hairlines and the fog haze still took their brightness from it: on a NIGHT raid whose hour rolled 8am or noon they drew at full noon strength over the darkest scene in the game, and on an 8pm hour at little more than half that, so two night raids in the same rain looked nearly twice apart in brightness. At night both now use the darkness figure the lamps use, so every night raid in rain or fog draws the same, and by day nothing changes. Check 16.00 draws rain and fog by day on the noon and 8pm hours and at night on the noon hour; it fails on v15.99',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
