# 266 notes (lane g, 11-02)
- Static read: only 8.64 ends a raid in [0..25]; __regressBg calls __runPrep once per slice, then only __topClear and __ctxHeal between checks, so nothing brings the pillager back.
- 25.34 ends him itself: __endRaid('abandon') after shots, then __showScreen('hub'); __hubEnter().
- Birth card opens from showScreen hub -> firstRunNext -> birthOpen when birthNeed().
- No Chrome here: probe with preflight draft cw-g266probe (never shipped). Answer in origin/spare-results spare/DESKTOP-82BKOP4/gate/ID.txt; a run returns 300 chars per pass of the gate.
