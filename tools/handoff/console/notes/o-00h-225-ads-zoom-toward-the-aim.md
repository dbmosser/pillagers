
--- codex run 2026-10-29 00:10 ---
2026-10-29, first implementation run, starting v36.28.

Prepared cw-cx-aimfocus. Only the render camera changes. The hip camera retains the existing player anchor, screen lean, zoom settings and world clamp. ADS uses a world focal point halfway along mouse aim, 60 percent for optics of 2.5 or more. Pad focus uses the aim angle and the existing chosen aim reach. The local G.player drives every view; no shared-camera or network rules change.

The task asks for both a halfway pivot and an unchanged aimed ground point. A literal halfway zoom pivot cannot preserve the target under a stationary cursor. The solver therefore calibrates the focal point's screen slot at entry, then eases the world focus as aim moves. This keeps the original mouse target fixed during the zoom and reverses the zoom on release. Pad framing centres toward the partial world focus and reprojects its endpoint through the camera in the same frame. The existing 11/second zoom ease and 9/second camera ease are retained.

The ADS camera clamps the pillager to the middle 76 percent before applying the existing world clamp. At the extreme map boundary, an existing world-clamp limit can take priority over the approximate 12 percent player margin; both constraints cannot always hold when the permitted outside-world padding is only 80 world units. No world boundary rule changed.

Validation available in the sandbox: mk prints written; both anchors match once; all patched inline scripts and the new fixture check parse; all output is ASCII. validate-camera.cjs evaluates the actual new helper and the actual old camera block with numerical projection inputs. With the cursor 400px right of the pillager, the old camera drifts 153.43px at the gate size. New entry, settled ADS and release stay within floating-point precision for unscoped, 2x, 2.5x and 4x at 1888x977, 1920x1080 and 3840x2160. Hip framing returns. A 1000-frame rotating pad/moving player audit stays finite and inside the safety margin. This is a numerical audit, not the browser fixture gate. ESLint dependencies are absent in this worktree; the lane must run its normal lint/preflight gates.

The shipped regression uses real __frame calls and mouseWorld/w2s projections, tests the 400px target case for host and join roles, unscoped and 4x, unchanged hip framing and release, pad endpoint alignment, 60 percent long-gun focus, reduced effects, and diagonal edge aim. No older checks need retargeting. The seed 4242 simulation fingerprint remains the lane gate's responsibility.

Six camera recipes are ready: player 1 hip, unscoped ADS, 4x ADS, pad ADS; player 2 2x ADS and hip. They use separate fixture pages (including the existing p2 URL) and freeze simulation only inside those camera pages. They cover host/join rendering, not a live connected two-window network session. The static sentry marks the aimed ground point. Custom recipes have no before pictures under the lane protocol.

The exact requested watch line is in the draft why text so the normal generated DESIGN entry includes it: aiming zooms toward the crosshair; watch that it never feels seasick and your pillager never leaves the screen.

Still required from the lane: preflight, ship, seed/regression gates, ON HIS PC confirmation, six pictures and critic review. Do not mark this task done yet.

