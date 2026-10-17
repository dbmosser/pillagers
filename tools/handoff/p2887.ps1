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

# PLAYER 2 FEELS THE OVERSEER CHANGE PHASE (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
  if(k==='phase'){ if(!G.sim) say(ovPhaseLine(m.n|0),'warn'); return 'mark:phase'; }   // v26.xx (ai24): the Overseer changed phase, said to the whole party
'@ @'
  if(k==='phase'){ if(!G.sim){ say(ovPhaseLine(m.n|0),'warn'); G.shake=Math.max(G.shake||0,6); } return 'mark:phase'; }   // v26.xx (ai24): the Overseer changed phase, said to the whole party   // v28.xx (cw-ovshake), CLOUD HUNT 2026-10-15: player 2 feels the same shake the host does (the alarm already comes over as a sound)
'@

SubRx @'
var VER='28.86';
'@ @'
var VER='28.87';
'@

$pat = "(?m)^  now:'v28\.86:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v28.87: In co-op, when THE OVERSEER changes phase, player 2s screen shakes too, just like player 1s. Check 28.87 fails on v28.86',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
