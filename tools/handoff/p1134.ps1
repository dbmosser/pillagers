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

# MY v11.26 REGRESSION, CAUGHT BY THE FULL CORPUS. Rewriting the pause key line
# at v11.26 I changed "E interact" to "E search / call for extraction" and
# "CTRL / C crouch toggle" to "crouch on/off". Check v10.41, which reads his
# words back off the pause box, requires those two exact phrases, and the
# batched checks from v11.26 to v11.33 never included it, so the red shipped
# eight builds. Both phrases go back to what v10.41 asks for; the rest of the
# v11.26 line (no literal entity, F melee strike, TAB backpack, 1-9 tactical
# belt, hold to sprint) stays, so check v11.26 still passes.
SubRx @'
MOUSE aim &nbsp; LMB fire &nbsp; RMB aim down sights &nbsp; WASD move &nbsp; SPACE dodge roll &nbsp; SHIFT hold to sprint &nbsp; CTRL / C crouch on/off<br>E search / call for extraction &nbsp; R reload &nbsp; F melee strike &nbsp; 1-9 tactical belt &nbsp; TAB backpack &nbsp; ENTER equip from backpack &nbsp; M map &nbsp; H controls &nbsp; P / ESC pause
'@ @'
MOUSE aim &nbsp; LMB fire &nbsp; RMB aim down sights &nbsp; WASD move &nbsp; SPACE dodge roll &nbsp; SHIFT hold to sprint &nbsp; CTRL / C crouch toggle<br>E interact &nbsp; R reload &nbsp; F melee strike &nbsp; 1-9 tactical belt &nbsp; TAB backpack &nbsp; ENTER equip from backpack &nbsp; M map &nbsp; H controls &nbsp; P / ESC pause
'@

# STAMPS.
SubRx @'
var VER='11.33';
'@ @'
var VER='11.34';
'@
SubRx @'
var WHATSNEW_VER='11.33';
'@ @'
var WHATSNEW_VER='11.34';
'@
SubRx @'
  'ONE WORD FOR THE PACK: BACKPACK. The title controls line, the empty-panel hint and the full-pack message called it the "bag"; they say backpack now, and the full-pack message names Z, which drops, not TAB, which opens it.',
'@ @'
  'THE PAUSE SCREEN KEY LINE READS RIGHT. Two phrases I changed by mistake are back: E interact and CTRL / C crouch toggle. No change you would notice beyond those two words.',
  'ONE WORD FOR THE PACK: BACKPACK. The title controls line, the empty-panel hint and the full-pack message called it the "bag"; they say backpack now, and the full-pack message names Z, which drops, not TAB, which opens it.',
'@
SubRx @'
  now:'v11.33: the old word "bag" in three player-facing strings, against his BACKPACK ruling: the title controls line, the empty backpack hint and the full-pack message. All say backpack now, and the full message names Z, which drops the selected stack, not TAB, which opens the backpack. The full-pack message is effectively unreachable with the unlimited pack but was fixed for the record. From the pad-and-words agent; the title-screen pause and ENTER-dismiss findings from the same agent did not reproduce through the fixture and are STILL OPEN pending a real title keypress test.',
'@ @'
  now:'v11.34: my own regression, caught by the full corpus. Rewriting the pause key line at v11.26 I changed "E interact" to "E search / call for extraction" and "crouch toggle" to "crouch on/off"; check v10.41 reads his words off the pause box and requires those two phrases, and the batched checks from v11.26 on never ran it, so the red shipped eight builds. Both phrases are back. Lesson: a build that edits a player-facing string a shipped check reads must run that check, or the full corpus.',
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
