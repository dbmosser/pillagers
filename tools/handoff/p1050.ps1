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

# ============ HIS NOTE, 2026-09-03 about 19:20: "freckles collide with eyes,
# ============ scar collides with eyes, beard stubble is too high, collides
# ============ with eyes -- shoes should be separate from pants". The eyes are
# ============ two ellipses at ty-29.5 with a half height of 3, so the eye band
# ============ runs ty-32.5 to ty-26.5 and x hx2-5.9 to hx2+5.9. Measured against
# ============ that: the freckles sat at ty-27.8 and ty-27.2, inside the band;
# ============ the scar ran ty-33.6 to ty-27.2 at hx2+2.2, through the right eye;
# ============ the stubble started at ty-28.2, 1.7 into the band; the goatee at
# ============ ty-27.8 and the mud at ty-27.6 clipped it too. And the boots were
# ============ the whole lower leg, ty-11 to the ground, so a boot colour was a
# ============ trouser colour.

# 1. Freckles below the eyes, on the cheeks.
SubRx @'
    else if(_fx===5){ wc.fillStyle='rgba(150,90,60,.55)';
      wc.fillRect(hx2-5.4,ty-27.8,1,1); wc.fillRect(hx2-3.2,ty-27.2,1,1);
      wc.fillRect(hx2+2.4,ty-27.8,1,1); wc.fillRect(hx2+4.4,ty-27.2,1,1); }
'@ @'
    else if(_fx===5){ wc.fillStyle='rgba(150,90,60,.55)';   // v10.50: on the cheeks, clear of the eye band (ty-26.5)
      wc.fillRect(hx2-5.8,ty-26.0,1,1); wc.fillRect(hx2-3.6,ty-25.4,1,1);
      wc.fillRect(hx2+2.8,ty-26.0,1,1); wc.fillRect(hx2+4.8,ty-25.4,1,1); }
'@

# 2. The scar on the outer cheek, beside the eye rather than through it.
SubRx @'
    if(_fx===6){ wc.fillStyle='#a04a3a'; wc.fillRect(hx2+2.2,ty-33.6,1.1,6.4); wc.fillStyle='#d47a6a'; wc.fillRect(hx2+2.2,ty-31.2,1.1,1); }
'@ @'
    if(_fx===6){ wc.fillStyle='#a04a3a'; wc.fillRect(hx2+6.2,ty-32.0,1.1,6.2); wc.fillStyle='#d47a6a'; wc.fillRect(hx2+6.2,ty-29.0,1.1,1); }   // v10.50: outside the eye (hx2+5.9)
'@

# 3. Mud on the cheeks and jaw, below the band.
SubRx @'
    else if(_fx===4){ wc.fillStyle='rgba(40,32,28,.30)'; rrF(hx2-6.4,ty-27.6,12.8,4.6,2.6); }
'@ @'
    else if(_fx===4){ wc.fillStyle='rgba(40,32,28,.30)'; rrF(hx2-6.4,ty-26.4,12.8,4.6,2.6); }   // v10.50: below the eye band
'@

# 4. The beards start under the eyes. Chops stay at the sides, where they were.
SubRx @'
      if(BEARD==='stubble'){ wc.globalAlpha=0.55; rrF(hx2-5.6,ty-28.2,11.2,3.6,1.6); wc.globalAlpha=1; }
      else if(BEARD==='goatee'){ rrF(hx2-2.4,ty-27.8,4.8,4.6,1.4); }
      else if(BEARD==='fullbeard'){ rrF(hx2-6.4,ty-29,12.8,6.2,2.4); }
'@ @'
      // v10.50, his note: the stubble sat 1.7 into the eye band. Every beard
      // starts under the band now (ty-26.5); the full beard reaches the chin.
      if(BEARD==='stubble'){ wc.globalAlpha=0.55; rrF(hx2-5.6,ty-26.2,11.2,3.6,1.6); wc.globalAlpha=1; }
      else if(BEARD==='goatee'){ rrF(hx2-2.4,ty-26.4,4.8,4.6,1.4); }
      else if(BEARD==='fullbeard'){ rrF(hx2-6.4,ty-26.2,12.8,5.8,2.4); }
'@

# 4b. The dust mask reaches the chin, so it still covers a beard that starts
#     lower (the v10.17 rule: full beard plus mask equals clean plus mask).
SubRx @'
    } else if(HAT==='mask'){
      wc.fillStyle=INK;       rrF(hx2-8,ty-29.4,16,6.2,2.6);
      wc.fillStyle='#14161b'; rrF(hx2-7.4,ty-28.9,14.8,5.2,2.2);
'@ @'
    } else if(HAT==='mask'){
      wc.fillStyle=INK;       rrF(hx2-8,ty-29.4,16,9.4,2.6);     // v10.50: down to the chin, over the lower beards
      wc.fillStyle='#14161b'; rrF(hx2-7.4,ty-28.9,14.8,8.4,2.2);
'@

# 5. Trousers are trousers and boots are boots: the leg plates take a trouser
#    shade cut from the coat, and the boot colour keeps the foot and a collar.
SubRx @'
  var _BT=BOOTCOL[st.hero?cosWorn('boots'):(st.boots||'bootblack')]||BOOTCOL.bootblack;
  wc.fillStyle=_BT[0];
  rrF(x-6.3+swing2*.5,ty-11,4.6,7.5-liftB*.5,1);
  rrF(x-6.5+swing2,ty-4.5-liftB,5.4,4.5,1);
  wc.fillStyle=_BT[1];
  rrF(x+1.7+swing*.5,ty-11,4.6,7.5-liftA*.5,1);
  rrF(x+1.1+swing,ty-4.5-liftA,5.4,4.5,1);
'@ @'
  var _BT=BOOTCOL[st.hero?cosWorn('boots'):(st.boots||'bootblack')]||BOOTCOL.bootblack;
  // v10.50, his note: "shoes should be separate from pants". The lower leg is
  // trousers, a darker cut of the coat, and the boot colour is the foot and a
  // collar two units tall above it, so a red boot is a red boot and not red
  // trousers.
  var _TRS=darkHex(cc,.50);
  wc.fillStyle=_TRS;
  rrF(x-6.3+swing2*.5,ty-11,4.6,7.5-liftB*.5,1);
  rrF(x+1.7+swing*.5,ty-11,4.6,7.5-liftA*.5,1);
  wc.fillStyle=_BT[0];
  rrF(x-6.4+swing2*.5,ty-6.6-liftB,4.8,2.4,.8);
  rrF(x-6.5+swing2,ty-4.5-liftB,5.4,4.5,1);
  wc.fillStyle=_BT[1];
  rrF(x+1.6+swing*.5,ty-6.6-liftA,4.8,2.4,.8);
  rrF(x+1.1+swing,ty-4.5-liftA,5.4,4.5,1);
'@

SubRx @'
var VER='10.49';
'@ @'
var VER='10.50';
'@
SubRx @'
  now:'v10.49: the words you change with the in-game editor ride in every run report, so they are picked up and made permanent in the game itself. Before this an edit lived only in your browser.',
'@ @'
  now:'v10.50: the freckles, the scar, the mud and every beard sit clear of the eyes, on the cheeks and the jaw where they belong, and boots are boots: the lower leg is trousers cut from the coat and the boot colour is the foot and a collar. In the Depot and in the raid alike.',
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
