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

# NO BONUS DAMAGE ON PILLAGERS (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
if(Math.abs(Math.atan2(Math.sin(_bsa-en.face),Math.cos(_bsa-en.face)))<0.9){
'@ @'
// v27.xx (nohead), HIS ANSWER 31 (2026-10-13): "no, consistent damage is better in pillage battles, no weakspots/headshorts". A round
                // into a pillager's back paid half again as much; a pillager is hit for what the round does, from any side. Machines keep their weak spots
                // and the back shot bonus (the weak points are all on machines, and the Bulwark and the Warden are built around being flanked).
                if(en.kind!=='raider'&&Math.abs(Math.atan2(Math.sin(_bsa-en.face),Math.cos(_bsa-en.face)))<0.9){
'@

SubRx @'
var VER='27.05';
'@ @'
var VER='27.06';
'@

$pat = "(?m)^  now:'v27\.05:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v27.06: Pillagers take the same damage from every side. No more extra damage for shooting one in the back. Check 27.06 fails on v27.05',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
