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

# ============ HIS NOTE: "TITLE SCREEN WASTES THE SCREEN. His shot on a wide
# ============ monitor: the whole thing is a narrow column in the middle with
# ============ empty space either side."
# ============
# ============ REPRODUCED on v10.72 at 1920x1080: the content runs from x=427 to
# ============ x=1493, so it is 1066 pixels of a 1920 pixel screen, FIFTY SIX
# ============ PERCENT, with 427 pixels of nothing down each side. This is the
# ============ first screen anybody sees, and on Saturday it is the first thing
# ============ his friends will see.
# ============
# ============ CAUSE: the column is capped at 820 pixels and the only rule that
# ============ ever widened it was gated on min-aspect-ratio 19/10, which is an
# ============ ultrawide. A 1920x1080 screen is 16/9, or 1.78, so the commonest
# ============ monitor in the world missed the rule by a tenth and got the
# ============ narrow-laptop layout.
# ============
# ============ Everything on this screen is inside a zoom, measured at 1.3 by
# ============ default, so 820 css pixels paint as 1066. The cap is written
# ============ against the viewport now with a floor, and the numbers come from
# ============ measuring rather than from taste: 62vw paints 81 percent of the
# ============ width at 1920 and the max(820px) floor means nothing narrower than
# ============ about 1320 wide changes at all. Measured at 1366x768 it goes 78 to
# ============ 81 percent and still fits; at 1920x1080, 56 to 81.
SubRx @'
  #title .titlecol{ max-width:820px; }
'@ @'
  /* v10.73, his note that the title screen wastes a wide monitor. 820 painted
     56 percent of a 1920 screen because the only widening rule was gated on
     ultrawide and 16/9 is not one. The cap follows the viewport now. Everything
     here sits inside a zoom of about 1.3, so 62vw is what paints near 80 percent;
     the max() floor keeps every screen narrower than about 1320 exactly as it
     was. Measured: 1920x1080 goes 56 to 81 percent, 1366x768 goes 78 to 81. */
  #title .titlecol{ max-width:max(820px,min(1320px,62vw)); }
'@

# The one block of real prose gets its own measure, or widening the column turns
# two sentences into a single 1,496 pixel line, which is worse to read than the
# narrow column was.
SubRx @'
    <div style="margin-top:26px;font-size:13.5px;line-height:1.65;color:var(--bone)">
      The elites left the surface to the machines and went somewhere better.
      You go up, you take what is worth taking, and you come back down.
    </div>
'@ @'
    <div style="margin-top:26px;font-size:13.5px;line-height:1.65;color:var(--bone);max-width:760px;margin-left:auto;margin-right:auto">
      The elites left the surface to the machines and went somewhere better.
      You go up, you take what is worth taking, and you come back down.
    </div>
'@

SubRx @'
var VER='10.72';
'@ @'
var VER='10.73';
'@
SubRx @'
  now:'v10.72: the death screen counts the gun it says you lost. It listed your gun as LOST and then left it out of the total underneath, so the number missed the most expensive thing you were carrying. An issued loaner is still in neither, because you never owned it.',
'@ @'
  now:'v10.73: the title screen uses the monitor. It was painting a narrow column across the middle of a 1920 screen with 427 pixels of nothing down each side, because the only rule that widened it was written for ultrawides and 16 by 9 missed it.',
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
