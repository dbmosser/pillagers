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

# HIS ORDER, 2026-09-06 about 14:15: "when I hotbar an item it should
# automatically move half of the stash stack unless I indicate the quantity
# -- e.g. how am I supposed to take multiple grenades, heals on tac belt etc.
# -- there's no quantity indicated". Putting an item on a key packed exactly
# one and the belt plan cell showed no count. Now a key takes half the stack
# (rounded up, at least one) unless some are already packed, and the cell
# shows how many are coming. The right-click menu keeps its exact rows.
SubRx @'
  // Only claim another inventory slot if this item is not already coming.
  if(picked<1){
    if(live.length>=DEPLOY_SLOTS) return 'Backpack is full at '+DEPLOY_SLOTS+', so there is no room to carry that.';
    P.kit.push(key);
  }
'@ @'
  // Only claim another inventory slot if this item is not already coming.
  // v11.96, HIS ORDER: half the stack, not one. A key on a stack of six
  // Bandages packs three; a stack of one packs one; a count he set himself
  // through the menu is left as it is.
  if(picked<1){
    if(live.length>=DEPLOY_SLOTS) return 'Backpack is full at '+DEPLOY_SLOTS+', so there is no room to carry that.';
    var _half=Math.max(1,Math.ceil(held/2));
    for(var _hq=0;_hq<_half&&live.length+_hq<DEPLOY_SLOTS;_hq++) P.kit.push(key);
  }
'@
SubRx @'
      (it?iconImgHTML(k,22):'<span style="color:var(--ash);font-size:10.5px">'+(i+1)+'</span>')+
      (it?'<span style="position:absolute;right:2px;bottom:0;font-size:10.5px;color:var(--ash)">'+(i+1)+'</span>':'')+
      '</div>';
'@ @'
      (it?iconImgHTML(k,22):'<span style="color:var(--ash);font-size:10.5px">'+(i+1)+'</span>')+
      (it?'<span style="position:absolute;right:2px;bottom:0;font-size:10.5px;color:var(--ash)">'+(i+1)+'</span>':'')+
      // v11.96, HIS ORDER: how many are coming, on the cell, so a key on a stack
      // reads as a stack. One is silent; the key number already says it is set.
      ((it&&packedCount(k)>1)?'<span style="position:absolute;left:2px;top:0;font-size:10.5px;color:var(--amber)">x'+packedCount(k)+'</span>':'')+
      '</div>';
'@

# STAMPS.
SubRx @'
var VER='11.95';
'@ @'
var VER='11.96';
'@
SubRx @'
var WHATSNEW_VER='11.95';
'@ @'
var WHATSNEW_VER='11.96';
'@
SubRx @'
  'THIS IS AN ALPHA. Things will break. When something does, the game writes it into your run report and tells you so; that report is how it gets fixed.',
'@ @'
  'THIS IS AN ALPHA. Things will break. When something does, the game writes it into your run report and tells you so; that report is how it gets fixed.',
  'A BELT KEY TAKES HALF THE STACK: put a stack on a key and half of it comes with you, and the key shows how many; the right-click menu still packs an exact number.',
'@
$cnt=([regex]::Matches($s,"now:'v11\.95:[^']*'")).Count
if($cnt -ne 1){ throw "DEVNOW v11.95 matched $cnt times" }
$s=[regex]::Replace($s,"now:'v11\.95:[^']*'",{ param($m) "now:'v11.96: HIS ORDER of 2026-09-06, a belt key should take half the stash stack unless he sets a quantity, and the belt showed no count. planPut packs half the stack (rounded up) when nothing of it is packed yet, and the plan cell shows how many are coming. Check 11.96 puts a stack of six Bandages on key 3 and requires three packed and x3 on the cell, a single item packs one; fails on v11.95.'" })
$n++

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count + 1
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
