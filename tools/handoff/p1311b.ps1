$ErrorActionPreference = 'Stop'
trap { Write-Output "FAILED: $_"; exit 1 }
$p = 'C:\claudecode\dark raiders\dark_raiders.html'
$s = [IO.File]::ReadAllText($p)

# p1311 bumped VER and forgot DEVNOW, which parsecheck enforces and which then
# failed the build. Mine. This is the second half of the same patch, kept as its
# own file rather than folded back in, because p1311 has already run and a
# rerun would not match.
#
# The old line is REPLACED, not preceded. Inserting a second now: key after the
# opening brace would leave two of them in one object literal and the stale one,
# being last, would be the one that wins.
$pat = "(?m)^  now:'v13\.10:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }

$new = "  now:'v13.11: a guard build, nothing in the game changed. v13.10 shipped a note of mine claiming that a raid deployed and driven by the loop does not run the raid clock and that the extraction pull never starts. Both halves were wrong and both were my instrument: the clock advances 0.1335 seconds over six frames, being the first frame clamped to 0.05 by the dt clamp plus five at 16.7ms, and the pull never started because calling the ship is a 1.6 second hold while I held E for six frames, a tenth of a second. The note is rewritten rather than deleted so the measurement that refutes it sits where the wrong one sat. What WAS real in it is now closed: every other check in this corpus ends a raid through the harness, which jumps to the payout and never touches the two-stage pull, so the call, the inbound wait, the landing, the cancel on release and the board had run in front of a player hundreds of times and in front of a test zero times, which made the most important thirty seconds in the game the least tested code in the file. Driven end to end on a live raid at seed 4242 with real frames and the real key, all of it is correct: 2.5 seconds of E calls the ship and moves the pointer for the way out onto that ring, the landing opens a 29.7 second window, the board fills at real time and ends the raid as an extraction at 1.4028 of 1.4, releasing clears the hold on the next frame rather than banking it, a knock-down mid-board loses the standing hold and lets the board restart from the floor and still complete, a body searched with X while the ship is down runs alongside the board and both finish, and a board at 1.30 against a raid clock at 0.30 wins by one frame rather than the timer killing a player who did everything right. One hypothesis was raised and refuted before it cost a build: the 1.6 second call is not silent, the call bar is drawn in three places and all three read the same value. Check 13.11 has five arms on a live raid. No failing control exists because nothing was broken, and I did not invent one; the negative arm, the same staging with E never pressed, fires four of the five and is what proves the check has teeth',"

$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'v13\.11:")).Count -ne 1) { throw "the new now line is not there once" }
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
[IO.File]::WriteAllText($p, $s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, DEVNOW replaced"
