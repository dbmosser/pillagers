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

# THE F1 CONTROLS HINT HAS A PLATE (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
ctx.fillText(legendKeys('F1')+'  controls',14,_hy);
'@ @'
{ var _f1t=legendKeys('F1')+'  controls', _f1w=Math.round(ctx.measureText(_f1t).width+LH(16)); /* v28.xx (cw-f1plate), the critic (2026-10-19): the f1 controls hint is dim grey over a busy map with no plate. It sits on the HUD plate in the quiet grey text colour. */ hudPlate(8,Math.round(_hy-LH(14)),_f1w,LH(22),null,HUDC.plate); ctx.fillStyle=UIC.tx_2; ctx.fillText(_f1t,16,_hy); }
'@

SubRx @'
var VER='32.13';
'@ @'
var VER='32.14';
'@

$pat = "(?m)^  now:'v32\.13:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v32.14: The f1 controls hint is on a plate and reads on any ground. Check 32.14 fails on v32.13',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
