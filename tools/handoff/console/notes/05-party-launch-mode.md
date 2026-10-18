# 05-party-launch-mode notes (lane a)
Code map (dark_raiders.html line numbers at start of run):
- netSlotOf..netArcOf 52147-52156; NETP2 3915; netSameBootP2 53020; netTitleInit 53036 (called 65799 inside title IIFE, `go` = title start fn at 65790)
- arcadePick 60534, arcadePadsIn 60567, arcadeEnter 60620, arcadeLeave 61154 (callers: arcoff p2 60663, opchord 60866, op card exit 61007)
- netSameOnMsg 52970 ('ready' answered by host at 52990), netSamePick 52868, p2RaidKey/p2RaidNow 52187
- title html id=title at 2314; rows titlestart modecoop modearcade modearcade1 slotpanel
Plan: PARTY const near NETP2 (3915) = /[?&]party=1/ ; one mk script per item or one combined.
