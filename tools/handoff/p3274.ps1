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

# PAUSE GLYPHS FOLLOW PAD LOSS (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
  padRelease(); PAD.on=false; PAD.mx=0; PAD.my=0; PAD.aiming=false;
'@ @'
  padRelease(); PAD.on=false; PAD.mx=0; PAD.my=0; PAD.aiming=false;
  try{ padBodyCls(); }catch(_plb){} /* v28.xx (cw-cx-padlostlegend): release the pad prompt style when polling detects loss, including an open pause box. */
'@

SubRx @'
var VER='32.73';
'@ @'
var VER='32.74';
'@

$pat = "(?m)^  now:'v32\.73:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v32.74: A lost pad releases its prompt style immediately. Same-slot A recovery stays intact. Check 32.74 fails on v32.73',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
