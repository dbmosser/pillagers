# 0p11-120j-coop-smooth-remote

Shipped v36.88 (cw-coopsmooth), ON HIS PC v36.88.

- Receive side only. netLeadSample reads each body speed from its last two samples (partner up top: netOnState; machines: netEntsApply). netLeadStep (netUpTick, netEntsEase) aims at sample + speed * time since it came (cap 0.12 s), moves the body at that speed and eases the error at the old rate. The send rate and what is sent are unchanged; the fingerprint held (85/374, 165/593).
- No lead for: a stopped body (step under 0.6 px), a jump over 160 px, a speed over 700 px/s (rolls), a gap over 0.3 s, or a lead end that falls inside a wall (pad 8, through wallsNear).
- Hub floor and Undercroft mate were not changed (they chase as before).
- Check 36.88: a body walking 150 px/s with sends every 5 to 7 frames: spread of frame steps under 20 percent, lag under 50 ms, no run-on past a stop over 20 px, rests within 3 px. Old build: fails (chase gives about 100 percent spread, ~130 ms lag).
- Not done: a live two-window fuzz run (not on this lane's command list). Watch line is in DESIGN.md.
