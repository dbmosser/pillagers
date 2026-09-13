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

# A BRAND-NEW SAVE SAID CONTINUING.
#
# Found by walking a fresh save, the way every friend on itch starts. The save list
# on the title screen tags whichever save you are on as CONTINUING, and it did that
# for a save with no raids at all, right beside the line that says "0 raids". A
# player on his first ever launch was told he was continuing something.
#
# THE TAG NOW READS THE SAME NUMBER THE LINE PRINTS. slotInfo already returns the
# saved run count, and the line beside the tag uses it; the current save reads
# CONTINUING once it has a raid and NEW until then. No new field, no new rule.
#
# NOT HIS WORDING: none of his baked edits touches it, and no check keys on it.
SubRx @'
           (me?' <span style="font-size:10px;letter-spacing:.14em">CONTINUING</span>':'')+'</b>'+
'@ @'
           // v13.28: the current save said CONTINUING even with no raids on it, beside
           // the line reading 0 raids. The tag now reads the same run count.
           (me?' <span style="font-size:10px;letter-spacing:.14em">'+((inf&&inf.runs>0)?'CONTINUING':'NEW')+'</span>':'')+'</b>'+
'@

SubRx @'
var VER='13.27';
'@ @'
var VER='13.28';
'@

$pat = "(?m)^  now:'v13\.27:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v13.28: A BRAND-NEW SAVE SAID CONTINUING. Found by walking a fresh save, the way every friend on itch starts: the save list on the title screen tags whichever save you are on as CONTINUING, and it did that for a save with no raids at all, right beside the line that says 0 raids, so a player on his first ever launch was told he was continuing something. The tag now reads the same number the line prints: slotInfo already returns the saved run count and the line beside the tag uses it, so the current save reads CONTINUING once it has a raid and NEW until then, with no new field and no new rule. Not his wording, since none of his baked edits touches it, and no check keys on it',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
