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

# FROM THE 2026-09-08 READ-ONLY AUDIT, confirmed by a skeptic against the source.
# THIS IS MY OWN v8.18 BUILD, AND MY OWN CHECK CHOSE THE CASE THAT WORKS.
#
# The buy button is supposed to say how short he is. The branch that writes that
# sentence is gated on the row behind the panel being ENABLED, and that row
# disables itself the moment he cannot afford ONE unit. So the sentence can only
# ever appear when he can already afford some of the order and not all of it.
#
# The commonest refusal at that counter, by a mile, is wanting one thing he
# cannot afford at all. In that case the panel shows a greyed BUY with the price
# above it and no reason anywhere, while the sentence that explains it sits one
# line below in the source, unreachable.
#
# That is exactly the fault the crafting bench was rewritten for at v12.32, on
# his own note. And my v8.18 entry claims the button "says exactly how short he
# is", measured with a Bandage at 660 and 2,100 in hand: enough for three, so the
# row was enabled and the branch did fire. The case that happens most was never
# measured.
SubRx @'
  var _canAll=(P.credits>=o.price*qty);
  b.disabled=(btn?btn.disabled:true)||!_canAll;
  if(btn&&!btn.disabled&&!_canAll){
    var _short=(o.price*qty)-P.credits;
    b.textContent='NEED $'+_short.toLocaleString()+' MORE';
  }
'@ @'
  var _canAll=(P.credits>=o.price*qty);
  b.disabled=(btn?btn.disabled:true)||!_canAll;
  // v12.64, 2026-09-08 audit: THE SHORTFALL IS ABOUT MONEY, so it must not be
  // gated on the row being otherwise buyable. This test used to require the row
  // behind the panel to be ENABLED, and that row disables itself the moment he
  // cannot afford ONE unit, which is the commonest refusal at this counter by a
  // long way: so the only time the sentence could appear was when he could
  // already afford some of the order. The rest of the time he got a dead button
  // and no reason. Money is the reason unless something else is: a row disabled
  // while he CAN afford one is locked for its own reason and keeps its own
  // words, and everything else short of the price now says how short.
  var _otherLock=!!(btn&&btn.disabled&&(P.credits>=o.price));
  if(!_canAll&&!_otherLock){
    var _short=(o.price*qty)-P.credits;
    b.textContent='NEED $'+_short.toLocaleString()+' MORE';
  }
'@

# NEW IN.
SubRx @'
  'A CONTRACT THAT PAYS A GUN YOU ALREADY HAVE PAYS ITS VALUE INSTEAD. The card is written long before you claim it, so the gun it promised can be one you picked up in the meantime; it used to hand over nothing and print a receipt saying it had.',
'@ @'
  'A CONTRACT THAT PAYS A GUN YOU ALREADY HAVE PAYS ITS VALUE INSTEAD. The card is written long before you claim it, so the gun it promised can be one you picked up in the meantime; it used to hand over nothing and print a receipt saying it had.',
  'THE BUY BUTTON SAYS HOW SHORT YOU ARE, including when you cannot afford even one. That was the commonest refusal at the counter and the only one it answered with a dead grey button and no reason at all.',
'@

# STAMPS.
SubRx @'
var VER='12.63';
'@ @'
var VER='12.64';
'@
SubRx @'
var WHATSNEW_VER='12.63';
'@ @'
var WHATSNEW_VER='12.64';
'@
$cnt=([regex]::Matches($s,"now:'v12\.63:[^']*'")).Count
if($cnt -ne 1){ throw "DEVNOW v12.63 matched $cnt times" }
$s=[regex]::Replace($s,"now:'v12\.63:[^']*'",{ param($m) "now:'v12.64: from the 2026-09-08 read-only audit, and this is my own v8.18 build with my own check having chosen the case that works. The buy button is supposed to say how short he is, and the branch that writes that sentence was gated on the row behind the panel being ENABLED; that row disables itself the moment he cannot afford ONE unit. So the sentence could only ever appear when he could already afford some of the order and not all of it, and the commonest refusal at that counter by a long way, wanting one thing he cannot afford at all, showed a greyed BUY with the price above it and no reason anywhere, while the sentence that explains it sat one line below in the source, unreachable. That is exactly the fault the crafting bench was rewritten for at v12.32 on his own note. My v8.18 entry claims the button says exactly how short he is, measured with a Bandage at 660 and 2,100 in hand: enough for three, so the row was enabled and the branch did fire; the case that happens most was never measured. Money is the reason unless something else is: a row disabled while he CAN afford one is locked for its own reason and keeps its own words, and everything else short of the price now says how short. Check 12.64 opens the counter with less money than one unit costs and requires the button to name the shortfall, with controls for the case v8.18 measured, for an affordable order, and for a row locked for a reason that is not money; fails on v12.63.'" })
$n++

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count + 1
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
