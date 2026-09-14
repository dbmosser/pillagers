$ErrorActionPreference = 'Stop'
trap { Write-Output "FAILED: $_"; exit 1 }
$p = 'C:\claudecode\dark raiders\dark_raiders.html'
$s = [IO.File]::ReadAllText($p)
$n = 0
function SubRx([string]$old, [string]$new) {
  $pat = ($old -split "`n" | ForEach-Object { [regex]::Escape($_.TrimEnd("`r")) }) -join "\r?\n"
  $c = ([regex]::Matches($script:s, $pat)).Count
  if ($c -ne 1) { throw "regex matched $c times: $($old.Substring(0,[Math]::Min(70,$old.Length)))" }
  $script:s = [regex]::Replace($script:s, $pat, { param($m) $new })
  $script:n++
}

SubRx @'
  var line='<b>Going up with:</b> '+(w?escHtml(w.name):'a gun issued at the lift');
'@ @'
  var line='<b>Going up with:</b> '+(w?escHtml(w.name):'a gun issued at the lift');
  // v14.67, ascent audit finding 3: AND HIS OWN GUN 2. With gun 1 emptied and his own gun put in gun 2, the raid issues a loaner
  // in hand and brings his gun as gun 2, riding the gun rules, so a death can lose it; the last screen before the lift named
  // only the loaner. Gun 2 is named whenever it is his own gun and not the gun in slot 1.
  var _s2=P.equippedSec;
  if(_s2&&_s2!=='none'&&_s2!=='fists'&&WEAPONS[_s2]&&(P.weapons||[]).indexOf(_s2)>=0&&_s2!==P.equipped) line+=', and your '+escHtml(WEAPONS[_s2].name)+' as gun 2';
'@
SubRx @'
var VER='14.66';
'@ @'
var VER='14.67';
'@

$pat = "(?m)^  now:'v14\.66:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v14.67: THE SECTOR PAGE NAMES HIS OWN GUN 2. With gun 1 empty and his own gun in gun 2, the raid issues a loaner in hand and brings his gun as gun 2, where a death can lose it, but the page before the lift named only the loaner. It now names gun 2 whenever it is his own gun. Check 14.67 fills the sector page with gun 1 empty and his gun in gun 2; it fails on v14.66',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
