# 64-audio-picks (lane a, 2026-10-20)

Shipped, one key each (no one can hear from here, so each line says what he should listen for):

1. **74 late night audio** (v33.19, cw-latenight). New row LATE NIGHT AUDIO in settings, AUDIO, OFF by default. On: world compressor ratio 3.5 to 6,
   world limiter threshold -3 to -9, world trim 0.5 to 0.4, master limiter -2 to -8. Off is exactly the old numbers.
   LISTEN: turn it on during a grenade or an LMG burst; blasts and heavy guns should hit about 4 to 6 dB softer, footsteps still clear. Chrome adds its own
   make-up gain when a threshold drops, so if it sounds LOUDER with it on, tell me and the trim goes lower (LATE_ON in the game file).
2. **70 low health filter** (v33.20, cw-lowhpfilter). Below 30 health the world mix low-passes, 12 kHz at 29 down to 2.2 kHz at 0, eased 0.5 s. It rides the
   downed dip's own filter (sndDipOf), waits 1.3 s after a fall, so no stacking. Menu clicks, pickups and stings do not go through it.
   LISTEN: bleed down to 10 health: guns and steps go dull, the heartbeat stays. Heal above 30: opens again. Get downed: the old dip, then back to dull if still low.
3. **72 climbing kill chain** (v33.24, cw-chaintick). Every kill that chains (the existing 4 s streak, career and demo) plays a soft sine tick, one E minor
   pentatonic note higher each time (E5 to A6, top note holds), on the sting bus, gain 0.06. A broken chain starts at E5 again. It plays together with the
   medal pop at DOUBLE/TRIPLE/MULTI/RAMPAGE/UNSTOPPABLE.
   LISTEN: a fast string of kills; the ticks should be small, not shrill.
4. **69 space-aware gunfire**: ALREADY IN THE GAME since v23.77 (gunLayers, gunTail, sndSpaceN: slaps indoors, roll outside, soft woods, ring in a vault,
   hiss over water, snap close and thump far, with his v10.58 note "tail a tenth of the crack or less"). The planner's grep missed it. I shipped a second
   tail on top (v33.25, cw-guntail) before I read the shot generator: MY MISTAKE. It is taken out again by cw-guntailundo (see below). Nothing new for him to hear.
5. **73 machine movement sounds**: see the end of this file.

## Own mistake, one line
v33.25 doubled the gunfire tail that v23.77 already has. I grepped the planner's words, not the shot code. Removing it (cw-guntailundo); the v33.25 check is
retargeted through fixq so it holds on both builds.
