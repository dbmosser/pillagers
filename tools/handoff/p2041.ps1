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

# YOU HEAR YOUR TEAMMATE FIRE (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
function sfxHere(type,wx,wy,wid){
'@ @'
// v20.41, from the whole-game bug hunt of 2026-10-08 (H51): YOUR OWN SOUNDS REACH THE PARTY. Your gunshots, reloads and footsteps
// play centred in your own ears (they are in your hands), straight through blip, so they never went to the other window: a
// teammate's rifle was silent at any distance, and with the sound on one window only his whole fight was silent. They now also
// go to the party, placed where you stand, as every other sound does. A crouched step stays yours alone.
function blipMine(type,a,b,c,d){
  blip(type,a,b,c,d);
  if(typeof NET==='object'&&NET&&NET.on&&!NET.fxIn&&G&&!G.sim&&G.player) netFxNoise(type,G.player.x,G.player.y,(typeof c==='string')?c:undefined);
}
function sfxHere(type,wx,wy,wid){
'@

SubRx @'
if(fromPlayer) blip(melee?'hit':'shot',0,undefined,wep.id);
'@ @'
if(fromPlayer) blipMine(melee?'hit':'shot',0,undefined,wep.id);   // v20.41 (H51): and the party hears it where you stand
'@

SubRx @'
if(!G.sim) blip('reloadin');
'@ @'
if(!G.sim) blipMine('reloadin');
'@

SubRx @'
T.reloads++; if(!G.sim) blip('reload'); }   // v10.56
'@ @'
T.reloads++; if(!G.sim) blipMine('reload'); }   // v10.56
'@

SubRx @'
    p.reloading=p.wep.reload*buzzSlow(); T.reloads++; if(!G.sim) blip('reload');
'@ @'
    p.reloading=p.wep.reload*buzzSlow(); T.reloads++; if(!G.sim) blipMine('reload');
'@

SubRx @'
say('Reloading...'); blip('reload');
'@ @'
say('Reloading...'); blipMine('reload');
'@

SubRx @'
if(!G.sim) blip('dry');
'@ @'
if(!G.sim) blipMine('dry');
'@

SubRx @'
blip('foot',crouch?540:
'@ @'
(crouch?blip:blipMine)('foot',crouch?540:
'@

SubRx @'
var VER='20.40';
'@ @'
var VER='20.41';
'@

$pat = "(?m)^  now:'v20\.40:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v20.41: In co-op, you hear the other player fire, reload and walk, from where he is. Check 20.41 fails on v20.40',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
