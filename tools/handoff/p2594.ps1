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

# U SWITCHES WHAT G THROWS, THE HIGHLIGHT STAYS ON THE GUN (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
function cycleThrow(){
  // v15.06, throwables audit finding 4: the hand is no longer moved here, before a key is found. See the cell search below.
  var _unkeyed=0;
  for(var i=1;i<=THROWKEYS.length;i++){
    var n=(G.tsel+i)%THROWKEYS.length;   // v23.xx (feat1a): four throws now, the Tripwire Mine is the fourth
    if(throwHave(THROWKEYS[n])>0){   // v25.xx (belt4): the pouch and the backpack
      // v12.56, 2026-09-06 in-raid audit: AND THE BELT FOLLOWS THE HAND. Which
      // grenade is in your hand and which cell the belt highlights are two
      // different fields, and this key wrote only the first, so choosing a
      // different grenade left the highlight and the caption on the cell you
      // were no longer holding while the trigger threw the new one. The
      // highlight now moves to the cell that actually holds what you chose,
      // whether that is the derived cell or one you dragged the grenade onto
      // yourself. Nothing else changes: Q still cycles, which is its job, and
      // v12.41 already stopped the USE keys doing it behind your back.
      var _cs=hotbarSlots(), _ck='throw:'+THROWKEYS[n], _ci, _cf=-1;
      for(_ci=0;_ci<_cs.length;_ci++){
        var _cc=_cs[_ci];
        if(!_cc) continue;
        if(_cc.k===_ck||_cc.itemKey===THROWKEYS[n]){ _cf=_ci; break; }
      }
      // v15.06, throwables audit finding 4: Q NEVER PICKS A GRENADE THAT HAS NO KEY ON THE TACTICAL BELT. Something of his own on
      // the Smoke key covers the Smoke cell, so the Smoke had no cell anywhere; Q still put the Smoke in hand, left the highlight
      // on the Frag and said the Smoke was ready, and the trigger cooked a Smoke under the Frag count. A grenade no key can use
      // is passed over, and the hand and the highlight now move together or not at all.
      if(_cf<0){ _unkeyed++; continue; }
      G.tsel=n; G.hot=_cf;
      say((ITEMS[THROWKEYS[n]].name+' ready').toUpperCase());   // v22.xx (R52)
      return;
    }
  }
  say(_unkeyed?'NO THROWABLE ON THE TACTICAL BELT':'NO THROWABLES LEFT');   // v22.xx (R52)
}
'@ @'
// v25.xx (belt5a), HIS DECISION 2026-10-13: "U picks what G throws". The throwable keys are 5 and 6; U switches which of the kinds on them G throws
// (G.tsel, the same index into THROWKEYS the trigger, doThrow and startCook read), and THE HIGHLIGHT STAYS ON THE GUN: it used to follow the
// grenade to its cell (v12.56, v15.06), which took the trigger off the gun. Pressing 5 or 6 still selects that cell, so the trigger cooks it.
// beltThrowCells lists the throwable keys that hold a kind he has; throwSelFix puts G.tsel on one of them when it points at a kind no key shows.
function beltThrowCells(){
  var sl=hotbarSlots(), out=[], ci, c;
  for(ci=GUNKEYS;ci<HOTBAR_N;ci++){
    if(BELT_CLASS[ci]!=='throw') continue;
    c=sl[ci];
    if(c&&c.kind==='throw'&&c.icon&&THROWKEYS.indexOf(c.icon)>=0&&(c.count|0)>0) out.push({ci:ci,tk:c.icon});
  }
  return out;
}
function throwSelFix(){
  var cs=beltThrowCells(), cur=THROWKEYS[G.tsel], i;
  if(!cs.length) return false;
  for(i=0;i<cs.length;i++) if(cs[i].tk===cur) return true;
  G.tsel=THROWKEYS.indexOf(cs[0].tk);
  return true;
}
function cycleThrow(){
  var cs=beltThrowCells(), cur=THROWKEYS[G.tsel], at=-1, i, nx;
  if(!cs.length){
    var _any=false;
    for(i=0;i<THROWKEYS.length;i++) if(throwHave(THROWKEYS[i])>0) _any=true;
    say(_any?'NO THROWABLE ON THE TACTICAL BELT':'NO THROWABLES LEFT');   // v22.xx (R52)
    return;
  }
  for(i=0;i<cs.length;i++) if(cs[i].tk===cur) at=i;
  nx=cs[(at+1)%cs.length];
  G.tsel=THROWKEYS.indexOf(nx.tk);
  say((ITEMS[nx.tk].name+' ready').toUpperCase());   // v22.xx (R52)
}
'@

SubRx @'
  if(code==='KeyG'&&G&&!G.over&&!G.paused&&!repeat) doThrow();   // v23.46 (arcade23): in the arcade G is the quick heal
'@ @'
  if(code==='KeyG'&&G&&!G.over&&!G.paused&&!repeat){ throwSelFix(); doThrow(); }   // v23.46 (arcade23): in the arcade G is the quick heal   // v25.xx (belt5a): G throws the kind on a throwable key
'@

SubRx @'
var VER='25.93';
'@ @'
var VER='25.94';
'@

$pat = "(?m)^  now:'v25\.93:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v25.94: U now switches which of the two throwable keys G throws, and the highlight stays on the gun. Check 25.94 fails on v25.93',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
