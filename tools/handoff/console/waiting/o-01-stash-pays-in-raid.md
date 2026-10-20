MONEY IN A RAID COMES FROM THE STASH (his order 2026-10-19, verbatim): "make it so any money spent in a raid comes from credits
stash, e.g. remove the concept of taking cash 'into' a raid. e.g. player should be able to walk up to the forge and upgrade gun
instantly". This reverses his 2026-10-15 cash part of cw-precash/cw-preraid ("quickly pick how much cash ... to take"); the
item, ammo, key, gun and data core parts of the pack row STAY. Same in DEMO and CAREER, and in both windows of two players
(each window pays from its own save's P.credits).

What to change (the coordinator read the code 10-19; line numbers drift, grep the names):
1. Remove the take-cash concept completely:
   - G.cash (set at raid start near "v28.xx (cw-precash)", ~line 16598-16601; G.cash=null / P.takeCashRaid) and its two uses in
     pedBuy (~14881 "NOT ENOUGH CASH ON YOU" and ~14896). The stall already charges banked P.credits; it keeps doing that.
   - P.takeCash / P.takeCashRaid: the cash stepper on the pre-raid page's pack row (~64976-65021: the "cash - all /900 + max"
     control, packList, the 'all' and clear buttons' cash part) and the deploy hand-off (~65740). Old saves that still hold
     takeCash/takeCashRaid must load fine (ignore or delete the fields on load).
   - Any word on screen about carried cash for spending ("carrying $...", "cash on you"). Grep for G.cash, takeCash, 'CASH ON YOU'.
2. The forge pays from the stash: forgeScore()/forgeSpend() (~13507-13512) read and take P.credits (banked) instead of the raid
   score (ARCADE.mine in the demo, G.cs.s in career). Spending saves the profile (saveProfile(), like pedBuy). The raid score is
   no longer reduced by the forge (drop the csTally('forge',-n) line or keep a tally that does not change the score; check the end
   card and the score board still add up). Rewrite the comment block above forgeScore so it says the stash pays.
3. "Instantly": at the forge, E on a gun that can go to MK II buys MK II at once (no panel to confirm), with the same result as
   today's purchase (GUN UPGRADED, gun card, sparks, the 700 ping). MK III still opens the panel, because the element must be
   chosen. Not enough banked credits: the deny sound and "need $6,000" style line, nothing opens. Pad: the same button that is E.
4. Money is shown as $ (his Q59: $ for money, SP for score). The forge prompt, panel and gun card show the cost in $ and the
   panel shows the banked credits it will draw from. All on-screen text lower case (his 10-18 order).

Checks (control must FAIL on the old build):
- career raid with P.credits=10000 and raid score 0, MK I gun in hand at the forge: one E press -> gun is MK II, P.credits=7500,
  raid score still 0, no forge panel open. (Old build: "need" and nothing changes.)
- same with P.credits=1000: nothing changes, P.credits stays 1000.
- demo (arcade) raid: the same E press takes P.credits, and ARCADE.mine is unchanged.
- a deploy with MY LOADOUT no longer sets any carried-cash cap: buying at a stall for more than the old takeCash amount works
  while banked credits cover it.
- the pre-raid pack row has no cash control (no element with the cash stepper), and a save holding takeCash loads.

Pictures: the forge prompt and panel (MK III element pick) and the pre-raid page, before and after (camera port: your lane's).
Note: the pre-raid page is about to be redesigned (his order 10-19, mockups pending his pick). Only REMOVE the cash control from
it here; do not restyle the page.

TASK DONE when shipped and the checks pass; TASK PARTIAL with what is left.

Coordinator note 10-20 00:20: back in tasks/ for the lane-side step it waited for. The lane now photographs camera-recipes.json itself (first 6 screens, critic on each) and sends you the pictures; the first pass spends no Codex run. Already shipped (do not ship again): cw-cx-stashraid . Review the pictures and the critic: end TASK DONE if they hold, or fix P0/P1 findings with a NEW key.

Coordinator note 10-20 00:58 (in the VM): back in tasks/ for the picture step only (your run count was reset once). Done already: cw-cx-stashraid shipped, and your fixture retarget is applied (633e412e, checks 26.21 26.25 28.94 29.26 31.83 all PASS). The lane's recipe round 1 staged 05-sector-page, but the three forge screens threw "Cannot set properties of undefined (setting 's')": the recipe set G.cs.s=0 in a career raid, where G.cs does not exist. The coordinator changed it to if(G.cs)G.cs.s=0; in forge-camera-recipes.json and prepare-forge-camera.js (backups *.bak-1020). The lane photographs them again on its first pass (no Codex run spent). Then review the pictures and the critic: end TASK DONE if they hold, or fix P0/P1 findings with a NEW key.

Lane note 2026-10-20 01:43: shipped cw-cx-stashraid cw-cx-forgeread cw-cx-forgefinish and parked: only lane-side steps are left. Codex's last words:
All changes shipped in v32.43. Checks pass; forge views scored 3/3/3 with no lint findings.

TASK PARTIAL: coordinator must verify independent stash payments in both real player windows and provide a picture from each.
