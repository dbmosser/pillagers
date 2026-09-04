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

# ============ HIS NOTE: THE FEEDBACK BUTTONS AT THE END OF A RAID ARE OLD.
# ============
# ============ "change the feedback buttons at the end of a raid to something
# ============ more current", 2026-09-04.
# ============
# ============ REPRODUCED BY READING THE LIST. Twenty-four tags, and their own
# ============ comment dates them: "the two music tags went where the music went.
# ============ These two are the live unknowns instead: the Listener teaching was
# ============ rewritten at v5.60 and nobody has tested it on a human, and the
# ============ Choir has never been fought at all." That was written at v5.72.
# ============ Eight of the twenty-four are one-machine questions from that era:
# ============ Listener beatable, Listener unfair, Pillbox worth it, Pillbox a
# ============ chore, Bulwark great, Bulwark unfair, Howler great, Howler unfair.
# ============ Every one of those machines still exists and he has played dozens
# ============ of runs since, so they are answered by his own log rather than
# ============ open. NOTHING from the last thirty builds has a tag at all: not the
# ============ grid backpack, not the hotbar, not being downed and crawling, not
# ============ the map screen, not the Undercroft, not the weather he now
# ============ chooses, and above all not "this crashed" or "this looked wrong",
# ============ which are the two things a friend cannot tell him any other way.
# ============
# ============ THE ALPHA IS THE REASON THIS MATTERS. His friends are about to
# ============ play, and a tag is the only feedback most people will ever give.
# ============ Every button here is something a person can judge in one raid.
SubRx @'
var TAGS=['Felt great','Too easy','Too hard','Too dark',
  // v5.72: the two music tags went where the music went. These two are the live
  // unknowns instead: the Listener teaching was rewritten at v5.60 and nobody
  // has tested it on a human, and the Choir has never been fought at all.
  'Listener beatable','Listener unfair','Pillbox worth it','Pillbox a chore',
  'Bulwark great','Bulwark unfair',
  'Howler great','Howler unfair','Pillagers felt human','Pillagers felt dumb',
  'Extract too easy','Extract too tense','Loot boring','Loot exciting',
  'Maps feel samey','This map has character','Ran out of ammo','New machines too rare'];
'@ @'
// v11.01, HIS NOTE: THE TAGS ARE THE FEEDBACK. Rewritten for the alpha, because
// his friends are about to play and a tag is the only feedback most people ever
// give. The v5.72 set asked eight one-machine questions from an era he has since
// answered with dozens of logged runs, and had nothing at all about the last
// thirty builds. Every button below is something a person can judge in one raid,
// and the first three lines are what he most needs to hear from someone who is
// not him: it broke, it looked wrong, I could not read it.
var TAGS=[
  // The two a friend cannot tell him any other way.
  'Something crashed','Something looked wrong','Sound was off',
  // Readability, which is where most of his own notes come from.
  'Text hard to read','Could not find myself on the map','Menus confusing',
  // The overall feel.
  'Felt great','Too easy','Too hard','Too dark',
  // The things carried and the room they live in.
  'Inventory fiddly','Hotbar worked well','Loot boring','Loot exciting',
  'Nothing worth carrying','Ran out of ammo','Undercroft confusing',
  // Who is up there.
  'Pillagers felt human','Pillagers felt dumb','Machines too tough',
  'Machines pushovers','Died to something I never saw',
  // What he changed most recently and cannot judge alone.
  'Downed and crawling worked','Weather choice worth it','Night not worth it',
  // The place, and his oldest open complaint.
  'Maps feel samey','This map has character',
  // Getting out.
  'Extract too easy','Extract too tense'];
'@

SubRx @'
var VER='11.00';
'@ @'
var VER='11.01';
'@
SubRx @'
  now:'v11.00: weather is a choice on the sector page, your note, and the hard ones pay your 1.1x. SURPRISE ME is the old roll and stays the default. Rain, fog, blackout and storm pay the bonus because they cut sight or kill the lamps, asked of the weather table rather than kept as a list. It stacks with night, so a hard night pays 1.32x. The seeded roll still happens whatever you pick, or the map itself would change.',
'@ @'
  now:'v11.01: the feedback buttons at the end of a raid, your note. The old twenty-four were the open questions of v5.72, eight of them one-machine questions you have since answered with dozens of runs, and nothing at all from the last thirty builds. The new thirty lead with the three a friend cannot tell you any other way: it crashed, it looked wrong, the sound was off.',
'@
SubRx @'
  'THIS IS AN ALPHA. Things will break. When something does, the game writes it into your run report and tells you so; that report is how it gets fixed.',
'@ @'
  'THIS IS AN ALPHA. Things will break. When something does, the game writes it into your run report and tells you so; that report is how it gets fixed.',
  'THE BUTTONS AT THE END OF A RAID ARE NEW. They start with SOMETHING CRASHED, SOMETHING LOOKED WRONG and SOUND WAS OFF, because those are the three things you cannot tell us any other way. Press as many as you like; they go into the report with the run.',
'@
SubRx @'
var WHATSNEW_VER='11.00';
'@ @'
var WHATSNEW_VER='11.01';
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
