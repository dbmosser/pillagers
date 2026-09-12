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

# FINDING 6 OF THE 2026-09-11 AUDIT, and it is the same class as the armoury
# omission that shipped at v11.66: a profile field surviving a REPLACE.
#
# THE INDEFENSIBLE HALF. A player who already has runs of his own pastes a friend's
# restore code over his save. The panel says, in those words, that it REPLACES the
# save he is playing. Everything else is replaced: name, credits, XP, runs, extracts,
# deaths, best haul, notoriety, the stash, the armoury. Net lifetime earnings is not,
# because nothing writes it, so his own figure stays and the career card prints it as
# a fact about the character he has just restored.
#
# THE OTHER HALF. On a fresh install the restored character lands with that card
# reading $0 beside a restored best haul of tens of thousands. The neighbouring cards
# honestly say nothing, because they are summed from the run log and the panel
# discloses that the log does not come back. This one states a figure instead.
#
# WHY NOT JUST RECOMPUTE IT. The only repair site fires when the field is ABSENT, and
# on an existing save it is present. And the log cannot answer the question anyway:
# it keeps the last sixty runs, while the counter is maintained for the life of the
# profile, so summing the log is a migration approximation and not the number.
#
# THE FIX. Carry it in the code beside the other counters, and write it in the same
# place. A code made before today has no key for it, and then it is set to zero
# rather than left showing the previous character's figure: an honest zero for a
# character whose maker never recorded it beats somebody else's lifetime.
SubRx @'
         j:P.junk||{},mi:P.mapIx||0,cd:P.cond||'day',wq:P.wxPick||'any',
'@ @'
         j:P.junk||{},mi:P.mapIx||0,cd:P.cond||'day',wq:P.wxPick||'any',
         // v12.97: NET LIFETIME EARNINGS. A counter kept for the life of the
         // profile, not a restatement of the run log, which keeps only the last
         // sixty runs; leaving it out meant a restored character wore the figure
         // belonging to whoever restored it.
         ne:P.netEarn||0,
'@

SubRx @'
  P.wxPick=o.wq||'any';
'@ @'
  P.wxPick=o.wq||'any';
  // v12.97: and the lifetime earnings with them. A code made before v12.97 has no
  // key for it, and an honest zero for a character whose maker never recorded it is
  // better than leaving the restorer's own lifetime standing as a fact about
  // somebody else. The panel promises this REPLACES the save he is playing.
  P.netEarn=(typeof o.ne==='number')?o.ne:0;
'@

# NEW IN.
SubRx @'
  'THE CAREER CARD STOPS COUNTING PILLAGERS YOU PICKED UP AS TIMES YOU GOT BACK UP.
'@ @'
  'A RESTORE CODE CARRIES NET LIFETIME EARNINGS. Everything else was replaced when you pasted one, so a character restored over your save wore YOUR lifetime earnings as its own, and one restored onto a fresh install read $0 beside a best haul of tens of thousands. Codes made before today set it to zero rather than leaving somebody else figure standing.',
  'THE CAREER CARD STOPS COUNTING PILLAGERS YOU PICKED UP AS TIMES YOU GOT BACK UP.
'@

# STAMPS.
SubRx @'
var VER='12.96';
'@ @'
var VER='12.97';
'@
SubRx @'
var WHATSNEW_VER='12.96';
'@ @'
var WHATSNEW_VER='12.97';
'@
$cnt=([regex]::Matches($s,"now:'v12\.96:[^']*'")).Count
if($cnt -ne 1){ throw "DEVNOW v12.96 matched $cnt times" }
$s=[regex]::Replace($s,"now:'v12\.96:[^']*'",{ param($m) "now:'v12.97: finding 6 of the 2026-09-11 audit, and the same class as the armoury omission that shipped at v11.66, a profile field surviving a REPLACE. The indefensible half: a player who already has runs of his own pastes a friend restore code over his save, and the panel says in those words that it REPLACES the save he is playing; everything else is replaced, name, credits, XP, runs, extracts, deaths, best haul, notoriety, the stash and the armoury, but Net lifetime earnings is not, because nothing writes it, so his own figure stays and the career card prints it as a fact about the character he has just restored. The other half: on a fresh install the restored character lands with that card reading zero beside a restored best haul of tens of thousands, while the neighbouring cards honestly say nothing because they are summed from the run log and the panel discloses that the log does not come back; this one states a figure instead. Recomputing is not the answer: the only repair site fires when the field is ABSENT and on an existing save it is present, and the log cannot answer the question anyway because it keeps the last sixty runs while the counter is maintained for the life of the profile, so summing the log is a migration approximation and not the number. The fix carries it in the code beside the other counters and writes it in the same place, and a code made before today has no key for it and then it is set to zero rather than left showing the previous character figure, because an honest zero for a character whose maker never recorded it beats somebody else lifetime. Check 12.97 makes a code from a profile with a known lifetime figure, applies it over a profile carrying a different one, and requires the restored figure rather than the old one to survive, requires a code with no key for it to zero the field rather than leave the previous character number standing, and controls that every counter the restore already carried is still carried; fails on v12.96.'" })
$n++

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count + 1
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
