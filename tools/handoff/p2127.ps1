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

# NO CLOSES IN 0:00 ON A RING STILL RUNNING (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
if(Z.open&&(_zAct||_zHold)) ctx.fillText(
'@ @'
if(Z.open&&(_zAct||_zHold)&&(Z.closeAt===undefined||G.timeLeft>Z.closeAt)) ctx.fillText(   /* v21.27 (R9): a ring called before its cutoff runs past it; no 0:00 then */
'@

SubRx @'
var VER='21.26';
'@ @'
var VER='21.27';
'@

$pat = "(?m)^  now:'v21\.26:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v21.27: The map no longer says closes in 0:00 on an extraction that is still running. Check 21.27 fails on v21.26',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
