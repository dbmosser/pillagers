# 19-party-audio notes

Shipped 10-20:
- v32.32 cw-masterlimit: master limiter (-2 dB, 20:1) now the end of every sound path (world, HUD, stings, music, end pieces); rain 0.045 -> 0.030 (a third quieter, 2.69 b); in the demo the impact bus is 3 dB down and the gun bus 2 dB down (2.12 b). Deep bass untouched (2.71 a).
- v32.34 cw-musicvar: THE ASCENT plays 3 variations in turn (as written, tune half a bar later, tune a quarter bar later) (2.70 c).

Not done:
- 2.73 a measured loudness pass: the headless test Chrome has no audio device, so levels cannot be measured here. The limiter caps peaks; levelling sounds against each other needs a play-by-ear pass by him.
- Not seen in two windows: no picture applies (sound only). The limiter sits after the split panner path in the pair mode, so left and right split is unchanged.
- Boss sounds are on the machine bus and are not trimmed in the demo (only blasts and guns); the limiter still caps them.
