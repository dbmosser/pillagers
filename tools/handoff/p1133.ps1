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

# THE OLD WORD "BAG" IN THREE PLAYER-FACING STRINGS. His ruling is BACKPACK
# everywhere; the title controls line, the empty-panel hint and the full-pack
# toast still said bag. The toast also told him TAB drops, where TAB opens the
# backpack and Z drops the selected stack.
SubRx @'
      <b style="color:var(--bone)">TAB</b> bag &nbsp;
'@ @'
      <b style="color:var(--bone)">TAB</b> backpack &nbsp;
'@
SubRx @'
    ctx.fillText('Bag is empty.',x+11,hintY);
'@ @'
    ctx.fillText('Backpack is empty.',x+11,hintY);
'@
SubRx @'
      say(P.autoloot?('Bag full ('+cap+') and nothing left worth dropping.')
                    :('Bag full ('+cap+'). TAB to drop something.'));
'@ @'
      say(P.autoloot?('Backpack full ('+cap+') and nothing left worth dropping.')
                    :('Backpack full ('+cap+'). Z drops the selected item.'));
'@

# STAMPS.
SubRx @'
var VER='11.32';
'@ @'
var VER='11.33';
'@
SubRx @'
var WHATSNEW_VER='11.32';
'@ @'
var WHATSNEW_VER='11.33';
'@
SubRx @'
  'COPY REPORT TELLS THE TRUTH. If your browser refuses the clipboard, the button says so and points you at Settings, Recorder, instead of saying Copied over an empty clipboard. This is how your bug reports reach me.',
'@ @'
  'ONE WORD FOR THE PACK: BACKPACK. The title controls line, the empty-panel hint and the full-pack message called it the "bag"; they say backpack now, and the full-pack message names Z, which drops, not TAB, which opens it.',
  'COPY REPORT TELLS THE TRUTH. If your browser refuses the clipboard, the button says so and points you at Settings, Recorder, instead of saying Copied over an empty clipboard. This is how your bug reports reach me.',
'@
SubRx @'
  now:'v11.32: Copy report said Copied when nothing was copied. The clipboard rejection handler was the success handler, and on a plain http page (no navigator.clipboard) the fallback selected a textarea inside a hidden modal, where execCommand copies nothing, then reported success. This is the channel his friends bugs reach him by. A refused copy now says so and names Settings, Recorder; the fallback copies from a visible off-screen textarea and believes execCommand. Reverted and held open this session: the combat beat-to-react floor, reproduced but its edge-fix could not be proven to fire without a line-of-sight harness.',
'@ @'
  now:'v11.33: the old word "bag" in three player-facing strings, against his BACKPACK ruling: the title controls line, the empty backpack hint and the full-pack message. All say backpack now, and the full message names Z, which drops the selected stack, not TAB, which opens the backpack. The full-pack message is effectively unreachable with the unlimited pack but was fixed for the record. From the pad-and-words agent; the title-screen pause and ENTER-dismiss findings from the same agent did not reproduce through the fixture and are STILL OPEN pending a real title keypress test.',
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
