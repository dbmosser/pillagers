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

# CO-OP MARKS AND CRIER MARKER GROW AT 4K (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
function netPingDraw(){
  var i, p, now=Date.now(), s, M=LH(30), e, nm, lbl, x, y, n=0, c;
'@ @'
// v22.xx, the raid text rewrite (R43): CO-OP MARKS, THE CRIER MARKER AND THE NOISE CHEVRONS GROW AT 4K. HIS ORDER (2026-10-09): the raid
// text reads like a shooter HUD, the same size on every screen, and its distances read 120m. A ping, a teammate Waypoint, the arrow
// to a teammate off screen, the Crier ring and countdown and the noise chevrons at the screen edge were all drawn in 1080p pixels,
// so at 4K they were half the size of the HUD around them, and the distances read 120M. Their words are now hudFS, their shapes,
// line widths, gaps and edge margins grow by the screen factor, and the distances end in a small m. The Crier marker is not drawn
// over the open backpack. At 1080p only the unit letter changes.
function netPingDraw(){
  var r=Math.max(1,(typeof hudRes==='function')?hudRes():1), i, p, now=Date.now(), s, M=LH(30)*r, e, nm, lbl, x, y, n=0, c;
'@

SubRx @'
    ctx.strokeStyle=c; ctx.lineWidth=2.5;
    ctx.beginPath(); ctx.moveTo(x,y-LH(12)); ctx.lineTo(x+LH(9),y); ctx.lineTo(x,y+LH(12)); ctx.lineTo(x-LH(9),y); ctx.closePath(); ctx.stroke();
'@ @'
    ctx.strokeStyle=c; ctx.lineWidth=2.5*r;
    ctx.beginPath(); ctx.moveTo(x,y-LH(12)*r); ctx.lineTo(x+LH(9)*r,y); ctx.lineTo(x,y+LH(12)*r); ctx.lineTo(x-LH(9)*r,y); ctx.closePath(); ctx.stroke();
'@

SubRx @'
    lbl=nm+(p.w?(': '+p.w):(p.dg?': DANGER':''))+'  '+((G&&G.player)?metres(dist(G.player,p)):0)+'M';
    ctx.font=FS(TYPE.micro); ctx.textAlign='center'; ctx.fillStyle=c; ctx.fillText(lbl,clamp(x,LH(60),W-LH(60)),y-LH(16)); ctx.textAlign='left';
'@ @'
    lbl=nm+(p.w?(': '+p.w):(p.dg?': DANGER':''))+'  '+((G&&G.player)?metres(dist(G.player,p)):0)+'m';   // v22.xx (R43): 120m
    ctx.font=hudFS(TYPE.micro); ctx.textAlign='center'; ctx.fillStyle=c; ctx.fillText(lbl,clamp(x,LH(60)*r,W-LH(60)*r),y-LH(16)*r); ctx.textAlign='left';
'@

SubRx @'
function netWpDraw(){
  var s, w, q, x, y, M=LH(30), nm, n=0;
'@ @'
function netWpDraw(){
  var r=Math.max(1,(typeof hudRes==='function')?hudRes():1), s, w, q, x, y, M=LH(30)*r, nm, n=0;   // v22.xx (R43): grown with the screen
'@

SubRx @'
    ctx.strokeStyle='#bfe0ff'; ctx.lineWidth=2;
    ctx.beginPath(); ctx.arc(x,y,LH(9),0,6.2832); ctx.stroke();
    ctx.beginPath(); ctx.moveTo(x-LH(14),y); ctx.lineTo(x-LH(4),y); ctx.moveTo(x+LH(4),y); ctx.lineTo(x+LH(14),y); ctx.moveTo(x,y-LH(14)); ctx.lineTo(x,y-LH(4)); ctx.moveTo(x,y+LH(4)); ctx.lineTo(x,y+LH(14)); ctx.stroke();
    nm=netSeatName(+s)||'PILLAGER';
    ctx.font=FS(TYPE.micro); ctx.textAlign='center'; ctx.fillStyle='#bfe0ff';
    ctx.fillText(nm+' MARKER  '+((G&&G.player)?metres(dist(G.player,w)):0)+'M',clamp(x,LH(70),W-LH(70)),y-LH(18)); ctx.textAlign='left';
'@ @'
    ctx.strokeStyle='#bfe0ff'; ctx.lineWidth=2*r;
    ctx.beginPath(); ctx.arc(x,y,LH(9)*r,0,6.2832); ctx.stroke();
    ctx.beginPath(); ctx.moveTo(x-LH(14)*r,y); ctx.lineTo(x-LH(4)*r,y); ctx.moveTo(x+LH(4)*r,y); ctx.lineTo(x+LH(14)*r,y); ctx.moveTo(x,y-LH(14)*r); ctx.lineTo(x,y-LH(4)*r); ctx.moveTo(x,y+LH(4)*r); ctx.lineTo(x,y+LH(14)*r); ctx.stroke();
    nm=netSeatName(+s)||'PILLAGER';
    ctx.font=hudFS(TYPE.micro); ctx.textAlign='center'; ctx.fillStyle='#bfe0ff';
    ctx.fillText(nm+' MARKER  '+((G&&G.player)?metres(dist(G.player,w)):0)+'m',clamp(x,LH(70)*r,W-LH(70)*r),y-LH(18)*r); ctx.textAlign='left';
'@

SubRx @'
function netMateArrow(g){
  var s=w2s(g.x,0,g.y), M=LH(34), cx=W/2, cy=H/2, dx, dy, k, ax, ay, a, nm, d, c;
'@ @'
function netMateArrow(g){
  var r=Math.max(1,(typeof hudRes==='function')?hudRes():1), s=w2s(g.x,0,g.y), M=LH(34)*r, cx=W/2, cy=H/2, dx, dy, k, ax, ay, a, nm, d, c;   // v22.xx (R43): grown with the screen
'@

SubRx @'
  ctx.save(); ctx.translate(ax,ay); ctx.rotate(a);
  ctx.fillStyle=c; ctx.strokeStyle='rgba(6,9,13,.9)'; ctx.lineWidth=2;
'@ @'
  ctx.save(); ctx.translate(ax,ay); ctx.rotate(a); if(r>1) ctx.scale(r,r);
  ctx.fillStyle=c; ctx.strokeStyle='rgba(6,9,13,.9)'; ctx.lineWidth=2;
'@

SubRx @'
  ctx.font=FS(TYPE.micro); ctx.textAlign='center'; ctx.fillStyle=c;
  ctx.fillText(nm+'  '+d+'M'+(g.dn?'  DOWN':''),clamp(ax-Math.cos(a)*LH(30),LH(40),W-LH(40)),clamp(ay-Math.sin(a)*LH(22),LH(14),H-LH(8)));
'@ @'
  ctx.font=hudFS(TYPE.micro); ctx.textAlign='center'; ctx.fillStyle=c;
  ctx.fillText(nm+'  '+d+'m'+(g.dn?'  DOWN':''),clamp(ax-Math.cos(a)*LH(30)*r,LH(40)*r,W-LH(40)*r),clamp(ay-Math.sin(a)*LH(22)*r,LH(14)*r,H-LH(8)*r));
'@

SubRx @'
function drawCrierMarkers(){
  var p=G.player,ps=w2s(p.x,0,p.y);
  if(!ps) return;
'@ @'
function drawCrierMarkers(){
  var p=G.player,ps=w2s(p.x,0,p.y), _cr=Math.max(1,(typeof hudRes==='function')?hudRes():1);   // v22.xx (R43): grown with the screen
  if(!ps||G.bagOpen) return;   // v22.xx (R43): never over the open backpack
'@

SubRx @'
    var s=w2s(e.x,26,e.y);
    var pad=26;
    var onScreen=s&&s.x>pad&&s.x<W-pad&&s.y>pad&&s.y<H-pad;
    if(onScreen){
      ctx.strokeStyle='rgba(255,90,74,'+pulse+')'; ctx.lineWidth=2;
      ctx.beginPath(); ctx.arc(s.x,s.y,LH(17),0,6.2832); ctx.stroke();
      ctx.font=FS(TYPE.micro); ctx.textAlign='center';
      ctx.fillStyle='rgba(255,120,100,.95)';
      ctx.fillText('CRIER '+left.toFixed(1)+'s',s.x,s.y-LH(22));
'@ @'
    var s=w2s(e.x,26*ZOOM(),e.y);   // v22.xx (R43): the lift is in world units, so the ring stays on the Crier at 4K and zoomed in
    var pad=26*_cr;
    var onScreen=s&&s.x>pad&&s.x<W-pad&&s.y>pad&&s.y<H-pad;
    if(onScreen){
      ctx.strokeStyle='rgba(255,90,74,'+pulse+')'; ctx.lineWidth=2*_cr;
      ctx.beginPath(); ctx.arc(s.x,s.y,LH(17)*_cr,0,6.2832); ctx.stroke();
      ctx.font=hudFS(TYPE.micro); ctx.textAlign='center';
      ctx.fillStyle='rgba(255,120,100,.95)';
      ctx.fillText('CRIER '+left.toFixed(1)+'s',s.x,s.y-LH(22)*_cr);
'@

SubRx @'
      ctx.save(); ctx.translate(mx,my); ctx.rotate(ang);
      ctx.fillStyle='rgba(255,90,74,'+pulse+')';
      ctx.beginPath(); ctx.moveTo(15,0); ctx.lineTo(-10,10); ctx.lineTo(-10,-10);
      ctx.closePath(); ctx.fill();
      ctx.restore();
      ctx.font=FS(TYPE.micro); ctx.textAlign='center';
'@ @'
      ctx.save(); ctx.translate(mx,my); ctx.rotate(ang); if(_cr>1) ctx.scale(_cr,_cr);
      ctx.fillStyle='rgba(255,90,74,'+pulse+')';
      ctx.beginPath(); ctx.moveTo(15,0); ctx.lineTo(-10,10); ctx.lineTo(-10,-10);
      ctx.closePath(); ctx.fill();
      ctx.restore();
      ctx.font=hudFS(TYPE.micro); ctx.textAlign='center';
'@

SubRx @'
      var _lx=clamp(mx-ca*LH(26),LH(42),W-LH(42));
      var _ly=clamp(my-sa*LH(26),LH(20),H-LH(12));
'@ @'
      var _lx=clamp(mx-ca*LH(26)*_cr,LH(42)*_cr,W-LH(42)*_cr);
      var _ly=clamp(my-sa*LH(26)*_cr,LH(20)*_cr,H-LH(12)*_cr);
'@

SubRx @'
function drawNoiseMarkers(){
  var p=G.player,i;
'@ @'
function drawNoiseMarkers(){
  var p=G.player,i,_nr=Math.max(1,(typeof hudRes==='function')?hudRes():1);   // v22.xx (R43): the chevrons grow with the screen
'@

SubRx @'
    var pad=26;
    var off=(s.x<pad||s.x>W-pad||s.y<pad||s.y>H-pad);
'@ @'
    var pad=26*_nr;
    var off=(s.x<pad||s.x>W-pad||s.y<pad||s.y>H-pad);
'@

SubRx @'
    var sz=6+Math.min(pn.s,600)/110;
'@ @'
    var sz=(6+Math.min(pn.s,600)/110)*_nr;
'@

SubRx @'
var VER='22.93';
'@ @'
var VER='22.94';
'@

$pat = "(?m)^  now:'v22\.93:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v22.94: On a 4K screen pings, teammate marks, the Crier countdown and the noise arrows are now full size, and distances read 120m. Check 22.94 fails on v22.93',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
