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

# THE DOWNED CARD SELF-REVIVE KEY IS A KEYCAP (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
var _k1='['+keyLabel('KeyF','F')+']', _k2=' SELF-REVIVE, one per raid', _kw=ctx.measureText(_k1.toLowerCase()).width, _kx=W/2-(_kw+ctx.measureText(_k2.toLowerCase()).width)/2;
      ctx.textAlign='left'; ctx.fillStyle=UIC.acc; ctx.fillText(_k1,_kx,_rowY); ctx.fillStyle=UIC.tx_1; ctx.fillText(_k2,_kx+_kw,_rowY); ctx.textAlign='center';
'@ @'
// v36.79 (cw-downedpolish), critic on screen 34 (P1 'self-revive is the primary action but has no key chip'): the key stands on the shared keycap (hudKey, the one the prompts and the controls list use), then the words
      var _k1=keyLabel('KeyF','F'), _k2='SELF-REVIVE, one per raid', _ka=Math.round(_hD*0.72), _kgap=LH(8), _kw0=Math.max((_ka+LH(7))*0.9,hudRawW(_k1.toLowerCase())+LH(10))+LH(2), _kx=W/2-(_kw0+_kgap+ctx.measureText(_k2.toLowerCase()).width)/2;
      hudKey(_k1,_kx,_rowY,_ka,0); ctx.textAlign='left'; ctx.fillStyle=UIC.tx_1; ctx.fillText(_k2,_kx+_kw0+_kgap,_rowY); ctx.textAlign='center';
'@

SubRx @'
var VER='36.79';
'@ @'
var VER='36.80';
'@

$pat = "(?m)^  now:'v36\.79:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v36.80: The downed card shows the self-revive key on a keycap chip. Check 36.80 fails on v36.79',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
