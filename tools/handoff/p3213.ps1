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

# THE GUN NAME IS THE QUIET LINE OVER THE AMMO (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
  ctx.font=FS(TYPE.head); ctx.fillStyle=_heldGun?'#cdd6dd':(_HH.c||'#cdd6dd');
'@ @'
  // v28.xx (cw-ammoname), the critic (2026-10-19): 'ammo name as heavy as the number'. A gun's name is the quiet line over the hero ammo figure: the label size in the grey, not the head size in the bright white.
  ctx.font=_heldGun?FS(TYPE.label):FS(TYPE.head); ctx.fillStyle=_heldGun?UIC.tx_2:(_HH.c||'#cdd6dd');
'@

SubRx @'
var VER='32.12';
'@ @'
var VER='32.13';
'@

$pat = "(?m)^  now:'v32\.12:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v32.13: The gun name on the card is smaller and quieter than the ammo. Check 32.13 fails on v32.12',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
