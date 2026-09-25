**Bottom line:** yes, this can be done with no library, no build step and no change to how the game draws. Today's itch embed already allows the microphone and autoplay; I saw that on public itch pages today, but itch does not document it. The simplest server that needs no Node is the owner's Cloudflare account running D1 with polling, set up entirely in the dashboard. A Durable Object WebSocket room is better but needs Wrangler (Node). Copy-paste codes work as a fallback that needs no server at all. For TURN, Cloudflare Realtime gives 1,000 GB a month free, and the same Worker can issue the short-lived logins. For voice, each player sends one mic track per peer, and distance sets the volume, either on a per-peer audio element or through Web Audio. Chrome has two known problems with remote voice routed through Web Audio (item 4).

## 1. Can the itch iframe use the mic and RTCPeerConnection?

**What I observed today** by fetching public HTML5 pages with curl (ncase.itch.io/wbwwb and ncase.itch.io/coming-out-simulator-2014):
- The iframe is `<iframe ... id="game_drop" src="https://html-classic.itch.zone/html/300364/index.html?v=..." allow="autoplay; fullscreen *; geolocation; microphone; camera; midi; monetization; xr-spatial-tracking; gamepad; gyroscope; accelerometer; xr; cross-origin-isolated; web-share">`.
- It has no `sandbox` attribute.
- The html-classic.itch.zone response carries no CSP and no Permissions-Policy header, so nothing blocks fetch or WebSocket calls to workers.dev.
- The itch.io page itself only sends `Content-Security-Policy: frame-ancestors 'self' https://itch.io`.
- The owner's page (pillagers.itch.io/pillagersv1306) asks for a password, so I could not see his iframe. It is very likely the same site-wide template, but I could not check it.

**What is documented:**
- itch's HTML5 docs say nothing about `allow` attributes or the microphone.
- The only statement is from leafo, about 5 years ago: "I've updated the list of allow properties on iframes for html5 games", with no list. The allow list is undocumented and could change.
- MDN: a cross-origin iframe needs `allow="microphone"`. A sandboxed iframe cannot call getUserMedia without `allow-same-origin`.
- RTCPeerConnection needs no permission policy.
- Chromium says delegated prompts "often â€¦ appear to be coming from the top-level origin", so players will probably see itch.io asking for the mic.

**Workarounds:**
- **itch launch modes:** the embed modes are "Embed in page", "Click to launch in fullscreen" and "maximized". I assume they all still use an iframe; I did not check.
- **Direct html-classic.itch.zone URL:**
  - For a public game it returned 200 with no cookies and no referrer. Opened directly, the game is the top-level page, so nothing needs delegating.
  - It is undocumented, and the path is tied to an upload id.
  - Whether it works for a Restricted or password-protected project is unknown.
- **Any HTTPS static host:** for example Cloudflare Pages. The game is then top-level and he has full control.

**LAN play from his plain static server:** `http://192.168.x.x` is not a secure context, so `navigator.mediaDevices` is undefined and there is no mic. `localhost` and `file://` do count as secure (MDN). So each friend should open their own copy locally, or use itch or another HTTPS host. I believe RTCPeerConnection itself works over plain http but did not verify that.

## 2. WebRTC signaling with no library

### (a) Copy-paste codes

**Sizes:**
- webrtcHacks: an audio and video offer is over 1,500 characters before ICE candidates.
- magarcia (Jan 2026) measured a data-channel-only SDP at 2,487 bytes.
- A Chrome audio section adds codec, extmap and rtcp-fb lines. My unmeasured estimate is 3â€“5 KB for an offer with audio and a data channel. I could not run a browser here.

**Ways to shorten it:**
1. **Paste only a data-channel offer.** Wait for ICE gathering to finish first, so no candidates trickle in later. Add the mic track afterwards and renegotiate over the open data channel (negotiationneeded or MDN's "perfect negotiation" pattern). This needs no second paste.
2. **Compress natively.** `CompressionStream('deflate-raw')` plus base64 is built in and has been Baseline since May 2023. I guess it roughly halves the size.
3. **Extreme:** send only ice-ufrag, ice-pwd, the DTLS fingerprint, setup and the candidates, and rebuild the SDP on the other side.
   - webrtcHacks got this to 106 characters (2015); magarcia got 55â€“100 bytes.
   - This is SDP munging: fragile across browser versions, and mDNS `.local` candidates complicate it.

**Timing:** webrtcHacks says that with TURN, less than 30 seconds may pass between creating the answer and applying it at the offerer, or ICE fails. STUN-only is probably more forgiving; a stale code just means redoing the paste (my inference).

**Several PCs:** a full mesh needs N(Nâˆ’1)/2 pairs with 2 pastes each. A star is better: the host pastes with each of the Nâˆ’1 joiners, then relays signaling for the joiner-to-joiner links over the data channels.

### (b) Cloudflare

**Workers Free:** 100,000 requests a day, 10 ms CPU per request.

**Durable Objects (free plan since 2025-04-07, SQLite storage only):**
- Limits: 100,000 requests a day and 13,000 GB-s a day. Incoming WebSocket messages are billed 20:1, and hibernating objects are not charged. Once a limit is hit, "further operations of that type will fail with an error" until 00:00 UTC.
- A room would be one object looked up with `idFromName(code)`, relaying JSON between WebSockets.
- The catch: a new object class needs a `new_sqlite_classes` migration in Wrangler config. The getting-started guide only documents the command line (`npm create cloudflare`) or a GitHub deploy button, and this machine has no Node.

**KV (what the collector uses):**
- Free: 1,000 writes a day and 100,000 reads a day.
- Cloudflare says "Changes may take up to 60 seconds or more to be visible in other global network locations" and steers coordination work to Durable Objects.
- Polling for an answer could stall for up to about 60 seconds. This is a poor fit.

**D1:**
- The docs give dashboard-only steps to create a database and bind it to a Worker.
- Free: 5M rows read and 100k rows written per day.
- Signaling would be polling over fetch: `POST /sig/<room>`, then `GET /sig/<room>?after=<id>` about once a second. That is trivial against the limits.
- **This is the path that needs no Node.** I did not check D1's read-replica consistency settings.

**Reaching it from an itch page:** use the same pattern as `tools/collector/worker.js`, which returns `'Access-Control-Allow-Origin': '*'` and has the game post `text/plain` as a simple request with no preflight. WebSocket upgrades are not subject to CORS; the Worker can check the Origin header if wanted. Add `/sig` and `/turn` routes to the same Worker. In the game, `var PUBLIC_DROP=null;` shows the collector is not deployed yet.

### (c) Free public relays

**ntfy.sh:**
- I confirmed `Access-Control-Allow-Origin: *` today with curl OPTIONS. It takes POST over fetch and has WebSocket at `/<topic>/ws`, with no signup.
- Limits: "60 requests as a burst, and then 1 request per 10 seconds". A search snippet said 250 messages a day per IP; the docs I read did not confirm that.
- Messages over 4,096 bytes become attachments.
- The topic name is the only password and SDP carries IP addresses, so room names must be random. There is no SLA.

**PeerJS cloud (0.peerjs.com):**
- Plain WebSocket to `wss://0.peerjs.com/peerjs?key=peerjs&id=<id>&token=<rand>&version=...`.
- Messages are JSON `{type, payload, dst}`, with a heartbeat every 5,000 ms. Message types: Heartbeat, Candidate, Offer, Answer, Open, Error, IdTaken, InvalidKey, Leave, Expire.
- PeerJS warns IDs may collide and says "For high-traffic applications, please host your own". Using it without their library means copying an undocumented wire protocol.

**Nostr, MQTT and WebTorrent trackers (the options Trystero uses):**
- Nostr events need secp256k1 Schnorr signatures, which WebCrypto does not provide, so that is too much code (my inference).
- MQTT needs binary framing.
- Trystero itself says these networks have "far less relay redundancy". Not recommended.

## 3. NAT traversal

**STUN:**
- `stun.cloudflare.com:3478`: Cloudflare documents it as "free and unlimited".
- `stun.l.google.com:19302`: widely used, but undocumented and with no SLA.

**How often peer-to-peer fails without TURN:**

| Source | Figure |
|---|---|
| callstats (2015â€“16, 100+ customers) | 22% of conferences needed TURN, 9% needed TCP |
| callstats, same data | 12% of sessions never connected; 85% of those failures were NAT or firewall |
| Tailscale (an estimate) | direct connections over 90% of the time with good traversal |

I found no current figure for home players only. My guess is that roughly 1 in 10 pairs would fail on STUN alone, mostly strict NAT on both sides or carrier-grade NAT such as phone hotspots. This is uncertain; test with his actual friends and keep TURN as the fallback.

**TURN options:**
- **Cloudflare Realtime:**
  - $0.05/GB, first 1,000 GB a month free (shared with their SFU service).
  - Logins come from `POST https://rtc.live.cloudflare.com/v1/turn/keys/$TURN_KEY_ID/credentials/generate-ice-servers` with a Bearer token. Cloudflare says "keep your TURN key on the server side", so the Worker issues them.
  - Logins last at most 48 hours. Servers are turn.cloudflare.com on ports 3478, 443, 80 and 5349 over UDP, TCP and TLS. There is no TCP relaying (RFC 6062) and no IPv6 relay address.
  - Unknown whether the free tier needs a card on file.
- **Metered Open Relay:** their site says 20 GB a month free with a signup and API key. An itch thread (Mar 2026) says 0.5 GB without a card and 20 GB with one. The sources conflict.
- **ExpressTURN:** their site says 1,000 GB a month free on port 3478; premium is $9 a month for 5 TB. The same itch thread says 100 GB free. The sources conflict.
- **Twilio:** $0.40/GB in the US and Germany.

**Volume:** at an assumed Opus voice rate of about 40 kbps, that is about 18 MB per hour per direction (my arithmetic). Friends' usage stays far below any free tier.

## 4. Browser mic chat

**Capture:** `getUserMedia({audio:{echoCancellation:true,noiseSuppression:true,autoGainControl:true}})`. Chrome 141 also accepts `"all"` and `"remote-only"` for echoCancellation. MDN says `true` must cancel at least as much as `"remote-only"`.

**Push-to-talk:**
- Set `track.enabled=false`. MDN: "a disabled track generates frames of silence" and "When implementing a mute/unmute feature, you should use the enabled property." No renegotiation is needed.
- `sender.replaceTrack(null)` would stop sending entirely (from the spec; I did not research it further).

**Proximity volume, option A (simplest):**
- One autoplaying audio element per peer, with `el.srcObject = e.streams[0]`.
- Each frame, set `el.volume` from distance.
- This keeps Chrome's normal echo-cancellation path. There is no left/right panning.
- Risk: a 2019 report says `.volume` on remote streams "didn't work on Linux and MacOS" in Chrome. It needs testing on Windows Chrome now.

**Proximity volume, option B (Web Audio, allows panning):**
- Route `AC.createMediaStreamSource(stream)` through a GainNode and a StereoPannerNode or PannerNode to `AC.destination`.
- **Chrome quirk:** the remote stream is silent in Web Audio unless it is also attached to a media element: `const a=new Audio(); a.srcObject=stream; a.muted=true;` (Chromium bugs 121673 and 933677, Babylon forum). Firefox does not need this.
- **Echo problem:** Chrome historically did not cancel echo from Web Audio output (Chromium 687574, focused.io 2020), so players on speakers get echo. Fixes:
  - a loopback RTCPeerConnection trick
  - headphones
  - possibly Chrome 141+ `echoCancellation:"all"`, which MDN says removes all system audio; I have not verified that it fixes this on Windows.
- The game already has one AudioContext, `var AC=null; function ac(){ if(!AC){ try{AC=new (window.AudioContext||window.webkitAudioContext)();}catch(e){AC=false;} } ...`, with resume-after-gesture logic. Voice should connect straight to `AC.destination`, not through the music dials.

**Autoplay:**
- The itch iframe has `allow="autoplay"` (observed).
- Chrome allows sound after a user interaction. An AudioContext created before a gesture starts "suspended" and needs `resume()`.
- Call `audioEl.play()` and `AC.resume()` inside the Join click.
- Chrome's autoplay doc says nothing about mic capture exempting a page, so do not rely on that.

**Bandwidth:** in a mesh, each player uploads Nâˆ’1 voice streams.

Sources:
- [itch HTML5 docs](https://itch.io/docs/creators/html5)
- [leafo: allow list updated](https://itch.io/post/2986302)
- [itch: more embed options](https://itch.io/updates/more-embed-options-for-html5-games)
- [Observed page: wbwwb](https://ncase.itch.io/wbwwb)
- [Observed page: coming-out-simulator-2014](https://ncase.itch.io/coming-out-simulator-2014)
- [MDN getUserMedia](https://developer.mozilla.org/en-US/docs/Web/API/MediaDevices/getUserMedia)
- [Chromium: permissions in cross-origin iframes](https://www.chromium.org/Home/chromium-security/deprecating-permissions-in-cross-origin-iframes/)
- [webrtcHacks: minimum viable SDP](https://webrtchacks.com/the-minimum-viable-sdp/)
- [magarcia: QR-sized WebRTC](https://magarcia.io/air-gapped-webrtc-breaking-the-qr-limit/)
- [MDN CompressionStream](https://developer.mozilla.org/en-US/docs/Web/API/CompressionStream/CompressionStream)
- [MDN perfect negotiation](https://developer.mozilla.org/en-US/docs/Web/API/WebRTC_API/Perfect_negotiation)
- [Cloudflare Workers limits](https://developers.cloudflare.com/workers/platform/limits/)
- [Durable Objects pricing](https://developers.cloudflare.com/durable-objects/platform/pricing/)
- [Durable Objects free tier changelog](https://developers.cloudflare.com/changelog/2025-04-07-durable-objects-free-tier/)
- [Durable Objects getting started](https://developers.cloudflare.com/durable-objects/get-started/)
- [How KV works](https://developers.cloudflare.com/kv/concepts/how-kv-works/)
- [D1 pricing](https://developers.cloudflare.com/d1/platform/pricing/)
- [D1 getting started](https://developers.cloudflare.com/d1/get-started/)
- [ntfy FAQ](https://docs.ntfy.sh/faq/)
- [ntfy publish docs](https://docs.ntfy.sh/publish/)
- [PeerJS socket.ts](https://raw.githubusercontent.com/peers/peerjs/master/lib/socket.ts)
- [PeerJS enums.ts](https://raw.githubusercontent.com/peers/peerjs/master/lib/enums.ts)
- [PeerServer Cloud](https://peerjs.com/server/cloud)
- [Trystero](https://github.com/dmotz/trystero)
- [Cloudflare TURN FAQ](https://developers.cloudflare.com/realtime/turn/faq/)
- [Cloudflare TURN credentials](https://developers.cloudflare.com/realtime/turn/generate-credentials/)
- [Cloudflare Realtime pricing](https://developers.cloudflare.com/realtime/sfu/pricing)
- [Metered Open Relay](https://www.metered.ca/tools/openrelay/)
- [ExpressTURN](https://www.expressturn.com/)
- [itch thread: free TURN servers](https://itch.io/t/6165128/free-turn-servers)
- [Twilio TURN pricing](https://www.twilio.com/en-us/stun-turn/pricing)
- [webrtcHacks: usage stats](https://webrtchacks.com/usage-stats/)
- [Tailscale: how NAT traversal works](https://tailscale.com/blog/how-nat-traversal-works)
- [MDN MediaStreamTrack.enabled](https://developer.mozilla.org/en-US/docs/Web/API/MediaStreamTrack/enabled)
- [MDN echoCancellation](https://developer.mozilla.org/en-US/docs/Web/API/MediaTrackConstraints/echoCancellation)
- [Chrome 141 release notes](https://developer.chrome.com/release-notes/141)
- [Chrome autoplay policy](https://developer.chrome.com/blog/autoplay)
- [Babylon forum: remote WebRTC sound workaround](https://forum.babylonjs.com/t/sound-created-with-a-remote-webrtc-stream-track-does-not-seem-to-work/7047/17)
- [TwoSeven: remote volume in Chrome](https://blog.twoseven.xyz/chrome-webrtc-remote-volume/)
- [focused.io: echo cancellation with Web Audio](https://focused.io/lab/echo-cancellation-with-web-audio-api-and-chromium)

Files read: `C:\claudecode\dark raiders\tools\collector\README.md`, `C:\claudecode\dark raiders\tools\collector\worker.js`, `C:\claudecode\dark raiders\dark_raiders.html`