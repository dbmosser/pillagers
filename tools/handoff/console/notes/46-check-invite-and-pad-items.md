46-check-invite-and-pad-items, lane a, 2026-10-20. Shipped as v32.82 (cw-codeguard, d2ffd724).

Item 1, invite code:
- The code itself was never lower-cased. Host (sdpPackPlain), the shown box (#partycode value), copy (netCopy), the paste box (#partyin value) and the join read (sdpUnpackPlain) all keep the case, even after the page-wide text sweep runs. The check proves it round trip with a mixed case code. No bug in the code paths.
- Real bug found: the lower-case door (ncFix) also lowered the words "PTY1o" and "PTY1a" in the paste box placeholders and in the error lines ("an invite code starts PTY1o"), so a player was told to look for "pty1o". The join read is case sensitive, so that hint was wrong.
- Fix: ncFix leaves exactly the tag PTY1o / PTY1a as written. Every other word stays lower case. Check fails on the old build (placeholder said pty1o) and passes now.

Item 2, pad reach (same check, all 6 layouts through PAD_PRESETS, fake pad driving pollPad):
- Armour plate: the belt is guns only since v26 (nine gun keys), so the route is the item wheel: hold the wheel button, aim stick down, let go (plate out), pull the use trigger (slots it). Works on all 6 layouts, lefty included (aim stick is the left one there).
- Air strike: both bumper buttons together arm it, the trigger calls it. Works on all 6 layouts.
- Nothing unreachable, so no question for him.

Staging note: in the fixture the easy mode question is live and takes the first A press as yes. The check answers it first. In lefty that same A is the left bumper button, so a real lefty player who has that question open would lose one press. Harmless, left alone.
