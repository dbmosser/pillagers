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

# ONE NAME FOR THE NUMBER KEYS (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
<div class="msub">Your inventory is your backpack plus your tactical belt. An item is in one or the other, never both.</div>
'@ @'
<div class="msub">Your inventory is your backpack plus your hotbar. An item is in one or the other, never both.</div>
'@

SubRx @'
<h2>Tactical belt</h2>
'@ @'
<h2>Hotbar</h2>
'@

SubRx @'
var TAGFWD={'Hotbar worked well':'Tactical belt worked well'};
'@ @'
var TAGFWD={'Tactical belt worked well':'Hotbar worked well'};   // v28.xx (cw-onehotbar), his word in every 10-27 order: "items on the hotbar", "hotbar swap". The row of number keys is the hotbar on every surface.
'@

SubRx @'
'Inventory fiddly','Tactical belt worked well','Loot boring'
'@ @'
'Inventory fiddly','Hotbar worked well','Loot boring'
'@

SubRx @'
"Thrown. Goes on a tactical belt key.":"Belt consumables ftw. "
'@ @'
"Thrown. Goes on a hotbar key.":"Hotbar consumables ftw. "
'@

SubRx @'
"Thrown. Goes on a tactical belt key. Makes 2.":"Belt consumables ftw."
'@ @'
"Thrown. Goes on a hotbar key. Makes 2.":"Hotbar consumables ftw."
'@

SubRx @'
return 'Thrown. Goes on a tactical belt key.';
'@ @'
return 'Thrown. Goes on a hotbar key.';
'@

SubRx @'
'ring search','belt -','belt +','focus'
'@ @'
'ring search','hotbar -','hotbar +','focus'
'@

SubRx @'
[n(4)+'/'+n(5)+' tap','change tactical belt slot']
'@ @'
[n(4)+'/'+n(5)+' tap','change hotbar slot']
'@

SubRx @'
['LB/RB tap','change tactical belt slot']
'@ @'
['LB/RB tap','change hotbar slot']
'@

SubRx @'
[b(4)+' / '+b(5),'tactical belt']
'@ @'
[b(4)+' / '+b(5),'hotbar']
'@

SubRx @'
['LB / RB','tactical belt']
'@ @'
['LB / RB','hotbar']
'@

SubRx @'
say(_any?'NO THROWABLE ON THE TACTICAL BELT':'NO THROWABLES LEFT');
'@ @'
say(_any?'NO THROWABLE ON THE HOTBAR':'NO THROWABLES LEFT');
'@

SubRx @'
say((findHeal()>=0)?'NO HEAL ON BELT':'NO MEDICAL SUPPLIES')
'@ @'
say((findHeal()>=0)?'NO HEAL ON HOTBAR':'NO MEDICAL SUPPLIES')
'@

SubRx @'
say('NO HEAL ON BELT','info'
'@ @'
say('NO HEAL ON HOTBAR','info'
'@

SubRx @'
(ITEMS[_rpk].use==='throw'?'ON BELT':'IN BACKPACK')
'@ @'
(ITEMS[_rpk].use==='throw'?'ON HOTBAR':'IN BACKPACK')
'@

SubRx @'
You come back down with an empty backpack and belt.</span>
'@ @'
You come back down with an empty backpack and hotbar.</span>
'@

SubRx @'
text('tactical belt',left,beltTop-16*s,20,'#aaa498');
'@ @'
text('hotbar',left,beltTop-16*s,20,'#aaa498');
'@

SubRx @'
[['','drag to tactical belt']]
'@ @'
[['','drag to hotbar']]
'@

SubRx @'
:'drag to tactical belt') // v28.xx (cw-cx-floorbag)
'@ @'
:'drag to hotbar') // v28.xx (cw-cx-floorbag)
'@

SubRx @'
past the ends to the tactical belt   A pick up or place   B close
'@ @'
past the ends to the hotbar   A pick up or place   B close
'@

SubRx @'
' drop one   drag to tactical belt'
'@ @'
' drop one   drag to hotbar'
'@

SubRx @'
'    BACKPACK '+_bpN+'    BELT '+_bltN
'@ @'
'    BACKPACK '+_bpN+'    HOTBAR '+_bltN
'@

SubRx @'
you packed, plus your current tactical belt and backpack.'
'@ @'
you packed, plus your current hotbar and backpack.'
'@

SubRx @'
:'your current tactical belt and backpack.'
'@ @'
:'your current hotbar and backpack.'
'@

SubRx @'
' off the tactical belt and into the backpack.'
'@ @'
' off the hotbar and into the backpack.'
'@

SubRx @'
'TACTICAL BELT \u00b7 PICK UP AN ITEM WITH A, THEN A HERE'
'@ @'
'HOTBAR \u00b7 PICK UP AN ITEM WITH A, THEN A HERE'
'@

SubRx @'
'TACTICAL BELT \u00b7 HOVER AN ITEM + PRESS 1-9 OR 0'
'@ @'
'HOTBAR \u00b7 HOVER AN ITEM + PRESS 1-9 OR 0'
'@

SubRx @'
<div class="srph"><b>belt</b><span id="srplanmsg">
'@ @'
<div class="srph"><b>hotbar</b><span id="srplanmsg">
'@

SubRx @'
'Large for tv: bigger raid panels, minimap and belt.'
'@ @'
'Large for tv: bigger raid panels, minimap and hotbar.'
'@

SubRx @'
var VER='36.80';
'@ @'
var VER='36.81';
'@

$pat = "(?m)^  now:'v36\.80:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v36.81: the number key row says hotbar everywhere: the backpack panel, the lift, the pad legends, the raid callouts and the stash words Check 36.81 fails on v36.80',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
