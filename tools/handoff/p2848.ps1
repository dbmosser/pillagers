$ErrorActionPreference = 'Stop'
trap { Write-Output "FAILED: $_"; exit 1 }
$p = 'C:\claudecode\dark raiders\dark_raiders.html'
$s = [IO.File]::ReadAllText($p)
$n = 0
function SubRx([string]$old, [string]$new) {
  $pat = ($old -split "`n" | ForEach-Object { [regex]::Escape($_.TrimEnd("`r")) }) -join "\r?\n"
  $c = ([regex]::Matches($script:s, $pat)).Count
  if ($c -ne 1) { throw "regex matched $c times: $($old.Substring(0,[Math]::Min(70,$old.Length)))" }
  $new = $new.Replace("`r`n", "`n")
  $script:s = [regex]::Replace($script:s, $pat, { param($m) $new })
  $script:n++
}

# YOUR TEAMMATE'S SHIELD BUBBLE IS SEEN IN YOUR WINDOW (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
  if(G.arcade&&p.arcSh) msg.sh=1;   // v23.30 (arcade9): only while shielded
'@ @'
  if(G.arcade&&p.arcSh) msg.sh=1;   // v23.30 (arcade9): only while shielded
  if(pwrOn('shield')) msg.pb=1;   // v28.48 (cloud-coop-teammate-shield-bubble), CLOUD HUNT 2026-10-15: pb, his SHIELD BUBBLE power-up is up, so his teammate sees the bubble too
'@

SubRx @'
  if(up&&(m.sh||g.sh)) g.sh=m.sh?1:0;   // v23.30 (arcade9): the teammate spawn shield
'@ @'
  if(up&&(m.sh||g.sh)) g.sh=m.sh?1:0;   // v23.30 (arcade9): the teammate spawn shield
  if(up) g.pb=m.pb?1:0;   // v28.48 (cloud-coop-teammate-shield-bubble), CLOUD HUNT 2026-10-15: his SHIELD BUBBLE, kept from every word; a word without it (an older window) reads as no bubble
'@

SubRx @'
    if(up&&g.fk){ out.fk=g.fk; if(g.el) out.el=g.el; }   // v23.xx (forge8)
'@ @'
    if(up&&g.fk){ out.fk=g.fk; if(g.el) out.el=g.el; }   // v23.xx (forge8)
    if(up&&g.pb) out.pb=1;   // v28.48 (cloud-coop-teammate-shield-bubble), CLOUD HUNT 2026-10-15: his SHIELD BUBBLE passed on as it came
'@

SubRx @'
    if(g.sh&&G&&G.arcade) arcadeShieldRing(g.x,g.y,0);   // v23.30 (arcade9)
'@ @'
    if(g.sh&&G&&G.arcade) arcadeShieldRing(g.x,g.y,0);   // v23.30 (arcade9)
    if(g.pb&&G&&(G.arcade||G.career)) pwrBubbleUp(g);   // v28.48 (cloud-coop-teammate-shield-bubble), CLOUD HUNT 2026-10-15: his SHIELD BUBBLE, drawn round him as his own window draws it
'@

SubRx @'
function pwrDraw2(c,p){
'@ @'
function pwrBubbleUp(g){   // v28.48 (cloud-coop-teammate-shield-bubble), CLOUD HUNT 2026-10-15: a teammate SHIELD BUBBLE on the world canvas, in world units: the same bubble pwrDraw2 draws round your own player (radius 34, centre 14 up), without the flash and the end blink, which only his own window knows
  var q, z, t, R=34, cy, gr, k, ang;
  if(!G||G.sim||!(G.arcade||G.career)||!wc||!g||!isFinite(g.x)||!isFinite(g.y)) return;
  q=ZOOM()||1; z=Math.max(1,hudRes()); t=+G.t||0; cy=g.y-14;
  wc.save(); wc.globalAlpha=1; wc.globalCompositeOperation='lighter';
  gr=wc.createRadialGradient(g.x,cy,R*0.5,g.x,cy,R);
  gr.addColorStop(0,'rgba(79,240,224,0)'); gr.addColorStop(1,'rgba(79,240,224,0.220)');
  wc.fillStyle=gr; wc.beginPath(); wc.arc(g.x,cy,R,0,6.2832); wc.fill();
  wc.strokeStyle='rgba(150,255,245,0.550)'; wc.lineWidth=2*z/q; wc.beginPath(); wc.arc(g.x,cy,R,0,6.2832); wc.stroke();
  wc.lineWidth=1.2*z/q; wc.strokeStyle='rgba(120,250,236,.38)';
  for(k=0;k<6;k++){ ang=t*0.6+k*1.0472; wc.beginPath(); wc.arc(g.x,cy,R*0.82,ang,ang+0.55); wc.stroke(); }
  wc.restore();
}
function pwrDraw2(c,p){
'@

SubRx @'
var VER='28.47';
'@ @'
var VER='28.48';
'@

$pat = "(?m)^  now:'v28\.47:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v28.48: In co-op, when your teammate picks up a SHIELD BUBBLE you now see the bubble round him too. Check 28.48 fails on v28.47',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
