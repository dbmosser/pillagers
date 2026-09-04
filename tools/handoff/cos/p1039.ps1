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

# ============ HIS NOTES, 2026-09-03 about 14:00: "i want a master chief esque
# ============ green halo helmet as one of the cosmetic options" and "ghostface
# ============ from scream as a helmet/head option".
#
# Two headgear on the racks: a green Spartan helmet with a gold visor, and a
# white ghost mask with black hollows. Both cover the face, so the beard and
# the face marks go under them, which is how the headgear branch already
# orders things. Earned: the helmet at twenty extracts, the mask for three
# Wardens. Named for what they are, not for where they came from.

SubRx @'
  {id:'hood',   name:'Hood',           how:'warden:2',    kind:'hat'},
'@ @'
  {id:'hood',   name:'Hood',           how:'warden:2',    kind:'hat'},
  // v10.39, his notes: a green Spartan helmet, and a white ghost mask.
  {id:'spartan',   name:'Spartan Helmet', how:'extracts:20', kind:'hat'},
  {id:'ghostmask', name:'Ghost Mask',     how:'warden:3',    kind:'hat'},
'@

SubRx @'
    } else if(HAT==='hood'){
      // a hood up: a hooded shape that wraps past the ears.
      wc.fillStyle=INK;       rrF(hx2-10.4,ty-41.6,20.8,12.2,6);
      wc.fillStyle='#2e3238'; rrF(hx2-9.8,ty-41.1,19.6,11.2,5.4);
      wc.fillStyle='#3d424b'; rrF(hx2-9.2,ty-40.6,18.4,3,4);
      wc.fillStyle='#14161b'; rrF(hx2-6.6,ty-35.2,13.2,5.4,3);
    }
'@ @'
    } else if(HAT==='hood'){
      // a hood up: a hooded shape that wraps past the ears.
      wc.fillStyle=INK;       rrF(hx2-10.4,ty-41.6,20.8,12.2,6);
      wc.fillStyle='#2e3238'; rrF(hx2-9.8,ty-41.1,19.6,11.2,5.4);
      wc.fillStyle='#3d424b'; rrF(hx2-9.2,ty-40.6,18.4,3,4);
      wc.fillStyle='#14161b'; rrF(hx2-6.6,ty-35.2,13.2,5.4,3);
    } else if(HAT==='spartan'){
      // v10.39: a full green helmet over the whole head, gold visor across the eyes.
      wc.fillStyle=INK;       rrF(hx2-10.2,ty-42.2,20.4,20.8,6);
      wc.fillStyle='#3f6a3a'; rrF(hx2-9.6,ty-41.7,19.2,19.8,5.4);
      wc.fillStyle='#55874c'; rrF(hx2-8.6,ty-41.2,17.2,4.4,4);
      wc.fillStyle='#2a4a28'; rrF(hx2-9.2,ty-26.2,18.4,3.8,1.6);   // the chin guard, over where a beard would be
      wc.fillStyle=INK;       rrF(hx2-8.2,ty-35.6,16.4,5.2,2.2);
      wc.fillStyle='#d9a52a'; rrF(hx2-7.6,ty-35.1,15.2,4.2,1.8);
      wc.fillStyle='#f5d47a'; wc.fillRect(hx2-6.4,ty-34.7,6.2,1.1);
    } else if(HAT==='ghostmask'){
      // a white ghost mask: a long pale face with black hollows for eyes and a mouth.
      wc.fillStyle=INK;       rrF(hx2-8.4,ty-38.6,16.8,17.4,6);
      wc.fillStyle='#f0ede4'; rrF(hx2-7.8,ty-38.1,15.6,16.4,5.4);   // down past the chin, over a beard
      wc.fillStyle='#0a0c10';
      wc.beginPath(); wc.ellipse(hx2-3.6,ty-32.6,2.2,3.2,-0.3,0,6.2832); wc.fill();
      wc.beginPath(); wc.ellipse(hx2+3.6,ty-32.6,2.2,3.2,0.3,0,6.2832); wc.fill();
      wc.beginPath(); wc.ellipse(hx2,ty-26.8,2.4,3.4,0,0,6.2832); wc.fill();
      wc.fillStyle='#1a1c22'; rrF(hx2-9.2,ty-40.6,18.4,3.2,2);
    }
'@

SubRx @'
         beanie:'\u2229',cap:'\u25E2',bandana:'\u25AC',hood:'\u2229',
         clean:'--',stubble:'\u2591',goatee:'\u25BE',fullbeard:'\u25BC',chops:'\u2016',
'@ @'
         beanie:'\u2229',cap:'\u25E2',bandana:'\u25AC',hood:'\u2229',spartan:'\u25D3',ghostmask:'\u263A',
         clean:'--',stubble:'\u2591',goatee:'\u25BE',fullbeard:'\u25BC',chops:'\u2016',
'@

SubRx @'
  var fbg={beanie:'#4a4f5a',cap:'#5a5a3e',bandana:'#8a2a2a',hood:'#2e3238'}[c.id]||'#1b1f26';
'@ @'
  var fbg={beanie:'#4a4f5a',cap:'#5a5a3e',bandana:'#8a2a2a',hood:'#2e3238',spartan:'#3f6a3a',ghostmask:'#f0ede4'}[c.id]||'#1b1f26';
'@

SubRx @'
  var hatGlyph={none:'',band:'\u25AC',phones:'\u25CF\u25CF',mask:'\u25AC',visor:'\u25AD',crown:'\u2662',
                beanie:'\u2229',cap:'\u25E2',bandana:'\u25AC',hood:'\u2229'}[hat]||'';
  var hatBg={none:'',band:'#c0503a',phones:'#22262e',mask:'#14161b',visor:'#a9682f',crown:'#c9962c',
             beanie:'#4a4f5a',cap:'#5a5a3e',bandana:'#8a2a2a',hood:'#2e3238'}[hat]||'';
'@ @'
  var hatGlyph={none:'',band:'\u25AC',phones:'\u25CF\u25CF',mask:'\u25AC',visor:'\u25AD',crown:'\u2662',
                beanie:'\u2229',cap:'\u25E2',bandana:'\u25AC',hood:'\u2229',spartan:'\u25AD',ghostmask:'\u25CB'}[hat]||'';
  var hatBg={none:'',band:'#c0503a',phones:'#22262e',mask:'#14161b',visor:'#a9682f',crown:'#c9962c',
             beanie:'#4a4f5a',cap:'#5a5a3e',bandana:'#8a2a2a',hood:'#2e3238',spartan:'#3f6a3a',ghostmask:'#f0ede4'}[hat]||'';
'@

SubRx @'
var VER='10.38';
'@ @'
var VER='10.39';
'@

# The what-is-new card moves with this build (drift from v10.14 would pass
# 0.15 at the next one). Everything he can see since v10.14, newest first.
SubRx @'
var WHATSNEW_VER='10.22';
'@ @'
var WHATSNEW_VER='10.39';
'@
SubRx @'
  'THE MENUS NEVER SHRINK BELOW THE SCREEN. The wheel still sizes them, and now says so, MENU SIZE 130%; the size cannot go below 1.0, so on a 4K monitor nothing is ever smaller than 1.9 times its 1080p size.',
  'THREE NEW RACKS AT THE DEPOT: BEARD, EYES and FACE. Stubble, a goatee, a full beard, chops; six eye colours; a scar, freckles, mud, war paint, a black eye. Earned. SURPRISE ME dresses you from every rack and three LOOKS keep an outfit.',
  'THE PILLAGERS DRESS FROM THE SAME RACKS you do, hair, hats, beards, eyes and faces, so no two look alike.',
  'A DOWNED PILLAGER CRAWLS FOR COVER, dragging himself to the nearest spot you cannot see, bleeding all the way.',
  'THE MOUSE SAYS WHAT A PANEL WILL DO: a resize arrow at a corner, a move hand on a grip, a pointer on a button.',
  'THE HOTBAR IS THE TACTICAL BELT, everywhere a word names it: the stash, the raid, the legends, the pause screen, the primer.',
  'THE STASH IS FIVE THINGS: the stash, your backpack, your tactical belt, the safe pocket and the freebie kit. Everything else that crowded it is gone. The backpack is a grid of twelve cells there and in the raid, empty cells drawn.',
'@ @'
  'A NEW CHARACTER GETS A WELCOME PACK: a green gun and a blue one, heals, plates and grenades, offered once, the first time down.',
  'THE FIGURE AT THE DEPOT IS THE RAID PAINTER\'S, five times raid size, so what you see there is what you see in the raid; the crowd in the Undercroft dresses from the racks too, eyes and all.',
  'THE MAINFRAME SHOWS NET LIFETIME EARNINGS: everything extracted minus everything carried in, over every run, a death or an abandon losing what it carried.',
  'THE TUNING CONSOLE IS A ROW IN SETTINGS, and the Settings rows read the live dials: an option when they match one, CUSTOM when they do not. The dev cheat box is behind a switch that unlocks after your first extraction.',
  'THE BLOTTER MELTS. The frame pours down the screen in strips on clocks rolled fresh with every dose, and the pouring comes and goes.',
  'THE HOTBAR IS THE TACTICAL BELT, everywhere a word names it.',
  'THE DISCOUNT FASHION DEPOT HAS FOURTEEN RACKS: build, skin, eyes, face, tattoo, hair, hairstyle, beard, headgear, clothing, patch, gloves, boots and backpack. Every piece is earned by playing. SURPRISE ME dresses you from every rack and three LOOKS keep an outfit.',
  'A GREEN SPARTAN HELMET AND A WHITE GHOST MASK are on the headgear rack. Both cover the face.',
  'PILLAGERS DRESS FROM THE SAME RACKS you do, hair, hats, beards and all, so no two look alike.',
  'A DOWNED PILLAGER CRAWLS FOR COVER, dragging himself to the nearest spot you cannot see, bleeding all the way.',
  'THE FULL CONTROLS LIST FITS THE SCREEN. Press H twice: it is centred and on the screen at any monitor size, and the message line scales with the panels.',
  'THE MOUSE SAYS WHAT A PANEL WILL DO: a resize arrow at a corner, a move hand on a grip, a pointer on a button.',
  'THE STASH IS FIVE THINGS: the stash, your backpack, your tactical belt, the safe pocket and the freebie kit. Everything else that crowded it is gone. The backpack is a grid of twelve cells there and in the raid, empty cells drawn.',
'@
SubRx @'
  now:'v10.38: the full controls list is on the screen. Press H twice and the whole list is centred and fits, at any monitor size; on a 4K screen it used to be drawn off the right edge entirely, and at 1080p its rule cards sat under the conditions panel.',
'@ @'
  now:'v10.39: two more on the headgear rack: a green Spartan helmet with a gold visor, and a white ghost mask. Both cover the face. Earned, like everything on the racks.',
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
