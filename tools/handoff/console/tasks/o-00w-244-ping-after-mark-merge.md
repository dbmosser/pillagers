# 244-red-35.74-20.76-ping-after-mark-merge : since v36.52 middle mouse makes no ping on an old saved key map, and the compact party legend lost its ping line
model: opus
Queue (JTPC Correspondent 10-29 14:00; spare PC run corpus-1029-1227 on v36.53, red there, green in corpus-1029-1104 on v36.50). Fix, HIGH: pinging is how the two players talk in the 2 player party demo, and his own save on the main PC is an old saved key map.
effort: high (Opus xhigh rung: can break the party demo)

The two checks (fail text from the spare PC):
- 35.74 (cw-meleez, his order 10-28: melee on Z, middle mouse should ping) -> "ONE: middle mouse made no ping with an old saved map". A profile saved before v35.74 (no ping on mouse 3 in its key map) must still ping with the middle mouse.
- 20.76 (on a controller the legends name D-UP for the ping, the compact party legend lists the ping once) -> "the compact party legend lists the ping 0 times".
Suspect ship: v36.52 (099d6febf, ping and map mark are one, his order: one deliberate mark per player through the png message, one record for raid, map and minimap). v36.53 (one mark glyph in all three views) touched it too.
First: on v36.53 with an old saved key map (staged like 35.74 part ONE), press the middle mouse in a raid, solo and in the 2 player demo: does a mark appear in both windows? If not, the merge dropped the mouse 3 route for old maps: put it back through the new single mark path. For the legend: if it now says mark instead of ping, that is his order working; retarget 20.76 to the new word (one entry, D-UP on a pad). If the line is gone, put it back.
Check (must FAIL on v36.53): with an old saved key map, a middle mouse press in a raid makes one mark that shows in the raid, map and minimap of both windows; the compact party legend names the mark key once (D-UP on a pad). Then 35.74, 20.76 and 36.52 pass.
Rules: keep his v36.52 order (one mark per player, spot marks stay until moved or cleared, entity pings follow 10 s, loot notices separate); storage key salvagerun:profile unchanged (old key maps load and keep their keys); seed 4242 fingerprint unchanged; no team damage; test both windows.
TASK DONE when shipped and ON HIS PC, with what he should watch for at the party.

CEO 10-29 14:05: renamed o-00w so Codex (which wrote v36.52) runs it now, ahead of its pace rest: party ping. Codex run 1 at high effort.
