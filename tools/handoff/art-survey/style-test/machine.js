// machine.js : the style test's machine, the small orange tank of his 10-20 pixel-art reference (crops/ref-tank.png).
// paintPixelMachine(ctx, x, y, scale): (x, y) is the centre of the bottom of the treads on the ground, in screen px.
// The tank is drawn once at art-pixel size (53 x 48 art px, cols 0..52, on a 56 x 52 canvas with a 2 px margin), cached, then put on
// screen at a whole-number scale with no smoothing. Needs pix.js (global PIX). Light from the top left.
(function () {
  var OUT = '#16121c';                                               // outline, near black
  var GM = ['#a9aeb6', '#8e939c', '#686c76', '#43464f', '#2a2c33'];  // gunmetal: top light, hi, base, shade, deep
  var DK = '#1e1f25';                                                // tread insides
  var OR = ['#ffa04a', '#e86a1c', '#b4461a', '#7a2c14'];             // orange: hi, base, shade, deep
  var RD = ['#e0503a', '#c4302a', '#8e1f1c', '#5c1616'];             // red-orange plate: hi, base, shade, deep
  var YL = '#ffc21e', YLD = '#e0a019', STK = '#2b2026';              // hazard yellow, its shade, the dark stripe
  var SPEC = '#eef1f4';                                              // bright specular pixels
  var M = 2;                                                         // margin: art (0,0) is canvas (2,2)
  var W = 56, H = 52, AX = 32, AY = 50;                              // canvas size; anchor (tread bottom centre) in canvas px
  var s;

  function R(col, x, y, w, h) { PIX.rect(s, col, x + M, y + M, w, h); }
  function P(col, x, y) { PIX.px(s, col, x + M, y + M); }
  function clr(x, y) { s.x.clearRect(x + M, y + M, 1, 1); }
  // ellipse inscribed in the box [x, x+w) x [y, y+h), whole pixels; fn(nx, ny) picks the colour (nx, ny in -1..1)
  function ell(x, y, w, h, fn) {
    var cx = x + w / 2, cy = y + h / 2, rx = w / 2, ry = h / 2, a, b, nx, ny, c;
    for (b = y; b < y + h; b++) for (a = x; a < x + w; a++) {
      nx = (a + 0.5 - cx) / rx; ny = (b + 0.5 - cy) / ry;
      if (nx * nx + ny * ny > 1.04) continue;
      c = typeof fn === 'string' ? fn : fn(nx, ny);
      if (c) P(c, a, b);
    }
  }
  // 4-tone shading by direction to the top-left light
  function lit(T) { return function (nx, ny) { var l = -(nx + ny) * 0.7071; return l > 0.42 ? T[0] : l > -0.22 ? T[1] : l > -0.72 ? T[2] : T[3]; }; }
  // stadium (a bar with round ends) in the box [x, x+w) x [y, y+h)
  function stadium(x, y, w, h, col) {
    var r = h / 2, c0 = x + r, c1 = x + w - r, a, b, dx, dy;
    for (b = y; b < y + h; b++) for (a = x; a < x + w; a++) {
      dy = b + 0.5 - (y + r); dx = a + 0.5 < c0 ? a + 0.5 - c0 : (a + 0.5 > c1 ? a + 0.5 - c1 : 0);
      if (dx * dx + dy * dy <= r * r + 0.3) P(col, a, b);
    }
  }
  // diagonal hazard stripes ("/"), period 4: 2 yellow, 2 dark; the last row of yellow a touch darker
  function hazard(x, y, w, h, dark) {
    for (var b = y; b < y + h; b++) for (var a = x; a < x + w; a++) {
      var k = ((a + b) % 4 + 4) % 4;
      P(k < 2 ? (b === y + h - 1 ? YLD : YL) : dark, a, b);
    }
  }
  // box outline with the corners left clear, then a fill
  function rbox(x, y, w, h, col) { R(OUT, x + 1, y, w - 2, h); R(OUT, x, y + 1, w, h - 2); if (col) R(col, x + 1, y + 1, w - 2, h - 2); }

  function treads() {
    // art cols 9..50, rows 36..47, round ends
    stadium(9, 36, 42, 12, OUT);
    stadium(10, 37, 40, 10, DK);
    // top run (row 37, just under the fender) and bottom run (row 46, just above the outline): links, 2 dark then 1 lit
    for (var a = 13; a <= 46; a++) { P(a % 3 === 1 ? GM[3] : DK, a, 37); P(a % 3 === 2 ? GM[3] : DK, a, 46); }
    // links around the round ends
    [[10, 40], [10, 43], [11, 38], [11, 45], [49, 40], [49, 43], [48, 38], [48, 45]].forEach(function (p) { P(p[0] < 30 ? '#5a5e68' : GM[3], p[0], p[1]); });
    // idlers at each end (behind the road wheels)
    [10, 43].forEach(function (x) { ell(x, 38, 7, 7, OUT); ell(x + 1, 39, 5, 5, lit([GM[2], GM[3], GM[4], GM[4]])); P(GM[1], x + 3, 41); });
    // four road wheels, 9 art px across (odd, so the hub has a true centre), neighbours share an outline column
    [13, 21, 29, 37].forEach(function (x) {
      ell(x, 37, 9, 9, OUT);
      ell(x + 1, 38, 7, 7, function (nx, ny) {                              // rim: lit by direction, a bright arc on the top left
        var l = -(nx + ny) * 0.7071, d = nx * nx + ny * ny;
        if (d > 0.42 && l > 0.5) return GM[0];
        return l > 0.3 ? '#9aa0a8' : l > -0.3 ? '#6e727c' : l > -0.7 ? GM[3] : GM[4];
      });
      ell(x + 2, 39, 5, 5, OUT);                                            // dark gap between rim and hub
      R(GM[4], x + 3, 40, 3, 3); P(GM[3], x + 3, 40); P(GM[1], x + 4, 41);  // 3x3 hub, light centre
      P(SPEC, x + 2, 39);                                                   // glint on the rim
    });
  }

  function hull() {
    // orange hull, art cols 16..49, rows 16..31 (the fender covers its foot)
    R(OUT, 16, 16, 34, 16);
    R(OR[1], 17, 17, 32, 14);
    R(OR[0], 17, 17, 32, 2);                          // lit top plane under the turret
    R('#ffc07a', 26, 17, 18, 1);                      // its sunlit edge
    R(OR[3], 17, 19, 32, 1);                          // fold between top and front
    R(OR[2], 17, 27, 32, 4);                          // shade near the fender
    R(OR[2], 46, 20, 3, 7);
    // hazard panel on the hull front
    R(OR[3], 34, 20, 11, 7); hazard(35, 21, 9, 5, STK);
    // grey bracket under the armour plate
    R(OUT, 16, 25, 11, 7); R(GM[2], 17, 26, 9, 5); R(GM[1], 17, 26, 9, 1); R(GM[3], 17, 29, 9, 2); P(GM[0], 18, 26); P(GM[4], 24, 28);
    // grey post on the right with a bolt
    R(OUT, 45, 21, 5, 11); R(GM[2], 46, 22, 3, 9); R(GM[1], 46, 22, 3, 1); R(GM[1], 46, 22, 1, 8); R(GM[3], 48, 23, 1, 8);
    P(GM[0], 47, 24); P(GM[4], 47, 25);
  }

  function fender() {
    // orange fender over the treads, art cols 10..51, rows 30..36, chamfered top corners
    R(OUT, 10, 30, 42, 7);
    R(OR[1], 11, 31, 40, 5);
    R(OR[0], 11, 31, 40, 1); R('#f58a32', 11, 32, 40, 1);   // top plane
    R(OR[2], 11, 35, 40, 1);                                 // shade at the lip
    hazard(12, 33, 10, 2, STK); hazard(40, 33, 10, 2, STK);
    clr(10, 30); clr(11, 30); clr(10, 31); P(OUT, 11, 31); P(OUT, 12, 30);
    clr(51, 30); P(OUT, 50, 31);
    P(OR[3], 50, 34); P(OR[3], 50, 35);
    // the two ends curve down 2 px over the round ends of the treads, like a mudguard
    R(OUT, 10, 36, 3, 3); clr(12, 38); P(OR[2], 11, 36); P(OR[3], 11, 37); P(OR[2], 12, 36);
    R(OUT, 49, 36, 3, 3); clr(49, 38); P(OR[3], 50, 36); P(OR[3], 50, 37); P(OR[3], 49, 36);
    P(OR[0], 11, 32); P(OR[1], 11, 33); P(OR[1], 11, 34);                   // the left end catches the light
    P('#ffd8a0', 14, 31); P('#ffd8a0', 15, 31); P('#ffd8a0', 44, 31);
  }

  // direction to the top-left light for a point (nx, ny) on a disc: 1 facing the light, -1 facing away
  function toLight(nx, ny) { var d = Math.sqrt(nx * nx + ny * ny) || 1e-6; return -(nx + ny) / (d * 1.4142); }
  var OX = 24, OY = 21, OD = 16;                       // orb housing box: art cols 24..39, rows 21..36, centre (32, 29)
  function orb() {
    ell(OX, OY, OD, OD, OUT);
    // grey housing ring, 2 px: the outer pixel carries a bright arc top left and a deep arc bottom right,
    // the inner pixel is the lip (shaded at the top left, warm orb light on the bottom right)
    ell(OX + 1, OY + 1, OD - 2, OD - 2, function (nx, ny) {
      var d = nx * nx + ny * ny, l = toLight(nx, ny);
      if (d > 0.74) return l > 0.55 ? GM[0] : l > 0 ? GM[1] : l > -0.55 ? GM[3] : GM[4];
      return l > 0.35 ? GM[3] : l > -0.35 ? GM[2] : '#a8622a';
    });
    // the orb, 10 px: emissive, a pale core high and left, amber body, a dark socket line top left, deep orange bottom right
    ell(OX + 3, OY + 3, OD - 6, OD - 6, function (nx, ny) {
      var dx = nx + 0.25, dy = ny + 0.3, d = Math.sqrt(dx * dx + dy * dy), r = Math.sqrt(nx * nx + ny * ny), l = toLight(nx, ny);
      if (r > 0.8) return l > 0.25 ? OUT : (l < -0.5 ? OR[2] : OR[1]);
      if (d < 0.34) return '#fff6c4';
      if (d < 0.64) return '#ffe066';
      return '#ffb21e';
    });
    P('#ffffff', OX + 5, OY + 5); P('#ffffff', OX + 6, OY + 5); P('#ffffff', OX + 5, OY + 6); // glint
    P('#fff6c4', OX + 10, OY + 10);                                                         // bounce light
    // sparse glow on the fender around the housing
    [[23, 31], [24, 33], [26, 35], [40, 31], [39, 33], [37, 35]].forEach(function (p) { P('#ffb21e', p[0], p[1]); });
  }

  function turret() {
    // boxy turret, art cols 26..43, rows 3..18
    rbox(26, 3, 18, 16, GM[2]);
    clr(43, 4); P(OUT, 42, 4);                        // chamfer, top right
    R(GM[1], 27, 4, 15, 4);                           // top plane
    R(GM[0], 27, 4, 15, 1);                           // its lit edge
    R('#9aa0a8', 27, 8, 16, 1);                       // edge where top meets front
    R('#767a84', 27, 9, 4, 7); R('#5e626c', 37, 9, 4, 7); // front face: lighter left, darker right
    R(GM[3], 41, 9, 2, 9); R(GM[4], 42, 10, 1, 8);    // shade on the right
    R(GM[3], 27, 16, 16, 2); R(GM[4], 27, 17, 16, 1); // shade at the bottom
    R(GM[3], 35, 10, 1, 6); R(GM[1], 36, 10, 1, 6);   // panel seam
    P(GM[0], 33, 13); P(GM[4], 34, 14); P(GM[0], 38, 11); P(GM[4], 39, 12); P(GM[0], 38, 14); P(GM[4], 39, 15); // bolts
    R(GM[3], 31, 5, 5, 2); R(GM[2], 32, 5, 3, 1);     // hatch on the top plane
    // round the top-left corner with a 3-step staircase (cols 26..29, rows 3..5)
    clr(26, 3); clr(27, 3); clr(28, 3); clr(26, 4); clr(27, 4); clr(26, 5);
    P(OUT, 28, 4); P(OUT, 27, 5);                     // (row 5 and below sit behind the cannon)
    P(SPEC, 30, 4); P(SPEC, 31, 4);
    // bright patch on the upper left of the front face (the part the cannon does not hide), one specular pixel
    R(GM[1], 32, 11, 3, 1); R(GM[0], 32, 9, 3, 2); P(SPEC, 32, 9); P(GM[1], 35, 9); R(GM[0], 32, 8, 2, 1);
  }

  function topBits() {
    // periscope with a red-orange light, art cols 35..41, rows 0..4
    rbox(35, 0, 7, 5, GM[2]);
    R(GM[0], 36, 1, 5, 1); R(GM[3], 36, 3, 5, 1);
    P('#ff6a2a', 39, 2); P('#ffd08a', 38, 2); P(OR[3], 40, 2);
    // small knob, art cols 29..31, rows 1..4
    rbox(29, 1, 3, 4, null); P(GM[1], 30, 2); P(GM[3], 30, 3);
  }

  function cylinder() {
    // big short cannon on the turret front-left: body cols 19..31, rows 5..16, end face on the left
    R(OUT, 19, 5, 13, 12);
    // round body: a lit band along the top (row 6), a bright streak just under it, then a steady fall to the deep shade
    var band = [GM[0], '#c4c8ce', '#8e939c', '#6e727c', '#5a5e68', '#4e525b', '#43464f', '#3a3d45', '#2a2c33', '#2a2c33'];
    for (var i = 0; i < 10; i++) R(band[i], 20, 6 + i, 11, 1);
    P(SPEC, 22, 7); P(SPEC, 23, 7);
    R(GM[4], 27, 6, 1, 10); R(GM[1], 28, 6, 1, 2); R(GM[3], 28, 8, 1, 7);  // ring groove
    // end face (left): a lit ring with a big dark bore
    ell(15, 5, 8, 12, OUT);
    ell(16, 6, 6, 10, lit(['#a9aeb6', '#7c808a', '#555963', GM[3]]));
    ell(17, 8, 4, 6, OUT);
    P(GM[3], 19, 12); P(GM[4], 19, 11);               // lip inside the bore catches light (bottom right)
    P(SPEC, 17, 7); P(SPEC, 18, 6);
  }

  function pod() {
    // 4-tube rocket pod on the turret's right side, art cols 40..52, rows 5..18: a lit top strip, then 2 x 2 tubes
    rbox(40, 5, 13, 14, GM[1]);                                        // lighter frame so the dark tubes stand apart
    R(GM[0], 42, 6, 9, 1); P(GM[0], 41, 7); P(GM[2], 51, 6);           // lit top edge
    [[41, 7], [47, 7], [41, 13], [47, 13]].forEach(function (h) {
      var x = h[0], y = h[1], lo = y === 13;
      R(GM[2], x, y, 5, 5); P(GM[3], x + 1, y); P(GM[3], x, y + 1);      // 5 x 5 tube ring: a soft bevel, deepest at the top-left corner
      P(GM[1], x, y); P(GM[1], x + 4, y); P(GM[1], x, y + 4); P(GM[1], x + 4, y + 4); // corners back to the frame: a round ring
      R(GM[0], x + 1, y + 4, 3, 1); R(GM[0], x + 4, y + 1, 1, 3);      // inner lip lit at the bottom right
      if (lo) { R(GM[1], x + 1, y + 4, 3, 1); P(GM[2], x + 4, y + 4); } // the low tubes sit nearer the shaded foot
      R(OUT, x + 1, y + 1, 3, 3);                                      // 3 x 3 dark mouth,
      P(GM[4], x + 1, y + 1); P(GM[4], x + 3, y + 1); P(GM[4], x + 1, y + 3); P(GM[3], x + 3, y + 3); // its corners softened so it reads round
    });
    R(GM[2], 46, 13, 1, 5); R(GM[2], 47, 12, 5, 1);                    // frame shaded to the lower right
    P(SPEC, 42, 6); P(SPEC, 43, 6);
  }

  function barrel() {
    // long dark barrel to the left: tube cols 5..14, rows 18..24
    R(OUT, 5, 18, 10, 7);
    R(GM[1], 6, 19, 9, 1); R(GM[2], 6, 20, 9, 1); R(GM[3], 6, 21, 9, 1); R(GM[4], 6, 22, 9, 2);
    for (var a = 7; a <= 13; a += 3) P(SPEC, a, 19);
    // wide muzzle ring, cols 1..7, rows 16..26
    rbox(2, 16, 6, 11, null);
    var band = ['#9aa0a8', '#8e939c', '#686c76', '#686c76', '#5a5e68', '#4e525b', '#43464f', '#2a2c33', '#2a2c33'];
    for (var i = 0; i < 9; i++) R(band[i], 3, 17 + i, 4, 1);
    R(OUT, 5, 17, 1, 9);                              // groove between the two rings
    P(SPEC, 6, 17);
    // end face (left): lit ring and dark bore
    ell(0, 16, 5, 11, OUT);
    ell(1, 17, 3, 9, lit(['#a9aeb6', '#7c808a', '#555963', GM[3]]));
    R(OUT, 1, 19, 2, 5); P(GM[3], 2, 23);
    P(SPEC, 2, 17);
  }

  function plate() {
    // red-orange armour plate on the turret front-left: cols 12..26, rows 15..27, top-left corner cut
    R(OUT, 12, 15, 15, 13);
    R(RD[1], 13, 16, 13, 11);
    R('#ec6a48', 13, 16, 13, 2);                      // top plane
    R('#f6a080', 16, 16, 8, 1);                       // its lit edge
    R(RD[3], 13, 18, 11, 1);                          // fold between the top and the front
    R('#d8402e', 13, 19, 10, 3);                      // upper front catches more light
    R(RD[0], 13, 19, 1, 7); R('#f08060', 14, 19, 3, 1); // lit left edge and a glint
    R(RD[2], 23, 18, 3, 9); R(RD[3], 25, 18, 1, 9);   // side face, in shade
    R(RD[2], 13, 25, 10, 2); R(RD[3], 14, 26, 9, 1);  // shade at the bottom
    R(RD[3], 18, 21, 1, 3); R('#e86a54', 19, 21, 1, 3); // a vertical crease
    // cut corner, top left
    clr(12, 15); clr(13, 15); clr(14, 15); clr(12, 16); clr(13, 16); clr(12, 17);
    P(OUT, 15, 15); P(OUT, 14, 16); P(OUT, 13, 17); P(OUT, 12, 18);
    P('#ec6a48', 14, 17);
    // two bolts
    P('#f6a080', 21, 20); P(RD[3], 22, 21); P('#f6a080', 15, 23); P(RD[3], 16, 24);
    // collar where the barrel goes in
    R(OUT, 11, 18, 2, 7); R(GM[3], 11, 19, 1, 5); P(GM[1], 11, 19);
  }

  function build() {
    s = PIX.canvas(W, H);
    // the orb goes last: it sits on the hull front, in front of the plate's lower corner
    treads(); hull(); fender(); turret(); topBits(); cylinder(); pod(); barrel(); plate(); orb();
    PIX.harden(s);
    return s;
  }

  // solid dark oval under the treads, whole art-pixel rows, shifted 2 px right (light from the top left),
  // with a darker core. Rows count from the anchor row: the tread bottom is art row 47 = row -1, so rows -5..1 end 2 px below it.
  function oval(ctx, x, y, sc, cx, top, hw, hgt, col) {
    ctx.fillStyle = col;
    for (var k = 0; k < hgt; k++) {
      var ny = (k + 0.5 - hgt / 2) / (hgt / 2), w = Math.round(hw * Math.sqrt(Math.max(0, 1 - ny * ny)));
      if (w > 0) ctx.fillRect(Math.round(x + (cx - w) * sc), Math.round(y + (top + k) * sc), w * 2 * sc, sc);
    }
  }
  function shadow(ctx, x, y, sc) {
    ctx.save();
    oval(ctx, x, y, sc, 2, -5, 26, 7, 'rgba(12,16,8,0.45)');
    oval(ctx, x, y, sc, 2, -4, 20, 5, 'rgba(12,16,8,0.25)');
    ctx.restore();
  }

  var cache = null;
  window.paintPixelMachine = function paintPixelMachine(ctx, x, y, scale) {
    var sc = Math.max(1, Math.round(scale || 4));
    if (!cache) cache = build();
    shadow(ctx, x, y, sc);
    PIX.blit(ctx, cache, x - AX * sc, y - AY * sc, sc);
  };
})();
