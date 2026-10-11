$ErrorActionPreference = 'Stop'
trap { Write-Output "FAILED: $_"; exit 1 }
$p = 'C:\claudecode\dark raiders\dark_raiders.html'
$s = [IO.File]::ReadAllText($p)
$n = 0
function SubRx([string]$old, [string]$new) {
  $pat = ($old -split "`n" | ForEach-Object { [regex]::Escape($_.TrimEnd("`r")) }) -join "\r?\n"
  $c = ([regex]::Matches($script:s, $pat)).Count
  if ($c -ne 1) { throw "regex matched $c times: $($old.Substring(0,[Math]::Min(70,$old.Length)))" }
  $new = $new.Replace("`r`n", "`n")
  $script:s = [regex]::Replace($script:s, $pat, { param($m) $new })
  $script:n++
}

# NOTORIETY IS SAID ONCE (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
  say('He was not fighting you. Notoriety '+P.notoriety+'.');
  label(e.x,e.y-18,'NOTORIETY +1','#ff6b5a',0,true);
'@ @'
  // v22.76, the raid text rewrite (R31): NOTORIETY IS SAID ONCE. Each point said a sentence with the new total in the feed while
  // his v8.27 stamp (YOU STARTED THAT FIGHT, the total and its word) and the NOTORIETY +1 label over the body already said it,
  // three times for one fact. The sentence is gone here, for the unarmed Survivor and for the Peddler; the stamp and label stay.
  label(e.x,e.y-18,'NOTORIETY +1','#ff6b5a',0,true);
'@

SubRx @'
    sayWhenFree('Word of that will travel too. Notoriety '+P.notoriety+'.');   // v13.39: waits for the cache and pay line above instead of writing over it
'@ @'
    sayWhenFree('NOTORIETY DOWN TO '+P.notoriety,'info');   // v13.39: waits for the cache and pay line above; v22.76 (R31): the HUD voice
'@

SubRx @'
          say('He was not armed. Notoriety '+P.notoriety+'.');
'@ @'
          // v22.76 (R31): no Notoriety sentence; the stamp and the NOTORIETY +1 label carry it
'@

SubRx @'
          say('The Peddler is dead. Word gets around. Notoriety '+P.notoriety+'.');
'@ @'
          // v22.76 (R31): no Notoriety sentence; the stamp and the NOTORIETY +1 label carry it
'@

SubRx @'
var VER='22.75';
'@ @'
var VER='22.76';
'@

$pat = "(?m)^  now:'v22\.75:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v22.76: A notoriety point is shown by the stamp and the label only, and helping a Survivor says NOTORIETY DOWN TO and the number. Check 22.76 fails on v22.75',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
