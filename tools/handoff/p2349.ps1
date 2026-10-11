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

# ARCADE: VALUABLES IGNORE A FULL BACKPACK (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
function arcadeLoot(key){
  var n=Math.max(1,Math.round(ival(key)/ARCADE_LOOT_DIV));
'@ @'
// v23.49, HIS YES (2026-10-11) to the five recommendations, arcade25 (a low finding of the arcade 7-13 review): VALUABLES IGNORE A FULL
// BACKPACK. The search refused any box with BACKPACK FULL once the backpack was at its cap, even a box whose loot never enters the
// backpack: in the arcade a valuable turns into points and pot (arcadeLoot), ammo goes to the reserve and a throwable to the pouch.
// The cap is unlimited on his 2026-08-22 order, so this is latent today, but the arcade rule is that the full test counts only what
// actually goes into the bag. arcadeBagFree(ct) is true when every item left in the box is one of those, and the search then neither
// refuses the box nor sheds the worst of the backpack (autoCull) to make room it does not need. A box with anything else in it is
// refused as before, and a normal raid is unchanged.
function arcadeBagFree(ct){
  var j, it;
  if(!ct||typeof G==='undefined'||!G||!G.arcade||G.sim||ct.mercSrc) return false;
  if(!Array.isArray(ct.loot)||!ct.loot.length) return false;
  for(j=0;j<ct.loot.length;j++){ it=ITEMS[ct.loot[j]]; if(!it||(it.use&&it.use!=='ammo'&&it.use!=='throw')) return false; }
  return true;
}
function arcadeLoot(key){
  var n=Math.max(1,Math.round(ival(key)/ARCADE_LOOT_DIV));
'@

SubRx @'
    // elite, so if that is all you are carrying it still refuses.
    if(bagWeight()>=cap&&P.autoloot) autoCull(cap);
    if(bagWeight()>=cap){
'@ @'
    // elite, so if that is all you are carrying it still refuses.
    // v23.49 (arcade25): in the arcade a box holding only valuables, ammo and throwables puts nothing in the backpack (arcadeBagFree),
    // so a full backpack neither refuses it nor sheds for it.
    var _abf=!!(G.arcade&&arcadeBagFree(near));
    if(!_abf&&bagWeight()>=cap&&P.autoloot) autoCull(cap);
    if(!_abf&&bagWeight()>=cap){
'@

SubRx @'
var VER='23.48';
'@ @'
var VER='23.49';
'@

$pat = "(?m)^  now:'v23\.48:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v23.49: In the arcade a full backpack no longer stops you looting a box of valuables, ammo or throwables, because none of it goes into the backpack. Check 23.49 fails on v23.48',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
