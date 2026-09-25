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
          var _sdk=_sl?(_sl.itemKey||((_sl.kind==='heal'||_sl.kind==='armor'||_sl.kind==='throw')&&_sl.icon&&ITEMS[_sl.icon]&&(_sl.kind!=='heal'||_sl.count>0)?_sl.icon:null)):null;
          if(_sl&&_sdk&&!(_sl.k==='gunA'||_sl.k==='gunB')){ G.drag={key:_sdk,fromHot:_H.i}; blip('pick'); }   // v11.97: a key holding a gun drags on the floor too
'@ @'
          // v15.69, grid audit finding: A CLICK ON THE MEDICAL KEY OF THE UNDERCROFT BELT NEVER BINDS A BANDAGE. The floor
          // player is always at full health (hubBagState), so findHeal skips every heal and the Medical cell falls back to showing
          // a Bandage while counting every heal packed. With only Medkits packed a press here started a drag of a Bandage he does
          // not carry, and the release bound it: to this key on a plain click, or to any key it was dragged to, where the Bandage
          // issued at the ascent kept the pin alive in the raid. A derived heal cell now drags only a heal the backpack really
          // holds, and the drag keeps its press point, as the raid's belt drag has since v14.61, for the click test on release.
          var _sdk=_sl?(_sl.itemKey||((_sl.kind==='heal'||_sl.kind==='armor'||_sl.kind==='throw')&&_sl.icon&&ITEMS[_sl.icon]&&(_sl.kind!=='heal'||G.bag.indexOf(_sl.icon)>=0)?_sl.icon:null)):null;
          if(_sl&&_sdk&&!(_sl.k==='gunA'||_sl.k==='gunB')){ G.drag={key:_sdk,fromHot:_H.i,px:mouse.x,py:mouse.y}; blip('pick'); }   // v11.97: a key holding a gun drags on the floor too
'@
SubRx @'
          G.hotAssign=G.hotAssign||{};
          // v14.25, Undercroft audit finding 4: ONE ITEM, ONE KEY, IN THE UNDERCROFT BACKPACK TOO. This drop only let go of the
'@ @'
          // v15.69, grid audit finding: A CLICK ON THE MEDICAL KEY OF THE UNDERCROFT BELT NEVER BINDS A BANDAGE. A release on
          // the key the drag came from is a click, the raid's v8.14 rule. This drop had no such check, so a plain click on a key
          // the belt fills by itself (Medical, a grenade, the plate) bound the item it showed to that key and saved it, and on
          // Medical that was the Bandage fallback: the key went grey with a red 0 on the Stash screen and Medical was gone. A key
          // he bound himself is left exactly as it was, which is all the old write of the same value did.
          if(d.fromHot===_H.i) return;
          G.hotAssign=G.hotAssign||{};
          // v14.25, Undercroft audit finding 4: ONE ITEM, ONE KEY, IN THE UNDERCROFT BACKPACK TOO. This drop only let go of the
'@
SubRx @'
      // Dropped off the belt entirely: the binding is released and the item goes
      // back to being just something in the backpack, which is his v8.72 note.
      if(d.fromHot!==undefined&&G.hotAssign) delete G.hotAssign[d.fromHot];
'@ @'
      // Dropped off the belt entirely: the binding is released and the item goes
      // back to being just something in the backpack, which is his v8.72 note.
      // v15.69, grid audit finding: A CLICK ON THE MEDICAL KEY OF THE UNDERCROFT BELT NEVER BINDS A BANDAGE, and a click that
      // slips just off a belt key does not unbind it. Every press on a key starts a drag, and any release off the belt took the
      // item off its key. A release within 24 units of the press is a click, the raid's v14.61 threshold; a real drag still
      // lets go, and a drag with no press point lets go as before.
      if(d.fromHot!==undefined&&G.hotAssign&&!(d.px!==undefined&&Math.sqrt((mouse.x-d.px)*(mouse.x-d.px)+(mouse.y-d.py)*(mouse.y-d.py))<=24)) delete G.hotAssign[d.fromHot];
'@
SubRx @'
var VER='15.68';
'@ @'
var VER='15.69';
'@

$pat = "(?m)^  now:'v15\.68:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v15.69: A CLICK ON THE MEDICAL KEY OF THE UNDERCROFT BELT NEVER BINDS A BANDAGE. With only Medkits packed, a click on the Medical key of the tactical belt in the Undercroft backpack bound a Bandage he does not carry to that key and saved it, so the key went grey and Medical was gone. A release on the key it came from is now a click as in a raid, the Medical key drags only a heal the backpack holds, and a click that slips just off a key no longer unbinds it. Check 15.69 clicks and drags the Medical key on the floor with Medkits packed and with a Bandage packed; it fails on v15.68',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
