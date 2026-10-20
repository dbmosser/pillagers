# Code sweep (chunks of 200 lines, model qwen2.5-coder:14b, 10-20 03:25, since abf82a29)

LINE 39421: calls or reads of names from removed systems (wallSprite)
LINE 39458: possible NaN or undefined values reaching canvas calls (arc, createRadialGradient, drawImage, fillText positions) - p.face could be undefined
LINE 39467: a try/catch that swallows a whole per-frame draw or update
LINE 39501: property access on a value that can be null or undefined in per-frame code without a guard (e2.kind)
LINE 39582: a try/catch that swallows a whole per-frame draw or update
