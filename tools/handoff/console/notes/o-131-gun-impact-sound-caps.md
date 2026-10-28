
--- codex run 2026-10-27 21:58 ---
2026-10-27: Prepared cw-cx-combatvoices against v35.37. Caps whole blip combat cues at 6 guns, 8 impacts, 3 explosions and 12 active voices per window. Oldest cues yield on a 4 ms fade, with at most two fading voices retained. All sources, including delayed pumps, stop together. Natural completion releases the graph. The SPK decoder keeps its cache keyed to the underlying AudioContext.

Sandbox anchors generated successfully. All patched inline scripts and the fixture check parse. Local source scheduling stress trace: 115 emissions over two seconds, LMG every 105 ms, shotgun every 650 ms with six metal pellet hits, LMG body and wall hits, blasts every 75 ms. In each listener role, peaks changed from 19 active/audible cues and 35 sources to 12 active, 14 including fading cues and 32 sources; 32 stolen cues, zero sources left after completion. This is a silent source probe, not connected-window validation. Buffers, gains, envelopes, filters, pitch and timing for isolated shots match across all ten gun types.

The fixture check repeats the stress trace for host and p2, logs combat voice measurement, and exposes window.__combatVoiceMeasure. Its old control reports measurements then fails for no cap. It also verifies kind and overall caps, oldest-first stealing, all delayed-source stops, natural-ended callbacks and inaudible culling. Chrome execution, regression gate, seed fingerprints and shipping remain with the lane. No shots.txt: this change has no visible output.

Full report prepared at .codex-work/o-131-gun-impact-sound-caps/notes/131-sound-caps.md. The draft why includes the requested DESIGN.md playtest watch line. No tracked game or fixture file was edited.

