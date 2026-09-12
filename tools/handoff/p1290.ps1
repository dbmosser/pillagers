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

# FINDING 4 OF THE 2026-09-11 AUDIT. His vocabulary is binding, the rename was
# announced outright in the release notes, and the game keeps it everywhere else:
# the pause key list, the stash heading, the loadout label, the keyboard and pad
# legends. This button is the one place it was missed, and it is the single
# most-seen piece of player-facing text in the run-report slice.
#
# IT REACHES HIM, NOT JUST THE PLAYER. Tap the tag and press LOG RUN AND RETURN
# and the string is stored on the run, printed on the Undercroft run row, and
# lands in the report twice: in the FEELING TAGS header and under the run itself.
# That report is the file a friend copies out and sends to Daniel, so the retired
# word is written into the thing he reads.
#
# THE LINT PROVABLY CANNOT CATCH THIS ONE, which is worth knowing before anyone
# trusts a green lint run on vocabulary. Its sweep only considers quoted strings
# of 30 to 400 characters; this one is 18. The word is on its banned list and the
# sweep never offers it the string.
#
# OLD RUNS STORE THE LITERAL, so renaming the button alone would leave every run
# already logged printing the retired word for the rest of the profile's life. A
# display-time map carries them forward instead of a migration: nothing stored is
# rewritten, so an export made before today still reads correctly, and there is no
# one-shot stamp to get wrong. The three places that show a stored tag go through
# it.
SubRx @'
  'Inventory fiddly','Hotbar worked well','Loot boring','Loot exciting',
'@ @'
  'Inventory fiddly','Tactical belt worked well','Loot boring','Loot exciting',
'@

SubRx @'
var TAGS=[
'@ @'
// v12.90: TAGS THAT HAVE BEEN RENAMED, carried forward where they are SHOWN
// rather than rewritten where they are stored. A run logged before the rename
// holds the old string; mapping at display leaves his exports readable and needs
// no one-shot migration stamp, which is its own defect class.
var TAGFWD={'Hotbar worked well':'Tactical belt worked well'};
function tagText(t){ return TAGFWD[t]||t; }
function tagList(a){ var o=[],i; for(i=0;i<(a||[]).length;i++) o.push(tagText(a[i])); return o; }
var TAGS=[
'@

SubRx @'
  if(r.tags&&r.tags.length) s+='<br><span style="color:var(--amber)">'+escHtml(r.tags.join(', '))+'</span>';
'@ @'
  if(r.tags&&r.tags.length) s+='<br><span style="color:var(--amber)">'+escHtml(tagList(r.tags).join(', '))+'</span>';
'@

SubRx @'
  P.log.forEach(function(r){ (r.tags||[]).forEach(function(t){ tagCount[t]=(tagCount[t]||0)+1; }); });
'@ @'
  P.log.forEach(function(r){ (r.tags||[]).forEach(function(t){ var _t=tagText(t); tagCount[_t]=(tagCount[_t]||0)+1; }); });
'@

SubRx @'
    if(r.tags&&r.tags.length) L.push('   tags: '+r.tags.join(', '));
'@ @'
    if(r.tags&&r.tags.length) L.push('   tags: '+tagList(r.tags).join(', '));
'@

# NEW IN.
SubRx @'
  'ESC CLOSES THE BACKPACK AND THE MAP IN A RAID.
'@ @'
  'THE FEELING TAG FOR THE TACTICAL BELT CALLS IT THE TACTICAL BELT. It was the one button left saying the old word, and it was written into the report you send. Runs you logged before today read the new name too, without anything stored being rewritten.',
  'ESC CLOSES THE BACKPACK AND THE MAP IN A RAID.
'@

# STAMPS.
SubRx @'
var VER='12.89';
'@ @'
var VER='12.90';
'@
SubRx @'
var WHATSNEW_VER='12.89';
'@ @'
var WHATSNEW_VER='12.90';
'@
$cnt=([regex]::Matches($s,"now:'v12\.89:[^']*'")).Count
if($cnt -ne 1){ throw "DEVNOW v12.89 matched $cnt times" }
$s=[regex]::Replace($s,"now:'v12\.89:[^']*'",{ param($m) "now:'v12.90: finding 4 of the 2026-09-11 audit. His vocabulary is binding, the rename was announced outright in the release notes, and the game keeps it everywhere else: the pause key list, the stash heading, the loadout label, the keyboard and pad legends. The feeling-tag button was the one place it was missed, and it is the single most-seen piece of player-facing text in the run-report slice. It reaches HIM and not just the player: tap the tag and press LOG RUN AND RETURN and the string is stored on the run, printed on the Undercroft run row, and lands in the report twice, in the FEELING TAGS header and under the run itself, and that report is the file a friend copies out and sends to Daniel, so the retired word was written into the thing he reads. The lint provably cannot catch this one, which is worth knowing before anyone trusts a green lint run on vocabulary: its sweep only considers quoted strings of 30 to 400 characters and this one is 18, so the word is on its banned list and the sweep never offers it the string. Old runs store the literal, so renaming the button alone would leave every run already logged printing the retired word for the rest of the profile life; a display-time map carries them forward instead of a migration, so nothing stored is rewritten, an export made before today still reads correctly, and there is no one-shot stamp to get wrong, which is its own defect class. The three places that show a stored tag go through it. Check 12.90 requires the retired word to be absent from the tag list the card draws and the new name to be present, presses that button through the real card and requires the stored run to carry it, plants a run holding the old string and requires the run row, the report aggregate and the per-run report line all to show the new name while the stored value is left alone, and controls that an unrenamed tag passes through untouched; fails on v12.89.'" })
$n++

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count + 1
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
