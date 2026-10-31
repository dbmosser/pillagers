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

# THE BIG MINIMAP AND LARGE HUD NO LONGER PUT PANELS OVER THE BELT (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
hudPanel(bx,by,bw,bh,undefined,1);   // v18.13: the one HUD panel
'@ @'
    // v28.xx (cw-hudbigfit), queue job 242 (CEO 10-29, from the o-00q camera): with the big minimap and the large HUD the open run info hung down over the belt keys and the air strike meter.
    // The panel now stops one gap above the highest belt key or live air strike plate that sits under it, and keeps what fits: the rows from the top, then one "+n more" line. The fold state is not touched.
    if(!HOc.c&&G.hotCells&&G.hotCells.length){
      var _hbS0=W+(bx-W)*_cz, _hbS1=W+(bx+bw-W)*_cz, _hbT=1e9, _hbi, _hbc, _hbA=airS();
      for(_hbi=0;_hbi<G.hotCells.length;_hbi++){ _hbc=G.hotCells[_hbi]; if(_hbc.x<_hbS1&&_hbc.x+_hbc.w>_hbS0&&_hbc.y<_hbT) _hbT=_hbc.y; }
      if(G.airBox&&G.airBox.w>0&&(_hbA.m>0||_hbA.aim||_hbA.sk.length)&&G.airBox.x<_hbS1&&G.airBox.x+G.airBox.w>_hbS0&&G.airBox.y<_hbT) _hbT=G.airBox.y;
      if(_hbT<1e8){
        var _hbM=Math.floor(((_hbT-Math.ceil(8*Math.max(1,hudRes())))/_cz-by-pad*2-lh)/lh);
        if(total>_hbM){
          var _hbK=[], _hbU=0, _hbR=0, _hbCut=false, _hbQ, _hbN;
          for(_hbQ=0;_hbQ<rows.length;_hbQ++){
            _hbN=(rows[_hbQ].k?1:0)+rows[_hbQ].wrapped.length;
            if(!_hbCut&&_hbU+_hbN<=_hbM-1){ _hbK.push(rows[_hbQ]); _hbU+=_hbN; } else { _hbCut=true; if(rows[_hbQ].v) _hbR++; }
          }
          while(_hbK.length&&!_hbK[_hbK.length-1].v){ _hbU-=1; _hbK.pop(); }
          if(_hbR>0&&_hbM>=1){ _hbK.push({k:'',v:'',wrapped:['+'+_hbR+' more'],vc:UIC.tx_2}); _hbU++; }
          rows=_hbK; total=_hbU; bh=pad*2+lh+total*lh;
        }
      }
    }
hudPanel(bx,by,bw,bh,undefined,1);   // v18.13: the one HUD panel
'@

SubRx @'
function feedDraw(){ var _lgS=LEGSIDE, _fst=0; LEGSIDE=null;
'@ @'
// v28.xx (cw-hudbigfit), queue job 242: the width a feed line at height yt may take. The left feed is 28 percent of the screen wide and the belt starts left of that in the large HUD window,
// so a line level with the belt ran under its keys; such a line now ends one gap before the belt (its detail shortens with "..." as before). Lines above or below the belt keep the full zone.
function feedHotW(R,x,yt,pad){
  var hc=G&&G.hotCells, i, L=1e9, T=1e9, B=-1e9, g=Math.max(2,Math.round(pad));
  if(!hc||!hc.length) return R.w;
  for(i=0;i<hc.length;i++){ if(hc[i].x<L) L=hc[i].x; if(hc[i].y<T) T=hc[i].y; if(hc[i].y+hc[i].h>B) B=hc[i].y+hc[i].h; }
  if(yt+R.rh<=T-g||yt>=B+g||x>=L) return R.w;
  return Math.max(R.fp*6,Math.min(R.w,L-g-x));
}
function feedDraw(){ var _lgS=LEGSIDE, _fst=0; LEGSIDE=null;
'@

SubRx @'
      pr=feedParts(ln,fL,R.w-pad*3-gs-Math.round(pad*0.7));
'@ @'
      yt=y-R.rh; x=R.x+(_fst=feedStep(_lgS,R,rs))+(_fst?0:Math.round((e-1)*LH(18)*rs)); var _fw=feedHotW(R,x,yt,pad);   // v28.xx (cw-hudbigfit): the row place and its width are known before the words are cut to fit
      pr=feedParts(ln,fL,_fw-pad*3-gs-Math.round(pad*0.7));
'@

SubRx @'
      w=Math.min(R.w,pad+Math.round(pad*0.5)+(ln.gl?gs+Math.round(pad*0.7):0)+pr.w+pad);
'@ @'
      w=Math.min(_fw,pad+Math.round(pad*0.5)+(ln.gl?gs+Math.round(pad*0.7):0)+pr.w+pad);
'@

SubRx @'
      x=R.x+(_fst=feedStep(_lgS,R,rs))+(_fst?0:Math.round((e-1)*LH(18)*rs)); yt=y-R.rh;
'@ @'
     
'@

SubRx @'
var VER='36.71';
'@ @'
var VER='36.72';
'@

$pat = "(?m)^  now:'v36\.71:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v36.72: Run info stops above the belt keys and the air strike meter in a crowded setup, and feed lines end before the belt. Check 36.72 fails on v36.71',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
