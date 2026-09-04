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

# ============ NOTE 17: NO PILLAGER HAS EVER WORN A HAT, A BEARD OR A TATTOO.
# ============
# ============ Found at v10.94 while proving the eye instrument, by asking each
# ============ rack whether it changes a NON-hero figure at all. The same rack, on
# ============ the same call, at nine times raid size:
# ============
# ============   headgear   hero 31,978 pixels changed, pillager 0
# ============   beard      hero  5,221 pixels changed, pillager 0
# ============   tattoo     hero    801 pixels changed, pillager 0
# ============
# ============ CAUSE: the block that draws the operator's fringe also contains the
# ============ tattoo, the beard and the headgear, and the whole block sits behind
# ============ a hero-only branch. Hair colour and cut are outside it, which is
# ============ why the crowd looks varied enough that this went unnoticed for
# ============ months.
# ============
# ============ WHAT IT COSTS: the Undercroft crowd rolls a hat, a beard and a
# ============ tattoo for every single member and none of them are drawn, and two
# ============ lines of his new-in card promise that the pillagers dress from the
# ============ same racks he does. That is a shipped promise that is not true.
# ============
# ============ THE FIX: the branch closes after the FRINGE, which is the one thing
# ============ in there that is genuinely hers, her own hair styling; the tattoo,
# ============ the beard and the headgear fall outside it and reach everybody.
# ============ Every one of them already reads the pillager's own look through
# ============ st, written for this and never reachable until now.

# ---- 1. close the hero branch after the fringe
SubRx @'
    if(_HCUT==='long'||_HCUT==='pigtails'){
      wc.fillStyle=HAIRLIT; rrF(hx2-7.5,ty-37,15,4,4);
      wc.fillStyle=HAIRHI;  wc.fillRect(hx2-6.6,ty-36.6,10.4,1.4);
    }
    // v10.36: TATTOO, ink on the face and neck, before the beard and headgear.
'@ @'
    if(_HCUT==='long'||_HCUT==='pigtails'){
      wc.fillStyle=HAIRLIT; rrF(hx2-7.5,ty-37,15,4,4);
      wc.fillStyle=HAIRHI;  wc.fillRect(hx2-6.6,ty-36.6,10.4,1.4);
    }
  }
  // v10.99, NOTE 17: EVERYTHING BELOW IS A RACK, AND THE RACKS REACH EVERYBODY.
  // The fringe above is hers, her own hair styling, and stays hers. The tattoo,
  // the beard and the headgear were inside that same branch, so no pillager and
  // nobody in the Undercroft has ever worn any of them, while the crowd rolls all
  // three for every member and the new-in card promises they dress from the same
  // racks he does. Each of these already reads a pillager's own look through st;
  // that code was written for this and has never once been reachable.
  {
    // v10.36: TATTOO, ink on the face and neck, before the beard and headgear.
'@

# ---- 2. and the old closing brace goes with it
SubRx @'
      wc.fillStyle='#1a1c22'; rrF(hx2-9.2,ty-40.6,18.4,3.2,2);
    }

  }
  // v10.54, his notes: THE SUIT'S OWN PAINT. Last, over everything the racks
'@ @'
      wc.fillStyle='#1a1c22'; rrF(hx2-9.2,ty-40.6,18.4,3.2,2);
    }
  }
  // v10.54, his notes: THE SUIT'S OWN PAINT. Last, over everything the racks
'@

SubRx @'
var VER='10.98';
'@ @'
var VER='10.99';
'@
SubRx @'
  now:'v10.98: the crash in your run report, and it was mine. Renaming your pillager threw every time you pressed SAVE, four times in your log, because v10.96 moved the name line into a function and left the rename button reading a variable that had gone with it. The name saved; the line under the title did not change and the handler died. It calls the one function now.',
'@ @'
  now:'v10.99: no pillager has ever worn a hat, a beard or a tattoo. Measured: the same rack changes your operator by 31,978 pixels and a pillager by zero, because the block that draws them sits inside a hero-only branch along with your fringe. The crowd rolls all three for every member and none were drawn. The branch closes after the fringe now, which is the one thing in there that is actually yours.',
'@
SubRx @'
  'THIS IS AN ALPHA. Things will break. When something does, the game writes it into your run report and tells you so; that report is how it gets fixed.',
'@ @'
  'THIS IS AN ALPHA. Things will break. When something does, the game writes it into your run report and tells you so; that report is how it gets fixed.',
  'PILLAGERS WEAR HATS, BEARDS AND TATTOOS NOW, and so does the crowd in the Undercroft. They always rolled them and none of it was ever drawn, because the code that draws them sat behind a branch meant only for your own fringe. Your fringe is still yours alone.',
'@
SubRx @'
var WHATSNEW_VER='10.98';
'@ @'
var WHATSNEW_VER='10.99';
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
