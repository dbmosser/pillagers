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

# RIGHT-CLICK "EQUIP AS YOUR GUN" ON A STASH GUN LOST THE GUN. itemMenuRows is
# built for `key`; the equip row spliced the gun out of P.stash and then called
# clearKeysFor(k), and k is not declared anywhere in that function. The IIFE is
# 'use strict', so that is a ReferenceError thrown AFTER the splice: the push to
# P.weapons, the equip and the save never ran, and the gun was in neither the
# stash nor the armoury. The copy of this verb in the stash grid uses a
# loop-scoped k and was fine, which is why it was not seen sooner.
SubRx @'
      P.stash.splice(ix,1);
      clearKeysFor(k);                 // v8.51, audit: it left the backpack
      P.weapons.push(it.gk);
'@ @'
      P.stash.splice(ix,1);
      // v11.48: k was never declared in this function (the IIFE is 'use strict'),
      // so this line threw ReferenceError AFTER the splice and the gun was gone,
      // neither in the stash nor in the armoury. The row is built for key.
      clearKeysFor(key);               // v8.51, audit: it left the backpack
      P.weapons.push(it.gk);
'@

# STAMPS.
SubRx @'
var VER='11.47';
'@ @'
var VER='11.48';
'@
SubRx @'
var WHATSNEW_VER='11.47';
'@ @'
var WHATSNEW_VER='11.48';
'@
SubRx @'
  'THIS IS AN ALPHA. Things will break. When something does, the game writes it into your run report and tells you so; that report is how it gets fixed.',
'@ @'
  'THIS IS AN ALPHA. Things will break. When something does, the game writes it into your run report and tells you so; that report is how it gets fixed.',
  'A GUN YOU EQUIP FROM THE STASH MENU NO LONGER VANISHES. Right-clicking a looted gun in the stash and picking the equip line used to remove it from the stash and then fail before it reached your armoury, so the gun was simply gone. It now lands in your armoury and is equipped.',
'@
$cnt=([regex]::Matches($s,"now:'v11\.47:[^']*'")).Count
if($cnt -ne 1){ throw "DEVNOW v11.47 matched $cnt times" }
$s=[regex]::Replace($s,"now:'v11\.47:[^']*'",{ param($m) "now:'v11.48: right-click Equip as your gun on a stash gun lost the gun. itemMenuRows is built for key, but the equip row spliced the gun out of P.stash and then called clearKeysFor(k); k is undeclared in that function and the IIFE is use strict, so it threw ReferenceError after the splice and the push to P.weapons, the equip and the save never ran. The row now clears keys for key. The copy in the stash grid used a loop-scoped k and was fine. From the v11.46 audit, P0.'" })
$n++

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count + 1
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
