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

# THE NEXT GUN KEYCAP NAMES RB ON A CONTROLLER (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
          var _ct=_cpre+String(keyLabel(_cc,_cc.slice(3))), _cs=Math.round(bw*0.2), _cw, _ckx=bx+LH(4), _cky;
'@ @'
          // v28.xx (cw-padcap), CLOUD HUNT 2026-10-15: on a controller the next gun cap said D-DOWN (PADLABEL.KeyF), but D-DOWN opens
          // the item wheel; the pad walks the belt to the next gun on RB (logical button 5, as bound), so that cap names that button, as the controls card does.
          var _ct=_cpre+String((_cc==='KeyF'&&padOn())?padB(pbn(5)):keyLabel(_cc,_cc.slice(3))), _cs=Math.round(bw*0.2), _cw, _ckx=bx+LH(4), _cky;
'@

SubRx @'
var VER='29.03';
'@ @'
var VER='29.04';
'@

$pat = "(?m)^  now:'v29\.03:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v29.04: On a controller the tactical belts next gun keycap says RB, the button that changes to it. Check 29.04 fails on v29.03',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
