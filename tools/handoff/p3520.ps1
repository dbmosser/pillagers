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

# NEW IN CARD NAMES YOUR BUILD (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
ctx.fillText('NEW IN '+verShown(WHATSNEW_VER,1),wnX+LH(22),wnY+LH(32));
'@ @'
ctx.fillText('NEW IN '+verShown(VER),wnX+LH(22),wnY+LH(32));   // v35.xx (cw-newinver), HIS ORDER (2026-10-27): he read v0.1137 off this card while playing v0.1149 and took it for an old build ("nope the main PC ... is serving v0.1137"). The card names the build he plays, so the menu shows one version number. WHATSNEW_VER still stamps the list and decides when the card is new.
'@

SubRx @'
if(S) S.textContent='NEW IN '+verShown(WHATSNEW_VER,1);
'@ @'
if(S) S.textContent='NEW IN '+verShown(VER);   // v35.xx (cw-newinver): the build he plays, like the floor card (WHATSNEW_VER read as an older build)
'@

SubRx @'
var VER='35.19';
'@ @'
var VER='35.20';
'@

$pat = "(?m)^  now:'v35\.19:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v35.20: the new in card shows the build you play Check 35.20 fails on v35.19',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
