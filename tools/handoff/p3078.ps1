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

# ARCADE CARDS GET THE 48PX X (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
body #attract .arcover .aoh:first-child{ color:var(--tx-2); }
'@ @'
body #attract .arcover .aoh:first-child{ color:var(--tx-2); }
/* v28.xx (cw-partyx2), the critic on 46 and 56 (3 of 5, three rounds): "no 48x48 ghost X at the top right of the card header, the one close place every other window has". The how to play and board cards get the 48px ghost X (1px line, 4px radius, light glyph) in the top right corner, as the pause box and the operator card have. Any button still closes the page, the X shows where. Restyle only. */
body #attract .arcpage::after{ content:'\00d7'; position:absolute; top:calc(var(--sp-2) * var(--attz,1)); right:calc(var(--sp-3) * var(--attz,1)); box-sizing:border-box; width:calc(var(--btn-h-sm) * var(--attz,1)); height:calc(var(--btn-h-sm) * var(--attz,1)); display:flex; align-items:center; justify-content:center; border:1px solid var(--ui-line-hi); border-radius:var(--rad); color:var(--tx-1); font:400 calc(var(--fs-title) * var(--attz,1))/1 var(--f-cond); pointer-events:none; }
'@

SubRx @'
var VER='30.77';
'@ @'
var VER='30.78';
'@

$pat = "(?m)^  now:'v30\.77:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v30.78: The how to play and board cards show a 48px X in the top right corner. Check 30.78 fails on v30.77',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
