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

# A THROWABLE PUT ON A TACTICAL BELT KEY WAS A DEAD KEY, AND IT DELETED THE
# WORKING ONE. Found by the 2026-09-06 read-only audit, raised independently by
# two regions and confirmed by a skeptic each. It is the same hole the v8.31
# comment records for the Stim Injector, one item type later: a throwable never
# enters the backpack (it lives in G.pouch), so `have` is always 0 and the cell
# fell through the kind ternary to 'item'. The trigger treats 'item' as a held
# gun, so pulling the trigger on his own Frag Charge fired his rifle, under a
# caption reading "[FIRE] use"; G did nothing; the cell drew greyed with a count
# of none while the pouch held two; and the dedupe pass then blanked the real
# throwable cell, so the only working way to that grenade was a cell labelled
# with a different item. Bind all three and nothing could throw at all.

# 1. THE CELL, built the way the derived throw cell is built.
SubRx @'
    } else {
      out[aix]={k:'item:'+akey,name:ait.name,icon:akey,
'@ @'
    } else if(ait.use==='throw'){
      // v11.59, from the 2026-09-06 audit: THE v8.31 STIM HOLE, one item type
      // later. A throwable lives in the pouch and never in the backpack, so
      // `have` is always 0 and this fell through to kind 'item', which the
      // trigger treats as a held gun: the key fired his rifle under a caption
      // saying [FIRE] use, G did nothing, and the dedupe below then blanked the
      // working throwable cell. Built exactly as the derived cell at 12930 is
      // built, so setHot syncs the selector, the trigger cooks it, and the
      // dedupe leaves exactly one cell for that grenade: the key he chose.
      var _pq=(G.pouch&&G.pouch[akey])||0;
      out[aix]={k:'throw:'+akey,name:ait.name,icon:akey,kind:'throw',
        count:_pq,c:ait.c||'#cdd6dd',assigned:1,itemKey:akey,empty:(_pq<=0)?1:0};
    } else {
      out[aix]={k:'item:'+akey,name:ait.name,icon:akey,
'@

# 2. THE KEY ITSELF. The assigned branch refuses anything not in the backpack,
# which is every throwable, so it needs the same verb the derived cell has.
SubRx @'
    var ait=ITEMS[s2.itemKey]; if(!ait) return;
'@ @'
    var ait=ITEMS[s2.itemKey]; if(!ait) return;
    // v11.59: a throwable is carried in the pouch, not the backpack, so the bag
    // test below would refuse it. Same verb the derived cell has: the key
    // throws it, and the selector is pointed at it first so the cook and the
    // throw can never disagree about which grenade is in hand.
    if(ait.use==='throw'){
      var _tsx=THROWKEYS.indexOf(s2.itemKey);
      if(_tsx>=0) G.tsel=_tsx;
      doThrow(); return;
    }
'@

# STAMPS.
SubRx @'
var VER='11.58';
'@ @'
var VER='11.59';
'@
SubRx @'
var WHATSNEW_VER='11.58';
'@ @'
var WHATSNEW_VER='11.59';
'@
SubRx @'
  'THIS IS AN ALPHA. Things will break. When something does, the game writes it into your run report and tells you so; that report is how it gets fixed.',
'@ @'
  'THIS IS AN ALPHA. Things will break. When something does, the game writes it into your run report and tells you so; that report is how it gets fixed.',
  'A GRENADE ON A BELT KEY WORKS NOW. Putting a Frag Charge, Smoke or Decoy on a tactical belt key gave you a dead key: it read x0, the trigger fired your gun instead, and it deleted the working grenade cell. The key you choose is now the grenade.',
'@
$cnt=([regex]::Matches($s,"now:'v11\.58:[^']*'")).Count
if($cnt -ne 1){ throw "DEVNOW v11.58 matched $cnt times" }
$s=[regex]::Replace($s,"now:'v11\.58:[^']*'",{ param($m) "now:'v11.59: a throwable put on a tactical belt key was a dead key and it deleted the working one. From the 2026-09-06 read-only audit, raised by two regions. It is the v8.31 stim hole one item type later: a throwable is never in the backpack so have is 0 and the cell fell through to kind item, which the trigger treats as a held gun, so the key fired his rifle under a caption saying FIRE use, G did nothing, the cell read x0 while the pouch held two, and the dedupe blanked the real throwable cell. The cell is now built as the derived throw cell is built and useHot throws it. Check 11.59 binds a frag to a key, requires a live throw cell with the pouch count, exactly one cell for that grenade, the selector synced by setHot and the key actually throwing it.'" })
$n++

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count + 1
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
