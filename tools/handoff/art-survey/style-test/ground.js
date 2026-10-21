// ground.js : pixel-art grass ground for the style test (his 10-20 pixel-art reference, ref-his-lineup.webp).
// paintPixelGround(ctx, W, H, seed, scale, opts) paints a W x H screen-px area of ctx starting at (0,0).
// It draws at art-pixel size on a small PIX canvas (ceil(W/scale) x ceil(H/scale)) and blits it at `scale` (default 4).
// Sizes are tuned at scale 4; at scale 2 things keep their screen size and get twice the art pixels.
// opts.clear: [{x, y, r}] in screen px where no rock, plant, clump or dirt patch may go (figures stand there);
//   small tufts keep out of the inner ~55% of the radius.
// opts.detail: optional density multiplier (default 1).
// After a call, paintPixelGround.last holds {dirt, rocks, plants, tufts} counts (plants = leafy plants + blade clumps).
// Needs pix.js (global PIX). Plain browser JS, no libraries. Same seed = same picture.
// Look (critic round 1): calm ground made of fine dark grass strokes over soft half-step patches; only the figures carry
// a hard dark outline, so ground props are edged on the bottom and right only, in their own darker tone.
(function (root) {
  'use strict';
  // grass key tones, dark to light: deep, dark, shade, base, mid, light, lite2, blade, tip, spark
  var GK = ['#2b4425', '#395a2a', '#486e2f', '#557d34', '#618a38', '#6d953c', '#7ba142', '#95b84b', '#b2ce5c', '#cfe37a'];
  function hx(hex) { var n = parseInt(hex.slice(1), 16); return [n >> 16, (n >> 8) & 255, n & 255]; }
  function toHex(r, g, b) { return '#' + ((1 << 24) + (Math.round(r) << 16) + (Math.round(g) << 8) + Math.round(b)).toString(16).slice(1); }
  function mix(a, b, t) { var p = hx(a), q = hx(b); return toHex(p[0] + (q[0] - p[0]) * t, p[1] + (q[1] - p[1]) * t, p[2] + (q[2] - p[2]) * t); }
  // the tone map uses a half-step ramp: index 2i is GK[i], odd indexes sit halfway (0..18)
  var G = [], i;
  for (i = 0; i < GK.length; i++) { G[2 * i] = GK[i]; if (i < GK.length - 1) G[2 * i + 1] = mix(GK[i], GK[i + 1], 0.5); }
  var GMAX = G.length - 1;                              // 18
  var STK = 20;                                         // 20..38: the dark grass stroke over tone t-20 (about 9% darker)
  function strokeOf(hex) { var p = hx(hex); return toHex(p[0] * 0.87, p[1] * 0.905, p[2] * 0.85); }   // #5a8c34 -> #4e7f2c
  // dirt (40..47): deep, dark, blob dark, base, blob light, hi, pebble light, pebble dark
  var DT = 40, DIRT = ['#5b4633', '#6e583d', '#7e6440', '#977e52', '#a68754', '#b39563', '#c2b598', '#5e4d39'];
  var D_BASE = 43, D_DARK = 42, D_LITE = 44, D_PL = 46, D_PD = 47;
  // rocks: a darker grey-brown ramp, moss on the flat top
  var RK = { deep: '#2e2b2c', shade: '#4a4644', base: '#605c55', lit: '#7d7566', top: '#8e8a78', moss: '#7a8f36', moss2: '#9cb04a' };
  // leafy plant families: inner line (also the bottom/right edge), dim, base, light, spec, top-left highlight leaves
  var PF = [
    { inner: '#28452d', dim: '#3a5f3c', base: '#4a7845', light: '#629552', spec: '#86b464', hi: '#a8cc56' },   // dark, a little blue
    { inner: '#2e4e29', dim: '#456d33', base: '#5a8a3b', light: '#7aaa46', spec: '#a2c858', hi: '#a8cc56' },   // mid green
    { inner: '#46692e', dim: '#6a953e', base: '#86b047', light: '#a8cc56', spec: '#d0e676', hi: '#c2dc68' }    // bright yellow-green
  ];

  function c32(hex) {
    var n = parseInt(hex.slice(1), 16);
    return ((255 << 24) | ((n & 255) << 16) | (((n >> 8) & 255) << 8) | (n >> 16)) >>> 0;
  }
  var PAL = new Uint32Array(48);
  for (i = 0; i <= GMAX; i++) { PAL[i] = c32(G[i]); PAL[STK + i] = c32(strokeOf(G[i])); }
  for (i = 0; i < DIRT.length; i++) PAL[DT + i] = c32(DIRT[i]);

  // move a tone up or down inside its own family (grass, stroke, dirt); pebbles stay
  function adj(t, d) {
    if (t <= GMAX) return Math.max(0, Math.min(GMAX, t + d));
    if (t >= STK && t <= STK + GMAX) return Math.max(STK, Math.min(STK + GMAX, t + d));
    if (t >= DT && t <= DT + 5) return Math.max(DT, Math.min(DT + 5, t + (d < 0 ? Math.ceil(d / 2) : d)));
    return t;
  }
  function isGrass(t) { return t <= GMAX || (t >= STK && t <= STK + GMAX); }
  function plain(t) { return t >= STK && t <= STK + GMAX ? t - STK : t; }

  // integer hash -> [0,1)
  function hash(x, y, s) {
    var n = (Math.imul(x | 0, 374761393) + Math.imul(y | 0, 668265263) + Math.imul(s | 0, 1442695041)) | 0;
    n = Math.imul(n ^ (n >>> 13), 1274126177);
    n ^= n >>> 16;
    return (n >>> 0) / 4294967296;
  }
  // smooth value noise -> [0,1)
  function vnoise(x, y, s) {
    var ix = Math.floor(x), iy = Math.floor(y), fx = x - ix, fy = y - iy;
    var u = fx * fx * (3 - 2 * fx), v = fy * fy * (3 - 2 * fy);
    var a = hash(ix, iy, s), b = hash(ix + 1, iy, s), c = hash(ix, iy + 1, s), d = hash(ix + 1, iy + 1, s);
    return a + (b - a) * u + (c - a) * v + (a - b - c + d) * u * v;
  }
  function putIdx(s, idx, cols) {
    var img = s.x.createImageData(s.w, s.h), buf = new Uint32Array(img.data.buffer), k, c = [];
    for (k = 0; k < cols.length; k++) c[k] = cols[k] ? c32(cols[k]) : 0;
    for (k = 0; k < idx.length; k++) if (idx[k] >= 0) buf[k] = c[idx[k]];
    s.x.putImageData(img, 0, 0);
  }
  // ground props sit back: no outline on the top or left, a 1 px edge in the prop's own darker tone on the bottom and right
  function edgeBR(s, col) {
    var d = s.x.getImageData(0, 0, s.w, s.h).data, w = s.w, h = s.h, a, b, list = [];
    function sol(x, y) { return x >= 0 && y >= 0 && x < w && y < h && d[(y * w + x) * 4 + 3] > 0; }
    for (b = 0; b < h; b++) for (a = 0; a < w; a++) if (!sol(a, b) && (sol(a - 1, b) || sol(a, b - 1))) list.push(a, b);
    s.x.fillStyle = col;
    for (a = 0; a < list.length; a += 2) s.x.fillRect(list[a], list[a + 1], 1, 1);
    return s;
  }

  // ---------- rock: an angular 6 or 7 point block; flat mossy top facet, lit left face, shaded right face, dark base ----------
  function makeRock(R, w, U, sd) {
    var h = Math.max(6, Math.round(w * (0.72 + R() * 0.16)));
    var a1 = Math.round(w * (0.12 + R() * 0.12)), a2 = Math.round(w * (0.1 + R() * 0.12));
    var yR = Math.round(h * (0.26 + R() * 0.16)), yL = Math.round(h * (0.36 + R() * 0.18));
    var a4 = Math.round(w * (0.04 + R() * 0.1)), a5 = Math.round(w * (0.02 + R() * 0.08));
    var pts = [[a1, 0], [w - 1 - a2, R() < 0.35 ? 1 : 0], [w - 1, yR], [w - 1 - a4, h - 1], [a5, h - 1], [0, yL]];
    if (R() < 0.5) pts.push([Math.round(a1 * 0.3), Math.round(yL * 0.45)]);           // a 7th point: a chipped upper-left corner
    else pts.splice(3, 0, [w - 1, Math.round(yR + (h - 1 - yR) * (0.55 + R() * 0.2))]);   // or a straight right side lower down
    var L = [], Rr = [], x, y, j;
    for (y = 0; y < h; y++) {
      var lo = 1e9, hi = -1e9, yc = y;
      for (j = 0; j < pts.length; j++) {
        var p = pts[j], q = pts[(j + 1) % pts.length];
        if (p[1] === q[1]) { if (p[1] === yc) { lo = Math.min(lo, p[0], q[0]); hi = Math.max(hi, p[0], q[0]); } continue; }
        if ((yc - p[1]) * (yc - q[1]) > 0) continue;
        var xx = p[0] + (yc - p[1]) * (q[0] - p[0]) / (q[1] - p[1]);
        lo = Math.min(lo, xx); hi = Math.max(hi, xx);
      }
      L[y] = Math.round(lo); Rr[y] = Math.round(hi);
    }
    function inR(xx, yy) { return yy >= 0 && yy < h && xx >= L[yy] && xx <= Rr[yy]; }
    var ft = Math.max(2, Math.round((2 + R() * 1.2) * U)), sl = (R() - 0.5) * 0.14, mid = w / 2;
    var ridge0 = Math.round(w * (0.54 + R() * 0.14)), rslant = R() < 0.6 ? 1 : 0, mossy = -0.04 + R() * 0.16;
    var idx = new Int8Array(w * h).fill(-1), k;
    // tones: 0 deep, 1 shade, 2 base, 3 lit, 4 top, 5 moss, 6 moss light
    for (y = 0; y < h; y++) for (x = L[y]; x <= Rr[y]; x++) {
      k = y * w + x;
      var fl = ft + Math.round(sl * (x - mid)), t;
      var ridge = ridge0 + (rslant ? Math.floor(Math.max(0, y - fl) / (3 * U)) : 0);
      var fh = Math.max(1, h - fl), fr = y - fl;
      if (y < fl) {                                                        // flat top facet, mossy
        t = 4;
        var m = vnoise(x / (2.3 * U), y / (1.3 * U), sd) + mossy + (0.5 - x / w) * 0.22;
        if (m > 0.58) t = m > 0.74 ? 6 : 5;
        if (x === Rr[y] && y > 0) t = 2;                                   // the facet's right corner turns away from the light
      } else if (x < ridge) {                                              // lit left face, darker low down
        t = fr < fh * 0.55 ? 3 : 2;
        if (fr === 0 && x > L[y]) t = 2;                                   // a crease under the facet edge
        if (fr < Math.max(1, U) && vnoise(x / (1.6 * U), 3.3, sd ^ 0x2f) + mossy > 0.6) t = 5;   // moss hanging over the edge
      } else t = 1;                                                        // shaded right face
      if (x === ridge && y >= fl && fr < fh * 0.7) t = 2;                  // the ridge between the two faces
      if (y >= fl && (x === Rr[y] || !inR(x + 1, y))) t = 0;               // right edge
      if (!inR(x, y + 1) || y >= h - Math.max(1, Math.round(U))) t = 0;    // dark base, 1 px (2 at scale 2)
      else if (y === h - 1 - Math.max(1, Math.round(U)) && x >= ridge) t = 0;   // and a second row under the shaded face
      idx[k] = t;
    }
    // a short crack running down the lit face from the facet edge
    if (w >= 12 * U) {
      var cx0 = ridge0 - Math.round((3 + R() * 3) * U), cy0 = ft + Math.round(sl * (cx0 - mid)), cl = Math.round((2 + R() * 2.5) * U);
      for (j = 0; j < cl; j++) {
        if (inR(cx0, cy0 + j)) { k = (cy0 + j) * w + cx0; if (idx[k] === 3 || idx[k] === 2) idx[k] = 1; }
        if (R() < 0.3) cx0 -= 1;
      }
    }
    var s = PIX.canvas(w, h);
    putIdx(s, idx, [RK.deep, RK.shade, RK.base, RK.lit, RK.top, RK.moss, RK.moss2]);
    return { s: s, ax: Math.floor(w / 2), ay: h, h: h };
  }

  // ---------- leafy plant: broad oval leaves, back leaves dimmer, bright highlight leaves on the top left ----------
  function makePlant(R, size, fam) {
    var cw = Math.round(size * 2.6) + 6, ch = Math.round(size * 1.5) + 6, bx = cw / 2, by = ch - 3;
    var idx = new Int8Array(cw * ch).fill(-1), x, y, k, j;
    for (y = 0; y < ch; y++) for (x = 0; x < cw; x++) {
      var ex = (x + 0.5 - bx) / (size * 0.45 + 1), ey = (y + 0.5 - (by - 0.8)) / (size * 0.22 + 0.8);
      if (ex * ex + ey * ey <= 1) idx[y * cw + x] = 1;
    }
    var n = 4 + Math.floor(R() * 3), leaves = [];
    for (j = 0; j < n; j++) {
      var a = -Math.PI - 0.25 + (j + 0.5) * ((Math.PI + 0.5) / n) + (R() - 0.5) * 0.3, up = -Math.sin(a);
      leaves.push({ a: a, L: size * (0.95 + R() * 0.3) * (0.85 + 0.15 * up), wd: size * (0.23 + R() * 0.05) + 0.5, ox: (R() - 0.5) * size * 0.2, oy: -up * size * 0.1 });
    }
    var droop = 1 + Math.floor(R() * 2);
    for (j = 0; j < droop; j++) {
      var a2 = (j % 2 === 0) === (R() < 0.5) ? 0.25 + R() * 0.35 : Math.PI - 0.25 - R() * 0.35;
      leaves.push({ a: a2, L: size * (0.7 + R() * 0.2), wd: size * 0.2 + 0.5, ox: (R() - 0.5) * size * 0.3, oy: 0 });
    }
    leaves.sort(function (p, q) { return Math.sin(p.a) - Math.sin(q.a); });
    var M = new Uint8Array(cw * ch), LD0 = -0.6, LD1 = -0.8;
    for (j = 0; j < leaves.length; j++) {
      var lf = leaves[j], ca = Math.cos(lf.a), sa = Math.sin(lf.a), L = lf.L, wd = lf.wd;
      var litDot = LD0 * -sa + LD1 * ca, bxx = bx + lf.ox, byy = by - 1 + lf.oy;
      // tone follows where the leaf points: up and left (toward the light) is brightest, down and right is dim
      var face = -ca * 0.62 - sa * 0.78, tl = face > 0.8;
      var tLit = tl ? 6 : (face > 0.3 ? 4 : (face > -0.3 ? 3 : 2)), tDim = tl ? 4 : (face > 0.3 ? 3 : 2);
      M.fill(0);
      var list = [];
      var x0 = Math.max(0, Math.floor(Math.min(bxx, bxx + ca * L) - wd - 1)), x1 = Math.min(cw - 1, Math.ceil(Math.max(bxx, bxx + ca * L) + wd + 1));
      var y0 = Math.max(0, Math.floor(Math.min(byy, byy + sa * L) - wd - 1)), y1 = Math.min(ch - 1, Math.ceil(Math.max(byy, byy + sa * L) + wd + 1));
      for (y = y0; y <= y1; y++) for (x = x0; x <= x1; x++) {
        var dx = x + 0.5 - bxx, dy = y + 0.5 - byy, t = (dx * ca + dy * sa) / L, sv = -dx * sa + dy * ca;
        if (t < 0.08 || t > 1) continue;
        var hw = wd * Math.pow(Math.max(0, Math.sin(Math.PI * Math.pow(t, 0.75))), 0.6);
        if (Math.abs(sv) > hw + 0.15) continue;
        k = y * cw + x; M[k] = 1;
        var lit = sv * litDot > 0.2;
        list.push(k, lit ? tLit : tDim);
      }
      // leaves behind this one get the dark inner line
      for (var q = 0; q < list.length; q += 2) {
        k = list[q]; x = k % cw;
        var nb = [k - cw, k + cw, x > 0 ? k - 1 : -1, x < cw - 1 ? k + 1 : -1];
        for (var z = 0; z < 4; z++) { var kk = nb[z]; if (kk >= 0 && kk < cw * ch && !M[kk] && idx[kk] >= 2) idx[kk] = 1; }
      }
      for (q = 0; q < list.length; q += 2) idx[list[q]] = list[q + 1];
      // vein on the front leaves
      if (face > -0.3 && L >= 5) {
        for (var tv = 0.25; tv < 0.75; tv += 0.5 / L) {
          var vx = Math.floor(bxx + ca * tv * L), vy = Math.floor(byy + sa * tv * L);
          if (vx >= 0 && vy >= 0 && vx < cw && vy < ch && M[vy * cw + vx]) idx[vy * cw + vx] = tDim;
        }
      }
      if (tLit === 4 && R() < 0.6) {
        var ss = (litDot > 0 ? 1 : -1) * wd * 0.5, sx = Math.floor(bxx + ca * 0.45 * L - sa * ss), sy = Math.floor(byy + sa * 0.45 * L + ca * ss);
        if (sx >= 0 && sy >= 0 && sx < cw && sy < ch && idx[sy * cw + sx] === 4) idx[sy * cw + sx] = 5;
      }
    }
    var s = PIX.canvas(cw, ch);
    putIdx(s, idx, [0, fam.inner, fam.dim, fam.base, fam.light, fam.spec, fam.hi]);
    edgeBR(s, fam.inner);
    return { s: s, ax: Math.round(bx), ay: by };
  }

  // ---------- soft blade clump: 5 to 9 curved blades, darker behind, bright tips in front, no outline ----------
  function makeBlades(R, hgt, U) {
    var cw = Math.round(hgt * 2.2) + 6, ch = hgt + 3, bx = Math.floor(cw / 2), by = ch - 2;
    var s = PIX.canvas(cw, ch), n = 5 + Math.floor(R() * 5), j, k, bl = [];
    var BACK = ['#4f7a33', '#5a8a3b', '#86b047'], FRONT = ['#557d34', '#6a953e', '#a8cc56'];
    for (j = 0; j < n; j++) bl.push({ d: (j / (n - 1)) * 2 - 1 + (R() - 0.5) * 0.3, back: R() < 0.4, r: R() });
    bl.sort(function (p, q) { return (q.back ? 1 : 0) - (p.back ? 1 : 0); });
    for (j = 0; j < n; j++) {
      var b = bl[j], ad = Math.abs(b.d), cols = b.back ? BACK : FRONT;
      var len = Math.max(3, Math.round(hgt * (1 - 0.38 * ad) * (0.72 + b.r * 0.32)));
      var x0 = bx + Math.round(b.d * (1 + hgt * 0.2)), bend = b.d * hgt * 0.38;
      for (k = 0; k < len; k++) {
        var f = len > 1 ? k / (len - 1) : 1, xx = x0 + Math.round(bend * Math.pow(f, 1.7));
        var c = f < 0.28 ? cols[0] : (f < 0.7 ? cols[1] : cols[2]);
        PIX.px(s, c, xx, by - k);
        if (!b.back && f < 0.4 && U >= 1) PIX.px(s, cols[0], xx + (b.d < 0 ? -1 : 1), by - k);   // a fuller foot on the front blades
      }
    }
    return { s: s, ax: bx, ay: by };
  }

  // ---------- small grass tuft, drawn straight onto the art canvas ----------
  function tuft(S, R, x, y, cols, n, hMax) {
    var half = (n - 1) / 2, j, k;
    for (j = 0; j < n; j++) {
      var off = Math.round((j - half) * 1.2 + (R() - 0.5) * 0.7), edge = Math.abs(j - half) / Math.max(1, half);
      var hgt = Math.max(2, Math.round(hMax * (1 - 0.5 * edge) * (0.75 + R() * 0.35)));
      var lean = (j - half) < -0.4 ? -1 : ((j - half) > 0.4 ? 1 : 0);
      for (k = 0; k < hgt; k++) {
        var f = k / (hgt - 1), c = f < 0.34 ? cols[0] : (f < 0.75 ? cols[1] : cols[2]);
        var sh = lean * Math.round(f * f * Math.min(2, hgt / 3));
        PIX.px(S, c, x + off + sh, y - k);
      }
    }
  }

  function paintPixelGround(ctx, W, H, seed, scale, opts) {
    opts = opts || {};
    scale = Math.max(1, Math.round(scale || 4));
    seed = (seed >>> 0) || 1;
    var aw = Math.max(1, Math.ceil(W / scale)), ah = Math.max(1, Math.ceil(H / scale)), N = aw * ah;
    var R = PIX.rng(Math.imul(seed, 2654435761) >>> 0);
    var detail = opts.detail == null ? 1 : opts.detail;
    var U = 4 / scale;                                 // art px per scale-4 art px
    var K = (W * H) / (960 * 1080);                     // feature count factor: 1 for a 960x1080 area
    var x, y, k, j, a, p;
    var s1 = seed ^ 0x51ed, s2 = seed ^ 0x2c1b, s4 = seed ^ 0x13a5, s5 = seed ^ 0x6e21, s6 = seed ^ 0x0bd3, s7 = seed ^ 0x44f9, s8 = seed ^ 0x7a31;

    // 1. soft low-frequency patches (two octaves, wide and flat like a field seen at 3/4), half a tone step apart
    var F = new Float32Array(N), T = new Uint8Array(N);
    var pcw = 210 / scale, pch = 95 / scale;
    for (y = 0; y < ah; y++) for (x = 0; x < aw; x++) {
      F[y * aw + x] = 0.68 * vnoise(x / pcw, y / pch, s1) + 0.32 * vnoise(x / (pcw * 0.4) + 7.3, y / (pch * 0.4) + 1.9, s2);
    }
    var srt = F.slice().sort();
    var q = function (pp) { return srt[Math.min(N - 1, Math.floor(pp * (N - 1)))]; };
    var c1 = q(0.33), c2 = q(0.8), c3 = q(0.97);   // the darker tones only come from shadows under things
    for (k = 0; k < N; k++) { var f = F[k]; T[k] = f < c1 ? 7 : (f < c2 ? 8 : (f < c3 ? 9 : 10)); }
    // no one-pixel slivers
    for (y = 1; y < ah - 1; y++) for (x = 1; x < aw - 1; x++) {
      k = y * aw + x;
      if (T[k - 1] === T[k + 1] && T[k - 1] !== T[k]) T[k] = T[k - 1];
      else if (T[k - aw] === T[k + aw] && T[k - aw] !== T[k]) T[k] = T[k - aw];
    }

    // 2. patch edges turn into grass: short teeth (1 or 2 art px) of the lower tone poke up
    var T0 = T.slice();
    for (y = 1; y < ah; y++) for (x = 1; x < aw - 1; x++) {
      k = y * aw + x; var tl = T0[k];
      if (tl === T0[k - aw] || hash(x, y, s4) > 0.24) continue;
      var hc = Math.max(1, Math.round((hash(x, y, s5) < 0.45 ? 2 : 1) * Math.min(1.5, U)));
      for (j = 1; j <= hc && y - j >= 0; j++) T[k - j * aw] = tl;
    }

    // 3. the grass texture: a field of tiny dark strokes (1x2 and 1x3 art px), one every 5 to 7 art px, all over the grass
    var cell = Math.max(4, Math.round(6 * (1 + (U - 1) * 0.35)));
    for (y = 0; y < ah; y += cell) for (x = 0; x < aw; x += cell) {
      if (hash(x, y, s8) < 0.04 + 0.3 * vnoise(x / (40 / scale * 4), y / (24 / scale * 4), s8 ^ 0x77)) continue;
      var sx0 = x + Math.floor(hash(x, y, s8 ^ 0x11) * cell), sy0 = y + Math.floor(hash(x, y, s8 ^ 0x22) * cell);
      var sl = (hash(x, y, s8 ^ 0x33) < 0.55 ? 2 : 3) + (U > 1.5 && hash(x, y, s8 ^ 0x44) < 0.5 ? 1 : 0);
      var lean = hash(x, y, s8 ^ 0x55) < 0.3 ? (hash(x, y, s8 ^ 0x66) < 0.5 ? -1 : 1) : 0;
      for (j = 0; j < sl; j++) {
        var xx = sx0 + (j === sl - 1 ? lean : 0), yy = sy0 - j;
        if (xx < 0 || yy < 0 || xx >= aw || yy >= ah) continue;
        k = yy * aw + xx; if (T[k] <= GMAX) T[k] += STK;
      }
    }

    // 4. a few light blades (single blades, pairs, small v's), in loose groups (half as many as the first test)
    var nMark = Math.round(N / 85 * detail * 0.38), cs = 140 / scale;
    for (j = 0; j < nMark; j++) {
      x = 1 + Math.floor(R() * Math.max(1, aw - 4)); y = 3 + Math.floor(R() * Math.max(1, ah - 4));
      var cf = vnoise(x / cs, y / (cs * 0.6), s7);
      if (R() > (cf - 0.4) * 2.5) continue;
      k = y * aw + x; var tt = plain(T[k]);
      if (tt > GMAX) continue;
      var mt = Math.min(tt + 2, 14), shape = R(), tall = U > 1.5 ? 1 : 0;
      if (shape < 0.5) { T[k] = mt; T[k - aw] = mt; if (tall || R() < 0.3) T[k - 2 * aw] = mt; }
      else if (shape < 0.75) { T[k] = mt; T[k - aw] = mt; T[k + 2] = mt; T[k + 2 - aw] = mt; T[k + 1 - 2 * aw] = mt; }
      else { T[k] = mt; T[k - aw - 1] = mt; T[k - aw + 1] = mt; if (tall) { T[k - 2 * aw - 1] = mt; T[k - 2 * aw + 1] = mt; } }
    }

    // 5. place the big features: dirt patches, then rock clusters and bush clusters (greenery always comes in groups)
    var clear = (opts.clear || []).map(function (c) { return { x: c.x / scale, y: c.y / scale, r: c.r / scale }; });
    var feats = [];
    function hitsClear(px0, py0, r) {
      for (var b = 0; b < clear.length; b++) { var dx = px0 - clear[b].x, dy = (py0 - clear[b].y) * 1.3; if (dx * dx + dy * dy < (r + clear[b].r) * (r + clear[b].r)) return true; }
      return false;
    }
    function freeOf(px0, py0, r, gap) {
      if (hitsClear(px0, py0, r)) return false;
      for (var b = 0; b < feats.length; b++) { var ex = px0 - feats[b].x, ey = (py0 - feats[b].y) * 1.3, rr = r + feats[b].r + gap; if (ex * ex + ey * ey < rr * rr) return false; }
      return true;
    }
    // best of a few random candidates (the one furthest from what is already placed): spread out, but not on a grid.
    // lift: the footprint centre sits this far above the base point (rocks and bushes grow upward from their foot)
    function spot(r, mx, my, gap, lift) {
      var best = null, bestD = -1e9;
      for (var t = 0; t < 40; t++) {
        var px0 = mx + R() * Math.max(1, aw - 2 * mx), py0 = my + lift + R() * Math.max(1, ah - 2 * my - lift), cy0 = py0 - lift;
        if (!freeOf(px0, cy0, r, gap)) continue;
        var dmin = 1e9;
        for (var b = 0; b < feats.length; b++) { var ex = px0 - feats[b].x, ey = (cy0 - feats[b].y) * 1.3; dmin = Math.min(dmin, Math.sqrt(ex * ex + ey * ey) - feats[b].r); }
        dmin = Math.min(dmin, 1.5 * Math.min(px0, aw - px0, (cy0 + 4) * 1.3, (ah - py0) * 1.3) + 6);
        if (dmin > bestD) { bestD = dmin; best = { x: px0, y: py0 }; }
        if (t >= 5 && best) break;
      }
      return best;
    }
    function cnt(lo, hi) {
      var nn = Math.round((lo + R() * (hi - lo)) * K * detail);
      if (K >= 0.8 && K <= 1.25) nn = Math.max(lo, Math.min(hi, nn));
      return nn;
    }
    var nDirt = cnt(2, 4), nRockCl = cnt(2, 3), nBushCl = cnt(3, 4);
    var dirts = [], rocks = [], plants = [], clumps = [], tufts = [];
    function okAt(px0, py0, r) { return !hitsClear(px0, py0, r) && px0 > 2 && px0 < aw - 2 && py0 < ah + 2; }
    for (j = 0; j < nDirt; j++) {
      if (R() < 0.5) {                                                   // one ragged patch
        var rx = (11 + R() * 7) * U; p = spot(rx * 1.25, rx + 2, rx * 0.5 + 3, 4 * U, 0);
        if (!p) continue; feats.push({ x: p.x, y: p.y, r: rx * 1.25 }); dirts.push({ x: p.x, y: p.y, rx: rx, ry: rx * (0.4 + R() * 0.1) });
      } else {                                                           // a broken chain of 2 to 4 smaller blobs, 3 to 6 art px apart
        var nb = 2 + Math.floor(R() * 3), ang = (R() - 0.5) * 0.6, list = [], tot = 0, big = Math.floor(R() * nb);
        for (a = 0; a < nb; a++) { var brx = (a === big ? 7 + R() * 3.5 : 3.2 + R() * 3.6) * U; list.push({ rx: brx, ry: brx * (0.45 + R() * 0.16), gap: (3 + R() * 3) * U }); tot += 2 * brx + (a < nb - 1 ? list[a].gap : 0); }
        var half = tot / 2; p = spot(half + 3 * U, half + 2, half * 0.35 + 4, 4 * U, 0);
        if (!p) continue; feats.push({ x: p.x, y: p.y, r: half + 3 * U });
        var pos = -half, chain = [];
        for (a = 0; a < nb; a++) {
          var cb = list[a]; pos += cb.rx;
          chain.push({ x: p.x + Math.cos(ang) * pos, y: p.y + Math.sin(ang) * pos * 0.6 + (a === big ? 0 : (R() < 0.5 ? -1 : 1) * (1.5 + R() * 3) * U), rx: cb.rx, ry: cb.ry });
          pos += cb.rx + cb.gap;
        }
        dirts.push({ x: p.x, y: p.y, rx: half, ry: half * 0.3, chain: chain });
      }
    }
    var FAM_ROCK = [0, 1, 1, 0], FAM_BUSH = [0, 1, 1, 0, 1];
    function addPlant(px0, py0, sz, fam) {
      if (!okAt(px0, py0 - sz * 0.5, sz * 1.1)) return false;
      plants.push({ x: Math.round(px0), y: Math.round(py0), size: Math.round(sz), fam: fam }); return true;
    }
    function addClump(px0, py0) {
      var hg = Math.round((3 + R() * 4) * U);
      if (!okAt(px0, py0 - hg * 0.5, hg)) return;
      clumps.push({ x: Math.round(px0), y: Math.round(py0), h: hg });
    }
    function addTuft(px0, py0, kind) { tufts.push({ x: Math.round(px0), y: Math.round(py0), kind: kind, near: 1 }); }
    // rock clusters: a main block, usually one or two smaller blocks stacked beside it, leafy plants and blades at the foot
    for (j = 0; j < nRockCl; j++) {
      var w = Math.round((16 + Math.floor(R() * 5)) * U), cr = w * 0.5 + 10 * U;
      p = spot(cr, cr + 2, w * 0.7 + 4, 6 * U, w * 0.25);
      if (!p) continue;
      var cx = Math.round(p.x), cy = Math.round(p.y), side = R() < 0.5 ? -1 : 1;
      feats.push({ x: cx, y: cy - w * 0.25, r: cr });
      rocks.push({ x: cx, y: cy, w: w });
      var lx = cx - w / 2, rxx = cx + w / 2, by2 = cy;
      if (R() < 0.85) {
        var w2 = Math.round((10 + Math.floor(R() * 5)) * U), behind = R() < 0.55;
        var x2 = Math.round(cx + side * (w / 2 + w2 / 2 - (3 + R() * 3) * U)), y2 = cy + Math.round((behind ? -(2 + R() * 2) : 2 + R() * 1.5) * U);
        if (okAt(x2, y2 - w2 * 0.35, w2 * 0.5)) { rocks.push({ x: x2, y: y2, w: w2 }); lx = Math.min(lx, x2 - w2 / 2); rxx = Math.max(rxx, x2 + w2 / 2); by2 = Math.max(by2, y2); }
        if (R() < 0.45) {
          var w3 = Math.round((7 + Math.floor(R() * 4)) * U), x3 = Math.round(cx - side * (w / 2 + w3 / 2 - (2 + R() * 2) * U)), y3 = cy + Math.round((1.5 + R() * 1.5) * U);
          if (okAt(x3, y3 - w3 * 0.35, w3 * 0.5)) { rocks.push({ x: x3, y: y3, w: w3 }); lx = Math.min(lx, x3 - w3 / 2); rxx = Math.max(rxx, x3 + w3 / 2); by2 = Math.max(by2, y3); }
        }
      }
      // 2 or 3 leafy plants: one tucked behind a side, one in front at the other side, sometimes a small one at the front corner
      var fa = FAM_ROCK[Math.floor(R() * FAM_ROCK.length)], fb = R() < 0.4 ? 2 : 1 - fa;
      var szA = (4.6 + R() * 1.8) * U, szB = (3.8 + R() * 1.6) * U;
      var leftSide = R() < 0.5;
      addPlant(leftSide ? lx - szA * 0.15 : rxx + szA * 0.15, cy - Math.round(1.5 * U), szA, fa);
      addPlant(leftSide ? rxx + szB * 0.2 : lx - szB * 0.2, by2 + Math.round((1 + R()) * U), szB, fb);
      if (R() < 0.5) addPlant(cx + (leftSide ? -1 : 1) * w * (0.28 + R() * 0.12), by2 + Math.round(2.5 * U), (3 + R() * 1.2) * U, fa);
      addClump(leftSide ? rxx + 2 * U : lx - 2 * U, by2 + Math.round(1.5 * U));
      if (R() < 0.3) addClump(cx + (R() - 0.5) * w * 0.5, by2 + Math.round(2 * U));
      var nt = 2 + Math.floor(R() * 2);
      for (a = 0; a < nt; a++) addTuft(lx + R() * (rxx - lx), by2 + (1 + R() * 2.5) * U, R() < 0.1 ? 2 : (R() < 0.5 ? 1 : 0));
    }
    // bush clusters: a big leafy plant with one or two smaller neighbours of other families, blades and tufts at the foot
    for (j = 0; j < nBushCl; j++) {
      var sz = (8 + R() * 3) * U, bcr = sz * 1.35 + 6 * U;
      p = spot(bcr, bcr + 2, sz * 1.5 + 4, 4 * U, sz * 0.5);
      if (!p) continue;
      var bxp = Math.round(p.x), byp = Math.round(p.y), sd2 = R() < 0.5 ? -1 : 1;
      feats.push({ x: bxp, y: byp - sz * 0.5, r: bcr });
      var f0 = FAM_BUSH[Math.floor(R() * FAM_BUSH.length)];
      plants.push({ x: bxp, y: byp, size: Math.round(sz), fam: f0 });
      var sz2 = sz * (0.55 + R() * 0.2);
      addPlant(bxp + sd2 * (sz * 0.95 + sz2 * 0.5), byp + (R() * 3 - 1) * U, sz2, 1 - Math.min(1, f0));
      if (R() < 0.6) addPlant(bxp - sd2 * (sz * 0.85 + sz * 0.25), byp + (1 + R() * 1.5) * U, sz * (0.4 + R() * 0.12), 2);
      addClump(bxp - sd2 * (sz * 1.1), byp + Math.round(1.5 * U));
      if (R() < 0.25) addClump(bxp + sd2 * sz * 0.3, byp + Math.round(2.5 * U));
      var nt2 = 1 + Math.floor(R() * 3);
      for (a = 0; a < nt2; a++) addTuft(bxp + (R() - 0.5) * sz * 2.6, byp + (1 + R() * 2.5) * U, R() < 0.1 ? 2 : (R() < 0.5 ? 1 : 0));
    }

    // 6. dirt patches go into the tone map
    var Tpre = T.slice();
    for (j = 0; j < dirts.length; j++) paintDirt(T, Tpre, aw, ah, dirts[j], R, seed + j * 977, U);

    // 7. loose tufts in the open grass (small: they may sit near figures, but not under their feet)
    var nT = Math.round(13 * K * detail), nB = Math.round(7 * K * detail), cc = 150 / scale;
    function tuftSpot() {
      for (var t = 0; t < 30; t++) {
        var tx = 3 + Math.floor(R() * Math.max(1, aw - 6)), ty = 7 * U + Math.floor(R() * Math.max(1, ah - 9 * U));
        var g = vnoise(tx / cc, ty / (cc * 0.6), s7 ^ 0x5a5a);
        if (R() > (g - 0.22) * 1.8) continue;
        if (!isGrass(T[ty * aw + tx])) continue;
        var bad = false;
        for (var b = 0; b < clear.length; b++) { var dx = tx - clear[b].x, dy = (ty - clear[b].y) * 1.3; if (dx * dx + dy * dy < clear[b].r * clear[b].r * 0.3) bad = true; }
        if (!bad) return { x: tx, y: ty };
      }
      return null;
    }
    for (j = 0; j < nT; j++) {
      p = tuftSpot(); if (!p) continue;
      tufts.push({ x: p.x, y: p.y, kind: R() < 0.55 ? 0 : 1 });
      if (R() < 0.35) tufts.push({ x: p.x + Math.round((R() < 0.5 ? -5 : 5) * U), y: p.y + Math.round((R() * 2 - 1) * U), kind: 0 });
    }
    for (j = 0; j < nB; j++) { p = tuftSpot(); if (p) tufts.push({ x: p.x, y: p.y, kind: 2 }); }
    // cluster tufts keep out of the figures' feet too
    tufts = tufts.filter(function (o) {
      for (var b = 0; b < clear.length; b++) { var dx = o.x - clear[b].x, dy = (o.y - clear[b].y) * 1.3; if (dx * dx + dy * dy < clear[b].r * clear[b].r * 0.3) return false; }
      return true;
    });

    // ghost leaves: faint lighter leaf shapes in the grass, like the painted undergrowth in the reference (half a step)
    var nGhost = Math.round(8 * K * detail);
    for (j = 0; j < nGhost; j++) {
      var gx = R() * aw, gy = R() * ah, gn = 3 + Math.floor(R() * 4);
      if (hitsClear(gx, gy, 2)) continue;
      for (a = 0; a < gn; a++) {
        var ga = R() * Math.PI * 2, gd = (1.5 + R() * 3) * U, lx2 = gx + Math.cos(ga) * gd * 1.4, ly2 = gy + Math.sin(ga) * gd * 0.7;
        var lrx = (1.6 + R()) * U, lry = (1 + R() * 0.6) * U;
        for (y = Math.max(0, Math.floor(ly2 - lry)); y <= Math.min(ah - 1, Math.ceil(ly2 + lry)); y++)
          for (x = Math.max(0, Math.floor(lx2 - lrx)); x <= Math.min(aw - 1, Math.ceil(lx2 + lrx)); x++) {
            var gex = (x + 0.5 - lx2) / lrx, gey = (y + 0.5 - ly2) / lry;
            if (gex * gex + gey * gey > 1) continue;
            k = y * aw + x; if (isGrass(T[k]) && plain(T[k]) < 13) T[k] = adj(T[k], 1);
          }
      }
    }

    // 8. shadows darken the ground under things (light from the top left, so they sit low and to the right)
    for (j = 0; j < rocks.length; j++) shadow(T, aw, ah, rocks[j].x + rocks[j].w * 0.2, rocks[j].y - 0.3 * U, rocks[j].w / 2 + 2.5 * U, Math.max(1.8, rocks[j].w * 0.17), 4, s6 + j);
    for (j = 0; j < plants.length; j++) shadow(T, aw, ah, plants[j].x + 1.5 * U, plants[j].y - 0.5 * U, plants[j].size * 1.25 + 1.5 * U, plants[j].size * 0.42 + 1, 4, s5 + j);
    for (j = 0; j < clumps.length; j++) shadow(T, aw, ah, clumps[j].x + 1 * U, clumps[j].y, clumps[j].h * 0.9 + 1.5 * U, 1.3 * U, 2, s5 ^ (j + 99));
    for (j = 0; j < tufts.length; j++) shadow(T, aw, ah, tufts[j].x + 0.8 * U, tufts[j].y + 0.3 * U, 3.2 * U, 1.2 * U, 2, s4 + j);

    // 9. tone map -> pixels
    var S = PIX.canvas(aw, ah), img = S.x.createImageData(aw, ah), buf = new Uint32Array(img.data.buffer);
    for (k = 0; k < N; k++) buf[k] = PAL[T[k]];
    S.x.putImageData(img, 0, 0);

    // 10. objects back to front; where a rock overlaps a rock behind it, a dark line parts the two
    var draw = [];
    for (j = 0; j < rocks.length; j++) draw.push({ y: rocks[j].y, t: 0, o: rocks[j] });
    for (j = 0; j < plants.length; j++) draw.push({ y: plants[j].y, t: 1, o: plants[j] });
    for (j = 0; j < clumps.length; j++) draw.push({ y: clumps[j].y, t: 2, o: clumps[j] });
    for (j = 0; j < tufts.length; j++) draw.push({ y: tufts[j].y, t: 3, o: tufts[j] });
    draw.sort(function (u, v) { return u.y - v.y || u.t - v.t; });
    var DARK = [G[2], G[4], G[6]], MIXT = [G[2], G[6], G[12]], LITE = [G[6], G[13], G[15]];
    var occ = new Uint8Array(N);
    for (j = 0; j < draw.length; j++) {
      var d = draw[j], o = d.o, spr = null;
      if (d.t === 0) {
        spr = makeRock(R, o.w, U, seed ^ (j * 7919));
        var ox = Math.round(o.x - spr.ax), oy = Math.round(o.y - spr.ay);
        S.x.drawImage(spr.s.c, ox, oy);
        var sdat = spr.s.x.getImageData(0, 0, spr.s.w, spr.s.h).data, sw = spr.s.w, sh = spr.s.h, line = [];
        var solidS = function (u, v) { return u >= 0 && v >= 0 && u < sw && v < sh && sdat[(v * sw + u) * 4 + 3] > 0; };
        for (y = 0; y < sh; y++) for (x = 0; x < sw; x++) {
          if (!solidS(x, y)) continue;
          var wx = ox + x, wy = oy + y;
          if (!solidS(x, y - 1) && wy - 1 >= 0 && wx >= 0 && wx < aw && occ[(wy - 1) * aw + wx]) line.push(wx, wy - 1);
          if (!solidS(x - 1, y) && wx - 1 >= 0 && wy >= 0 && wy < ah && occ[wy * aw + wx - 1]) line.push(wx - 1, wy);
        }
        S.x.fillStyle = RK.deep;
        for (a = 0; a < line.length; a += 2) S.x.fillRect(line[a], line[a + 1], 1, 1);
        for (y = 0; y < sh; y++) for (x = 0; x < sw; x++) { var wx2 = ox + x, wy2 = oy + y; if (solidS(x, y) && wx2 >= 0 && wy2 >= 0 && wx2 < aw && wy2 < ah) occ[wy2 * aw + wx2] = 1; }
        continue;
      }
      if (d.t === 1) spr = makePlant(R, o.size, PF[o.fam]);
      else if (d.t === 2) spr = makeBlades(R, o.h, U);
      else if (o.kind === 0) tuft(S, R, o.x, o.y, DARK, 4 + Math.floor(R() * 3), Math.round((4 + R() * 2) * U));
      else if (o.kind === 1) tuft(S, R, o.x, o.y, MIXT, 4 + Math.floor(R() * 3), Math.round((4 + R() * 3) * U));
      else tuft(S, R, o.x, o.y, LITE, 3 + Math.floor(R() * 3), Math.round((4 + R() * 3) * U));
      if (spr) S.x.drawImage(spr.s.c, Math.round(o.x - spr.ax), Math.round(o.y - spr.ay));
    }

    paintPixelGround.last = { dirt: dirts.length, rocks: rocks.length, plants: plants.length + clumps.length, tufts: tufts.length };   // counts, for checking
    // 11. on to the screen at a whole-number scale, clipped to W x H
    ctx.save();
    ctx.beginPath(); ctx.rect(0, 0, W, H); ctx.clip();
    PIX.blit(ctx, S, 0, 0, scale);
    ctx.restore();
  }

  // dirt patch: ragged flat blob (or a broken chain of blobs) with light and dark blobs inside; grass eats into every edge
  function paintDirt(T, Tpre, aw, ah, D, R, sd, U) {
    var blobs = [], crumbs = [], j, x, y, k, nf;
    if (D.chain) {
      for (j = 0; j < D.chain.length; j++) {
        var c = D.chain[j]; blobs.push(c);
        if (R() < 0.5) blobs.push({ x: c.x + (R() - 0.5) * c.rx, y: c.y + (R() - 0.5) * c.ry * 0.6, rx: c.rx * (0.5 + R() * 0.2), ry: c.ry * (0.6 + R() * 0.3) });
      }
      nf = 1 + Math.floor(R() * 2);
    } else {
      blobs.push({ x: D.x, y: D.y, rx: D.rx, ry: D.ry });
      var nb = 1 + Math.floor(R() * 2);
      for (j = 0; j < nb; j++) blobs.push({ x: D.x + (R() - 0.5) * D.rx * 1.2, y: D.y + (R() - 0.5) * D.ry * 0.8, rx: D.rx * (0.45 + R() * 0.25), ry: D.ry * (0.6 + R() * 0.3) });
      nf = 2 + Math.floor(R() * 3);
    }
    for (j = 0; j < nf; j++) {
      var bb = blobs[Math.floor(R() * blobs.length)], an = R() * Math.PI * 2, dist = 1.05 + R() * 0.3;
      crumbs.push({ x: bb.x + Math.cos(an) * bb.rx * dist, y: bb.y + Math.sin(an) * bb.ry * dist, rx: (1.5 + R() * 1.4) * U, ry: (1 + R() * 0.6) * U });
    }
    var bx0 = 1e9, bx1 = -1e9, by0 = 1e9, by1 = -1e9, all = blobs.concat(crumbs);
    for (j = 0; j < all.length; j++) { bx0 = Math.min(bx0, all[j].x - all[j].rx * 1.6); bx1 = Math.max(bx1, all[j].x + all[j].rx * 1.6); by0 = Math.min(by0, all[j].y - all[j].ry * 2); by1 = Math.max(by1, all[j].y + all[j].ry * 2); }
    var x0 = Math.max(0, Math.floor(bx0)), x1 = Math.min(aw - 1, Math.ceil(bx1)), y0 = Math.max(0, Math.floor(by0)), y1 = Math.min(ah - 1, Math.ceil(by1));
    if (x1 < x0 || y1 < y0) return;
    var bw = x1 - x0 + 1, bh = y1 - y0 + 1, mask = new Uint8Array(bw * bh), V = new Float32Array(bw * bh), nfx = 3.2 * U, nfy = 2 * U;
    for (y = y0; y <= y1; y++) for (x = x0; x <= x1; x++) {
      var v = -9, cv = -9, b, ex, ey;
      for (j = 0; j < blobs.length; j++) { b = blobs[j]; ex = (x + 0.5 - b.x) / b.rx; ey = (y + 0.5 - b.y) / b.ry; v = Math.max(v, 1 - (ex * ex + ey * ey)); }
      for (j = 0; j < crumbs.length; j++) { b = crumbs[j]; ex = (x + 0.5 - b.x) / b.rx; ey = (y + 0.5 - b.y) / b.ry; cv = Math.max(cv, 1 - (ex * ex + ey * ey)); }
      var nz = (vnoise(x / nfx, y / nfy, sd) - 0.5) * 0.7, mi = (y - y0) * bw + (x - x0);
      V[mi] = v + nz;
      if (v + nz > 0) mask[mi] = 1;
      else if (cv + nz * 0.5 > 0.1) mask[mi] = 2;
    }
    function inM(xx, yy) { return xx >= x0 && xx <= x1 && yy >= y0 && yy <= y1 && mask[(yy - y0) * bw + (xx - x0)] > 0; }
    // grass teeth on every edge: up from the bottom, down from the top, in from the sides (1 or 2 art px)
    var eat = new Uint8Array(bw * bh), tl = Math.max(1, Math.round(U));
    function eatAt(xx, yy, lite) { if (inM(xx, yy)) { var e = (yy - y0) * bw + (xx - x0); if (!eat[e]) eat[e] = lite ? 2 : 1; } }
    for (y = y0; y <= y1; y++) for (x = x0; x <= x1; x++) {
      if (mask[(y - y0) * bw + (x - x0)] !== 1) continue;
      var dn = !inM(x, y + 1), upE = !inM(x, y - 1), lf = !inM(x - 1, y), rt = !inM(x + 1, y), n2;
      if (dn && hash(x, y, sd ^ 0x99) < 0.34) {
        var lite = hash(x, y, sd ^ 0x17) < 0.35, ln = tl + (hash(x, y, sd ^ 0xaa) < 0.4 ? tl : 0);
        for (n2 = 0; n2 < ln; n2++) eatAt(x, y - n2, lite);
      } else if (upE && hash(x, y, sd ^ 0x5b) < 0.26) {
        for (n2 = 0; n2 < tl + (hash(x, y, sd ^ 0x6c) < 0.25 ? tl : 0); n2++) eatAt(x, y + n2, false);
      } else if ((lf || rt) && !dn && !upE && hash(x, y, sd ^ 0x3d) < 0.3) {
        for (n2 = 0; n2 < tl + (hash(x, y, sd ^ 0x4e) < 0.3 ? tl : 0); n2++) eatAt(x + (lf ? n2 : -n2), y, false);
      }
    }
    var cells = [];
    for (y = y0; y <= y1; y++) for (x = x0; x <= x1; x++) {
      var mi2 = (y - y0) * bw + (x - x0);
      if (!mask[mi2]) continue;
      k = y * aw + x;
      if (eat[mi2]) { T[k] = eat[mi2] === 2 ? adj(plain(Tpre[k]), 2) : Tpre[k]; continue; }
      T[k] = D_BASE; cells.push(x, y);
    }
    // break up the flat fill: 3 to 6 px blobs of light and dark dirt
    var nbl = Math.max(2, Math.round(cells.length / 2 / (36 * U * U)));
    for (j = 0; j < nbl && cells.length; j++) {
      var ci = Math.floor(R() * cells.length / 2) * 2, cx = cells[ci] + 0.5, cy = cells[ci + 1] + 0.5;
      var tone = R() < 0.68 ? D_LITE : D_DARK, brx = (tone === D_LITE ? 1.8 + R() * 1.3 : 1 + R() * 1) * U, bry = (tone === D_LITE ? 1.1 + R() * 0.6 : 0.7 + R() * 0.4) * U;
      for (y = Math.floor(cy - bry - 1); y <= Math.ceil(cy + bry + 1); y++) for (x = Math.floor(cx - brx - 1); x <= Math.ceil(cx + brx + 1); x++) {
        if (x < 0 || y < 0 || x >= aw || y >= ah) continue;
        var e1 = ((x + 0.5 - cx) / brx), e2 = ((y + 0.5 - cy) / bry), ee = e1 * e1 + e2 * e2 + (hash(x, y, sd ^ 0x2a) - 0.5) * 0.5;
        k = y * aw + x;
        if (ee < 1 && T[k] === D_BASE) T[k] = tone;
      }
    }
    // a lighter dry rim of grass around the patch, soft and broken
    for (y = y0; y <= y1; y++) for (x = x0; x <= x1; x++) {
      var mi3 = (y - y0) * bw + (x - x0);
      if (mask[mi3] || V[mi3] <= -0.55) continue;
      k = y * aw + x;
      if (isGrass(T[k]) && vnoise(x / (2.2 * U), y / (1.4 * U), sd ^ 0x1f) > 0.52) T[k] = adj(T[k], 1);
    }
    // one or two pebbles: a flat light top over a dark underside, far apart and on different rows (two close dots read as eyes)
    function dirtAt(xx, yy) { if (xx < 0 || yy < 0 || xx >= aw || yy >= ah) return false; var t = T[yy * aw + xx]; return t >= D_DARK && t <= D_LITE; }
    var np = 1 + (R() < 0.5 ? 1 : 0), peb = [];
    for (j = 0; j < np * 5 && peb.length < np && cells.length; j++) {
      var pi = Math.floor(R() * cells.length / 2) * 2, px0 = cells[pi], py0 = cells[pi + 1], pw = R() < 0.5 ? 2 : 1, okp = true;
      for (var e = 0; e < peb.length; e++) if (Math.abs(peb[e][0] - px0) < 6 * U || Math.abs(peb[e][1] - py0) < 2) okp = false;
      if (!okp || !(dirtAt(px0 - 1, py0) && dirtAt(px0 + pw, py0) && dirtAt(px0, py0 + 2) && dirtAt(px0 + pw - 1, py0 + 2))) continue;
      for (var e2 = 0; e2 < pw; e2++) { T[py0 * aw + px0 + e2] = D_PL; T[(py0 + 1) * aw + px0 + e2] = D_PD; }
      peb.push([px0, py0]);
    }
  }

  // darken an elliptical patch of ground, with a ragged edge
  function shadow(T, aw, ah, cx, cy, rx, ry, amt, sd) {
    var x0 = Math.max(0, Math.floor(cx - rx - 1)), x1 = Math.min(aw - 1, Math.ceil(cx + rx + 1));
    var y0 = Math.max(0, Math.floor(cy - ry - 1)), y1 = Math.min(ah - 1, Math.ceil(cy + ry + 1)), x, y;
    for (y = y0; y <= y1; y++) for (x = x0; x <= x1; x++) {
      var ex = (x + 0.5 - cx) / rx, ey = (y + 0.5 - cy) / ry, e = ex * ex + ey * ey + (hash(x >> 1, y, sd) - 0.5) * 0.3;
      if (e >= 1) continue;
      var k = y * aw + x;
      T[k] = adj(T[k], e < 0.5 ? -amt : -Math.ceil(amt / 2));
    }
  }

  root.paintPixelGround = paintPixelGround;
})(typeof window !== 'undefined' ? window : this);
