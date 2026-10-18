// where the 3x inset looks, per question or per option (a key like "a01-D" overrides the question's entry).
// x,y = centre of the region in 1080 picture pixels (the frame is 1920x1080); w,h = size of the box on the page (default 640x400);
// right,top = margin from the top right corner (default 20,20). crops: a column of boxes down the right side; xs: a row of boxes along the top.
export const INSETS = {
  a01: { x: 781, y: 445, h: 450 },                                   // P1's head and the top of his shoulders
  a02: { x: 781, y: 410, h: 800, right: 10, top: 10 },               // P1 head to chest, tall (the figure grows, so the head moves up)
  a03: { x: 781, y: 455 },                                           // P1's head from above
  a04: { xs: [608, 960, 1310], y: 535, w: 480, h: 380 },             // the three figures side by side: lean, broad (hired), curved
  a05: { crops: [{ x: 781, y: 440 }, { x: 781, y: 585 }] },          // P1 head and vest, then belt and boots
  a06: { crops: [{ x: 781, y: 392 }, { x: 781, y: 640 }] },          // P1 above the head (the tag), then the feet (the ring)
  a07: { x: 958, y: 553, w: 560, h: 540 },                           // P1 whole, on the busy ground
  a08: { crops: [{ x: 800, y: 600 }, { x: 1185, y: 545 }] },         // P1's gun, then P2's backpack
  a09: { x: 800, y: 625 },                                           // P1's feet and the shadow
};
