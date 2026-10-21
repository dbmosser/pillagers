81c-extract-siren-short : the extraction alarm sounds about 4 s at the call and 4 s before the extraction starts, not the whole time (his order 2026-10-20 evening)
Queue (coordinator 10-20 22:10): 81c, after 81b.
effort: low

Source (his words, 10-20 about 22:00, verbatim): "extraction siren is intrusive, it doesn't need to go off the entire time, just for maybe 4 seconds
when the extraction is first called, and 4 seconds before the extraction actually starts"
Also his words, the same evening: "that game was fun overall -- all the pillagers pushing the extract at the end was really fun". The end rush stays;
only the alarm gets shorter.
Where: tickExtractPoints, dark_raiders.html about line 27503: v27.xx (xalarm), from his answer 41, loops blip('xalarm') every XALARM_GAP=1.8 s from
the call until the beacon clears (countdown, the wait for the ship and the boarding hold). This newer order replaces answer 41.

What to do:
1. The alarm sounds for about 4 s right after the call, then stops.
2. It sounds again for the last 4 s before the extraction actually starts (read the code for that moment, most likely the beacon reaching 0 as the
   ship arrives, and name it in the DONE note), then stops. Nothing during boarding.
3. The inbound ping (its interval shrinks as the ship comes) stays as it is, so the wait still has a pulse.
4. 4 s is one constant, so he can ask for another length. The Settings dial (CFG.xAlarm 0) still mutes it all. Only the ring you called, never
   the bot sim, as now; each player hears their own called ring.
Check (new, must fail on the build before): in a live raid, call an extraction and step the clock: xalarm plays only in the first 4 s after the call
and in the last 4 s before the start; none between and none during boarding. If the xalarm check asserts the loop, retarget it in the same ship.
Pictures: none needed (sound only); say so in the DONE note.
Cut-off: FEATURES. Ship before Mon 10/26. Party risk: low.

TASK DONE when shipped with its check; TASK PARTIAL with what is left.
