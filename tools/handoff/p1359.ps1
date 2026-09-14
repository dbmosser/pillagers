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

# UNDERCROFT AUDIT OF 2026-09-14, finding 1: CRAFTING AND THE BUILD RACK SPENT PACKED ITEMS
# AND LEFT THEIR BELT KEYS BOUND TO NOTHING. Both counted every stash copy, packed or not,
# and spliced whichever copy came first, never touching the kit or the belt. The packing
# check then silently dropped the kit entries, so two Bandages packed on key 3 vanished
# from the backpack, key 3 kept showing Bandage with a red 0, and a quick ascent went up
# with nothing to heal with. Both now spend unpacked copies first; any packed copies they
# still need are unpacked properly (kit entry and belt key), and crafting says so.
SubRx @'
function packSome(key,want){
'@ @'
// v13.59, Undercroft audit: SPEND FROM THE STASH WITHOUT BREAKING THE PACKING. Unpacked
// copies go first. Any packed copies still needed are unpacked through unpackSome, which
// takes them off the loadout and clears a belt key left pointing at nothing. Returns how
// many packed copies it had to use, so the caller can say so.
function spendHeld(key,n){
  var free=Math.max(0,heldCount(key)-packedCount(key)), fromPacked=Math.max(0,n-free);
  if(fromPacked>0) unpackSome(key,fromPacked);
  for(var q=0;q<n;q++){ var ix=P.stash.indexOf(key); if(ix>=0) P.stash.splice(ix,1); }
  return fromPacked;
}
function packSome(key,want){
'@
SubRx @'
      var next=P.stash.slice();
      for(k2 in r.need){
        for(var q=0;q<r.need[k2];q++){
          var ix=next.indexOf(k2);
          if(ix<0) return;
          next.splice(ix,1);
        }
      }
      for(var k3 in r.out){ for(var q2=0;q2<r.out[k3];q2++) next.push(k3); }
      P.stash=next;
'@ @'
      // v13.59: every ingredient is affordable (checked above), so spend them through
      // spendHeld: unpacked copies first, packed ones unpacked properly, and say so.
      var _usedPacked=[];
      for(k2 in r.need){ var _fp=spendHeld(k2,r.need[k2]); if(_fp>0) _usedPacked.push(_fp+' packed '+((ITEMS[k2]&&ITEMS[k2].name)||k2)); }
      for(var k3 in r.out){ for(var q2=0;q2<r.out[k3];q2++) P.stash.push(k3); }
      if(_usedPacked.length){ try{ say2('Used '+_usedPacked.join(', ')+' out of your backpack.'); }catch(_s2){} }
'@
SubRx @'
  for(var k in RACK_COST){
    for(var q=0;q<RACK_COST[k];q++){
      var ix=P.stash.indexOf(k);
      if(ix>=0) P.stash.splice(ix,1);
    }
  }
'@ @'
  for(var k in RACK_COST) spendHeld(k,RACK_COST[k]);   // v13.59: unpacked copies first, packed ones unpacked properly
'@
SubRx @'
var VER='13.58';
'@ @'
var VER='13.59';
'@

$pat = "(?m)^  now:'v13\.58:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v13.59: CRAFTING NO LONGER BREAKS WHAT YOU PACKED. Undercroft audit of 2026-09-14, finding 1: the crafting bench and the Build Rack counted every stash copy, packed or not, and spliced whichever came first without touching the loadout or the belt, so packed items vanished from the backpack and their belt keys kept showing the item with a red 0. spendHeld now spends unpacked copies first and unpacks any packed copies it still needs through unpackSome, which also clears the belt key, and crafting says when it used packed items. Check 13.59 packs two Bandages on a belt key, crafts a Medkit, and requires the Bandages off the loadout and the key cleared, with spare unpacked Bandages leaving the packing and the key untouched as the control; it fails on v13.58',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
