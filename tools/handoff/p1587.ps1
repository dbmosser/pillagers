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

# AT NIGHT THE SECTOR MAP HEADER NAMES A NIGHT HOUR. buildRaid rolls G.tod with pickTod on every raid, night included, to keep
# the seeded stream the same; every use of that hour is gated on isDay(), but the sector map header and the CONDITIONS row
# printed it with no gate, so a night raid could say noon, 8am or 6pm beside the weather.
SubRx @'
  // conditions belong on the map, since they change how far you can see
  ctx.textAlign='right';
  ctx.fillStyle=wx().id==='clear'?'#9aa8d0':'#4de3d0';
  ctx.fillText(tod().name+'  '+wx().name+
'@ @'
  // conditions belong on the map, since they change how far you can see
  ctx.textAlign='right';
  ctx.fillStyle=wx().id==='clear'?'#9aa8d0':'#4de3d0';
  // v15.87, sector audit finding: AT NIGHT THE SECTOR MAP HEADER NAMES A NIGHT HOUR. buildRaid rolls G.tod with pickTod on
  // every raid, night included, so the seeded stream stays the same, and every use of that hour is gated on isDay() (the lamp
  // level, the tint, the dim, lampBase), so at night it does nothing; but this header printed it with no gate, and three rolls
  // in five put noon, 8am or 6pm over a raid that went up in the dark, the same contradiction as his v3.59 note that golden
  // hour should not happen at night. At night the header now says night beside the weather; in daylight it names the rolled
  // hour as before. The CONDITIONS row in drawHUD is gated the same way. No number, no seeded draw and no existing sentence
  // moved.
  ctx.fillText((isDay()?tod().name:'night')+'  '+wx().name+
'@
SubRx @'
    if(MW.lightning) wv.push('lightning shows you');
    rows.push({k:MT.name+'   '+MW.name,v:(wv.length?wv.join(', '):''),
      c:MW.id==='clear'?'#9aa8d0':'#4de3d0'});
'@ @'
    if(MW.lightning) wv.push('lightning shows you');
    // v15.87, sector audit finding: AT NIGHT THE SECTOR MAP HEADER NAMES A NIGHT HOUR. The same hour label as the sector map
    // header, printed here with no isDay() gate, so at night this row read noon or 8am beside the weather while the surface
    // button on the sector page said NIGHT. It says night now when the surface is night, and names the rolled hour in daylight
    // as before. The effects list under it is unchanged.
    rows.push({k:(isDay()?MT.name:'night')+'   '+MW.name,v:(wv.length?wv.join(', '):''),
      c:MW.id==='clear'?'#9aa8d0':'#4de3d0'});
'@
SubRx @'
var VER='15.86';
'@ @'
var VER='15.87';
'@

$pat = "(?m)^  now:'v15\.86:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v15.87: AT NIGHT THE SECTOR MAP HEADER NAMES A NIGHT HOUR. The game rolls an hour of the day for every raid, and at night that hour does nothing, but the sector map header and the CONDITIONS row printed it anyway, so a raid that went up in the dark could say noon, 8am or 6pm beside the weather. At night both now say night beside the weather, and in daylight they name the rolled hour as before. Check 15.87 draws the sector map and the CONDITIONS panel with noon rolled, in daylight and at night; it fails on v15.86',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
