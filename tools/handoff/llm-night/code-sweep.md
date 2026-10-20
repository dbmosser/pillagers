# Code sweep (chunks of 200 lines, model qwen2.5-coder:14b, 10-20 02:05, since c2a7b924)

LINE 18401: try/catch that swallows a whole per-frame draw or update.
LINE 18457: calls clamp without checking if W and H are defined, which could lead to NaN values reaching canvas calls (arc, createRadialGradient, drawImage, fillText positions).
LINE 18463: calls clamp without checking if x and y are defined, which could lead to NaN values reaching canvas calls (arc, createRadialGradient, drawImage, fillText positions).
LINE 18502: property access on a value that can be null or undefined in per-frame code without a guard (PAD.held[c]).
LINE 18569: property access on a value that can be null or undefined in per-frame code without a guard (G&&!G.over&&!G.sim&&state==='raid').
