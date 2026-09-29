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

# DRAGGING A BELT KEY THAT HOLDS A GUN FROM THE BACKPACK NO LONGER SWAPS OUT THE GUN IN HAND (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
        setHot(_HC2.i);
'@ @'
        // v17.18, belt hunt 2026-09-28: A PRESS ON A KEY HOLDING A BACKPACK GUN ONLY PICKS IT UP. The press equipped it before the
        // drag was armed, so dragging the key to tidy the belt (or pad A on it, backpack open) put the gun in his hands and pushed
        // out the one there: an armoury gun went home for the raid and an issued one was lost. The equip waits for the release
        // and happens only when the release is a click (window mouseup).
        var _bagGun=!!(_hs2&&_hs2.kind==='gun'&&_hs2.itemKey&&!_hs2.equipped);
        if(!_bagGun) setHot(_HC2.i);
'@

SubRx @'
        if(d.fromHot===HC.i){ dropped=true; break; }
'@ @'
        if(d.fromHot===HC.i){
          // v17.18, belt hunt 2026-09-28: a click on a key holding a backpack gun equips it here, on the release (v11.91).
          var _cg=hotbarSlots()[HC.i];
          if(_cg&&_cg.kind==='gun'&&_cg.itemKey===d.key&&!_cg.equipped) setHot(HC.i);
          dropped=true; break;
        }
'@

SubRx @'
    if(!_onBelt&&_dMoved&&d&&d.fromHot!==undefined&&G.hotAssign&&G.hotAssign[d.fromHot]!==undefined){
'@ @'
    // v17.18, belt hunt 2026-09-28: and a click that slips just off that key still equips it, as the press used to.
    if(!_onBelt&&!_dMoved&&!dropped&&d&&d.fromHot!==undefined){
      var _cg2=hotbarSlots()[d.fromHot];
      if(_cg2&&_cg2.kind==='gun'&&_cg2.itemKey===d.key&&!_cg2.equipped) setHot(d.fromHot);
    }
    if(!_onBelt&&_dMoved&&d&&d.fromHot!==undefined&&G.hotAssign&&G.hotAssign[d.fromHot]!==undefined){
'@

SubRx @'
var VER='17.17';
'@ @'
var VER='17.18';
'@

$pat = "(?m)^  now:'v17\.17:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v17.18: Belt drag of a backpack gun key equipping it. The raid belt mousedown called setHot on every press before arming the drag, and setHot on an assigned gun cell that is not in hand runs equipFromBag. With two real guns in hand the gun held was replaced: an armoury gun was sent home without being bagged, so it was out of the raid, and an issued gun was deleted. It happened with the backpack open against the v11.90 comment, and through pad A (bagPadAct sends the same mousedown). The mousedown now skips setHot for a cell of kind gun with an itemKey that is not equipped and only arms the drag. The window mouseup equips it when the release is a click: on the key it came from (the d.fromHot click line), or off the belt within the 24 unit click threshold. A real drag to another key or off the belt moves or unbinds the key and never touches the hands. Number keys and every other cell are unchanged. Check 17.18 fails on v17.17',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
