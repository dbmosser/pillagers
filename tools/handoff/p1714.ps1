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

# A PLAYER 2 WINDOW STILL ON ITS TITLE GOES UP WITH THE PARTY, AND A HOST WHO WENT UP ALONE IS TOLD WHY (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
    if(netUpBusy()==='still on the run card') netCardOff();   // v16.55: the run card closes so the kit question reaches him
'@ @'
    if(netUpBusy()==='still on the run card') netCardOff();   // v16.55: the run card closes so the kit question reaches him
    // v17.14, co-op hunt 2026-09-28: A PLAYER 2 WINDOW STILL ON ITS TITLE GOES UP WITH THE PARTY. The player 2 window pairs on
    // its title and stays there until its own ENTER THE UNDERCROFT, so a host who took the lift in those first seconds had the
    // kit question answered busy at once and went up alone. The title is passed the way its own start passes it (NET.start).
    if(netUpBusy()==='on the title'&&typeof NET.start==='function'){ try{ NET.start(); }catch(_ts){} }
'@

SubRx @'
  if(why==='still on the run card'&&netCardOff()) why=netUpBusy();   // v16.55
'@ @'
  if(why==='still on the run card'&&netCardOff()) why=netUpBusy();   // v16.55
  if(why==='on the title'&&typeof NET.start==='function'){ try{ NET.start(); }catch(_ts2){} why=netUpBusy(); }   // v17.14, co-op hunt 2026-09-28: the title is passed as the kit question passes it, so the host word carries him up
'@

SubRx @'
  if(st==='no'){ NET.status=nm+' could not go up with you: '+netUpWhyText(m.why)+'.'; netRefresh(); }
'@ @'
  // v17.14, co-op hunt 2026-09-28: said in the raid too, as the spec word is, not only in a PARTY window that startRaid has just
  // shut: a host who went up alone was told nothing, and did not know his teammate had stayed below.
  if(st==='no'){ NET.status=nm+' could not go up with you: '+netUpWhyText(m.why)+'.'; netRefresh(); try{ if(typeof G!=='undefined'&&G&&!G.over) sayWhenFree(NET.status); }catch(_sn){} }
'@

SubRx @'
var VER='17.13';
'@ @'
var VER='17.14';
'@

$pat = "(?m)^  now:'v17\.13:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v17.14: Co-op hunt 2026-09-28, finding 8: the player 2 window pairs on its title (netTitleInit runs netSameBootP2 at boot) and stays there until its ENTER THE UNDERCROFT is clicked. On a kitask, netKitTake closed only the run card (v16.55) and for any other busy state answered kitok at once, so netUpBusy said on the title, the host kit wait ended on the spot and ascendNow ran. The raid word was then refused the same way in netUpTake. On the host the answering up word with st no only set NET.status and called netRefresh, which draws only a PARTY window that is already open, and startRaid had just shut every window, so the host up top was told nothing; player 2, once on the floor, was held at the lift by netGuestHeld for the whole host raid. Now netKitTake and netUpTake pass the title through NET.start, the same go the title start button runs (it commits a typed name, drops the title and shows the Undercroft floor), and read netUpBusy again, so the kit question is asked and the host word carries the window up. In netUpWord a no word is also said in the raid with sayWhenFree, as the spec word already is, when this window is in a raid that has not ended. No number, no seeded draw and no new player text: the line said is the PARTY status line that was already written. Check 17.14 fails on v17.13',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
