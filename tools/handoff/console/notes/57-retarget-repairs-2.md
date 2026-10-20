# 57 retarget repairs 2 (lane a, 2026-10-20)

All seven checks PASS on HEAD (57-out4.txt, runchk on the rebuilt fixture). Fixture commits ebdc8d51, 43284dd8 (temporary dump, removed), 42676e59, a3e940f6.

- 29.31: FIXED. The cue is matched by its own text (`\S\s+backpack$`, left aligned) and the first match is kept, so the later corner label cannot overwrite it. Mutation test is built into the check: a second frame turns the real cue amber on its way to the canvas, and the detector must read amber, otherwise the check fails with "cannot fail". PASS on HEAD (grey cue, amber mutation seen).
- 27.56: FIXED. Only the HUD canvas counts (the floor's own full screen fill is on another canvas), full screen rects are left out, and every card sized rect must be at globalAlpha 0.99 or more. PASS. Not run against a broken game: a card at .94 fails by the alpha line, by reading the code.
- 29.33: FIXED. Block wide scan for colour and font-size literals is back. Debt pinned: 17 selectors (19 rules) and 20 literal tokens; a new selector with a literal fails, and more tokens than 20 fails. The check also proves its scan sees a planted `#fff` rule. PASS. Follow-up token pass (not done here, no restyling): the 19 rules are the #root #hub rules at dark_raiders.html 2009, 2187, 2198-2201 (the long stash label list), 2202, 2204-2205, 2210-2213, 2223-2225; settings/keys at 2064 and the mask at 2149 (#000); pause 2094 (#pausefb 26px line height); codex 2180-2182 (24, 18, 16px).
- 20.95: FIXED (comments only). Claim held: 960 comes from v32.52, #srkitcol from v32.46. Comment added on the mapWidth line and the d: string corrected. o-02-corpus-green.md not edited (not my file).
- 24.37: FIXED (comment only). The refuted vest comment is replaced by the head scale reason.
- 26.54: FIXED. Claim held. Top 0 and the 4px gap are allowed only for the rail; a strip wider than 0.6 of the list must keep top -3px and the 1.6px bound. PASS.
- 27.75: FIXED. Claim held. Only a data-go button is skipped; a chip without data-sec fails; fewer than 3 chips tested fails. PASS.
