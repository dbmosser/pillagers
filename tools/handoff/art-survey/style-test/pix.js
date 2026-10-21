// pix.js : small pixel-art helpers for the style test (job: his 10-20 pixel-art reference, ref-his-lineup.webp).
// The idea the game could use too: draw each thing at ART-PIXEL size on a small canvas with whole-pixel shapes only, run the passes
// below (harden, rim light, outline), then put it on screen at 3x or 4x with no smoothing. Plain browser JS, no libraries.
var PIX = (function () {
  function canvas(w, h) {
    var c = document.createElement('canvas'); c.width = w; c.height = h;
    var x = c.getContext('2d'); x.imageSmoothingEnabled = false;
    return { c: c, x: x, w: w, h: h };
  }
  function rect(s, col, a, b, w, h) { s.x.fillStyle = col; s.x.fillRect(Math.round(a), Math.round(b), Math.round(w), Math.round(h)); }
  function px(s, col, a, b) { s.x.fillStyle = col; s.x.fillRect(Math.round(a), Math.round(b), 1, 1); }
  // filled ellipse made of whole-pixel rows (no anti-aliasing)
  function ellipse(s, col, cx, cy, rx, ry) {
    s.x.fillStyle = col;
    for (var yy = -ry; yy <= ry; yy++) {
      var t = 1 - (yy * yy) / ((ry + 0.5) * (ry + 0.5)); if (t < 0) continue;
      var hw = Math.round(rx * Math.sqrt(t));
      s.x.fillRect(Math.round(cx - hw), Math.round(cy + yy), hw * 2 + 1, 1);
    }
  }
  // one-pixel line (Bresenham)
  function line(s, col, x0, y0, x1, y1) {
    x0 = Math.round(x0); y0 = Math.round(y0); x1 = Math.round(x1); y1 = Math.round(y1);
    var dx = Math.abs(x1 - x0), dy = -Math.abs(y1 - y0), sx = x0 < x1 ? 1 : -1, sy = y0 < y1 ? 1 : -1, e = dx + dy;
    s.x.fillStyle = col;
    for (;;) { s.x.fillRect(x0, y0, 1, 1); if (x0 === x1 && y0 === y1) break; var e2 = 2 * e; if (e2 >= dy) { e += dy; x0 += sx; } if (e2 <= dx) { e += dx; y0 += sy; } }
  }
  function data(s) { return s.x.getImageData(0, 0, s.w, s.h); }
  function solidAt(d, w, h, a, b) { return a >= 0 && b >= 0 && a < w && b < h && d.data[(b * w + a) * 4 + 3] > 0; }
  // every pixel is either fully solid or fully clear (kills any soft edge from arcs, text or drawImage)
  function harden(s, cut) {
    var d = data(s), p = d.data, k; cut = cut == null ? 128 : cut;
    for (k = 3; k < p.length; k += 4) p[k] = p[k] >= cut ? 255 : 0;
    s.x.putImageData(d, 0, 0); return s;
  }
  // light from the top left: a solid pixel with a clear pixel above (or to its left) is lightened, one with a clear pixel below (or right) is darkened
  function rim(s, up, down) {
    var d = data(s), out = new Uint8ClampedArray(d.data), w = s.w, h = s.h, a, b, i, f;
    up = up == null ? 0.22 : up; down = down == null ? 0.22 : down;
    for (b = 0; b < h; b++) for (a = 0; a < w; a++) {
      if (!solidAt(d, w, h, a, b)) continue;
      i = (b * w + a) * 4; f = 0;
      if (!solidAt(d, w, h, a, b - 1) || !solidAt(d, w, h, a - 1, b)) f = up;
      else if (!solidAt(d, w, h, a, b + 1) || !solidAt(d, w, h, a + 1, b)) f = -down;
      if (f > 0) { out[i] += (255 - out[i]) * f; out[i + 1] += (255 - out[i + 1]) * f; out[i + 2] += (255 - out[i + 2]) * f; }
      else if (f < 0) { out[i] *= 1 + f; out[i + 1] *= 1 + f; out[i + 2] *= 1 + f; }
    }
    d.data.set(out); s.x.putImageData(d, 0, 0); return s;
  }
  // outline: every clear pixel that touches a solid one becomes `col` (4 neighbours; diag=true adds the corners)
  function outline(s, col, diag) {
    var d = data(s), w = s.w, h = s.h, a, b, list = [];
    for (b = 0; b < h; b++) for (a = 0; a < w; a++) {
      if (solidAt(d, w, h, a, b)) continue;
      if (solidAt(d, w, h, a - 1, b) || solidAt(d, w, h, a + 1, b) || solidAt(d, w, h, a, b - 1) || solidAt(d, w, h, a, b + 1) ||
          (diag && (solidAt(d, w, h, a - 1, b - 1) || solidAt(d, w, h, a + 1, b - 1) || solidAt(d, w, h, a - 1, b + 1) || solidAt(d, w, h, a + 1, b + 1)))) list.push(a, b);
    }
    s.x.fillStyle = col || '#141018';
    for (a = 0; a < list.length; a += 2) s.x.fillRect(list[a], list[a + 1], 1, 1);
    return s;
  }
  // put a small art canvas on the real canvas at a whole-number scale, no smoothing
  function blit(ctx, s, x, y, scale) {
    var old = ctx.imageSmoothingEnabled; ctx.imageSmoothingEnabled = false;
    ctx.drawImage(s.c, Math.round(x), Math.round(y), s.w * scale, s.h * scale);
    ctx.imageSmoothingEnabled = old;
  }
  // '#rrggbb' lightened (f > 0) or darkened (f < 0), -1..1
  function shade(hex, f) {
    var n = parseInt(hex.slice(1), 16), r = n >> 16, g = (n >> 8) & 255, b = n & 255;
    function m(v) { return Math.max(0, Math.min(255, Math.round(f >= 0 ? v + (255 - v) * f : v * (1 + f)))); }
    return '#' + ((1 << 24) + (m(r) << 16) + (m(g) << 8) + m(b)).toString(16).slice(1);
  }
  // seeded random numbers (mulberry32), so every picture is the same each time
  function rng(seed) {
    var t = seed >>> 0;
    return function () { t += 0x6D2B79F5; var r = Math.imul(t ^ (t >>> 15), 1 | t); r ^= r + Math.imul(r ^ (r >>> 7), 61 | r); return ((r ^ (r >>> 14)) >>> 0) / 4294967296; };
  }
  return { canvas: canvas, rect: rect, px: px, ellipse: ellipse, line: line, harden: harden, rim: rim, outline: outline, blit: blit, shade: shade, rng: rng };
})();
