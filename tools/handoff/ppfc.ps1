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

# THE RAIDER RISES FROM UNDERGROUND AND RARE DROPS GET LIGHT SHAFTS (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
function startRaid(){

'@ @'
// v28.xx (cw-ascent), HIS PICK 77 (2026-10-14): "you don't drop in, you come up from underground". A raid starts with the raider rising out of a
// dark hatch in the ground (1.3 s, ease out) and extraction sinks him back into it over the 1.4 s boarding hold, so the exit matches. It is
// only how the figure is drawn: he can move, shoot and roll the whole time, and the first key, click, touch, step or shot ends the rise at
// once. ascentSink gives how many pixels of him are still below the ground (0 = none); sim raids and a downed raider never sink. No seeded draw.
var RISE_SEC=1.3, ASC_SINK=56;
function ascentSink(p){
  var g=G, r, k, s=0, z, i, zs;
  if(!g||g.sim||!p||p.downed) return 0;
  r=g.rise;
  if(r){
    if(p.moving||(p.muzzle>0)||(p.roll>0)||g.over){ g.rise=null; }
    else {
      k=((g.t||0)-r.t0)/r.dur;
      if(!(k<1)){ g.rise=null; }
      else { k=Math.max(0,k); s=ASC_SINK*(1-k)*(1-k)*(1-k); }
    }
  }
  zs=g.zones;
  if(zs&&!g.over) for(i=0;i<zs.length;i++){ z=zs[i]; if(z&&z.pullT>0){ k=Math.min(1,z.pullT/1.4); s=Math.max(s,ASC_SINK*k*k); } }
  return s;
}
['keydown','mousedown','touchstart'].forEach(function(n){ window.addEventListener(n,function(e){ if(e&&e.repeat) return; if(G&&G.rise) G.rise=null; },true); });
// the hatch, the teal light up out of it and the clip at the ground line; ascentEnd closes the clip and draws the dust ring
function ascentBegin(p,s){
  var f=s/ASC_SINK, y=p.y, gr;
  wc.save();
  wc.fillStyle='rgba(6,5,10,'+(.8*f).toFixed(3)+')'; wc.beginPath(); wc.ellipse(p.x,y,12+4*f,4.5+1.5*f,0,0,6.2832); wc.fill();
  wc.globalCompositeOperation='lighter';
  gr=wc.createLinearGradient(0,y-70,0,y);
  gr.addColorStop(0,'rgba(53,214,200,0)'); gr.addColorStop(1,'rgba(53,214,200,'+(.30*f).toFixed(3)+')');
  wc.fillStyle=gr; wc.fillRect(p.x-9,y-70,18,70);
  wc.restore();
  wc.save(); wc.beginPath(); wc.rect(p.x-40,y-110,80,111); wc.clip(); wc.translate(0,s);
}
function ascentEnd(p,s){
  var f=s/ASC_SINK;
  wc.restore();
  wc.save(); wc.strokeStyle='rgba(205,195,170,'+(.5*f).toFixed(3)+')'; wc.lineWidth=1.2;
  wc.beginPath(); wc.ellipse(p.x,p.y,14+18*(1-f),5+6*(1-f),0,0,6.2832); wc.stroke();
  wc.restore();
}
// v28.xx (cw-ascent), HIS PICK 75 (2026-10-14): "rarity light shafts ... integrate it". A pile somebody DROPPED (his own drop or a teammate's: the
// contents are known to everyone) stands in a column of its best rarity's colour: taller and brighter the rarer it is, none for common.
// A box nobody has opened never gets one (his 2026-08-26 note: a box must not tell what it holds), and v28.xx lean6 stays: no ring, no pulse dot.
var RSHAFT={uncommon:[58,.20],rare:[88,.30],elite:[118,.38],gold:[148,.46]};
function lootShaft(ct,lift){
  var r=ct.best, S=RSHAFT[r], c=RCOL[r], x=ct.x, y=ct.y-lift*0.5, h, a, gr;
  if(!S||!c) return;
  h=S[0]; a=S[1]*(1+.18*Math.sin((G.t||0)*2.2+ct.x*.05));
  wc.save(); wc.globalCompositeOperation='lighter';
  gr=wc.createLinearGradient(0,y-h,0,y);
  gr.addColorStop(0,hexA(c,0)); gr.addColorStop(.7,hexA(c,(a*.5).toFixed(3))); gr.addColorStop(1,hexA(c,a.toFixed(3)));
  wc.fillStyle=gr; wc.fillRect(x-5,y-h,10,h);
  gr=wc.createLinearGradient(0,y-h,0,y);
  gr.addColorStop(0,'rgba(255,255,255,0)'); gr.addColorStop(1,'rgba(255,255,255,'+(a*.55).toFixed(3)+')');
  wc.fillStyle=gr; wc.fillRect(x-1.5,y-h,3,h);
  wc.restore();
}
function startRaid(){

'@

SubRx @'
  G.carriedIn=bagValue();

'@ @'
  G.carriedIn=bagValue();
  if(G&&!G.sim) G.rise={t0:G.t||0,dur:RISE_SEC};   // v28.xx (cw-ascent), his pick 77: he comes up from underground

'@

SubRx @'
      drawOp(p.x,p.y,p.face,p.roll>0?(1-p.roll/.38)*12.6:p.bob,'#242832',
        0,p.muzzle,
'@ @'
      var _asc=0; try{ _asc=ascentSink(p); }catch(_ae){ _asc=0; }   // v28.xx (cw-ascent), his pick 77
      if(_asc>0.5){ wc.save(); _svd++; ascentBegin(p,_asc); }
      else _asc=0;
      drawOp(p.x,p.y,p.face,p.roll>0?(1-p.roll/.38)*12.6:p.bob,'#242832',
        0,p.muzzle,
'@

SubRx @'
      try{ forgeGlow(p.x,p.y,p.face,p.wep,p.downed||p.hp<=0); }catch(_fg){}   // v23.xx (forge8): a forged gun glows at the hands

'@ @'
      try{ forgeGlow(p.x,p.y,p.face,p.wep,p.downed||p.hp<=0); }catch(_fg){}   // v23.xx (forge8): a forged gun glows at the hands
      if(_asc>0){ ascentEnd(p,_asc); wc.restore(); _svd--; }   // v28.xx (cw-ascent)

'@

SubRx @'
  wc.globalAlpha=1;
  // SPEC 7.4: partial progress is shown ON the container
'@ @'
  wc.globalAlpha=1;
  if(ct.dropped&&!ct.opened&&!G.sim&&ct.best){ try{ lootShaft(ct,lift); }catch(_ls){} }   // v28.xx (cw-ascent), his pick 75
  // SPEC 7.4: partial progress is shown ON the container
'@

SubRx @'
var VER='30.33';
'@ @'
var VER='30.34';
'@

$pat = "(?m)^  now:'v30\.33:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v30.34: You rise up out of the ground when a raid starts and sink back into it when you board, and dropped rare loot has a coloured light shaft. Check 30.34 fails on v30.33',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
