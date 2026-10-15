# Pillagers sound pack: sources and licences

Built 2026-10-14 on branch `cloud/sound-pack`. Every recording in this pack is **CC0 1.0** (public domain dedication,
https://creativecommons.org/publicdomain/zero/1.0/). No attribution is required. Optional credit line for a credits screen:

> Sound effects: Kenney (kenney.nl), CC0

Everything else in `sound-pack.js` (every synthesized layer, the mixing, the levels) is original code written for Pillagers.
No account was created or used: both packs came from Kenney's public direct download links.

## Sources

| Tag | Pack | Author | Page | Download | Licence and proof |
|---|---|---|---|---|---|
| K-SCI | Sci-Fi Sounds 1.0 (created 11-10-2020) | Kenney, www.kenney.nl | https://kenney.nl/assets/sci-fi-sounds | https://kenney.nl/media/pages/assets/sci-fi-sounds/6b296f9ecf-1677589334/kenney_sci-fi-sounds.zip (sha256 119340f351a5098ad814f78719438c0da355a9ce8a4c8a3af6a8d48aa3d49e04) | CC0 1.0, stated on the page and in `License.txt` inside the zip: `licences/kenney_sci-fi-sounds_License.txt` |
| K-IMP | Impact Sounds 1.0 (created 19-12-2019) | Kenney, www.kenney.nl | https://kenney.nl/assets/impact-sounds | https://kenney.nl/media/pages/assets/impact-sounds/87b4ddecda-1677589768/kenney_impact-sounds.zip (sha256 029d734af1582474edf3a694d1b0cebc97c1c152f2f39fa34d4c2bafc5de77f8) | CC0 1.0, stated on the page and in `License.txt` inside the zip: `licences/kenney_impact-sounds_License.txt` |

The two licence files are byte for byte the same as the ones the foley bank already carries in `tools/sounds/`.

## Files

All 13 files in `samples/` were made the same way the game's foley bank was: decoded in Chrome, the window below cut from the source,
mixed to mono, resampled to the rate shown (low rates for the low sounds, which have nothing above half that rate worth keeping), silence
trimmed at 40 to 60 dB under the peak, peak normalised to 0.95, a 3 ms fade in and a fade out of 40 to 250 ms, and stored as 8-bit
mu-law WAV (format 7), the format the game's own decoder (`sfxbWav`) reads by hand. The same bytes are embedded as base64 in `SPK_BANK`
in `sound-pack.js`.

| File | Used for | Source | Original file in the zip | Window (s of the source) | Rate | Length | Bytes | Base64 | Licence |
|---|---|---|---|---|---|---|---|---|---|
| `samples/xplBig.wav` | orbital debris landing | K-SCI | `Audio/explosionCrunch_003.ogg` | 0.000 to 1.554 (whole) | 16000 Hz | 1.554 s | 24914 | 33220 | CC0 1.0 |
| `samples/xplMid.wav` | barrel blast, gate breach | K-SCI | `Audio/explosionCrunch_001.ogg` | 0.000 to 1.200 | 16000 Hz | 1.200 s | 19260 | 25680 | CC0 1.0 |
| `samples/xplShort.wav` | air strike blasts, barrel chain | K-SCI | `Audio/explosionCrunch_000.ogg` | 0.000 to 0.760 (whole) | 16000 Hz | 0.760 s | 12220 | 16296 | CC0 1.0 |
| `samples/xplLow.wav` | gate breach, screen clear, debris callout | K-SCI | `Audio/explosionCrunch_004.ogg` | 0.000 to 1.945 (whole) | 11025 Hz | 1.945 s | 21498 | 28664 | CC0 1.0 |
| `samples/subBoom.wav` | screen clear | K-SCI | `Audio/lowFrequency_explosion_000.ogg` | 0.007 to 1.251 | 6000 Hz | 1.244 s | 7520 | 10028 | CC0 1.0 |
| `samples/thruster.wav` | air strike inbound, debris falling | K-SCI | `Audio/thrusterFire_003.ogg` | 0.600 to 2.200 | 11025 Hz | 1.600 s | 17700 | 23600 | CC0 1.0 |
| `samples/engineLow.wav` | machine convoy setting off | K-SCI | `Audio/spaceEngineLow_002.ogg` | 0.400 to 2.200 | 8000 Hz | 1.800 s | 14460 | 19280 | CC0 1.0 |
| `samples/forceField.wav` | shield bubble pickup | K-SCI | `Audio/forceField_001.ogg` | 0.000 to 0.712 | 16000 Hz | 0.712 s | 11458 | 15280 | CC0 1.0 |
| `samples/metalCrash.wav` | debris landing, coolant pipe burst, gate breach | K-IMP | `Audio/impactMetal_heavy_001.ogg` | 0.000 to 0.206 | 22050 Hz | 0.206 s | 4592 | 6124 | CC0 1.0 |
| `samples/metalHit.wav` | convoy tread clanks, bounty paid | K-IMP | `Audio/impactMetal_heavy_003.ogg` | 0.000 to 0.204 (whole) | 22050 Hz | 0.204 s | 4558 | 6080 | CC0 1.0 |
| `samples/drumBonk.wav` | barrel blast and chain (the drum itself) | K-IMP | `Audio/impactPlate_heavy_001.ogg` | 0.000 to 0.338 | 16000 Hz | 0.338 s | 5458 | 7280 | CC0 1.0 |
| `samples/punch.wav` | finisher, bounty callout drums | K-IMP | `Audio/impactPunch_heavy_000.ogg` | 0.000 to 0.386 | 16000 Hz | 0.386 s | 6232 | 8312 | CC0 1.0 |
| `samples/stomp.wav` | Overseer rampage stomps | K-IMP | `Audio/impactMining_000.ogg` | 0.000 to 0.539 | 11025 Hz | 0.539 s | 6002 | 8004 | CC0 1.0 |

Totals: 13 files, 155872 bytes of WAV, 207848 bytes of base64 in `SPK_BANK`. The whole `sound-pack.js` (bank, code and comments) is about
266 KB, inside the 600 KB budget of the order.

## Synthesized only (no recording)

These cues are built from oscillators and filtered noise in `sound-pack.js`, in the style of the game's own `SNDA_GEN` sounds, and carry
no third party material: `evCoolantWarn`, `airConfirm`, `pwrAppear`, `pwrGetClip`, `pwrGetDmg`, `pwrGetRapid`, `pwrGetMagnet`, `pwrEnd`,
`pwrLast`, `pwrBubbleHit`, `medal1` to `medal5`, `arHit`, `arMiss`, `lmgSpinUp`, `lmgWindDown`, `goldAppear`, `haulTick`, `haulUncommon`,
`haulRare`, `haulElite`, `haulGold`. The rest layer synthesis over the recordings listed above.
