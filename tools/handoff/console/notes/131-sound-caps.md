copied 11-01 from the Codex work folder; the voice counts are its local probe, not a browser measurement

# 131 sound caps

2026-10-27, starting build v35.37. Shipped v35.38, commit 9bd6b6a57.
Key: cw-cx-combatvoices. ON HIS PC v35.38 confirmed by the lane ship log.

One voice means one complete sound cue, including every oscillator, noise layer,
gun tail and delayed pump or bolt. Each window has its own budget: 6 guns,
8 impacts, 3 explosions, and 12 active combat cues overall. The oldest sound
of the full kind yields first; when the shared budget fills, the oldest sound
across kinds yields. At most two outgoing sounds fade for 4 milliseconds,
so the maximum including fades is 14. All sources in a stolen cue stop,
including sources scheduled to start later. Completed and inaudible cues do
not occupy slots. Existing SNDA rate limits stay in place.

The local source scheduling probe uses the real old and patched blip,
gunLayers, gunTail and impactMat functions with a silent recording context.
The trace lasts two seconds: LMG shots every 105 ms, shotgun shots every
650 ms with six metal hits, LMG body and wall hits, and overlapping blasts
every 75 ms. It emits 115 cues. The same trace runs for both listener roles.
It is a repeatable stress trace, not a recording of two connected clients.

| listener | build | peak active cues | peak audible cues including fades | peak audible sources | sources left after completion |
| --- | --- | ---: | ---: | ---: | ---: |
| player 1 | v35.37 | 19 | 19 | 35 | 0 |
| player 1 | draft | 12 | 14 | 32 | 0 |
| player 2 | v35.37 | 19 | 19 | 35 | 0 |
| player 2 | draft | 12 | 14 | 32 | 0 |

The draft stole 32 cues per listener during this trace. All ten gun types
retain identical isolated source buffers, generator gains, filters, envelopes,
pitch and scheduling with a fixed cosmetic random stream. The added output
gain is unity. No seeded random stream or gameplay value changes.

The fixture check repeats this trace for host and p2 with a silent recording
AudioContext. It writes window.__combatVoiceMeasure and logs the results to
the console, including on the old control build before failing for no cap.
It also checks kind caps, overall oldest-first stealing, delayed-source stops,
natural completion callbacks and inaudible shots. The local probe parsed all
patched inline scripts and the new check.

Lane validation is now complete: PREFLIGHT PASS; fixture check 35.38 PASS / PASS;
verifySafe pass; seed 4242 entities 85/374 and containers 165/593 unchanged.
The shipping log confirms ON HIS PC v35.38 after 319 seconds. DESIGN.md and
AUDIT.md record that the new check passes and fails on v35.37. The shipped
check exercised both host and p2 listener roles. The exact browser measurement
object is not included in the lane's saved log; the table above remains the
explicitly labeled local source probe measurement.

Coordinator work remaining: publish this report at notes/131-sound-caps.md,
capture window.__combatVoiceMeasure from the fixture if recording the browser
numbers, and verify the sound budget in two connected windows. The sandbox
has no network or browser access and cannot perform those steps.

The draft why field adds the playtest watch line to DESIGN.md through shipping:
fire an LMG and shotgun in both windows near metal hits and explosions; listen
for clicks, lost nearby shots or missing shotgun pumps under pressure.
