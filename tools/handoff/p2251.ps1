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

# THE BELT ANSWERS IN THE HUD VOICE (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
          if(d.gunSlot){
            if(d.fromHot===_H.i) return;
'@ @'
          // v22.51, from the review of the four-gun belt, build 4 (his order of 2026-10-09, the shooter HUD voice): THE FLOOR BELT
          // TOASTS READ LIKE A SHOOTER HUD. The drag of a gun on this belt answered in explaining sentences (only gun, traded places,
          // to slot, how to take a gun out of his hands) beside the new ALL CAPS toast of v22.45; they are short ALL CAPS callouts now,
          // and name keys, not slots, as the rest of the belt does.
          if(d.gunSlot){
            if(d.fromHot===_H.i) return;
'@

SubRx @'
hubToast(_hb8n+' is your only gun, so there is no other gun for it to trade places with.'); return; }
'@ @'
hubToast('ONLY ONE GUN'); return; }
'@

SubRx @'
blip('pick'); hubToast((_hb8at===_H.i)?(_hb8n+' to slot '+(_H.i+1)+'.'):(_hb8n+' traded places with '+_hb8o+(_hb8at>=0?('; '+_hb8n+' is on key '+(_hb8at+1)+'.'):'.')));
'@ @'
blip('pick'); hubToast(((_hb8at>=0)?(_hb8n+' on key '+(_hb8at+1)+((_hb8at===_H.i)?'':(' \u00b7 swapped with '+_hb8o))):('swapped with '+_hb8o)).toUpperCase());
'@

SubRx @'
blip('pick'); hubToast(_hb8n+' to slot '+(_hb8h+1)+'. '+((ITEMS[_hb8c]&&ITEMS[_hb8c].name)||'Item')+' to slot '+(d.fromHot+1)+'.');
'@ @'
blip('pick'); hubToast((_hb8n+' on key '+(_hb8h+1)+' \u00b7 '+((ITEMS[_hb8c]&&ITEMS[_hb8c].name)||'Item')+' on key '+(d.fromHot+1)).toUpperCase());
'@

SubRx @'
hubToast('To take a gun out of your hands, open it in the armoury on the Stash screen.'); return; }
'@ @'
hubToast('UNEQUIP IN ARMOURY'); return; }
'@

SubRx @'
say2((PAD&&PAD.on)?padB('Pick an item up with A first, then A on this key puts it there.'):'Hover an item in the stash and press a number key to put it on your tactical belt.');
'@ @'
say2((PAD&&PAD.on)?padB('TACTICAL BELT \u00b7 PICK UP AN ITEM WITH A, THEN A HERE'):'TACTICAL BELT \u00b7 HOVER AN ITEM + PRESS 1-9');   // v22.51: the shooter HUD voice, his name for the belt kept (v10.26)
'@

SubRx @'
var VER='22.50';
'@ @'
var VER='22.51';
'@

$pat = "(?m)^  now:'v22\.50:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v22.51: The belt answers on the Undercroft floor and the Stash screen are short ALL CAPS callouts. Check 22.51 fails on v22.50',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
