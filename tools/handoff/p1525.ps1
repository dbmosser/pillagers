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
      else if(dsl.k==='throw:'+ak2) dupe=true;
      else if(ai2.use==='gun'&&(dsl.k==='gunA'||dsl.k==='gunB')&&dsl.icon===ai2.gk) dupe=true;
      if(dupe) break;
'@ @'
      else if(dsl.k==='throw:'+ak2) dupe=true;
      // v15.25, his note: KEY 1 NEVER GOES BLACK WHILE HE HOLDS A GUN. A gun on a belt key that he was holding blanked the gun
      // cell showing the same gun, so taking a gun from the backpack with its key put it in his hands and turned cell 1 black
      // (cell 2 when it went to the empty second slot) while he held it. Cells 1 and 2 are the two guns in his hands and always
      // show them. The key he bound keeps showing it too, because keys he set never move; gunCell and swapGuns still pick his
      // key first, as they did while the gun cell was blank.
      if(dupe) break;
'@
SubRx @'
function gunCell(){
  var sl=hotbarSlots();
  for(var i=0;i<sl.length;i++) if(sl[i]&&sl[i].kind==='gun'&&sl[i].inHand) return i;
  return 0;
}
'@ @'
// v15.25, his note: KEY 1 NEVER GOES BLACK WHILE HE HOLDS A GUN. With the dedupe no longer blanking the gun cell, a gun he
// holds that is bound to key 5 shows on cell 1 as well, and the first cell holding it would have become cell 1. A key he bound
// comes first, so a raid still starts on key 5 and an empty cell still says Press 5, exactly as while cell 1 was blank.
// -1 when no cell holds the gun in his hands.
function heldGunCell(sl){
  var i;
  for(i=0;i<sl.length;i++) if(sl[i]&&sl[i].kind==='gun'&&sl[i].inHand&&sl[i].assigned) return i;
  for(i=0;i<sl.length;i++) if(sl[i]&&sl[i].kind==='gun'&&sl[i].inHand) return i;
  return -1;
}
function gunCell(){
  var i=heldGunCell(hotbarSlots());
  return i<0?0:i;
}
'@
SubRx @'
      var _sl=hotbarSlots();
      for(var _si=0;_si<_sl.length;_si++){
        if(_sl[_si].kind==='gun'&&_sl[_si].inHand){ G.hot=_si; return; }
      }
'@ @'
      var _sl=hotbarSlots();
      // v15.25, his note: KEY 1 NEVER GOES BLACK WHILE HE HOLDS A GUN, so the gun that came up can show on cell 1 or 2 and on
      // the key he bound. The highlight stays on the cell he pressed when that cell holds it, and otherwise goes where it went
      // while the gun cell was blank: the key he bound first (heldGunCell).
      if(_sl[G.hot]&&_sl[G.hot].kind==='gun'&&_sl[G.hot].inHand) return;
      var _hg=heldGunCell(_sl);
      if(_hg>=0){ G.hot=_hg; return; }
'@
SubRx @'
      // The highlight stays on the pressed cell: once the gun is in hand the
      // derived gun cell is blanked by the dedupe, so pointing at it read EMPTY.
'@ @'
      // The highlight stays on the pressed cell: once the gun is in hand the
      // derived gun cell was blanked by the dedupe, so pointing at it read EMPTY.
      // v15.25: that cell shows the gun now; the pressed cell is still the key he chose.
'@
SubRx @'
  // and the dedupe pass would blank slot 1 or 2 under you mid-fight.
'@ @'
  // and the dedupe pass would blank slot 1 or 2 under you mid-fight.
  // v15.25: the dedupe no longer blanks a gun cell; a pinned copy would still show the gun twice.
'@
SubRx @'
var VER='15.24';
'@ @'
var VER='15.25';
'@

$pat = "(?m)^  now:'v15\.24:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v15.25: KEY 1 NEVER GOES BLACK WHILE YOU HOLD A GUN, HIS NOTE. A gun on a tactical belt key that you were holding blanked the gun cell showing the same gun, so taking a gun from the backpack with its key put it in your hands and turned key 1 black (key 2 when it went to your empty second slot). Keys 1 and 2 now always show the two guns in your hands, and the key you set shows it too. Check 15.25 takes the SMG from the backpack with key 3 over two guns and over one and reads keys 1 and 2, then brings a stowed carbine on key 5 up with key 5 and with key 2 and reads the highlight; it fails on v15.24',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
