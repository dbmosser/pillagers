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

# THE FLOOR SAYS ITS MONEY ONCE (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
  if(!hubWinOn()) ctx.fillText('$'+P.credits.toLocaleString()+'  \u00b7  XP '+(P.xp||0).toLocaleString()+
'@ @'
  // v27.xx, UI CLEANUP uic9 (his 2026-10-14 note, from the 1080p shot of the Undercroft): THE FLOOR SAYS ITS MONEY ONCE. The line under the heading printed credits and XP in 9 px
  // type, the same two numbers the corner readout shows at 32 px; it keeps the stash and the runs, and the readout keeps the money.
  if(!hubWinOn()) ctx.fillText((
'@

SubRx @'
+P.runs+' run'+(P.runs===1?'':'s'),16,44);   // v8.56: said "1 runs" beside a correctly pluralised stash count
'@ @'
+P.runs+' run'+(P.runs===1?'':'s')).replace(/^\s+\S\s+/,''),16,44);   // v8.56: said "1 runs" beside a correctly pluralised stash count
'@

SubRx @'
var VER='27.56';
'@ @'
var VER='27.57';
'@

$pat = "(?m)^  now:'v27\.56:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v27.57: The line under THE UNDERCROFT no longer repeats credits and XP. Check 27.57 fails on v27.56',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
