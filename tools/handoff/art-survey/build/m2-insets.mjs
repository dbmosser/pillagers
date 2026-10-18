// where the 3x boxes look, per option of the machine questions (second pass). x,y = centre of the region in the 1080 frame; w,h = the box on the page; l,t = its left and top on the page.
export const SETS = {
  // three machines of three colours, side by side above the row: the blue sentry, the red crawler, the yellow crier
  'a24-D': { screen: 'm-lineup', crops: [{ x: 203, y: 335, w: 360, h: 270, l: 20, t: 10 }, { x: 361, y: 400, w: 360, h: 270, l: 388, t: 10 }, { x: 503, y: 372, w: 360, h: 270, l: 756, t: 10 }] },
  // four machines of four lens colours, side by side in the free strip above the row: the crawler (amber), the crier (lime), the howler (violet), the listener (magenta)
  'a25-B': { screen: 'm-lineupmood', crops: [{ x: 329, y: 392, w: 360, h: 270, l: 20, t: 10 }, { x: 503, y: 342, w: 360, h: 270, l: 392, t: 10 }, { x: 825, y: 380, w: 360, h: 270, l: 764, t: 10 }, { x: 1010, y: 305, w: 360, h: 270, l: 1136, t: 10 }] },
  // the four size settings share one box: the warden tank (a tank in every setting) at 3x, in the empty strip above the row
  'a26-A': { screen: 'm-lineupbig', crops: [{ x: 1412, y: 455, w: 560, h: 330, l: 20, t: 10 }] },
  'a26-B': { screen: 'm-lineupbig', crops: [{ x: 1412, y: 455, w: 560, h: 330, l: 20, t: 10 }] },
  'a26-C': { screen: 'm-lineupbig', crops: [{ x: 1412, y: 455, w: 560, h: 330, l: 20, t: 10 }] },
  'a26-D': { screen: 'm-lineupbig', crops: [{ x: 1412, y: 455, w: 560, h: 330, l: 20, t: 10 }] },
  // the fights: two boxes in the empty bottom-left corner, one on each machine
  'a27-B': { screen: 'm-fightwind', crops: [{ x: 1440, y: 462, w: 520, h: 300, l: 20, t: 760 }, { x: 1275, y: 590, w: 520, h: 300, l: 570, t: 760 }] },
  'a27-C': { screen: 'm-fightwind', crops: [{ x: 1440, y: 462, w: 520, h: 300, l: 20, t: 760 }, { x: 1275, y: 590, w: 520, h: 300, l: 570, t: 760 }] },
  'a28-C': { screen: 'm-fightdead', crops: [{ x: 1540, y: 487, w: 520, h: 300, l: 20, t: 760 }, { x: 1235, y: 635, w: 520, h: 300, l: 570, t: 760 }] },
  'a28-D': { screen: 'm-fightdead', crops: [{ x: 1350, y: 380, w: 520, h: 300, l: 20, t: 760 }, { x: 1500, y: 570, w: 520, h: 300, l: 570, t: 760 }] },
};
