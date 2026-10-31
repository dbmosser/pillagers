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

# MEDAL ROW CLEAR OF THE CONTROLS CHIP (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
  MEDALBOX.h=Math.round(LH(40)*rs); MEDALBOX.y=bot-MEDALBOX.h;
'@ @'
  /* v28.xx (cw-medalchip): the medal row keeps the feed width (his o-209 order) and stays clear of the folded f1 controls chip (his note of 2026-10-25, the lower corner): on a short window the chip stands where the row's bottom edge reaches, so the row (and the feed on it) lifts to just over the chip */
  var _cs=(typeof legChipSpot==='function')?legChipSpot():null, _mh=Math.round(LH(40)*rs);
  if(_cs&&_cs.x<hudIns()+fw&&_cs.y+_cs.h>bot-_mh&&_cs.y<bot) bot=Math.min(bot,Math.round(_cs.y-LH(4)*rs));
  MEDALBOX.h=Math.round(LH(40)*rs); MEDALBOX.y=bot-MEDALBOX.h;
'@

SubRx @'
var VER='36.92';
'@ @'
var VER='36.93';
'@

$pat = "(?m)^  now:'v36\.92:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v36.93: In a short window the medal row stays above the folded controls chip, still as wide as the feed. Check 36.93 fails on v36.92',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
