# 111-pix-fault-in-corpus : the two pixel art checks that still fail in the full test run pass again, and the pixel fault they see is found and fixed at its source (coordinator 2026-10-24)
Queue (coordinator 10-24 16:55): keeps three jobs waiting for the helpers (his 10-24 order to spend the week before the reset). Top of the
feed order: checks newly failing in the newest finished full test run, leaving out ones fixed since.
effort: medium

Source: tools/handoff/stable-status.txt (checked 10-24 16:43), run corpus-1023-2304 (v34.18, failing 14, new 9). Seven of the nine are
fixed or re-aimed (jobs 87r, 97, 98: v18.01, v24.95, v33.33, v21.42, v18.78, v23.45, v9.55). Two are left. Lane c's note in 87r said they
were "not in the newest run's failing list": that was wrong. The run file (stable picker's scratch folder):
C:/Users/VMOCT2~1/AppData/Local/Temp/claude/C--Users-User1-Desktop-dark-raiders/8a09e991-b4f4-4b23-b10f-ded92e837fc3/scratchpad/corpus-1023-2304.txt
line 2, block [120,240):
- v33.69 cw-pixveg (86d): THE PIXEL TREE, BUSH AND SHADOW -> "pixel faults logged: 1"
- v33.66 cw-pixwalls (86d): THE PIXEL WALL -> "pixel faults logged: 1"
Both read pixFaults() (dark_raiders.html, PIX.errs plus G.drawErr). PIX.errs goes up when a pixel bake or draw throws and the game falls
back to the vector look (pixGuardFail, the try/catch at pixVegBake, pixWallBake, pixGroundStep, pixDoorDraw, pixWinDraw, pixHubWall);
G.drawErr keeps the first message ("pixel KIND: message"). So something earlier in that block made a pixel drawing throw. A silent
fallback is a real fault even when the robots do not see it (4765 robot minutes, 0 problems): find it.

Steps:
1. Run each check alone on the current build. If both pass alone, the fault comes from an earlier check in block [120,240).
2. Run the block in order (or bisect it) and read G.drawErr and PIX.errs after each check until the count goes up. Write down which
   check stages it, which pixel kind threw and the message.
3. Say which of two it is:
   a. a state a player can reach makes that drawing throw (an odd size, a missing palette, a door or wall shape the pixel code does not
      expect): fix the drawing in an mk script so it does not throw, and keep the pixel look for that object;
   b. only a check's own staging can make it (a state the game never builds): make that staging check put back what it changed, so it
      leaves no fault for the checks after it.
   Never loosen v33.69 or v33.66: a fault during their own drawing must still fail them.
4. One batch per cause, through preflight.sh and shipq.sh as usual. Note the cause in the ship's DESIGN.md section.

Rules: rendering only (no change to the simulation, saves or the storage key); the 2.5D canvas look only; never test on port 8802.
Checks (each must FAIL on the old build): a check that stages the state you found and asserts the pixel drawing does not throw (PIX.errs
unchanged, no G.drawErr) with the pixel look on.
TASK DONE when v33.69 and v33.66 pass on the drafted build run after the block's other checks, or the cause is fixed in a shipped
batch; TASK PARTIAL with what is left and why.
