# o-00j-227 lance-reload-long-tail : a reverb-like sound runs far too long when the Meridian Lance reloads
HIS WORDS 10-28 about 22:05 EDT (in the Gameplay Edit Intaker chat), on v36.23: "reloading or maybe active reloading the meridian lance makes some sort of reverb sound that goes wayyy too long". Minutes later the game froze as he went down holding the Lance (o-00d2-228); if 228 finds the cause in the Lance reload sound, this job may already be half done: read 228's result first.

FIRST FIND WHICH SOUND IT IS (render offline or log every audio node's start/stop with its scheduled end during a Lance reload, plain and active; do not guess). Leads, dark_raiders.html on v36.23:
- The Lance reload plan (~26148-26152): at 0 'injector' rate 0.75 + 'boltLatch'; 0.62 'lmgClack' rate 1.25; 0.66 '~whine'; 1 '~ping' + 'boltLatch'. reload 4000 ms (~4471).
- ~whine (rlfxWhine ~26198): a saw rising 180 to 1150 Hz for the rest of the reload, cut by rlfxStop. On an ACTIVE RELOAD (~26266, sweet spot 0.42-0.60, before the 0.66 whine) tickReload(0.002) runs rlfxPlay(1) then rlfxStop: check the whine is really cut, here and in the partner window ('~whine' then '~whinex' order over the net), and that the 70 ms 'at' spacing does not start a node after rlfxStop ran.
- The Lance SHOT (~10159 FV.lance): len 5000, decay 2.2, tail:1, a 5 s tail; with a 3 round magazine the auto reload starts right after the last shot, so the shot tail rings through the reload. If so shorten it (check Longshot 5600 and rocket 5200 the same way) so it never outlasts about 1.5 s audibly.
- The gun bus space/reverb send (gunLayers, sndSpaceN) indoors.
FIX it so nothing from a Lance reload or shot is audible more than about 1.5 s after it should end; keep the vent, seat, whine and ready ping. Both windows.
Check (must FAIL on the current build): node log for a full and an active Lance reload: nothing on the gun bus above gain 0.001 more than 1.5 s after the reload ends; the last shot's tail under the same limit.
Rules: seed 4242 fingerprint must hold; never touch the pickup stack, loot sounds or loot rows. DESIGN.md watch line: "the Lance no longer rings on after a reload". Model: Opus high.
TASK DONE when it shipped and is ON HIS PC.
