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

# THE PILLAGER BOARD READS AT 16 PX (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
var LW=LH(214),LH1=LH(11);
'@ @'
var LW=LH(230),LH1=LH(14);   // v28.xx (cw-hudroster), the critic (o-120d, o-01, o-09f): "eight rows of 14-15px text set at equal weight form a dense block", "rows are about 12px, unreadable from a couch". The rows go to the label size (about 16.8 px on screen, the style guide floor is 16; they were 14), the pitch and the panel width follow it (was 214 wide and 11 a row)
'@

SubRx @'
  ctx.font=FS(TYPE.micro);
  ctx.fillStyle=HUDC.text;   // v28.xx (cw-hudquiet), the critic: the board title was amber while the run info title is cream; one title colour, amber stays for focus and warnings
'@ @'
  ctx.font=FS(TYPE.label);   // v28.xx (cw-hudroster): the title and every row at the label size (was micro)
  ctx.fillStyle=HUDC.text;   // v28.xx (cw-hudquiet), the critic: the board title was amber while the run info title is cream; one title colour, amber stays for focus and warnings
'@

SubRx @'
var VER='36.75';
'@ @'
var VER='36.76';
'@

$pat = "(?m)^  now:'v36\.75:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v36.76: The pillager board text is bigger and easier to read. Check 36.76 fails on v36.75',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
