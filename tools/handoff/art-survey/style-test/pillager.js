// pillager.js : the red-hood pillager for the pixel-art style test (his 10-20 reference, ref-his-lineup.webp).
// paintPixelPillager(ctx, x, y, scale, look)
//   (x, y) = the ground point between the feet, in screen px; scale = whole screen px per art pixel (4 for the lineup, 2 still reads);
//   look   = optional colours {hood, pads, suit, stock, skin, hair} ('#rrggbb'), defaults from the reference.
// How: the figure is built at art-pixel size (52 x 66) from parts drawn back to front. Each part is a whole-pixel mask shaded in
// 4 tones by its place along the light (top left), with hand-placed folds, specular pixels and the face grid on top; a dark line
// is laid where a part sits over an earlier one; then PIX.harden + PIX.outline give the dark silhouette and PIX.blit puts it on
// screen with no smoothing. The result is cached per look. Needs pix.js (global PIX).
(function () {
  var W = 52, H = 66, AX = 27, AY = 63;          // art canvas size; anchor (between the feet) in art px
  var OUT = '#16121c', LINE = '#1c1622';          // outer outline, inner lines between parts
  var DEF = { hood: '#c4302a', pads: '#c4302a', suit: '#43464f', stock: '#e8901c', skin: '#eeb08a', hair: '#a8482a' };
  var HAND = { // hand-picked ramps for the reference colours: highlight, base, shade, deep shade
    '#c4302a': ['#e4553a', '#c4302a', '#8e1f1c', '#561420'],
    '#43464f': ['#686c76', '#43464f', '#2a2c33', '#1c1d23'],
    '#e8901c': ['#ffc23a', '#e8901c', '#b0561a', '#6e3012'],
    '#eeb08a': ['#fdd6b6', '#eeb08a', '#c87c5c', '#8e4a3c'],
    '#a8482a': ['#f08a46', '#a8482a', '#6e2a1a', '#44170f']
  };
  var FIX = {
    vest: ['#50535c', '#34363e', '#25262c', '#18181d'],
    pouch: ['#7c6e50', '#5a4e38', '#3e3628', '#2a241c'],
    pack: ['#726040', '#54452e', '#3a3022', '#272018'],
    metal: ['#5c606a', '#34363e', '#232429', '#141418'],
    boot: ['#4c4e58', '#30323a', '#212228', '#141418'],
    knee: ['#6c705e', '#4c5044', '#363a30', '#24271f'],
    amber: ['#ffe07a', '#ffb21e', '#c47a10', '#7a4a0c']
  };
  var MASKHAND = { '#c4302a': ['#ec6a48', '#d8402e', '#a8281f'] }; // the cloth mask: one step brighter and warmer than the hood
  var cache = {};

  // ---- colour ramps (any base colour -> 4 tones, highlights lean warm, shades lean cool) ----
  function hsl(hex) {
    var n = parseInt(hex.slice(1), 16), r = (n >> 16) / 255, g = ((n >> 8) & 255) / 255, b = (n & 255) / 255;
    var mx = Math.max(r, g, b), mn = Math.min(r, g, b), l = (mx + mn) / 2, d = mx - mn, h = 0, s = 0;
    if (d > 0) { s = d / (1 - Math.abs(2 * l - 1)); h = mx === r ? ((g - b) / d) % 6 : mx === g ? (b - r) / d + 2 : (r - g) / d + 4; h *= 60; if (h < 0) h += 360; }
    return [h, s, l];
  }
  function hex(h, s, l) {
    h = ((h % 360) + 360) % 360; s = Math.max(0, Math.min(1, s)); l = Math.max(0, Math.min(1, l));
    var c = (1 - Math.abs(2 * l - 1)) * s, x = c * (1 - Math.abs((h / 60) % 2 - 1)), m = l - c / 2;
    var t = [[c, x, 0], [x, c, 0], [0, c, x], [0, x, c], [x, 0, c], [c, 0, x]][Math.floor(h / 60) % 6];
    return '#' + t.map(function (v) { var q = Math.round((v + m) * 255).toString(16); return q.length < 2 ? '0' + q : q; }).join('');
  }
  function toward(h, to, deg) { var d = ((to - h + 540) % 360) - 180; return h + Math.max(-deg, Math.min(deg, d)); }
  function ramp(col) {
    col = String(col).toLowerCase(); if (HAND[col]) return HAND[col];
    var q = hsl(col), h = q[0], s = q[1], l = q[2];
    return [hex(toward(h, 50, 8), s * 1.1, l + 0.12), col, hex(toward(h, 260, 7), s, l * 0.66), hex(toward(h, 260, 14), s * 0.85, l * 0.4)];
  }
  function maskRamp(col) {
    col = String(col).toLowerCase(); if (MASKHAND[col]) return MASKHAND[col];
    var q = hsl(col), r = ramp(hex(toward(q[0], 25, 6), q[1], q[2] + 0.07));
    return [r[0], r[1], r[2]];
  }
  // where a pixel centre sits on a bar from (x0, y0) to (x1, y1): t along it (0..1), d across it (+ = the upper, screen-right side)
  function barAt(x0, y0, x1, y1) {
    var dx = x1 - x0, dy = y1 - y0, L = Math.sqrt(dx * dx + dy * dy), nx = dy / L, ny = -dx / L;
    return function (x, y) { var px = x + 0.5 - x0, py = y + 0.5 - y0; return { t: (px * dx + py * dy) / (L * L), d: px * nx + py * ny }; };
  }

  // ---- whole-pixel masks (pixel centres decide what is in) ----
  function M() { return new Uint8Array(W * H); }
  function inb(x, y) { return x >= 0 && y >= 0 && x < W && y < H; }
  function mrect(m, x0, y0, x1, y1) { for (var y = y0; y <= y1; y++) for (var x = x0; x <= x1; x++) if (inb(x, y)) m[y * W + x] = 1; return m; }
  function mell(m, x0, y0, x1, y1) {
    var cx = (x0 + x1 + 1) / 2, cy = (y0 + y1 + 1) / 2, rx = (x1 - x0 + 1) / 2, ry = (y1 - y0 + 1) / 2;
    for (var y = y0; y <= y1; y++) for (var x = x0; x <= x1; x++) { var u = (x + 0.5 - cx) / rx, v = (y + 0.5 - cy) / ry; if (u * u + v * v <= 1.04 && inb(x, y)) m[y * W + x] = 1; }
    return m;
  }
  function mrr(m, x0, y0, x1, y1, r) { // rounded rectangle, inclusive pixel bounds
    for (var y = y0; y <= y1; y++) for (var x = x0; x <= x1; x++) {
      var px = x + 0.5, py = y + 0.5, cx = Math.min(Math.max(px, x0 + r), x1 + 1 - r), cy = Math.min(Math.max(py, y0 + r), y1 + 1 - r);
      if ((px - cx) * (px - cx) + (py - cy) * (py - cy) <= r * r && inb(x, y)) m[y * W + x] = 1;
    }
    return m;
  }
  function mseg(m, x0, y0, x1, y1, r) { // a bar: pixel centres within r of the segment
    var dx = x1 - x0, dy = y1 - y0, L2 = dx * dx + dy * dy;
    for (var y = 0; y < H; y++) for (var x = 0; x < W; x++) {
      var px = x + 0.5, py = y + 0.5, t = ((px - x0) * dx + (py - y0) * dy) / L2; t = t < 0 ? 0 : t > 1 ? 1 : t;
      var ex = x0 + dx * t - px, ey = y0 + dy * t - py; if (ex * ex + ey * ey <= r * r) m[y * W + x] = 1;
    }
    return m;
  }
  function mbar(m, x0, y0, x1, y1, r) { // a bar with square ends: pixel centres within r of the segment, not past its ends
    var dx = x1 - x0, dy = y1 - y0, L2 = dx * dx + dy * dy;
    for (var y = 0; y < H; y++) for (var x = 0; x < W; x++) {
      var px = x + 0.5, py = y + 0.5, t = ((px - x0) * dx + (py - y0) * dy) / L2;
      if (t < 0 || t > 1) continue;
      var ex = x0 + dx * t - px, ey = y0 + dy * t - py; if (ex * ex + ey * ey <= r * r) m[y * W + x] = 1;
    }
    return m;
  }
  function mpoly(m, pts) {
    for (var y = 0; y < H; y++) for (var x = 0; x < W; x++) {
      var px = x + 0.5, py = y + 0.5, ins = false;
      for (var i = 0, j = pts.length - 1; i < pts.length; j = i++) {
        var a = pts[i], b = pts[j];
        if ((a[1] > py) !== (b[1] > py) && px < (b[0] - a[0]) * (py - a[1]) / (b[1] - a[1]) + a[0]) ins = !ins;
      }
      if (ins) m[y * W + x] = 1;
    }
    return m;
  }
  // tone index per pixel (0 highlight .. 3 deep shade) from where it sits between the lit (top left) and the dark edge
  function tones(m, o) {
    o = o || {};
    var lx = o.lx == null ? -0.45 : o.lx, ly = o.ly == null ? -0.9 : o.ly, n = Math.sqrt(lx * lx + ly * ly);
    var b1 = o.b1 == null ? 0.2 : o.b1, b2 = o.b2 == null ? 0.6 : o.b2, b3 = o.b3 == null ? 0.86 : o.b3, T = new Int8Array(W * H);
    lx /= n; ly /= n;
    function at(fx, fy) { var x = Math.floor(fx), y = Math.floor(fy); return inb(x, y) && m[y * W + x]; }
    for (var y = 0; y < H; y++) for (var x = 0; x < W; x++) {
      if (!m[y * W + x]) continue;
      var u = 1, d = 1;
      while (u < 60 && at(x + 0.5 + lx * u, y + 0.5 + ly * u)) u++;
      while (d < 60 && at(x + 0.5 - lx * d, y + 0.5 - ly * d)) d++;
      var t = (u - 0.5) / (u + d - 1);
      T[y * W + x] = t < b1 ? 0 : t < b2 ? 1 : t < b3 ? 2 : 3;
    }
    return T;
  }
  function on(m, x, y) { return inb(x, y) && m[y * W + x]; }
  // lay a part on the figure: a dark line where it sits over earlier parts, then its tones
  function stamp(F, m, T, R, line) {
    var x, y, i, mark = [];
    if (line !== false) {
      for (y = 0; y < H; y++) for (x = 0; x < W; x++) {
        i = y * W + x;
        if (!m[i] && F[i] && (on(m, x - 1, y) || on(m, x + 1, y) || on(m, x, y - 1) || on(m, x, y + 1))) mark.push(i);
      }
      for (i = 0; i < mark.length; i++) F[mark[i]] = line || LINE;
    }
    for (i = 0; i < W * H; i++) if (m[i]) F[i] = R[T[i]];
  }

  // the face inside the hood opening: columns x 20..38, rows y 11..28
  // . keep   L hood light   o hood inside (dark)   H h e d hair   S s k skin   B brow (one slanted row)   X lid
  // w white of the eye   W glint   r R iris dark / red   M m n mask light / base / shade   N fold and edge (hood deep)
  // each eye is 5 wide and 3 tall: lid row, then white + red iris + glint, then white + dark iris + skin; a full skin row (the
  // nose bridge) sits right over the mask so the opening reads as skin over cloth; the mask has its own brighter, warmer ramp
  // and two folds running down to the right
  var FACE = [
    '.....LLLLLLLLL.....',
    '....LoooooooooL....',
    '..LooddeedeeedooL..',
    '.LoehHhhHhhhHhheoL.',
    '.oeBBshsshsshsBBeo.',
    '.esSsBBBsSsBBBsske.',
    '.ekXXXXXsSsXXXXXke.',
    '.eswRRWXsSkXWRRwse.',
    '.kswrrrksSkkrrrwsk.',
    '.okkkkkkkSkkkkkkko.',
    '.oMMMMMMMMMMMMmmno.',
    '.oMnMmmmnMmmmnnnNo.',
    '.oMmNMmmmNMmmnnnNo.',
    '.oMmmNMmmmNMmnnnNo.',
    '.oommmNMmmnNmnnNoo.',
    '..oommmnMnnnnnNoo..',
    '...ooNnnnnnnNNoo...',
    '.....ooooooooo.....'
  ];

  function build(look) {
    var L = {}, k;
    for (k in DEF) L[k] = (look && look[k]) || DEF[k];
    var key = JSON.stringify(L); if (cache[key]) return cache[key];
    var hood = ramp(L.hood), pads = ramp(L.pads), suit = ramp(L.suit), stock = ramp(L.stock), skin = ramp(L.skin), hair = ramp(L.hair);
    var F = new Array(W * H).fill(null), A = FIX.amber, m, i, x, y;
    var vest = L.suit === DEF.suit ? FIX.vest : ramp(PIX.shade(L.suit, -0.25)), boot = L.suit === DEF.suit ? FIX.boot : ramp(PIX.shade(L.suit, -0.3));
    function put(mm, R, o) { var T = tones(mm, o); stamp(F, mm, T, R, o && o.line); return T; }
    function P(px, py, c) { if (inb(px, py)) F[py * W + px] = c; }
    function Pif(px, py, c) { if (inb(px, py) && F[py * W + px]) F[py * W + px] = c; }
    var hoodIn = PIX.shade(hood[3], -0.55), padSpec = PIX.shade(pads[0], 0.4), hoodSpec = PIX.shade(hood[0], 0.3), mask = maskRamp(L.hood);
    // plate edges: a light 1 px line on the top and left edges of the dark suit parts, so they read as plates and not one black mass
    var plate = L.suit === DEF.suit ? '#686c76' : PIX.shade(L.suit, 0.25), spec = L.suit === DEF.suit ? '#8e939c' : PIX.shade(L.suit, 0.45);
    function edgeTL(mm, col, y0) {
      for (var yy = y0 || 0; yy < H; yy++) for (var xx = 0; xx < W; xx++) if (mm[yy * W + xx] && (!on(mm, xx - 1, yy) || !on(mm, xx, yy - 1))) F[yy * W + xx] = col;
    }

    // backpack frame, then the red canister on it (lid, valve, bottom band, amber label)
    put(mrr(M(), 10, 15, 21, 41, 2.5), FIX.pack);
    put(mrr(M(), 5, 20, 16, 36, 2.5), pads, { b1: 0.22, b2: 0.55, b3: 0.85 });
    put(mrr(M(), 5, 20, 16, 22, 1.5), FIX.metal);
    put(mrect(M(), 9, 18, 11, 19), FIX.metal);
    put(mrr(M(), 5, 34, 16, 36, 1.5), FIX.metal);
    for (x = 6; x <= 15; x++) { P(x, 29, x < 9 ? A[0] : A[1]); P(x, 30, A[2]); }
    for (y = 24; y <= 32; y++) if (y < 29 || y > 30) Pif(12, y, pads[2]);
    P(7, 24, padSpec); P(7, 25, padSpec); P(8, 24, pads[0]); P(6, 21, '#8e939c'); P(7, 21, '#8e939c'); P(14, 21, '#686c76'); P(10, 18, '#8e939c');

    // body first (legs go on over its lower edge so the hips read)
    put(mpoly(M(), [[18, 26], [39, 26], [40, 31], [38, 42], [39, 47], [17, 47], [18, 42], [17, 31]]), suit);
    // legs in a planted A stance, knee pads, boots with red toe caps and a dark sole
    m = mseg(M(), 22.5, 45, 20.2, 56, 3.5); put(m, suit); edgeTL(m, plate);
    m = mseg(M(), 33.5, 45, 35.8, 56, 3.5); put(m, suit); edgeTL(m, plate);
    put(mrr(M(), 17, 49, 23, 53, 2), FIX.knee);
    put(mrr(M(), 33, 49, 39, 53, 2), FIX.knee);
    P(18, 50, FIX.knee[0]); P(19, 50, '#8e937e'); P(34, 50, FIX.knee[0]); P(35, 50, '#8e937e');
    m = mrr(M(), 15, 54, 23, 58, 1.5); mrr(m, 12, 57, 23, 62, 2.6); put(m, boot); edgeTL(m, plate);
    m = mrr(M(), 32, 54, 40, 58, 1.5); mrr(m, 32, 57, 43, 62, 2.6); put(m, boot); edgeTL(m, plate);
    put(mrr(M(), 12, 58, 17, 62, 2.2), pads);
    put(mrr(M(), 38, 58, 43, 62, 2.2), pads);
    for (x = 12; x <= 43; x++) Pif(x, 62, x < 18 || x > 37 ? pads[3] : boot[3]);
    P(13, 59, padSpec); P(14, 58, padSpec); P(39, 58, padSpec); P(16, 55, spec); P(33, 55, spec);

    // vest, belt, pouches
    m = mrr(M(), 20, 29, 36, 44, 2); put(m, vest, { b1: 0.2, b2: 0.72, b3: 0.94 }); edgeTL(m, plate);
    put(mrect(M(), 18, 43, 38, 45), FIX.metal); P(18, 43, spec);
    put(mrr(M(), 31, 31, 36, 35, 1.5), FIX.pouch);
    put(mrr(M(), 19, 39, 24, 44, 1.5), FIX.pouch);
    put(mrr(M(), 34, 39, 38, 44, 1.5), FIX.pouch);
    P(27, 44, A[1]); P(28, 44, A[0]);
    for (x = 33; x <= 36; x++) P(x, 37, plate); P(36, 37, spec); // a plate edge between the two right pouches

    // hood: a round dome with a small peak leaning right, and a cowl that flares out behind the shoulder pads (rows 29 to 32,
    // in the two dark tones); 4 tones, a crease on the left, a bright spot on the dome
    m = mell(M(), 15, 3, 41, 31); for (i = 29 * W; i < W * H; i++) m[i] = 0;
    mrect(m, 30, 1, 30, 1); mrect(m, 28, 2, 30, 2); mrect(m, 27, 3, 30, 3);
    mrect(m, 17, 29, 39, 29); mrect(m, 16, 30, 40, 30); mrect(m, 16, 31, 23, 31); mrect(m, 33, 31, 40, 31); mrect(m, 16, 32, 21, 32); mrect(m, 35, 32, 40, 32);
    var hT = put(m, hood, { lx: -0.75, ly: -0.66, b1: 0.24, b2: 0.56, b3: 0.82 });
    for (y = 29; y <= 32; y++) for (x = 0; x < W; x++) if (m[y * W + x]) F[y * W + x] = (y === 29 && hT[y * W + x] < 3) || (y === 30 && x < 24) ? hood[2] : hood[3];
    [[24, 30], [25, 30], [32, 30], [22, 31], [34, 31]].forEach(function (p) { Pif(p[0], p[1], hood[3]); });
    var hl = mell(M(), 18, 4, 28, 10); for (i = 0; i < W * H; i++) if (hl[i] && m[i] && (i % W) + ((i / W) | 0) < 34) F[i] = hood[0];
    [[24, 5], [23, 6], [22, 7], [21, 8], [21, 9], [20, 10], [20, 11], [19, 12], [19, 13], [18, 14], [18, 15], [18, 16], [18, 17], [18, 18]].forEach(function (p) { Pif(p[0], p[1], hood[2]); Pif(p[0] - 1, p[1], hood[0]); });
    [[34, 4], [36, 6], [38, 8], [39, 10]].forEach(function (p) { Pif(p[0], p[1], hood[2]); });
    P(21, 5, hoodSpec); P(22, 5, hoodSpec); P(20, 6, hoodSpec); P(25, 4, hoodSpec);

    // face grid
    var FC = { L: hood[0], o: hoodIn, H: hair[0], h: hair[1], e: hair[2], d: hair[3], S: skin[0], s: skin[1], k: skin[2], B: '#2a1418', X: '#140c12',
      w: '#f2e8e4', W: '#ffffff', r: '#8e1a1c', R: '#e03a28', M: mask[0], m: mask[1], n: mask[2], N: hood[3] };
    for (y = 0; y < FACE.length; y++) for (x = 0; x < FACE[y].length; x++) { var ch = FACE[y][x]; if (FC[ch]) P(20 + x, 11 + y, FC[ch]); }
    // the mask's knot tail at the screen-right cheek, out over the hood
    P(36, 22, mask[2]); P(37, 22, mask[0]); P(38, 23, mask[1]); P(37, 23, hood[3]);

    // upper arms, shoulder pads (right one big, left one small)
    m = mrr(M(), 14, 31, 19, 38, 1.5); put(m, suit); edgeTL(m, plate);
    m = mrr(M(), 38, 32, 43, 40, 1.5); put(m, suit); edgeTL(m, plate);
    put(mrr(M(), 14, 26, 20, 32, 2.5), FIX.metal);
    put(mrr(M(), 15, 26, 19, 30, 2), pads, { line: false });
    put(mrr(M(), 37, 24, 44, 33, 2.5), FIX.metal);
    put(mrr(M(), 38, 24, 43, 31, 2.5), pads, { line: false });
    for (x = 38; x <= 43; x++) Pif(x, 28, pads[2]);
    P(16, 27, padSpec); P(39, 25, padSpec); P(40, 25, padSpec); P(39, 26, padSpec); P(38, 32, spec);

    // forearm guards (behind the rifle)
    put(mrr(M(), 15, 35, 24, 39, 2), pads);
    for (y = 35; y <= 39; y++) Pif(21, y, pads[3]);
    m = mseg(M(), 41, 38, 37, 45, 2.2); put(m, suit); edgeTL(m, plate);
    put(mseg(M(), 40.6, 39.5, 38.6, 42.8, 2.3), pads);
    P(17, 36, padSpec); P(18, 36, padSpec);

    // rifle on the diagonal: orange magazine, black grip, solid black receiver at the rear with a light top glint, an orange body
    // split along its length (light upper half, dark lower half, three dark slots), a long black barrel whose muzzle breaks
    // the silhouette past the right boot
    var BLK = ['#1c1d23', '#1c1d23', '#141418', '#141418'], T, b, q;
    put(mbar(M(), 30.5, 39.5, 26.6, 43.8, 1.7), stock);
    put(mbar(M(), 27.8, 35.5, 25.6, 40, 1.4), FIX.metal);
    m = mbar(M(), 21.2, 28.2, 26.4, 34.2, 2.0); b = barAt(21.2, 28.2, 26.4, 34.2); T = new Int8Array(W * H);
    for (i = 0; i < W * H; i++) if (m[i]) { q = b(i % W, (i / W) | 0); T[i] = q.d < -1.2 ? 2 : 0; }
    stamp(F, m, T, BLK);
    for (i = 0; i < W * H; i++) if (m[i]) { q = b(i % W, (i / W) | 0); if (q.d > 1.1 && q.t > 0.12 && q.t < 0.8) F[i] = '#8e939c'; }
    m = mbar(M(), 25.6, 33.2, 38.8, 48.6, 2.7); b = barAt(25.6, 33.2, 38.8, 48.6); T = new Int8Array(W * H);
    for (i = 0; i < W * H; i++) if (m[i]) { q = b(i % W, (i / W) | 0); T[i] = q.d > 1.3 ? 0 : q.d > 0 ? 1 : 2; }
    stamp(F, m, T, stock);
    for (k = 0; k < 3; k++) { q = 2.5 + 4 * k; x = Math.floor(25.6 + 0.651 * q + 0.759 * 0.7); y = Math.floor(33.2 + 0.759 * q - 0.651 * 0.7); P(x - 1, y, stock[3]); P(x, y, stock[3]); }
    m = mbar(M(), 38.4, 48.2, 47, 56, 1.5); put(m, FIX.metal);
    put(mrr(M(), 45, 54, 47, 56, 1), BLK);
    P(28, 33, '#fff0a0'); P(31, 37, '#fff0a0'); P(37, 44, '#fff0a0');
    P(41, 50, '#8e939c'); P(44, 53, '#8e939c'); P(45, 54, '#686c76'); P(39, 49, '#686c76');

    // hands on top of the rifle: left glove on the grip, right bare hand gripping the gun body (two finger lines)
    m = mrr(M(), 23, 36, 27, 40, 1.5); put(m, boot); edgeTL(m, plate); P(24, 37, spec); P(24, 39, boot[3]); P(25, 38, boot[3]);
    put(mrr(M(), 33, 41, 36, 44, 1.5), skin);
    P(33, 43, skin[3]); P(34, 42, skin[3]); P(34, 44, skin[3]); P(35, 43, skin[3]); P(34, 41, skin[0]);

    // to a PIX canvas: hard edges, dark outline, then the antenna (thin, so it goes on after the outline)
    var s = PIX.canvas(W, H), d = s.x.createImageData(W, H);
    for (i = 0; i < W * H; i++) if (F[i]) {
      var n = parseInt(F[i].slice(1), 16); d.data[i * 4] = n >> 16; d.data[i * 4 + 1] = (n >> 8) & 255; d.data[i * 4 + 2] = n & 255; d.data[i * 4 + 3] = 255;
    }
    s.x.putImageData(d, 0, 0);
    PIX.harden(s); PIX.outline(s, OUT, false);
    PIX.line(s, OUT, 10, 2, 10, 14); PIX.rect(s, OUT, 9, 11, 3, 3); PIX.px(s, '#686c76', 10, 12); PIX.px(s, '#8e939c', 10, 2);
    cache[key] = s; return s;
  }

  // one clear dark oval under the feet, at art-pixel size so it stays chunky: centred 1 px below the soles and 1 px right of the
  // boots' middle (art pixel 28, row 63), with a darker core
  var shadowS = null;
  function shadow() {
    if (shadowS) return shadowS;
    var s = PIX.canvas(46, 11);
    PIX.ellipse(s, 'rgba(14,10,20,0.45)', 22, 5, 21, 4);
    PIX.ellipse(s, 'rgba(14,10,20,0.30)', 22, 5, 14, 3);
    return (shadowS = s);
  }

  window.paintPixelPillager = function (ctx, x, y, scale, look) {
    scale = Math.max(1, Math.round(scale || 4));
    PIX.blit(ctx, shadow(), x - 21 * scale, y - 5 * scale, scale);
    PIX.blit(ctx, build(look), x - AX * scale, y - AY * scale, scale);
  };
})();
