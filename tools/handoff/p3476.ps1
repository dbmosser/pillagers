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

# GLOW POOLS: THE FORGE, FORGED GUNS AND ELEMENTS LIGHT THE WORLD (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
function gfxqApply(){ var q=DRS.q|0; GFXQ.q=q; GFXQ.post=1; GFXQ.shadow=1;
'@ @'
function gfxqApply(){ var q=DRS.q|0; GFXQ.q=q; GFXQ.post=q>=2?0:1; GFXQ.shadow=1;
'@

SubRx @'
function gfxqCan(l){ if(l==='post'||l==='shadow') return false;
'@ @'
function gfxqCan(l){ if(l==='shadow') return false; if(l==='post') return true;
'@

SubRx @'
    if(az){
      k=inb?(90+120*urg):70;
'@ @'
    // v34.xx (cw-glowpools), his 10-12 graphics list ("add ALL of this stuff"), I5: the glow sources the world pass queued this frame (the forge
    // furnace, a forged gun, burning, shocked and frozen bodies) light the ground in their own colour. The same sprite the lamps use, in the
    // light map; the halo over the world is drawn by gfxGlowHalo before the fog. POST FX off, the effect rung or intensity 0 draw none.
    GFX.glowL=0;
    if(gfxPostNow()&&GFX.emit.length){
      fk=gfxGlowK();
      if(fk>0) for(i=0;i<GFX.emit.length;i++){
        E=GFX.emit[i]; er=E.r*1.6;
        if(!(er>0)||E.x<ox-er||E.x>ox+VW+er||E.y<oy-er||E.y>oy+VH+er) continue;
        put(gfxLightSpr(E.c,'map'),E.x,E.y+8,er,2*a*.55*E.a*fk); GFX.glowL++;
      }
    }
    if(az){
      k=inb?(90+120*urg):70;
'@

SubRx @'
function gfxPreFog(dt){ return gfxHook('prefog'); }   // F2: bloom; loot beams
'@ @'
function gfxPreFog(dt,ox,oy,Z,VW,VH){ if(!gfxHook('prefog')) return false; return gfxGlowHalo(ox,oy,Z,VW,VH); }   // F2: bloom; loot beams
function gfxGlowK(){ return (CFG.fxInt===undefined)?1:Math.max(0,Math.min(1,+CFG.fxInt||0)); }   // v34.xx (cw-glowpools): EFFECT INTENSITY scales the glow
// v34.xx (cw-glowpools), I5: the soft halo of every glow source queued this frame, one cached sprite each, added over the world and under the fog.
// No blur; the centre sits on the art pixel grid in the pixel look. Returns how many it drew (GFX.glowN).
function gfxGlowHalo(ox,oy,Z,VW,VH){
  var L=GFX.emit, i, e, k, r, n=0, day;
  GFX.glowN=0;
  if(!L.length||!wc||!(Z>0)||!gfxPostNow()) return 0;
  k=gfxGlowK(); if(!(k>0)) return 0;
  day=isDay();
  wc.save(); wc.scale(Z,Z); wc.translate(-ox,-oy); wc.globalCompositeOperation='lighter';
  try{
    for(i=0;i<L.length;i++){
      e=L[i]; r=e.r*1.1;
      if(!(r>0)||e.x<ox-r||e.x>ox+VW+r||e.y<oy-r||e.y>oy+VH+r) continue;
      wc.globalAlpha=Math.min(.6,e.a*k*(day?.12:.28));
      wc.drawImage(gfxLightSpr(e.c,'glow'),pixMarkSnap(e.x)-r,pixMarkSnap(e.y)-r,r*2,r*2); n++;
    }
  } finally { wc.restore(); wc.globalAlpha=1; wc.globalCompositeOperation='source-over'; }
  GFX.glowN=n; return n;
}
'@

SubRx @'
  try{ gfxPreFog(dt); }catch(_gpf){}
'@ @'
  try{ gfxPreFog(dt,ox,oy,Z,VW,VH); }catch(_gpf){}
'@

SubRx @'
hint:'Bloom and colour grade. Off runs faster.'
'@ @'
hint:'Glow pools from the forge, fire and shock. Off runs faster.'
'@

SubRx @'
var VER='34.75';
'@ @'
var VER='34.76';
'@

$pat = "(?m)^  now:'v34\.75:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v34.76: The forge and the elements cast a soft coloured light on the ground and a gentle halo; POST FX off, effect intensity 0 or a busy frame removes it. Check 34.76 fails on v34.75',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
