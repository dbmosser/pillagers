# Pixel rendering craft for a 2.5D 3/4 top-down Canvas 2D game (PILLAGERS)

Scope note: research done 2026-10-20 with web search and page fetches. Punctuation follows the project rule (no em or en dashes); each finding ends with its source link. Where a page could not be opened, the finding says it came from a search summary. Numbers for PILLAGERS: pillagers are about 80 screen px tall at 1920x1080 and the target look uses about 4 screen px per art pixel, so a pillager is about 20 art px tall and a 1920x1080 screen is a 480x270 art-pixel view.

## Q1. How professional pixel-art games get a consistent look (pixel scale, mixels, palette, hue shift, sel-out, anti-aliasing, readability, silhouette, 3/4 perspective, reference games)

### Takeaway
Consistency comes from a handful of hard rules applied everywhere: one art-pixel grid for every object (no mixels, no rotated or non-integer-scaled pixels), one small master palette built from hue-shifted ramps, outlines that always add contrast (dark near-black on the outer edge when backgrounds are busy, coloured or selective on inner lines), hand-judged anti-aliasing used sparingly, chibi proportions (head a third to half of the body) for readability at small size, and one projection per scene. Slynyrd's own 3/4 top-down mockup uses exactly the PILLAGERS frame: 480x270 native at 4x.

### Cited Findings
**One pixel grid (mixels)**
- "Mixels" means changing the pixel size for some parts of the art; a common cause is scaling a small sprite up in engine so its pixels are larger than the rest of the scene. Community guidance: all pixel art should sit on the same grid and all outlines should have the same thickness; results otherwise read as "unprofessional". [Flowlab community rant on mixels](https://community.flowlab.io/t/mini-rant-stop-using-mixels/38287); [itch.io comment on mixels](https://itch.io/post/15697736)
- Practical fix cited by developers: decide the art resolution up front and draw everything as if the window were that small; in Godot that means a small viewport, "viewport" stretch mode and integer scaling; in Unity, one pixels-per-unit value for every sprite. [itch.io post](https://itch.io/post/8967436); [GameDev Stack Exchange mirror](https://backiee.wasmer.app/http_gamedev_stackexchange_com/q/141609)
- Some modern games mix resolutions successfully, but sparingly and mostly for gameplay reasons; one developer who mixed densities said it was deliberate because they were not aiming for canonical pixel art. [Guard Duty dev retrospective, ModDB](https://www.moddb.com/features/guard-duty-a-development-retrospective-dev-diary-4); [itch.io post](https://itch.io/post/9267691)
- MDN warns that when CSS pixels do not line up with device pixels (non-integer devicePixelRatio) some pixels draw larger than others. [MDN: Crisp pixel art look](https://developer.mozilla.org/en-US/docs/Games/Techniques/Crisp_pixel_art_look)

**Palette and hue shifting**
- Slynyrd (Raymond Schlitter) builds ramps ordered by brightness that also shift hue; his Mondo palette is 128 colours: 8 ramps of 9 swatches, 20 degrees of positive hue shift per swatch (160 degrees per ramp), each ramp a 45 degree rotated copy of the first, plus desaturated neutrals made from the palette's own middle columns. [Slynyrd Pixelblog 1: Color Palettes](https://www.slynyrd.com/blog/2018/1/10/pixelblog-1-color-palettes)
- Same source: positive hue shift "usually results in more natural colors, warming as they become brighter"; brightness rises along the ramp and usually never starts at 0 unless black is wanted; saturation peaks around the middle and never hits 0 or 100; darks carry more saturation ("X pattern"); avoid high saturation together with high brightness; straight (no hue shift) ramps harmonise poorly with other hues. [Slynyrd Pixelblog 1](https://www.slynyrd.com/blog/2018/1/10/pixelblog-1-color-palettes)
- Same source: a fixed shared palette "will ensure everything in your game has consistent colors" and "A little color goes a long way with pixel art". [Slynyrd Pixelblog 1](https://www.slynyrd.com/blog/2018/1/10/pixelblog-1-color-palettes)
- Hue-shift tutorials agree on cooler hues in shadow and warmer in highlights, guided by the scene's light. [Xenogene tutorials, Ascension GameDev](https://www.ascensiongamedev.com/topic/3680-xenogenes-art-tutorials/); [LPC OpenGameArt: insights on colour ramps](https://lpc.opengameart.org/node/20643)
- A ramp generator tool exists that builds hue-shifted ramps from one base colour (credits Slynyrd). [ColorRampGenerator on GitHub](https://github.com/Exerionius/ColorRampGenerator)

**Outlines, sel-out, internal lines**
- Lospec (skeddles, 2016): the default outline is a darker shade of the object's own colour; "an outline should always increase contrast, and never decrease it"; the outline should be darker than both the object and the background. [Lospec: Pixel Art Outlines Part 2, Using Color](https://lospec.com/articles/pixel-art-outlines-part-2-using-color)
- Same source on selective outlining: darker outline shades on the shadow side, lighter on the lit side; but light outline shades that work on light backgrounds fail on dark ones, so games with changing backgrounds should stick to darker shades; where a solid black outer outline is needed, sel-out can still be used on internal lines. [Lospec Part 2](https://lospec.com/articles/pixel-art-outlines-part-2-using-color)
- Same source on internal lines: one step darker than the surrounding area gives a subtle line; break thin lines so they show only near shadows; fade a line lighter where it ends at a joint; between two colours use the colour of the part nearer the viewer (or the darker one if one part is in shadow). [Lospec Part 2](https://lospec.com/articles/pixel-art-outlines-part-2-using-color)
- Black outlines give clear separation but can look overpowering or retro; black may be necessary for changing backgrounds. [Lospec Part 2](https://lospec.com/articles/pixel-art-outlines-part-2-using-color)
- Sel-out is described as a shaded outline: lit outline pixels take other values while the sprite's own shading is unchanged. [itch.io pixel tutorial: selective outlines](https://itch.io/t/2422252/pixel-tutorial-selective-outlines)

**Anti-aliasing**
- AA in pixel art is hand-placed: small shifts in perceived lightness suggest forms the grid cannot show; it must be applied judiciously by hand. [Pixel Parmesan: Anti-Aliasing Fundamentals for Pixel Artists](https://pixelparmesan.com/anti-aliasing-fundamentals-for-pixel-artists)
- AA on an outline effectively thickens it and makes it background-dependent; selective AA reduces but never removes background dependence. [PixelJoint critique](https://pixeljoint.com/pixelart/111010.htm)

**Proportions, readability, directions (top-down characters)**
- Slynyrd Pixelblog 22: "1 tile wide by 2 tiles tall is one of the most common sprite sizes" (16x32 on 16 px tiles); his mockup ran 16x16 tiles at 480x270 native resolution at 4x scale. [Slynyrd Pixelblog 22: Top Down Character Sprites](https://www.slynyrd.com/blog/2019/10/21/pixelblog-22-top-down-character-sprites)
- Same source: "the head usually takes up a third to half of the total sprite"; realistic proportions at small size read as stick figures; emphasise expressive features. [Slynyrd Pixelblog 22](https://www.slynyrd.com/blog/2019/10/21/pixelblog-22-top-down-character-sprites)
- Same source: draw at least up, down and side and mirror the side, unless the design is asymmetric or there is dramatic directional lighting; 4 sprites can serve 8-way movement (16-bit games did this); walk cycle 4 frames, run 8; start large sprites as a dummy of solid-colour body parts. [Slynyrd Pixelblog 22](https://www.slynyrd.com/blog/2019/10/21/pixelblog-22-top-down-character-sprites)
- Same source on depth: lower on screen is closer, so the top half of a 2-tile sprite may overlap things slightly higher up; overlap along X reads as confusing. [Slynyrd Pixelblog 22](https://www.slynyrd.com/blog/2019/10/21/pixelblog-22-top-down-character-sprites)
- Pixelblog 55 (2025) names the 3/4 top-down projection (large share of front and top visible, as in Chrono Trigger) and covers 8-direction animation. [Slynyrd Pixelblog 55: Top Down Character Animation](https://www.slynyrd.com/blog/2025/3/24/pixelblog-55-top-down-character-animation)

**3/4 projection conventions**
- Slynyrd Pixelblog 3: 3/4 top-down is like looking at a house from about 45 degrees, seeing about three quarters of roof and front wall; he shortens the front wall but keeps roof angles as seen straight on for clean lines; a scene should stick to one projection. [Slynyrd Pixelblog 3: Graphical Projection](https://www.slynyrd.com/blog/2018/3/14/pixelblog-3-graphical-projections-1)
- Developers note square ground tiles become visually squashed in 3/4 view; one suggestion is to draw ground tiles straight top-down and switch to 3/4 only for buildings and objects. [OpenGameArt thread](https://opengameart.org/node/5288)

**Reference games (what could be confirmed)**
- Hyper Light Drifter: lead Alex Preston said the game "is 480p" and the low resolution is very intentional. The exact 480x270 figure was not confirmed by the source. [GamingBolt interview](https://gamingbolt.com/our-game-is-480p-yeah-its-low-resolution-and-very-intentionally-so/amp)
- Enter the Gungeon: a preview said its weapons are individually hand-crafted down to the last pixel; an itch.io developer contrasted auto-rotated rifle sprites (distorted) with Gungeon's "much more accurate work". [Destructoid preview](https://www.destructoid.com/dd-meets-bullet-hell-shooter-in-enter-the-gungeon/); [itch.io post](https://itch.io/post/4160406)
- Eastward: Pixpil describes "retro-pixel + 3D lighting" aiming at 90s Japanese animation, lighting as "general deferred shading" letting designers add lights and tune ambient tone, a homebrew engine fused with MOAI, and a pipeline importing layered Aseprite files directly. (From search summaries; full pages not fetched.) [Red Bull interview](https://www.redbull.com/my-en/eastward-interview); [Game Developer: Road to the IGF, Eastward](https://www.gamedeveloper.com/disciplines/road-to-the-igf-pixpil-s-i-eastward-i-)
- Children of Morta: built in Unity with dynamic lighting and specular maps; Dead Mage's art lead described stretching pixel animations to HD so lights run at high resolution, "high-res dynamic lights instead of pixelated lights" (search summary; the TechRaptor page returned 403). [Jump Dash Roll review](https://jumpdashroll.com/article/children-of-morta-review); [Engadget hands-on](https://www.engadget.com/2018/03/22/children-of-morta-hands-on-indie-xbox-gdc/); [TechRaptor (blocked)](https://techraptor.net/content/how-dead-mage-created-the-art-for-children-of-morta)

### Inferences
- PILLAGERS at 4 screen px per art px is a 480x270 art view at 1080p, the same as Slynyrd's 3/4 mockup. A 20 art px chibi pillager fits his "1 by 2 tile" convention (about 16x20 to 16x32 frame) with a head of about 7 to 10 art px.
- Integer scale trap: 480x270 scales by 4 at 1080p and 8 at 4K but by 5.33 at 1440p (non-integer, mixel risk). A 640x360 art buffer scales by exactly 3 (1080p), 4 (1440p) and 6 (4K). If his "camera further out" order means a wider view anyway, 640x360 is the one base size that stays integer on all three common 16:9 monitors (pillagers would then be 60 screen px at 1080p unless they grow to about 27 art px). Any free (non-integer) camera zoom breaks the grid; zoom should step between integer art scales.
- Grid alignment between objects: if each sprite is drawn on its own small offscreen canvas and blitted at a fractional screen position, each sprite's 4 px grid is offset from its neighbours'. That is a quiet form of mixels. Every blit position must be snapped to the shared art grid (camera-relative multiples of the scale), or the whole world drawn into one low-res buffer and upscaled once.
- Outline rule for the reference look: outer outline near-black (busy grass behind every sprite, so Lospec's "darker than object and background" wins), inner lines coloured from the part's own ramp (one step darker), and a lighter outline tint only on the top-left lit edge if it still beats the grass in contrast.
- Palette: a master palette of roughly 32 to 64 colours from hue-shifted ramps (Slynyrd pattern scaled down) with each material using a 3 to 4 tone slice of a ramp. Customization colours (outfits) should pick a ramp, not a free RGB value; free RGB is what makes procedural art look "off palette".
- Light from the top left is fixed in screen space. Mirrored sprites break that (Slynyrd's caveat), so a procedural or layered renderer that shades per facing is an advantage here, not a cost.

### Gaps
- No primary developer source found for Moonlighter, Zero Sievert or Enter the Gungeon art pipelines (sprite sizes, palette size, gun rotation method). Gungeon's per-angle gun art is inferred from a preview quote, not confirmed.
- Hyper Light Drifter's exact native size (480x270 vs other "480p" frames) not confirmed.
- No source found for a formal numeric rule on how many tones per material at 20 px sprite height; 3 to 4 tones is the owner's reference brief, not a cited rule.
- Pedro Medeiros (Saint11) tutorial index lives at blog.studiominiboss.com/pixelart per search results, but the page was not opened, and a 2022 reply says no new tutorials are planned. [itch.io reply](https://itch.io/t/694553/new-update); [Creative Bloq on his GIF tutorials](https://creativebloq.com/news/artist-makes-animated-gif-tutorials-to-teach-you-pixel-art)

## Q2. Procedural and paper-doll character systems; customization without drawing every combination; aiming in any direction

### Takeaway
The standard answer to customization is a paper doll: a shared base body with every layer (outfit, hat, hair, weapon) drawn on same-size frames with a shared origin, plus palette swapping for colour. Free aim is handled by separating the arms and weapon from the body: the body uses 4 or 8 facings, and the gun uses either hand-drawn angle sets or rotation. Naive nearest-neighbour rotation of pixel art produces jaggies and distortion, so careful games either hand-draw angles or pre-bake rotations with a pixel-aware rotator (RotSprite) rather than rotating at runtime.

### Cited Findings
- Full sprite sets for every combination multiply quickly; the suggested structure is same-size frames with transparent unused pixels and a shared origin so layers line up, with palette swaps handled by shaders where possible. [Solarus forum: ways to think about sprites for character customization](https://forum.solarus-games.org/en/index.php/topic,1324.0.html)
- A paper-doll guide describes clothing and accessories as stackable layers over a clean base sprite that anchors alignment. [Playgama guide](https://playgama.com/blog/unity/how-can-i-design-and-animate-character-sprites-to-resemble-paper-dolls-for-an-interactive-story-game/)
- Commercial pixel-art bases ship exactly this way: palette swap shaders for the Mana Seed series and layered overlays (for example eye colours) for a farmer base; tools like PaperDoll switch multiple layers and sheets. [itch.io character-customization pixel assets](https://itch.io/game-assets/newest/tag-character-customization/tag-pixel-art?page=2)
- Colour options: a swap shader or a separate sprite per colour; the shader route scales better after the upfront work. [Reddit discussion snapshot](https://reddit.sentinel-team.org/posts/1r9838e/snapshots/2026-02-19T22%3A17%3A43.00803Z)
- Without shaders, HTML5 canvas cannot swap palette buffers directly; recolouring means iterating the pixels in JS. Phaser developers recolour once per palette and store the result in a cached dynamic atlas. [Construct forum](https://www.construct.net/en/forum/construct-3/how-do-i-8/efficiently-quickly-154231); [HTML5GameDevs: Phaser 3 palette swapping](https://html5gamedevs.com/topic/36547-solved-phaser-3-palette-swapping)
- GPU palette lookup (sprite colour used as an index into a palette texture) is the shader method; it needs WebGL, so it does not apply here. [HTML5GameDevs: palette cycling in PixiJS](https://www.html5gamedevs.com/topic/29482-palette-cycling-in-pixijs/); [Godot Shaders: palette swap](https://godotshaders.com/shader/palette-swap-no-recolor-recolor/)
- Gun assets for top-down pixel shooters are sold with template hand sprites and separated magazines and moving parts. [Pixel Guns asset pack](https://randgamedev.itch.io/pixel-guns)
- A Godot user building an Enter-the-Gungeon-style shooter mentions switching which hand holds the gun by aim side (question thread, not an answer). [Godot forum](https://forum.godotengine.org/t/how-to-move-the-gun-properly-in-a-top-down-shooter-game/15310)
- RotSprite (Xenowhirl) exists because ordinary editors rotate either with AA (blurry) or with primitive nearest neighbour (ugly); it guesses pixel patterns to preserve features. Rotating an already rotated sprite compounds the damage. A Rust port is AGPL-3.0. [Sonic Retro: RotSprite](https://info.sonicretro.org/RotSprite); [Aseprite community: rotation jumbles pixels](https://community.aseprite.org/t/when-rotating-pixles-get-jumbled/15773); [docs.rs rotsprite](https://docs.rs/rotsprite)
- No single rotation algorithm wins on every image; artists try several and keep the best. [Aseprite community: rotation distortion](https://community.aseprite.org/t/rotating-is-causing-distortion-to-the-sprite-solved/4380)
- Spine-style skeletal animation of pixel art upscales pixels with no filtering, so jaggies scale too; a workaround was rendering high and downscaling. [Esoteric Software forum: Spine needs RotSprite](https://ru.esotericsoftware.com/forum/d/13789-spine-needs-rotsprite)
- Sprite stacking (horizontal 2D slices drawn with about 1 px vertical offset, each rotated) gives rotatable pseudo-3D objects with plain 2D draws; low view angles show gaps; it is cheap but every slice renders every frame unless cached. [Wee Boats devlog](https://jamespoole.itch.io/wee-boats/devlog/685630/using-sprite-stacking-for-pseudo-3d-in-wee-boats); [Sprite stacking with perspective (GameMaker)](https://azuzota.itch.io/sprite-stacking-with-perspective); [Codemagic: Flaming Stacks](https://blog.codemagic.io/flaming-stacks/); [Defold forum: stacking vs 3D](https://forum.defold.com/t/stacking-2d-sprites-vs-3d/67723)

### Inferences
- Recommended structure for pillagers (Canvas 2D, single file): body in 8 facings (or 4 plus 4 diagonals) chosen from the aim angle; legs animate from movement; arms plus weapon are a separate layer rotated to the exact aim. Head, hair and hat are layers anchored to a per-frame head point. Each layer is drawn as whole art pixels using palette indices, not RGB.
- Palette swap in Canvas 2D without shaders: draw each part once in index colours (for example a few reserved "marker" colours per ramp slot), then recolour with a getImageData loop once per outfit choice and cache the canvas. The loop runs at load or when a player changes outfit, never per frame.
- Composite cache: cache the finished composite per (outfit key, facing, frame), not per part, so a frame costs one drawImage per pillager. With 2 human players plus bots, the number of distinct outfits in a raid is small, so the cache stays small.
- Gun rotation: three options, best first. (a) Pre-bake 16 or 32 angles per weapon at load into the cache (rotate at art resolution with smoothing off, then run an outline pass on the result; optionally hand-fix key angles). (b) Rotate at art resolution at runtime into the low-res buffer with smoothing off (jaggy but on grid). (c) Never rotate the upscaled image at screen resolution: that produces rotated 4 px squares, which is the most visible mixel error.
- Snap the aim to the baked angle step (for example 32 steps of 11.25 degrees) only in the drawing layer; the simulation keeps the exact aim angle (layer split rule).
- Sprite stacking suits rigid rotating objects (machines, crates, vehicles) and is plain drawImage work, so it fits the no-WebGL rule, but it gives a voxel look that may clash with hand-pixel characters; bake angles rather than drawing every slice every frame.
- Procedural drawing keeps its two real advantages: unlimited outfit combinations and shading that stays lit from the top left at any facing. The weakness is the look: code-drawn shapes lack hand clusters, sel-out decisions and hand AA. The hybrid that keeps both is "procedural composition of hand-designed pixel parts": small hand-authored part bitmaps (stored as strings or small PNG data URIs inside the HTML) assembled and recoloured by code.

### Gaps
- No primary source on exactly how Enter the Gungeon, Nuclear Throne or Zero Sievert draw guns at arbitrary angles (hand-drawn sets vs runtime rotation).
- No measured per-frame cost of RotSprite-style rotation; runtime use is unverified.
- No source with a verified Canvas 2D getImageData palette-swap-and-cache code example; the pattern above is assembled from forum descriptions.

## Q3. Render-at-low-resolution pipelines, camera snapping and shimmer, 3D-to-pixel (Dead Cells) and post-process approaches, and what they mean for Canvas 2D

### Takeaway
The clean pipeline is: render the world into one low-resolution buffer at art-pixel size with integer positions, upscale once by an integer factor with smoothing off, and hide camera stepping by rendering one extra pixel of border and offsetting the final blit by the camera's fractional part. Dead Cells' 3D-to-pixel method (low-res render, no AA, normal maps, toon shader) bought animation speed at the cost of detail and flickering pixels at 50 px tall; it needs a 3D renderer, so for PILLAGERS it could only ever be an offline bake, and the project forbids 3D code. Canvas 2D also never lets you turn off anti-aliasing on path fills, which shapes how procedural art must be drawn.

### Cited Findings
**Low-res buffer and upscale in Canvas 2D**
- imageSmoothingEnabled = false keeps scaled images sharp (default true blurs); widely available since April 2017. CSS image-rendering: pixelated covers browser-level scaling of the canvas element. [MDN: imageSmoothingEnabled](https://developer.mozilla.org/en/docs/Web/API/CanvasRenderingContext2D/imageSmoothingEnabled); [MDN: Crisp pixel art look](https://developer.mozilla.org/en-US/docs/Games/Techniques/Crisp_pixel_art_look)
- MDN canvas tips: avoid floating-point coordinates (sub-pixel rendering forces AA work), do not scale images inside drawImage per frame (cache sizes), and ideally "use a smaller canvas and scale it up rather than a larger canvas scaled down". [MDN: Optimizing canvas](https://developer.mozilla.org/en-US/docs/Web/API/Canvas_API/Tutorial/Optimizing_canvas)
- Canvas 2D path anti-aliasing cannot be switched off: in 2007 Ian Hickson rejected a setAntialiasing() method for the spec; a Mozilla bug asking to optionally disable it (to avoid seams) remained open. [WHATWG list: Canvas draw quality (2007)](https://lists.whatwg.org/pipermail/whatwg-whatwg.org/2007-May/011263.html); [WHATWG list: Turn off Anti-Aliasing in Canvas (2009)](https://lists.w3.org/Archives/Public/public-whatwg-archive/2009Sep/0377.html); [Mozilla bug 1023102](https://bugzilla.mozilla.org/show_bug.cgi?id=1023102)
- In an Adobe Animate HTML5 canvas case, imageSmoothingEnabled = false on the context fixed pixel art while CSS image-rendering alone made no visible difference. [Adobe community thread](https://community.adobe.com/t5/animate-discussions/turn-off-anti-aliasing-for-html5-canvas-projects/td-p/14894544)

**Smooth camera without breaking the grid**
- yal.cc technique: floor the camera to whole pixels, render a view surface 1 px larger in each dimension, and draw it to screen offset by frac(x), frac(y); the extra row and column cover the edge gap. This gives sub-pixel camera motion with native-size pixels and stops fractional entities wobbling against the view. Parallax layers are not covered by the offset and need their own surfaces; cost was reported as negligible even with a surface per split-screen player. Enlarging the render surface to output resolution instead "introduces potential for rotated, scaled, misplaced or otherwise mismatched pixels". [yal.cc: Smooth pixel-perfect camera](https://yal.cc/gamemaker-smooth-pixel-perfect-camera/)
- Experienced developers say true pixel-perfect rendering inherently jitters at low speeds; rendering at full resolution avoids it but costs performance; scrolling at integer or 1/x px per frame reduces visible jitter. [Godot forum: smooth camera in pixel perfect game](https://forum.godotengine.org/t/smooth-camera-in-pixel-perfect-game/112586?page=2); [Godot Q&A](https://ask.godotengine.org/80858/pixel-camera-movement-with-pixel-perfect-stretched-viewport); [shmups forum](https://shmups.system11.org/viewtopic.php?p=1424880)
- A Godot 4 user reports shader-based snap-camera methods (after a write-up by Daniel Ludwig) broke with parallax in Godot 4. [Godot forum: better pixel snap camera](https://forum.godotengine.org/t/better-pixel-snap-camera/42603)

**3D-to-pixel (Dead Cells)**
- Thomas Vasseur (Motion Twin): characters modelled and rigged in 3DS Max from a 2D pixel model sheet, exported FBX; an in-house tool renders each frame very small with no anti-aliasing, exporting PNG plus normal map; a basic toon shader uses the normals for volume; characters are about 50 px tall; animation is keyframed pose to pose with interpolation frames only before or after keys, "Never in-between". [Game Developer: Art Design Deep Dive, 3D pipeline for 2D animation in Dead Cells](https://www.gamedeveloper.com/production/art-design-deep-dive-using-a-3d-pipeline-for-2d-animation-in-i-dead-cells-i-)
- Same source, trade-offs: retakes take minutes and assets are reused across monsters (saving "hundred of hours"), but "the disappointing level of details" is accepted and flickering pixels were left uncleaned to keep the process fast. [Game Developer: Dead Cells deep dive](https://www.gamedeveloper.com/production/art-design-deep-dive-using-a-3d-pipeline-for-2d-animation-in-i-dead-cells-i-)
- Dan Moran's video and repo recreate a 3D/2D blended pipeline with normal-mapped sprites and C# tooling. [80.lv: Dead Cells character art pipeline case study](https://80.lv/articles/case-study-dead-cells-character-art-pipeline/); repo named there: github.com/Broxxar/PixelArtPipeline
- Third-party tools mimic the approach (for example a Houdini pixel-art renderer). [Pixelart renderer for Houdini](https://fatalexit.itch.io/pixelart-renderer-for-sidefx-houdini)

### Inferences
**Pipeline recipe for PILLAGERS (Canvas 2D only)**
1. One world buffer canvas at art size (480x270 at 1080p, or 640x360, see Q1), plus 1 art px of border each side. imageSmoothingEnabled = false on every context that scales.
2. Camera: integer art-pixel part drives where things draw into the buffer; fractional part times the scale becomes the offset of the single upscale drawImage to the screen canvas (yal.cc method).
3. Every sprite, tile and prop is drawn into the buffer at integer art coordinates relative to the integer camera. Simulation keeps float positions (layer split).
4. Upscale once per frame: one drawImage from buffer to screen at the integer scale. Fog, darkness and HUD can then draw at full resolution on top (see Q4 for the Children of Morta "high-res light over pixel sprites" choice).
5. HUD stays on its own full-resolution canvas (MDN layered canvases), so text stays sharp and is not pixelated by the world scale.

**Procedural art must avoid Canvas path AA**: because fill() and stroke() always anti-alias, code-drawn shapes leave half-transparent edge pixels that upscale into soft mush and break the palette. Draw procedural art only with fillRect at integer coordinates (whole-pixel shapes, as the current test does), or with pixel-plotting into ImageData, or threshold alpha to 0 or 1 in a one-time bake.

**Approaches compared for our constraints**

| Approach | Look ceiling | Customization and free aim | Fits Canvas 2D, single file, no 3D? | Verdict |
|---|---|---|---|---|
| Hand-authored sprite sheets | Highest (hand clusters, sel-out, AA) | Explodes unless split into paper-doll layers plus palette swap; guns need angle sets | Yes; tiny at 20 px (PNG data URIs) | Best quality; most art labour |
| Procedural code-drawn every frame (today) | Medium; reads as "vector in pixels" | Unlimited; light stays top-left at any facing | Yes | Keep the system, change what it draws |
| Hybrid: hand-designed pixel parts, code-assembled and recoloured, baked to a cache | High | Unlimited combos; per-facing parts; guns baked at 16 to 32 angles | Yes | Recommended |
| 3D-to-pixel (Dead Cells) | Medium at small size; flicker; low detail | Strong (reuse rigs) | Runtime needs 3D (banned). Offline bake to PNG is possible but the project bans 3D code in tree; owner's call | Not recommended at 20 px |
| Post-process (draw high-res, then pixelate and palette-quantise) | Low to medium: uneven clusters, no sel-out | Unlimited | Per-frame getImageData over the frame is slow (see Q6) | Only as a one-time bake aid, then hand rules |

- Dead Cells accepted low detail and flickering at 50 px tall; PILLAGERS sprites are about 20 art px, so a downsampled 3D or vector render would lose even more and flicker more when aiming (every angle resamples). That is the main reason the hybrid wins.
- Shimmer sources to watch in PILLAGERS: per-sprite fractional blits, any non-integer zoom, rotating at screen resolution, and per-frame re-rasterising of rotated procedural shapes (pixels "boil" as aim changes). Baked angle sets remove the last one.

### Gaps
- Dead Cells' outline method and palette handling are not in the Game Developer article; the Habr post (Russian) and Moran's repo were not read. [Habr post](https://habr.com/post/416589)
- No source measured the cost of a full-frame upscale drawImage in Chrome at 4K; it is believed to be GPU-cheap but unmeasured here.

## Q4. Lighting pixel art: normal-mapped sprites, palette-based lighting, muddiness, fit with Canvas 2D

### Takeaway
Normal-mapped pixel lighting (Sprite Lamp, Laigter, Dead Cells, Kiyo, Eastward's deferred shading) is a GPU shader technique; Canvas 2D has no per-pixel shader, so it would mean CPU loops over pixel data every frame. Even where it works, research and practitioners note it can fight the hand-painted shading and soften edges. For PILLAGERS the practical lighting stack is: baked 3 to 4 tone shading lit from the top left inside the sprites, plus composite-mode light and darkness layers (the Children of Morta "high-res light over pixel figures" look).

### Cited Findings
- Laigter auto-generates normal, parallax, specular and occlusion maps from a 2D diffuse image and has a real-time light preview; Sprite Lamp is for hand-drawn normal maps (paid, Windows). [Laigter docs](https://laigter.readthedocs.io/en/latest/Introduction/intro.html); [AlternativeTo: Sprite Lamp](https://alternativeto.net/software/sprite-lamp)
- A Godot developer using nearest-neighbour pixel art with normal-mapped lighting saw smoothing and blurring at light edges; the only workaround found was adjusting light height and energy. [Godot forum thread](https://forum.godotengine.org/t/low-bit-pixel-art-light-texture-on-canvastexture-sprite-has-unexpected-smoothing-blurring/129394)
- An SBGames 2022 paper notes that normal maps applied to pixel art "may not yield correct results due to the style specificities" (as summarised in search results). [arXiv 2212.09692](https://arxiv.org/abs/2212.09692); a related SIGGRAPH student project, DynaPix, pixelizes normal maps for dynamic lighting. [SFU news on DynaPix](https://sfu.ca/computing/newsandevents/2022/two-computing-science-undergraduate-projects-feature-at-siggraph.html)
- Dead Cells used normal maps from its 3D renders and a toon shader, and built a lighting system to replace costly hand-drawn shadows. [Game Developer: Dead Cells deep dive](https://www.gamedeveloper.com/production/art-design-deep-dive-using-a-3d-pipeline-for-2d-animation-in-i-dead-cells-i-)
- Kiyo: everything drawn once as 2D pixel art in Aseprite; a quick extra step supplies shape information so the engine can light it under any condition; actual 3D assets and perspective rendering are banned. [ModDB: Kiyo's modern pixel art](https://www.moddb.com/features/kiyos-modern-pixel-art-a-showcase)
- Eastward: "general deferred shading", designers add many lights and tune ambient tone (search summary). [Red Bull interview](https://www.redbull.com/my-en/eastward-interview). A forum reply judged from trailers that it probably does not use normal maps and that 2D lights on a dark scene get close; this is speculation. [itch.io post](https://itch.io/post/9044697)
- Children of Morta: Unity, dynamic lighting and specular maps; pixel animations stretched to HD so lights render at high resolution, "pixelated figures lit by real lights" (search summary). [Jump Dash Roll review](https://jumpdashroll.com/article/children-of-morta-review); [Engadget](https://www.engadget.com/2018/03/22/children-of-morta-hands-on-indie-xbox-gdc/)
- Heightmap-based 3D shadows on 2D pixel art exist as an open-source Rust renderer (lumenpyx), again GPU based. [libraries.io: lumenpyx](https://libraries.io/cargo/lumenpyx)
- MDN: avoid shadowBlur whenever possible. [MDN: Optimizing canvas](https://developer.mozilla.org/en-US/docs/Web/API/Canvas_API/Tutorial/Optimizing_canvas)

### Inferences
- Does not suit Canvas 2D at runtime: per-pixel N dot L needs a shader. A CPU version means getImageData and putImageData on the whole buffer every frame, which forces GPU readback (see Q6); not worth it for a 60 fps target.
- Why it goes muddy (reasoned from the sources): auto-generated normals from flat art give generic bevels; the light adds continuous colour values outside the limited palette; it double-shades sprites that already carry painted shading; and smooth light falloff blurs crisp pixel edges (the Godot thread).
- What fits Canvas 2D: (1) bake the 3 to 4 tone ramp shading into each part with the light fixed top-left in screen space; (2) a rim-light pass baked into the cache, not run per frame; (3) darkness and fog as a multiply or destination-out overlay and lights as "lighter" composite gradients drawn at screen resolution over the upscaled world (Children of Morta style, a deliberate mixed-resolution choice); or, to keep everything on the grid, draw the light masks into the low-res buffer and quantise light to 2 or 3 bands so lit pixels jump one ramp step instead of blending.
- Palette-based lighting (shift a pixel one step up or down its ramp in light or shadow) is the pixel-pure option; in Canvas 2D it is affordable only as pre-baked lit and unlit variants of a sprite, chosen per frame, not computed per pixel.

### Gaps
- No primary Pixpil or Dead Mage technical write-up was opened; Eastward and Children of Morta details come from interview summaries.
- The SBGames paper was not read beyond the summary quote.
- No benchmark found for a JS per-pixel lighting pass on a 480x270 buffer.

## Q5. Environments: ground tilesets, autotiling (Wang, blob 47, dual grid), breaking repetition, layering in 3/4 top-down

### Takeaway
Build the ground from a low-contrast base texture that loops on all four sides, derive transitions with a dual-grid (corner-based, 16 tiles, 6 with rotation) or blob (47) autotile, and hide repetition with variant tiles, mirrored tiles, layered partial-transparency tiles and scattered props (tufts, rocks, dirt patches) with short consistent drop shadows. Busy textures next to busy textures tire the eye; keep the ground calm so dark-outlined sprites read on top.

### Cited Findings
**Ground texture rules (Slynyrd)**
- Use 16x16 tiles ("probably the most common size"); "Anything over 32x32px seems like overkill for pixel art". Aim for "a homogenous distribution of visual weight within a tile"; let clusters wrap across edges to hide seams; mirroring gives cheap new orientations. [Slynyrd Pixelblog 20: Top Down Tiles](https://www.slynyrd.com/blog/2019/8/27/pixelblog-20-top-down-tiles)
- Same source: one grass tile is monotonous; mix flat areas with textured areas of different vegetation density and occasional flower variants; use few colours (too many blur the texture; strong contrast inside a texture is displeasing); busy next to busy is tiring, "Negative space is your friend"; check tiles in a zoomed-out preview. [Slynyrd Pixelblog 20](https://www.slynyrd.com/blog/2019/8/27/pixelblog-20-top-down-tiles)
- Same source on transitions: pair a busy texture (dry dirt) with a simple one (grass edging); key clusters may touch corner to corner but not edge to edge (noise). [Slynyrd Pixelblog 20](https://www.slynyrd.com/blog/2019/8/27/pixelblog-20-top-down-tiles)
- Pixelblog 43: base texture first, must loop on all four sides; side and corner variants are shaved from it; remove the background from partial textures and layer tiles instead of baking every combination; drop shadows conservative, on one or two wall faces following the light, never longer than one tile, all the same length regardless of wall height; 2-frame animations can convince at the right speed. [Slynyrd Pixelblog 43: Top Down Tiles Part 2](https://slynyrd.com/blog/2023/3/26/pixelblog-43-top-down-tiles-part-2)
- Grid repetition (tufts lining up) can be removed by hand-correcting small repeated details; large grass fields are broken up with cliffs and trees. [OpenGameArt grass tutorial](https://opengameart.org/content/grass)
- Commercial top-down packs advertise pattern variance to avoid repetition and dirt paths in varied shapes. [PixAdvent Grasslands pack](https://longtrailassets.itch.io/top-down-adventure-sprites-grasslands); [Box Robot Studios grass terrain](https://boxrobotstudios.itch.io/pixel-assets-grass-terrain)

**Autotiling schemes**
- Boris the Brave: dual grid draws tiles at a half-cell offset and picks each tile from the terrain at its four corners; needs 6 tiles with rotation or 16 without; simple, few tiles, extends to larger curves, borders and multiple terrains, but is hard to grasp and must handle ambiguous tiles. Quarter-tile autotiling needs 5 half-size tiles with rotation (14 to 20 without), is "substantially less effort", but cannot draw large swooping curves and "has far less variation between tiles, which can give it an artificial look". Blob precomposes to 48 tiles. [Boris the Brave: Quarter-Tile Autotiling (2023)](https://www.boristhebrave.com/2023/05/31/quarter-tile-autotiling/)
- An autotile overview page on redblobgames.com: 4-bit (cardinal) autotiling gives 16 tiles and handles inner corners poorly; 8-bit blob counts a diagonal only when both adjacent cardinals match, reducing 256 masks to 47 tiles; dual grid and 2-colour Wang sets need 16; multiple terrains via priority (a neighbour matches if equal or higher priority; draw each terrain as an overlay from lowest to highest); recompute masks only for changed cells and cache indices. Caution: this page names no author, is marked "Written 2026" and "Inspired by Red Blob Games", and sits under an /autotile/claude/ path, so it is likely an AI-written experiment rather than Amit Patel's own article; treat as secondary. [redblobgames.com autotile page](https://www.redblobgames.com/articles/autotile/claude/)
- Counts conflict slightly: 47 (Red Blob page) vs 48 (Boris); the Red Blob page explains RPG Maker's 48 as 47 unique plus one duplicate. [redblobgames.com autotile page](https://www.redblobgames.com/articles/autotile/claude/); [Boris the Brave](https://www.boristhebrave.com/2023/05/31/quarter-tile-autotiling/)
- Dual grid is credited to Oskar Stalberg; a Godot plugin's docs say it cuts required tiles from 47 to 15 (plus empty), and implementations exist for square, isometric and hex grids. [TileMapDual on GitHub](https://github.com/pablogila/TileMapDual); [5-Tile Dual-Grid AutoTiler](https://godotengine.org/asset-library/asset/4183)
- Boris the Brave has also written on generating tilesets with Stable Diffusion (relevant to the AI-assisted art lane, not read here). [Boris the Brave: tiles tag](https://boristhebrave.com/tag/tiles)

### Inferences
**Ground layer stack for PILLAGERS (bottom to top)**
1. Base grass: 2 to 4 loopable 16x16 art-px variants, low internal contrast, picked per cell by a coordinate hash (not by the map RNG).
2. Terrain transitions (grass, dirt, gravel, concrete): dual-grid 16-tile sets per pair, drawn by priority. Caution: the "6 tiles with rotation" saving only works for tiles without directional shading; rotating a tile with top-left light flips its lighting, so shaded transition tiles need all 16 drawn (mirroring only where the shading survives it).
3. Decals: dirt patches, cracks, stains, small flower clusters as transparent overlays, scattered by seeded noise with a minimum spacing, never aligned to the tile grid.
4. Scatter props: grass tufts, pebbles, rocks, each with a 1 art px dark outline on the bottom edge and a short drop shadow to the lower right (light from top left), all shadows the same length (Slynyrd rule).
5. Walls, machines and characters y-sorted on top (existing render pass).
- Bake steps 1 to 4 into large chunk canvases (for example 256x256 art px) once per raid, since the ground is static (MDN pre-render tip); per frame the ground costs one drawImage per visible chunk.
- Project-specific warning: scatter placement must use its own hash keyed by cell coordinates, not the map generator's random stream, or the seed 4242 fingerprint (ents 85/374, containers 165/593) shifts.
- Keep the ground darker and calmer than sprites so the near-black outlines and top-left highlights of pillagers stay readable over grass (Slynyrd's "busy next to busy is tiring").
- Per Slynyrd's projection notes, ground stays straight top-down (no 3/4 squash) while walls and props carry the 3/4 front faces.

### Gaps
- Boris the Brave's ambiguity-resolution article for dual grid and his full tileset classification were not read.
- No source gave numbers for scatter density (props per tile) in shipped 3/4 games.
- No source on how Zero Sievert or Moonlighter build their ground specifically.

## Q6. Performance on Canvas 2D: offscreen caches, imageSmoothingEnabled, per-frame pixel passes vs pre-baked caches

### Takeaway
Everything expensive (outlines, rim light, palette swaps, rotations, ground scatter) belongs in one-time bakes to offscreen canvases; the per-frame work should be integer-position drawImage calls into a low-res buffer plus one upscale. getImageData per frame is the main trap: making it fast with willReadFrequently forces a software canvas.

### Cited Findings
- Pre-render repeated drawing to an offscreen canvas once and copy it as needed; avoid float coordinates; do not scale in drawImage per frame; layer canvases by update rate (UI, game, background); alpha: false when no transparent backdrop is needed; batch calls; avoid shadowBlur; avoid needless state changes; avoid text rendering where possible. [MDN: Optimizing canvas](https://developer.mozilla.org/en-US/docs/Web/API/Canvas_API/Tutorial/Optimizing_canvas)
- willReadFrequently: true "will force the use of a software (instead of hardware accelerated) 2D canvas and can save memory when calling getImageData() frequently"; alpha: false lets the browser assume an opaque backdrop and speed up drawing. [MDN: HTMLCanvasElement.getContext](https://developer.mozilla.org/en-US/docs/Web/API/HTMLCanvasElement/getContext)
- imageSmoothingEnabled controls scaled image smoothing, default true. [MDN: imageSmoothingEnabled](https://developer.mozilla.org/en/docs/Web/API/CanvasRenderingContext2D/imageSmoothingEnabled)
- Sprite stacking is cheap per slice but renders every slice every frame unless optimised. [Codemagic: Flaming Stacks](https://blog.codemagic.io/flaming-stacks/)
- Phaser-era practice: recolour once per palette and store in a cached atlas. [HTML5GameDevs: Phaser 3 palette swapping](https://html5gamedevs.com/topic/36547-solved-phaser-3-palette-swapping)

### Inferences
**Do**
- Use a bake cache keyed by (part set + palette + facing + frame [+ gun angle]); fill lazily on first use and at raid start for known outfits; cap it (LRU) so memory stays bounded.
- Run the automatic outline and rim-light passes on the baked art-resolution canvas (getImageData on a 20x20 image is trivial), then cache; use a separate scratch canvas with willReadFrequently for bakes so the main game canvases stay GPU accelerated.
- For a GPU-side outline without readback (useful if anything must stay dynamic), draw the sprite's silhouette 4 times at plus or minus 1 art px offsets in the outline colour (via a source-in tinted copy), then the sprite on top. This is a common Canvas idiom, not taken from a cited source here.
- Keep the world buffer small (480x270 or 640x360) so even per-frame composite overlays (fog, darkness) cost little; draw the HUD on its own canvas.
- Round every draw position to integers in art space (MDN float rule plus grid alignment).

**Don't**
- Don't call getImageData or putImageData on the main or full-frame canvas every frame (readback stalls; willReadFrequently would push the whole game to software rendering).
- Don't rely on fill() or stroke() for art-resolution shapes (always anti-aliased, Q3); don't use shadowBlur for shadows; don't rotate or scale already-upscaled sprites; don't let camera zoom take non-integer values; don't re-rasterise procedural characters every frame once a cache exists.
- Don't ship per-frame normal-map lighting in Canvas 2D (Q4).

### Gaps
- No measured numbers found for Chrome Canvas 2D drawImage throughput, getImageData readback cost, or memory per cached canvas at these sizes; the project's own frame-cost tools would need to measure the hybrid cache before shipping.
- Whether the current test's outline and rim pass already runs per frame or once per cache entry was not checked in the game file (out of scope for this research).
