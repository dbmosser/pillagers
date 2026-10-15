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

# A DEAD OVERSEER ENDS ITS RAMPAGE (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
    var b=ev.d.b, wps=[], qs=[0,1,2,3], seed=(((G.seed>>>0)^Math.imul((ev.n|0)+61,2654435761))>>>0)||1;
    if(!b||!(b.hp>0)) return;
'@ @'
    var b=ev.d.b, wps=[], qs=[0,1,2,3], seed=(((G.seed>>>0)^Math.imul((ev.n|0)+61,2654435761))>>>0)||1;
    if(!b||!(b.hp>0)||G.ents.indexOf(b)<0){ ev.d.over=1; return; }   // v28.63 (cloud-raid-rampagedead), CLOUD HUNT 2026-10-15: an Overseer killed in the warning ends the rampage, not a 120 s hunt by a dead boss
'@

SubRx @'
var VER='28.62';
'@ @'
var VER='28.63';
'@

$pat = "(?m)^  now:'v28\.62:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v28.63: An Overseer killed during the rampage warning now ends the rampage when the warning runs out, not two minutes later. Check 28.63 fails on v28.62',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
