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
    tickReload(dt);   // v13.83, combat audit: and the reload keeps going through a roll
    tryExtractTick(dt);
    return;
'@ @'
    tickReload(dt);   // v13.83, combat audit: and the reload keeps going through a roll
    // v15.08, throwables audit finding 6: A COOKED FRAG CHARGE KEEPS BURNING THROUGH A ROLL. This branch returns before both
    // fuse ticks, so a roll stopped the fuse and the COOKING countdown for the whole 0.38s, and two rolls held a live Frag
    // Charge about 0.76s past its fuse, against the v13.62 rule that a cooked grenade keeps burning. Not gated on the trigger:
    // a release cannot throw mid-roll, so the grenade is still in hand. The roll cover is dropped at the cook-off, because
    // damagePlayer ignores a hit while p.iv runs and the blast in his hand would otherwise do nothing. No seeded draw.
    if(p.cooking&&p.cookKind==='frag'){ p.cookT=(p.cookT||0)+dt; if(p.cookT>=FRAG_FUSE){ p.iv=0; cookOff(); } }
    tryExtractTick(dt);
    return;
'@
SubRx @'
var VER='15.07';
'@ @'
var VER='15.08';
'@

$pat = "(?m)^  now:'v15\.07:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v15.08: A COOKED FRAG CHARGE KEEPS BURNING THROUGH A ROLL. With the pin out, a roll stopped the fuse and the COOKING countdown for the whole roll, so two rolls held a live Frag Charge in hand about three quarters of a second past its fuse. The fuse now burns through a roll, and if it runs out mid-roll it goes off in his hand with the roll cover dropped. Check 15.08 cooks a Frag Charge, rolls and reads the fuse and the cook-off; it fails on v15.07',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
