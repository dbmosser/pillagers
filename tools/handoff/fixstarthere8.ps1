$ErrorActionPreference = 'Stop'
trap { Write-Output "FAILED: $_"; exit 1 }
# START-HERE: the queue after his afternoon notes and two renumbers
# (renum1195 +1, renum1196 +4). Inserted right after the queue header, above
# the older CURRENT QUEUE block, which is now history. Idempotent.
$f = 'C:\claudecode\dark raiders\tools\handoff\START-HERE.md'
$s = [IO.File]::ReadAllText($f)
$marker = '**CURRENT QUEUE (2026-09-06 14:50, after his afternoon notes; this list outranks every older list below):**'
if ($s.IndexOf($marker) -ge 0) { Write-Output 'START-HERE: already current'; exit 0 }
$hdr = '**THE QUEUE, ALL DRAFTED (p/f/d/a/cm in this folder), SHIP IN THIS ORDER:**'
$i = $s.IndexOf($hdr)
if ($i -lt 0) { throw 'queue header not found' }
$block = @(
  $marker,
  '- **1194 HIS FOUR WORDING NOTES** (Crier alarm, Pillbox death, one per raid, Search resumed). In flight at 14:50.',
  '- **1195 GUNS DRAG LIKE ANY OTHER ITEM** (his order: rack cells drag; rackToStash and rackPut; a figure gun takes the key alone). Drafted, NOT dry-run.',
  '- **1196 A BELT KEY TAKES HALF THE STACK AND SHOWS xN** (his order; planPut packs half, the plan cell shows the count). Drafted, NOT dry-run.',
  '- **1197 THE TACTICAL BELT DRAGS WITH THE BACKPACK CLOSED** (his notes: ghost on the cursor, hand gun released off the belt bags it, a gun key drags). Drafted, NOT dry-run.',
  '- **1198 A HOLD STARTED BEFORE THE WINDOW SHUT FINISHES, E ANYWHERE IN THE RING** (his orders; the ring already accepted E anywhere, the first press is a 1.6 s hold). Drafted, NOT dry-run.',
  '- **1199 to 1201 FIRST TEN MINUTES** (were 1195 to 1197 this morning): pause note survives ESC, first session setup, freebie death keeps the pistol.',
  '- **1202 THE HEAL VERB, 1203 THE NOTES LINE** (were 1198 and 1199 earlier; check 12.02 was 11.97).',
  '- **1204 to 1211 POLISH** (were 1199 to 1206 this morning; labels 12.04 to 12.11).',
  '- **1212 to 1218 MORE FIRST-RAID FIXES** (were 1207 to 1213: second down toast, lift freebie clears the belt plan, ESC closes the floor backpack, controls card X key, death banks card XP, empty grenade cell trigger, arrows do not walk with the bag open). The read-only review wf_282ab182-3ea of these seven (as 1207 to 1213) is in its journal and NOT yet folded in: its first finding is that the second-down toast should name the pad button through keyLabel.',
  '- **NOT DRAFTED, his notes of 14:00 to 14:30:** the stash right-click menu gets no menu zoom at 4K (.imenu is appended to body; give it the same zoom applyMenuZoom gives modals and divide its clientX/Y by the zoom); the Howler should not bomb from outside a building into it.',
  '- **DRY RUN:** after the v11.94 commit, `dry.ps1 1195 1218` from the tree at v11.94, then dry/mk.ps1, then checks 11.95 to 12.18 on :8801 between corpora. The pane is hidden all afternoon, so a corpus takes about 45 minutes.',
  '',
  ''
) -join "`n"
$s = $s.Substring(0, $i + $hdr.Length) + "`n`n" + $block + $s.Substring($i + $hdr.Length)
[IO.File]::WriteAllText($f, $s, (New-Object Text.UTF8Encoding $false))
Write-Output 'START-HERE: 14:50 queue inserted'
