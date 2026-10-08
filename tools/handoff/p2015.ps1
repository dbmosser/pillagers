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

# NO ROSE MOUTH OVER A MASK (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
wc.fillStyle=(_BLD==='curved'&&!(OUTF&&/^(skeleton|robot|trooper)$/.test(OUTF.mark)))?'#c25a6c':'#8a5c46';
'@ @'
wc.fillStyle=(_BLD==='curved'&&!(OUTF&&/^(skeleton|robot|trooper)$/.test(OUTF.mark))&&!/^(mask|spartan|ghostmask)$/.test(HAT))?'#c25a6c':'#8a5c46';   /* v20.15, code review: nor over a mask or helmet worn as a hat */
'@

SubRx @'
var VER='20.14';
'@ @'
var VER='20.15';
'@

$pat = "(?m)^  now:'v20\.14:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v20.15: Masks and helmets no longer show a pink mouth on a Curved body. Check 20.15 fails on v20.14',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
