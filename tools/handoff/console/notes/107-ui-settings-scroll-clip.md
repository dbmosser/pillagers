# 107-ui-settings-scroll-clip
Shipped v34.35 (cw-setscroll), v34.37 (cw-setscroll2), v34.38 (cw-setscroll3). Pictures: shots/107-before, 107-after, 107-after2.
Critic (before+after pair): 27=3, 29=3, 73=3, 18=3 (stays 3). Defects gone and checked (34.35: every key step in view going down and back, no row past the card, clicked tab is the lit tab, no outline on focused tab, no focus bar on list row while tab focused, restore not filled; 34.37: no halo, no sliver; 34.38: hint ends cleanly).
Left (P1 from the critic, all at 3 = done for a non-pause screen): detail pane mostly empty (hero value idea), no group labels (cw-setsechd hid them on purpose), rail gap before send play data, esc close hint.
Gotcha: setting an inline style on a section head row breaks its [style*="opacity:.7"] CSS match; checks must not touch head rows.
