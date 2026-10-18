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

# VITALS BARS ONE WIDTH (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
    bar(16,by-46,280,16,p.armor/armorCap(),'#5aa9e6');
'@ @'
    bar(16,by-46,HBW,16,p.armor/armorCap(),'#5aa9e6');   /* v28.xx (cw-barsame), the critic (2026-10-19): the three vitals bars had three widths (360, 280, 280); all are HBW wide now */
'@

SubRx @'
  bar(16,by-25,280,12,p.stam/100,_stc);
'@ @'
  bar(16,by-25,HBW,12,p.stam/100,_stc);   /* v28.xx (cw-barsame): same width as the health bar */
'@

SubRx @'
  ctx.fillText(p.stamLock?'WINDED':'STAMINA',16+280+8,by-15);
'@ @'
  ctx.fillText(p.stamLock?'WINDED':'STAMINA',16+HBW+8,by-15);   /* v28.xx (cw-barsame): the word follows the longer bar */
'@

SubRx @'
var VER='31.16';
'@ @'
var VER='31.17';
'@

$pat = "(?m)^  now:'v31\.16:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v31.17: HP, armour and stamina bars are the same width. Check 31.17 fails on v31.16',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
