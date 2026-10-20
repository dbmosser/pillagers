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

# THE FIRE CHIP IS GREY, NOT LIME (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
_ks.forEach(function(q){ hudKey(q.s.slice(1,-1),q.x,_y,_a,q.w); });
'@ @'
_ks.forEach(function(q){ hudKey(q.s.slice(1,-1),q.x,_y,_a,q.w,{fill:'#3b434b',ink:UIC.tx_1}); });   // v28.xx (cw-firechip), the critic (2026-10-20): the fire chip had a lime fill beside the lime selected slot, two lime fills. The belt caption keycaps are a quiet grey chip now; lime stays on the selected slot.
'@

SubRx @'
var VER='32.23';
'@ @'
var VER='32.24';
'@

$pat = "(?m)^  now:'v32\.23:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v32.24: The fire chip above the belt is grey with light text; lime is only on the selected slot. Check 32.24 fails on v32.23',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
