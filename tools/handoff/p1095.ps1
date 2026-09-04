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

# ============ HIS NOTE 18: THE LOOT POP IS STILL THE WRONG FONT.
# ============
# ============ "the loot text that pops on screen upon looting that tells you
# ============ what item you got is still too bolded -- use the entire font
# ============ across the entire game", 2026-09-04. STILL, so this is the second
# ============ time, after his note about looted names being super-bold.
# ============
# ============ REPRODUCED BY COUNTING, not by looking. Every text draw in a raid
# ============ frame, its HUD and four Undercroft frames was traced and its font
# ============ recorded. Everything came back Rubik in one of the five roles,
# ============ at three sizes because the HUD scale multiplies them, EXCEPT:
# ============   17.2px "Titan One"   the item name on the loot pop
# ============   15.6px "Titan One"   PICKED UP, and every other world label
# ============   114 to 244px "Titan One"  the faint district numbers baked into
# ============                             the ground of every map
# ============ Titan One is the toybox display face the title wordmark is set in.
# ============ At 15 pixels it does not read as a bold word, it reads as a slab.
# ============ That is his "too bolded", and it was never a weight: it was a
# ============ different typeface.
# ============
# ============ WHY IT SURVIVED THE FIRST PASS: the type system built for his
# ============ August note gives five ROLES and every call site was moved onto
# ============ them, but the world label function measures and draws with its own
# ============ string, so it never went through a role and the sweep never saw
# ============ it. A check that counted families would have caught it then, and
# ============ there is one now.

# ---- 1. the world label, where it is measured
SubRx @'
    wc.font=FS((big?'11px':'10px')+' "Titan One","Rubik",sans-serif');
'@ @'
    // v10.95, HIS NOTE: was Titan One, the title wordmark face. Roles now, and
    // the SAME roles the renderer uses, or the plate would be measured in one
    // font and filled in another.
    wc.font=FS(big?TYPE.label:TYPE.micro);
'@

# ---- 2. and where it is drawn
SubRx @'
    wc.font=FS((lb.big?'11px':'10px')+' "Titan One","Rubik",sans-serif');
'@ @'
    // v10.95, HIS NOTE: the loot pop and every other world label were set in
    // Titan One, which at fifteen pixels reads as a slab rather than a word.
    wc.font=FS(lb.big?TYPE.label:TYPE.micro);
'@

# ---- 3. the district numbers baked into the ground. Nobody reads them, they are
# ---- 13 percent opaque, but "the entire font across the entire game" is the
# ---- instruction and a second family on the canvas is a second family.
SubRx @'
    c.font='700 '+Math.round(Math.min(b3.w,b3.h)*(_bf===2?.52:.42))+'px "Titan One", sans-serif';
'@ @'
    c.font='700 '+Math.round(Math.min(b3.w,b3.h)*(_bf===2?.52:.42))+'px "Rubik",system-ui,sans-serif';   // v10.95, his note: one family
'@

# ---- 4. the placeholder dash on an item icon with no art, the last call in the
# ---- file that names a family of its own.
SubRx @'
    else { pcx.fillStyle='#8a96a1'; pcx.font='14px sans-serif'; pcx.textAlign='center'; pcx.fillText('--',17,22); }
'@ @'
    else { pcx.fillStyle='#8a96a1'; pcx.font='600 14px "Rubik",system-ui,sans-serif'; pcx.textAlign='center'; pcx.fillText('--',17,22); }   // v10.95, his note: one family
'@

SubRx @'
var VER='10.94';
'@ @'
var VER='10.95';
'@
SubRx @'
  now:'v10.94: the eye collisions on Undercroft faces, your note. Enumerated every look the crowd can roll: four of the six face marks are clean, war paint covered 66 percent of the eye area with two bars straight across both eyeballs, and the shiner covered 51 percent, which is one whole eye. A mark is on the skin and an eye is not skin, so the marks are painted before the eyes now.',
'@ @'
  now:'v10.95: the loot pop font, your note. Traced every text draw in a raid, its HUD and the Undercroft: all of it was already the game font in one of five roles, except the world labels and the faint district numbers on the ground, which were set in Titan One, the title wordmark face. At fifteen pixels that reads as a slab, not a word. It was never the weight, it was a second typeface.',
'@
SubRx @'
  'THIS IS AN ALPHA. Things will break. When something does, the game writes it into your run report and tells you so; that report is how it gets fixed.',
'@ @'
  'THIS IS AN ALPHA. Things will break. When something does, the game writes it into your run report and tells you so; that report is how it gets fixed.',
  'ONE FONT, EVERYWHERE ON THE SCREEN. The loot pop, PICKED UP and every other world label were set in the title wordmark face, which at that size reads as a slab rather than a word. They are in the game font now, in the same five roles as everything else, and so are the faint district numbers on the ground.',
'@
SubRx @'
var WHATSNEW_VER='10.94';
'@ @'
var WHATSNEW_VER='10.95';
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
