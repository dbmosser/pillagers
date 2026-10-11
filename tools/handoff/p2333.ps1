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

# ARCADE: WALK-OVER LOOT (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
  if(near&&(keys['KeyX']||(keys['KeyE']&&!onPad))){
'@ @'
  // v23.33, HIS ORDER (2026-10-11), build 11 of 20 (arcade11): WALK-OVER LOOT. In the arcade a box in reach with loot left in it is
  // searched with no key (arcadeAutoSrch), so a walk-up player loots by walking over it. X and E still search as before.
  if(near&&(keys['KeyX']||(keys['KeyE']&&!onPad)||arcadeAutoSrch(near))){
'@

SubRx @'
      near.prog=(near.prog||0)+dt/buzzSlow();
'@ @'
      near.prog=(near.prog||0)+dt/buzzSlow()*(G.arcade?ARCADE_SRCH:1);   // v23.33 (arcade11): six times as fast in the arcade
'@

SubRx @'
    ct.prog=(ct.prog||0)+dt/r.slow;
'@ @'
    ct.prog=(ct.prog||0)+dt/r.slow*(G.arcade?ARCADE_SRCH:1);   // v23.33 (arcade11): a box held through the host is fast in the arcade too
'@

SubRx @'
    else { G.bag.push(key); _beltGot=autoBelt(key,1); if(_beltGot) _beltKeep.push(_beltGot); if(beltTag()) _ptags[l]=beltTag(); }
'@ @'
    else if(G.arcade&&!G.sim&&itm&&!itm.use) _ptags[l]='+'+arcadeLoot(key).toLocaleString();   // v23.33 (arcade11): a valuable is points and pot, never the backpack
    else { G.bag.push(key); _beltGot=autoBelt(key,1); if(_beltGot) _beltKeep.push(_beltGot); if(beltTag()) _ptags[l]=beltTag(); }
'@

SubRx @'
// A kill this window credited to its own player. Returns the points.
'@ @'
// v23.33, HIS ORDER (2026-10-11), build 11 of 20 (arcade11): WALK-OVER LOOT. In an arcade raid a box in reach that still holds loot
// is searched with no key, and the bar fills six times as fast (ARCADE_SRCH), in the solo search and in the host netSrchTick for
// a box player 2 holds. A valuable (an item with no use) never enters the backpack: it scores its value / 10 into ARCADE.mine
// at once and the same into ARCADE.pot (paid again on extract), with +N as the tag on its pickup row. Ammo, heals, throws,
// plates and keys go where they always went. A pile the player dropped, a box a teammate holds and a hired man are never
// searched by walking over them. Everything is behind G.arcade, so a normal raid is unchanged.
var ARCADE_SRCH=6, ARCADE_LOOT_DIV=10;
function arcadeAutoSrch(ct){
  var me;
  if(!ct||typeof G==='undefined'||!G||!G.arcade||G.sim||G.over||ct.opened||ct.dropped||ct.mercSrc) return false;
  if(!Array.isArray(ct.loot)||!ct.loot.length) return false;
  me=(typeof NET==='object'&&NET&&NET.on&&NET.role==='join')?(NET.seat|0):0;
  if(typeof ct.netBy==='number'&&ct.netBy>=0&&ct.netBy!==me) return false;
  return true;
}
function arcadeLoot(key){
  var n=Math.max(1,Math.round(ival(key)/ARCADE_LOOT_DIV));
  ARCADE.mine=(ARCADE.mine|0)+n; ARCADE.pot=(ARCADE.pot|0)+n;
  try{ arcadeScSend(); }catch(_as){}
  return n;
}
// A kill this window credited to its own player. Returns the points.
'@

SubRx @'
var VER='23.32';
'@ @'
var VER='23.33';
'@

$pat = "(?m)^  now:'v23\.32:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v23.33: In the arcade walking over a box loots it fast, and valuables become points and pot instead of backpack weight. Check 23.33 fails on v23.32',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
