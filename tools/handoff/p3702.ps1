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

# THE PICTURE STORES KEEP A RUNNING TOTAL (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
  row.pix=pixTelRow();   // v33.51 (cw-pixkit): builds, bake ms, hits, misses, bytes and the device scale S

'@ @'
  row.pix=pixTelRow();   // v33.51 (cw-pixkit): builds, bake ms, hits, misses, bytes and the device scale S
  picTelFill(row);   // v28.xx (cw-picstoretotal): the running total of the off screen picture stores

'@

SubRx @'
// ---- the kit, from the style test (tools/handoff/art-survey/style-test): 4 tone ramps, banding toward the top left light, harden, ink ring, silhouettes, palette swap ----

'@ @'
// v28.xx (cw-picstoretotal), the research brief of 10-25 (row 17, leak watch; the party runs about 3 hours and one picture store grew once before, v32.75): ONE RUNNING TOTAL OF THE OFF
// SCREEN PICTURE STORES. Each store kept its own count (WALLSPR.n, SHADSPR.n, ICONSPR.n, the gfxStore ones) and nothing added them up. picStoreTotal() walks the wall, tree, shadow and icon
// stores, every registered gfxStore (guns, lights, muzzle flashes, effects), the byte capped pixel stores and the big baked canvases (ground, fog of war, hub, fog and light sheets) and
// returns {n: pictures, b: estimated bytes (width x height x 4), pn/pb: the biggest n and b seen this raid, by: {store: [n, b]}}. It is cached for a second, so the frame telemetry can
// ask every frame. The run record and the flight recorder carry it as gfx.pic ("pics:" on the run line). Reads only: no seeded draw, nothing a raid plays by.
var PICTOT={t:0,v:null,pn:0,pb:0,g:null};
function picBytes(e){
  if(!e) return 0;
  if(e.width>0&&e.height>0) return e.width*e.height*4;
  if(e.c&&e.c.width>0&&e.c.height>0) return e.c.width*e.c.height*4;
  return 0;
}
function picStoreTotal(fresh){
  var now=gfxNow(), by={}, maps={wall:WALLSPR.m,veg:VEGSPR.m,shad:SHADSPR.m,icon:ICONSPR.m}, n=0, b=0, nm, map, k, sn, sb, g=(typeof G!=='undefined')?G:null, big=[], v, i;
  if(!fresh&&PICTOT.v&&now-PICTOT.t<1000) return PICTOT.v;
  for(nm in GFXSTORES) if(Object.prototype.hasOwnProperty.call(GFXSTORES,nm)) maps['g.'+nm]=GFXSTORES[nm].m;
  for(nm in maps){
    map=maps[nm]; sn=0; sb=0;
    for(k in map){ if(!Object.prototype.hasOwnProperty.call(map,k)||!map[k]) continue; sn++; sb+=picBytes(map[k]); }
    by[nm]=[sn,sb]; n+=sn; b+=sb;
  }
  for(nm in PIXSTORE.m){ sn=PIXSTORE.m[nm].size; sb=PIXSTORE.bytes[nm]||0; by['pix.'+nm]=[sn,sb]; n+=sn; b+=sb; }
  big=[g&&g.ground, g&&g._fowCv, (typeof hubGround!=='undefined')?hubGround:null, fogC, litC]; sn=0; sb=0;
  for(i=0;i<big.length;i++) if(big[i]&&big[i].width>0){ sn++; sb+=big[i].width*big[i].height*4; }
  by.big=[sn,sb]; n+=sn; b+=sb;
  if(PICTOT.g!==g){ PICTOT.g=g; PICTOT.pn=0; PICTOT.pb=0; }
  if(n>PICTOT.pn) PICTOT.pn=n;
  if(b>PICTOT.pb) PICTOT.pb=b;
  v={n:n,b:b,pn:PICTOT.pn,pb:PICTOT.pb,t:Math.round(now),by:by};
  PICTOT.v=v; PICTOT.t=now;
  return v;
}
function picRowCopy(v){
  var by={}, k;
  if(!v) return null;
  for(k in v.by) by[k]=v.by[k].slice();
  return {n:v.n,b:v.b,pn:v.pn,pb:v.pb,t:v.t,by:by};
}
function picTelFill(row){
  var v=picStoreTotal();
  if(!row.pic||row.pic.t!==v.t) row.pic=picRowCopy(v);
  return row.pic;
}
function picLine(p){   // the run line of the flight recorder: total pictures and megabytes now, the peak, and the count in each store
  var k, s=[];
  if(!p) return '';
  for(k in p.by) s.push(k+' '+p.by[k][0]);
  return ' pics:'+p.n+'/'+(Math.round(p.b/104857.6)/10)+'mb peak:'+p.pn+'/'+(Math.round(p.pb/104857.6)/10)+'mb by:'+s.join(',');
}// ---- the kit, from the style test (tools/handoff/art-survey/style-test): 4 tone ramps, banding toward the top left light, harden, ink ring, silhouettes, palette swap ----

'@

SubRx @'
cap:T.gfx.cap||0}:null,
'@ @'
cap:T.gfx.cap||0,pic:picRowCopy(T.gfx.pic)}:null,
'@

SubRx @'
      if(r.gfx.w95>0) line+=' work:'+r.gfx.w50+'/'+r.gfx.w95+'ms screen:'+(r.gfx.scr||'?')+'hz cap:'+(r.gfx.cap||'off');   // v28.xx (cw-fpswork): what held the frame rate, the game (work near the gap) or something outside it

'@ @'
      if(r.gfx.w95>0) line+=' work:'+r.gfx.w50+'/'+r.gfx.w95+'ms screen:'+(r.gfx.scr||'?')+'hz cap:'+(r.gfx.cap||'off');   // v28.xx (cw-fpswork): what held the frame rate, the game (work near the gap) or something outside it
      if(r.gfx.pic) line+=picLine(r.gfx.pic);   // v28.xx (cw-picstoretotal)

'@

SubRx @'
var VER='37.01';
'@ @'
var VER='37.02';
'@

$pat = "(?m)^  now:'v37\.01:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v37.02: The flight recorder run line now ends with pics:N/MB peak:N/MB by:store counts. Nothing on screen changes. Check 37.02 fails on v37.01',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
