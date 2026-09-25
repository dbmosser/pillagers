A. VERDICT

Yes, it can be done within every constraint. It fits in the one file and uses the browser's own peer-to-peer connections and microphone. It needs no library, no build step, no drawing change, and no server to get started.

One PC hosts and runs the real raid. Each friend's PC keeps its own body, bag and save, sends the host what it does, and draws what the host sends back. Solo play never runs the new code.

Three things decide how well it works:
1. Whether itch allows the mic. Public itch game frames allow the microphone today (I saw this on a live page), but itch does not promise it, and nobody has checked your password-protected page yet. That is the first test. The mic is also blocked when the game is opened from a LAN address such as 192.168.x.x over plain http. localhost and itch both work. Opening the game anywhere other than itch starts a blank save.
2. Home routers. With no relay server, about 1 pair of PCs in 10 may fail to connect. That is a guess from old data. A relay needs your Cloudflare account and probably a card on file.
3. The host's window. If the host minimises the game or covers it with another window, the raid freezes for everyone.

B. DECISIONS FOR THE OWNER

1. Co-op or player-versus-player? I recommend co-op. Pillagers stay as AI and bullets never hit teammates. PvP roughly doubles the work, because it needs rules for who owns a hit and how far to trust each PC.
2. How many players? I recommend 2 first and 4 later. Enemy counts stay as they are because numbers are frozen, so raids will get easier as more people join.
3. How friends join. I recommend copy-paste invite codes for now, which need no account. Later, short room codes need your Cloudflare account: you create a small database and paste in the server code. A relay for the 1 pair in 10 needs a Cloudflare relay (TURN) key and probably a card. Only you can set these up.
4. Voice. I recommend push-to-talk on Y, which no key uses today. Everyone hears everyone at full volume in the Undercroft. In the raid, voices get quieter with distance. Headsets are advised. Open mic is available as an option, and controller players start on open mic.
5. Co-op rulings:
   - Should grenades, lightning and the nuke hurt teammates in range? I recommend yes.
   - Each player's kills, contracts, gun wear and notoriety go to that player's own save. I recommend yes.
   - Pillager grudges come from the host's history. I recommend accepting that.
   - If the host drops out mid-raid, I recommend the others keep what they carry.
   - Reviving a teammate: I recommend leaving it out of the first version.

C. PHASES

Every build sits behind NET.on, which is off by default.

Phase 1: Connect and talk in the Undercroft
- What the player sees: a PARTY option on the lift (F) to host or join by code, friends walking the floor, and push-to-talk voice.
- Code that changes: a new NET section, the lift station's acts, updateHubWorld and drawHubWorld, and new Settings rows.
- Verified on one PC with a harness page: two iframes, each with its own profile, a real connection over loopback, and a fake mic.
- Needs two real PCs: routers, the itch mic prompt, and echo.
- Size: about 1,200 new lines and about 30 touched.

Phase 2: Co-op raid in one shared world
- What the player sees: everyone ascends together and sees each other and the same enemies. Enemies go after the nearest player.
- Builds:
  - The start handshake and the client's own map build, with a fingerprint compare.
  - World snapshots (enemies, rings, timers, weather), smoothed on the client, with a fork in loop.
  - Each client sends its position. Other players are drawn with drawOp.
  - Enemy targeting uses the nearest player in updateEnts, navSeek's lodR test, updateBullets, feudEngage, howlerImpact, tickNuke, tickRaiderWaves and strikeTick. The host decides enemy hits, and each player's own damagePlayer applies them.
  - Client shots become fire requests. Kill events are credited to the shooter's own save.
  - Area damage applies to every player in range.
  - Superhot is off, pause becomes an overlay, and the death slow-down is local to the dying player.
- Verified on one PC with the harness plus a fake connection that adds lag and loss.
- Needs two real PCs: feel, a 60 Hz PC against a 144 Hz PC, clock drift over a 540-second raid, and host CPU load.
- Size: about 1,500 to 2,000 new lines and about 400 touched.

Phase 3: Loot and extraction per player
- What the player sees:
  - Only one player can search a container at a time, so two players cannot double the search speed.
  - Loot goes into the searcher's own bag.
  - Drops and restocks show for everyone.
  - Each player extracts, dies or abandons alone through their own endRaid.
  - The beacon and siege are shared by the whole party.
  - A host who leaves early keeps watching while the raid runs on.
- Verified on one PC: staged pulls, and a staged G.active for each player. After a client dies, the host's save must be byte-identical.
- Needs two real PCs: one full raid where one player extracts and one dies.
- Size: about 800 new lines and about 200 touched.

Phase 4: Polish
- Voice panning left and right, and muffling through walls.
- A "lift radio" so players back in the Undercroft can hear those still in the raid.
- Roster statuses, name tags and map dots.
- Room codes and a relay, if you set up the account.
- A vocabulary check on every new string.
- Size: about 600 lines.

D. RISKS AND WHAT STAYS UNTOUCHED

- Solo play: every hook is inside if(NET.on), and the net code never calls rr, rnd or pick. After every build: __verifySafe, the seed 4242 counts 85/165 and 374/593 plus RNGS, and a paired A/B run against the previous build.
- Frozen numbers: there is no enemy scaling and no stat change. One searcher per container keeps search speed unchanged. Superhot off and pause-as-overlay are rules for the multiplayer mode only.
- Profile leaks: saveProfile writes P.cfg=CFG. While the host's world dials are loaded, saves must write the player's own stored CFG instead. Fog must save under the host's mapIx. About 200 CFG keys have to be sorted into world and personal first.
- Client build: buildRaid reads P.stash and ends in saveProfile, so on the client it runs on a full clone of that player's P, with saving turned off.
- Voice: the visibilitychange handler calls AC.suspend(), so voice needs its own AudioContext. Chrome also needs a muted audio element for each remote voice.
- The Cold Mile is 9000Ã—7600, so the position encoding must not top out at 8,191.
- The harness gets a new port, for example :8805. It must never use :8802 or :8803. The fixture replaces say, sfx and blip, so no net hooks go inside those.

E. FIRST THREE BUILDS

Build 1: two copies connect, text only
- SLOT and SKEY (L2199â€“2200): add a ?netslot=A|B override that uses 'salvagerun:profile:net'+slot and never writes salvagerun:activeSlot.
- Add:
  - NET={on:false,...}
  - netHost(), netJoin(code) and netAccept(code)
  - sdpPack and sdpUnpack: a data-channel-only offer, sent after ICE gathering finishes, compressed with CompressionStream('deflate-raw') and base64url
  - netSend and netOnMsg, with hello{proto,ver,pid,name,look}, welcome, reject and roster
  - STUN server stun:stun.cloudflare.com:3478
- Lift station: add KeyF:['party',...] beside KeyT:['the terms',...] to open a PARTY modal with CLOSE and ESC.
- Checks:
  - The solo fingerprint and RNGS are unchanged, and boot creates zero RTCPeerConnections.
  - Saving under netslot A leaves slot B's key and activeSlot untouched.
  - In the harness, after the host and joiner connect, both rosters show 2 players within 5 seconds, and RNGS is unchanged across the handshake.
  - A version mismatch is rejected. As the control, a matching version is accepted.
  - The invite code length is reported. The target is under 2,000 characters so it fits in one Discord message.

Build 2: see each other on the floor
- netHubTick(dt), called from updateHubWorld, sends x, y, face and look at 10 Hz on the unreliable channel.
- netDrawPeers(), called from drawHubWorld, draws each peer with drawOp(x,y,face,...) and a name tag.
- Checks:
  - A real W key dispatched on window in iframe A moves A's copy in iframe B to within 16 px after 300 ms.
  - A peer disappears when it leaves.
  - The solo hub frame hash matches the previous build with NET off.

Build 3: voice in the Undercroft
- voiceInit() creates its own VAC, separate from AC.
- voiceMicOn() calls getUserMedia with echo cancellation, noise suppression and auto gain, only on the Mic click. It adds the mic track by renegotiating over the open data channel.
- voiceAttach(peer,stream) sets up a muted audio element and routes MediaStreamSource to Gain to VAC.destination.
- Push-to-talk: holding Y, read in its own capture listener, toggles track.enabled. The listener ignores text fields and releases on blur and visibilitychange.
- P.netMute[pid] holds the mute list. New Settings rows cover mic mode and device.
- Checks:
  - After boot, getUserMedia has been called zero times.
  - Fake mic test: an oscillator feeds createMediaStreamDestination. The receiver's analyser level rises only while Y is held. As the control, it stays silent when Y is not held.
  - Mute sets the gain to 0.
  - Hiding the page suspends AC but not VAC.
  - Y does nothing in solo play.
- Needs two real PCs: the mic prompt on your itch page, and echo on speakers.