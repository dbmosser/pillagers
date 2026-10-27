# 119t-steady-frame-reds
- VM, v34.97: 9.07 and 33.51 each PASS 5 of 5. Spare run 1027-0155 (newer): 9.07 passes, 33.51 still red x3.
- Cause (a, game): render2D fed drsTick (auto resolution) on every raid redraw, even __frame(0) with no clock step. A slow PC has a stale slow frame gap, so repeated redraws build slow time and the scale can move between two redraws of a frozen frame.
- Fix: v34.98 cw-steadyframe, drsTick only when dt>0. New check proves 8 frozen redraws leave the window empty.
- Watch: next spare run, 33.51 should go green. If it stays red the cause is something else on that PC (unproven).
