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

# A SEARCH SOUNDS LIKE HANDS IN A BOX (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
function lootVoice(keys){
'@ @'
// v25.30 (usefoleyg), HIS ORDER 2026-10-12 (about 21:10): "add sounds for bandaging, applying armor, etc". A SEARCH SOUNDS LIKE
// HANDS IN A BOX. Holding E on a container was silent until a rare item came out (a common pull made no sound at all, v2.59) and
// the box finished. Now (the v25.20 bank) your hands rummage as the search starts and every half second while it runs, with a
// light metal knock in a locker, a safe, a cache or a wreck and a softer, lower rummage on a body; a common item that comes out
// makes its own small sound (a magazine rattle for ammo, a handling sound for the rest), and the rare, elite and gun voices are
// kept. The rummage rides the half-second tick the search ring already uses, so letting go stops it at once. Your teammates hear
// it where you stand. Cosmetic only: no seeded draw, nothing under G.sim, no game state.
function searchFoley(ct,what,k){
  if((G&&G.sim)||typeof foley!=='function'||!ct) return false;
  var t=String(ct.type||''), metal=(t==='locker'||t==='safe'||t==='botwreck'||t==='cache'||t==='jackpot'), cloth=(t==='body'||!!ct.mercSrc), it;
  if(what==='pull'){
    it=ITEMS[k];
    if(it&&it.use==='ammo') foley('magIn',null,null,{rate:1.35,g:0.45,dur:0.12});
    else foley('pickup',null,null,{g:0.75});
    return true;
  }
  foley('rummage',null,null,{rate:cloth?0.8:(metal?1.1:0.95),g:cloth?0.8:1,gap:0.2});
  if(metal) foley('boltLatch',null,null,{rate:1.8,g:0.25,dur:0.1,at:0.08,local:1});
  return true;
}
function lootVoice(keys){
'@

SubRx @'
      if(G.searching!==near){
        G.searching=near;
'@ @'
      if(G.searching!==near){
        G.searching=near;
        searchFoley(near,'rummage');   // v25.30 (usefoleyg): hands in the box
'@

SubRx @'
      if(near.noiseAcc>0.5){
        near.noiseAcc=0;
'@ @'
      if(near.noiseAcc>0.5){
        near.noiseAcc=0;
        searchFoley(near,'rummage');   // v25.30 (usefoleyg): and every half second while it runs
'@

SubRx @'
            if(_lv!=='pick') blip(_lv);
'@ @'
            if(_lv!=='pick') blip(_lv); else searchFoley(near,'pull',_k);   // v25.30 (usefoleyg): a common item makes its own small sound
'@

SubRx @'
var VER='25.29';
'@ @'
var VER='25.30';
'@

$pat = "(?m)^  now:'v25\.29:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v25.30: Searching a container now rummages as you search, and each common item that comes out makes its own small sound. Check 25.30 fails on v25.29',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
