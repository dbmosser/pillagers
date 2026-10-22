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

# TEAMMATE PAD LOST GLYPH (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
      if(icon){ ctx.save(); ctx.translate(24,20); ctx.strokeStyle=UIC.warn; ctx.lineWidth=2; ctx.stroke(icon); ctx.restore(); }
'@ @'
      // v28.xx (cw-cx-padlostglyph): the controller path is 18 units wide in a 24-unit box; show a full 24px glyph, with the same 2px stroke.
      if(icon){ ctx.save(); ctx.translate(20,16); ctx.scale(4/3,4/3); ctx.strokeStyle=UIC.warn; ctx.lineWidth=1.5; ctx.stroke(icon); ctx.restore(); }
'@

SubRx @'
var VER='34.11';
'@ @'
var VER='34.12';
'@

$pat = "(?m)^  now:'v34\.11:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v34.12: The teammate warning controller drawing is 24px wide with the same 2px stroke. Check 34.12 fails on v34.11',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
