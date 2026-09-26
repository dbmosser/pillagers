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

# A LIGHTNING FLASH SHOWS YOU TO THEM FROM FARTHER, NOT ACROSS THE WHOLE MAP. His order, answering the question parked at v16.01.

SubRx @'
if(sees&&p.downed&&e.kind!=='raider') sees=false;
'@ @'
if(sees&&p.downed&&e.kind!=='raider') sees=false;
    // v16.03, HIS ORDER: A LIGHTNING FLASH SHOWS YOU TO THEM FROM FARTHER, NOT ACROSS THE WHOLE MAP. While the flash is up
    // (G.lightning, set by the bolt) anything looking your way sees you out to FLASH_SEE times its own sight, through its own
    // cone and walls (canSee), and not under a roof on either side. Crouching does not hide you in the flash inside that range.
    // Blinding still cuts it (wkSight is in _fSee). Nobody sees you down. No draw is made here.
    if(!sees&&G.lightning>0&&!p.downed&&!roofAt(p.x,p.y)&&!roofAt(e.x,e.y)) sees=canSee(e.x,e.y,e.face,p.x,p.y,G.vseg,_fSee*FLASH_SEE,e.cone,_aSee*FLASH_SEE);
'@

SubRx @'
function canSee(px,py,face,tx,ty,segs,far,cone,amb){
'@ @'
var FLASH_SEE=2;   // v16.03, his order: how many times farther a machine or pillager sees you while a lightning flash is up
function canSee(px,py,face,tx,ty,segs,far,cone,amb){
'@

SubRx @'
  wxTick(dt); strikeTick(dt); try{ tickHot(dt); }catch(_th){}
'@ @'
  wxTick(dt); strikeTick(dt); if(G.lightning>0) G.lightning=Math.max(0,G.lightning-dt); try{ tickHot(dt); }catch(_th){}   // v16.03: the flash counts down headless too (render2D, its only countdown, never runs in the sim), or a sim bolt would show the bot for the rest of the storm
'@

SubRx @'
   line:'Storm. Lightning strikes, and every flash shows you the whole map for a moment.'}   // v16.01, weather audit finding: the old line promised the flash shows you to everything out there, and nothing on the map reads it
'@ @'
   line:'Storm. Lightning strikes, and every flash shows you the map and shows you to them from farther off.'}   // v16.03, his order: the flash shows you to them, farther, not across the whole map
'@

SubRx @'
    if(MW.lightning) wv.push('lightning strikes, and a flash shows you the map');   // v16.01: the flash lifts the fog for you; nothing on the map reads it
'@ @'
    if(MW.lightning) wv.push('lightning strikes, and a flash shows you to them from farther');   // v16.03: the flash lifts the fog for you and doubles how far they see you
'@

SubRx @'
      // for you (above). Nothing on the map reads it; whether it should is his call (v16.01)
'@ @'
      // for you (above), and updateEnts reads it: they see you FLASH_SEE times farther while it is up (v16.03, his order)
'@

SubRx @'
var VER='16.02';
'@ @'
var VER='16.03';
'@

$pat = "(?m)^  now:'v16\.02:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v16.03: A LIGHTNING FLASH SHOWS YOU TO THEM FROM FARTHER. His order. While a flash is up, anything looking your way sees you out to twice its own sight, through its own cone and walls, not under a roof, and crouching does not hide you inside that range. Not the whole map. The flash counts down in the sim too. The storm line and the CONDITIONS row say so. Map building untouched. Check 16.03 fails on v16.02',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
