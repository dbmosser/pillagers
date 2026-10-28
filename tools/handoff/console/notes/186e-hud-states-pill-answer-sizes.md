# 186e notes (helper session, lane g, Chrome 9357, uishots 9367)

Findings 10-27 night:
- cw-quiettext already moved the "concealed / in cover" chip off the bottom right into the status column (STATUSL 'hide', concealState). Build 1 takes it out of the column and draws small icons beside the stance chip (body zoom, y = by-_up-LH(18)).
- "location revealed" = G.marked>0 (the crier mark, 2.2 s); the crier line itself stays a danger alert.
- No low health or low ammo text lines exist. hp bar has drawLowHpRing (0.95 Hz). Ammo: ammoDraw (amber at 25%, red at 0).
- Top centre: clock, then the extract pill (_lbl+' '+metres+'m', HUDC.plate), then the cw-quiettext edge line (_zEdge: "extraction c available") which build 2 replaces with an edge arrow "c 152m".
- Weather: G.wx (WEATHER ids clear partly rain fog blackout storm), G.tod (TODS dawn morning noon golden dusk). The contracts panel already lists "dawn clear".
- P4 answers: msgReach 'e' -> feedSay at once. Build 3 moves them under the character.

Decisions (logged, no question needed):
- Icons show their word for about 2 s the first time they turn on, then icon only (so a new icon is never a mystery).
- Low ammo pulses red (alpha), empty is solid red plus the key cap; the card width measure always includes the cap so the card never changes size.
