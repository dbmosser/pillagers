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

# THE CROWBAR PAYS A PILLAGER THE SAME FROM BEHIND (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
if(Math.abs(Math.atan2(Math.sin(base-_me.face),Math.cos(base-_me.face)))<0.9) _mdm*=1.5;
'@ @'
if(_me.kind!=='raider'&&Math.abs(Math.atan2(Math.sin(base-_me.face),Math.cos(base-_me.face)))<0.9) _mdm*=1.5;   // v27.xx (crowbar15), the cloud review of 2026-10-15 (finding 14) and his answer 31: no bonus damage on a pillager, from any side; a machine keeps its blow from behind
'@

SubRx @'
var VER='27.88';
'@ @'
var VER='27.89';
'@

$pat = "(?m)^  now:'v27\.88:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v27.89: The crowbar does a pillager the same damage from behind as from the front. Check 27.89 fails on v27.88',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
