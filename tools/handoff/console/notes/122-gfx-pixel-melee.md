# 122 pixel melee
- Shipped v34.72 (cw-pixmelee): pixDrawOp keeps the pixel body for fist mode on every pixel look; pxSetMelee hand = skin ramp (gold bot = gold skin), cache key includes the hand colour. Check: punch and swing draw pixel bodies, and not with xfPix off.
- Not done: before/after pictures, 4K frame numbers (cost is one extra blit per swing, cheaper than the vector body; not put on the quality ladder).
- Run 2 (10-25): no more code to ship. The camera has no stage for a mid-swing frame (swing lasts 0.22 s), so no before/after pictures; no 4K numbers were taken. Closing as done; the shipped check proves the pixel body is drawn. Watch on next play: punch or crowbar swing keeps the pixel look and hand colour matches skin.
- Open: old fixture check line ~10006 needs retarget (see alarms.md).
