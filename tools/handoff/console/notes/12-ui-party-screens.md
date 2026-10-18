# 12-ui-party-screens notes
Before shots: notes/shots/12-before2 (all 13, 1080, current build after S1). 53/54 stage the raid HUD, not the initials card (staging gap; do not chase).
Findings: 52/55 Run over plain; 56/46/64 attract card; 58 P2 title orange paragraph; 49 pause sparse w/ sentence.
DONE: S1 cw-party-op SHIPPED v29.44 (62/63). Fixture retargeted. Lesson: computed px under zoom 639.987, use abs()<1.
Run over strings asserted by old checks: restyle only. Text displays sentence-case already via CSS.
S2 cw-party-over: mk script S/mk-cw-party-over.ps1 (CSS after arcstrip line ~1461; overrides #attract .arcover injected at arcadeOverEl ~60471). NEXT: preflight a, ship.
Then S3 pause 49, S4 coop P2 title 58, S5 attract 46/56/64 (shared css lines ~1438-1461 arcpage). Tokens: fs-hero 56 title 32 body 20 label 16, sp 8/16/24/32/48, btn-h 56, menu-w 560.
Pattern: mk-cw-party-op.ps1 (function replace) / mk-cw-party-over.ps1 (css insert).
