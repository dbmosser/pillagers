
--- codex run 2026-11-07 13:09 ---
2026-11-07: Prepared cw-cx-chargefrag against v37.49. Preserves the existing !e.golden low-health exemption. Fixed temperament uses the exact requested nid/position hash without rnd. Only hostile, non-hired, non-friendly pillagers can charge; others keep the existing escape behavior. Brave pillagers turn through runnerTurns, skip smoke and the running callout, and rush toward the seen or last seen target at 1.25x speed for four seconds. The clock ticks once per host update even during a dodge. Grenade avoidance follows the mortar dodge, includes hires and fx party copies and simulated raids, reacts at 0.15s, ignores the thrower and expired grenades, checks sight beyond 120, and moves at 1.35x speed before collision and continue.
Local validation: four anchors each match exactly once; generated the draft; applied all replacements to an output-only candidate; node --check passes for the complete candidate script and new fixture check. No game or fixture file was edited. No browser or gameplay check was run in the sandbox. Existing targeted runner and grenade checks found do not require changes.
New check stages 20 hurt hostiles (nid 1..20), measures the charge/escape split and escape-only smoke, verifies actual rush displacement and expiry, and lets live grenades burst beside looters in simulated and live raids. Also covers fx copies, hires and reaction/own/expired controls. The old build fails the 20-pillager split and grenade escape assertions.
LINKED REVIEW NEEDED: synced. Host-owned pillager movement/state travels in netEntRow snapshots; the peer runs netEntsEase rather than AI. No new packet field is needed. Lane/coordinator must verify charging and grenade escape in both smooth-look windows with a picture from each, including player 2 grenade copies on the host. No static menu appearance, text or rendering changes; menu camera/critic work would not establish these movement rules.
Watch: deaths to nearly dead charging pillagers; whether the charge reads as a choice; frag kill rate as pillagers escape (cooking is the counter). This watch text is included in the draft why for DESIGN.md.
Pending: lane preflight, shipping, ON HIS PC confirmation and linked review.

--- codex run 2026-11-07 13:14 ---
2026-11-07 preflight follow-up: cw-cx-chargefrag did not ship. Spare preflight reported exactly one older regression: 37.38, FOUR: the second brakka is brakka iii. Inspected the test and naming functions. The four AI edits do not touch naming or retirement. Check 37.38 calls birthFinish(false) after each of two retirements, without controlling the generated heir name. pilHeirs seeds its legal names from account name, first birth timestamp and generation via pilSeed/wornRand. If the generation 2 heir is brakka, the hall correctly contains two brakkas before FOUR renames the living generation 3 pillager to brakka. pilNum correctly returns 3. The hardcoded brakka ii assertions (FOUR and SIX) then fail. This depends on birth time/account, so repeating the gate could merely hide it.
The job explicitly says never change tools/mkfixture.ps1; if a check must change, give the finding and exact change in notes and stop. No fixture-retarget.json was created and no fixture was edited. The AI script and keys remain ready, unchanged. Coordinator must make the following staging correction inside check 37.38 only, then retry cw-cx-chargefrag preflight. Do not change the brakka ii expectations or naming behavior.
Exact change 1, unique anchor:
       birthFinish(false);
       need(P.pil&&P.pil.gen===2,'ONE: the birth card did not birth after a retire');
Replacement:
       birthState().name='vosk'; birthFinish(false);
       need(P.pil&&P.pil.gen===2,'ONE: the birth card did not birth after a retire');
Exact change 2, unique anchor:
       birthFinish(false);
       // THREE: refused in the demo
Replacement:
       birthState().name='vosk'; birthFinish(false);
       // THREE: refused in the demo
This chooses a legal explicit birth name for both successors through the existing birth-state input. The hall then contains brakka and vosk before FOUR, so brakka ii tests a second brakka deterministically. It preserves the real birth/retirement and rename paths. Run 37.38 on current and drafted build after coordinator applies this correction. Pending: coordinator fixture staging correction, lane preflight and ship, ON HIS PC, linked smooth-look review in both windows.
