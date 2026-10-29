# 220-red-end-cards-v36 : the KIA and run over cards turned 3 older checks red between v35.98 and v36.11
Queue (JTPC Correspondent 10-28 21:40; spare PC run corpus-1028-1954 on v36.11, red there, green in corpus-1028-1659 on v35.98). Fix or retarget, MEDIUM: these are the cards he reads after every raid, and all 3 now block stable.
effort: medium (Opus high; bisect first, then a card layout fix or a retarget with pictures)

The three checks (fail text from the spare PC):
- 23.87 (his #29 and answer 33) the KIA card says KILLED BY who WITH what, and the KIA and EXTRACTED cards list DAMAGE TAKEN by source -> "DAMAGE TAKEN does not total the sentry at 60" (the card text shows SENTRY x2 -42 and an AUTOCANNON line). First suspect: v36.00 (476199d76, cw-kiafit, tighter KIA table rows for his 4K screen). If the total is still there and only the markup moved, retarget; if a source's damage is lost or split wrongly, fix the game.
- 29.47 the run over card is Panel P on the shared look (1px panel, 32px Run over, 56px score, 20px rows) -> "Run over is 32px, not 32px x 0.901": the check expects the card to scale with the window (0.901) and it drew unscaled.
- 31.77 the run over card: a 16px score label over the 56px figure -> "the label is 20px under a 50.456px figure": the figure scaled (56 x 0.901) and the label did not, or the label grew to 20px.
First find which ship turned each red (v36.00 to v36.11; the run over ones may also be v35.98 o-09 run over crown and moments landing late, or an order effect: rerun each alone in a fresh profile before working). Say per check whether the game or the check was wrong.
Check (must FAIL on v36.11 for whatever is fixed in the game): at 1080p and 4K the run over card title, label and figure all follow one scale, and the KIA DAMAGE TAKEN rows total each source's damage. Then 23.87, 29.47 and 31.77 pass alone and in their slice.
Rules: menu styling only; the v36.00 4K fit stays (the whole KIA card shows with 8 hits, no scrolling); player text lower case, $ for money, SP for score; no storage key change; seed 4242 fingerprint unchanged; looting and pickup rows are never touched. Pictures of both cards at 1080p and 4K, looked at.
TASK DONE when the 3 checks pass and it is ON HIS PC.
