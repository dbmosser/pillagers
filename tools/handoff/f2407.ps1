$ErrorActionPreference = 'Stop'
trap { Write-Output "FAILED: $_"; exit 1 }
$p = 'C:\claudecode\dark raiders\tools\mkfixture.ps1'
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

if ($s.Contains("  {v:'24.07',what:")) { throw "check 24.07 is in the fixture already" }

SubRx @'
  {v:'24.06',what:
'@ @'
  {v:'24.07',what:'graphics program gfx7: the coloured light map: at night under LIGHTING HIGH a warm sodium lamp tints its pool (red over blue at least 6 above CLASSIC) and STANDARD does too, the pool holds the CLASSIC brightness within 20 percent, and ground 410 units from the lamp keeps the CLASSIC luminance within 4 percent; read from the world canvas just before the fog of war sheet',
   run:function(){
     if(!(window.__gfxStage&&window.__frame&&window.__state&&window.__endRaid)||typeof gfxPreFog!=='function'||typeof render2D!=='function'||typeof ZOOM!=='function') return 'SKIP: this fixture cannot stage and draw a raid frame';
     var bad=[], g=null, p, keepPF=gfxPreFog, gl0=CFG.gfxLight, L0=null, E0=null, F0=null, cap=null, want=null, best=null, i, j, R, C1, H1, S1, C2,
         dirs=[[1,0],[-1,0],[0,1],[0,-1]], lx, ly, fx, fy, sc, dRB, dRBs, lc, lh, fc, fh;
     function lum(c){ return .2126*c[0]+.7152*c[1]+.0722*c[2]; }
     function ring(cx,cy,r){ var a=[], k; for(k=0;k<8;k++) a.push([cx+Math.cos(k*Math.PI/4)*r, cy+Math.sin(k*Math.PI/4)*r]); return a; }
     function grab(){
       var out=[], q, s, d, n, r0, g0, b0, k, m, Zq=ZOOM(), dx, dy;
       for(q=0;q<want.length;q++){
         r0=0; g0=0; b0=0; n=0;
         for(k=0;k<want[q].length;k++){
           s=want[q][k]; dx=Math.round((s[0]-VX)*Zq*DPR); dy=Math.round((s[1]-VY)*Zq*DPR);
           if(dx<3||dy<3||dx>cv.width-4||dy>cv.height-4) continue;
           d=wc.getImageData(dx-2,dy-2,5,5).data;
           for(m=0;m<d.length;m+=4){ r0+=d[m]; g0+=d[m+1]; b0+=d[m+2]; n++; }
         }
         out.push(n?[r0/n,g0/n,b0/n]:null);
       }
       return out;
     }
     function shoot(q){
       CFG.gfxLight=q; cap=null;
       gfxPreFog=function(dt){ try{ cap=grab(); }catch(_g){ cap=null; } return keepPF(dt); };
       try{ __frame(0); } finally { gfxPreFog=keepPF; }
       return cap;
     }
     try{
       __resetCfg();
       g=__gfxStage({cond:'night',wx:'clear',frames:3});
       if(!g) return 'SKIP: __gfxStage built no raid';
       if(isDay()) return 'SKIP: the staged raid is not at night';
       p=g.player; G.shake=0; G.lightning=0;
       L0=G.lights; E0=G.ents; F0=G.flashes; G.ents=[]; G.flashes=[];
       // the brightest side for the test: a lamp 170 units one way, ground 240 the other way (410 from the lamp)
       for(i=0;i<dirs.length;i++){
         lx=p.x+dirs[i][0]*170; ly=p.y+dirs[i][1]*170; fx=p.x-dirs[i][0]*240; fy=p.y-dirs[i][1]*240;
         G.lights=[]; want=[ring(lx,ly,40),[[fx,fy],[fx+12,fy],[fx-12,fy],[fx,fy+12],[fx,fy-12]]];
         for(j=0;j<4;j++) __frame(0.12);
         R=shoot(0);
         if(R&&R[0]&&R[1]){ sc=Math.min(lum(R[0]),lum(R[1])); if(!best||sc>best.sc) best={sc:sc,lx:lx,ly:ly,w:want}; }
       }
       if(!best) return 'SKIP: staging: no side has the lamp and the far ground on screen';
       G.lights=[{x:best.lx,y:best.ly,r:180,c:'#ffbe6a',i:.40,f:0,fl:false}]; want=best.w;
       for(j=0;j<3;j++) __frame(0.12);
       C1=shoot(0); H1=shoot(2); S1=shoot(1); C2=shoot(0);
       if(!(C1&&H1&&S1&&C2&&C1[0]&&C1[1]&&H1[0]&&H1[1]&&S1[0]&&C2[0]&&C2[1])) return 'SKIP: staging: the lamp or the far ground left the screen';
       if(Math.abs(lum(C1[0])-lum(C2[0]))>1||Math.abs(lum(C1[1])-lum(C2[1]))>1) return 'SKIP: staging: two CLASSIC frames differ';
       dRB=(H1[0][0]-H1[0][2])-(C1[0][0]-C1[0][2]); dRBs=(S1[0][0]-S1[0][2])-(C1[0][0]-C1[0][2]);
       if(!(dRB>=6)) bad.push('under HIGH the sodium lamp pool is only '+dRB.toFixed(1)+' redder over blue than CLASSIC (want 6 or more)');
       if(!(dRBs>=6)) bad.push('under STANDARD the sodium lamp pool is only '+dRBs.toFixed(1)+' redder over blue than CLASSIC (want 6 or more)');
       lc=lum(C1[0]); lh=lum(H1[0]);
       if(Math.abs(lh-lc)>Math.max(3,lc*.20)) bad.push('the lamp pool luminance is '+lh.toFixed(1)+' under HIGH against '+lc.toFixed(1)+' CLASSIC (want within 20 percent)');
       fc=lum(C1[1]); fh=lum(H1[1]);
       if(Math.abs(fh-fc)>Math.max(2,fc*.04)) bad.push('ground 410 units from the lamp reads '+fh.toFixed(1)+' under HIGH against '+fc.toFixed(1)+' CLASSIC (want within 4 percent)');
     }catch(err){ bad.push('threw: '+(err&&err.message||err)); }
     finally{
       gfxPreFog=keepPF; CFG.gfxLight=gl0;
       try{ if(g&&G===g){ if(L0) G.lights=L0; if(E0) G.ents=E0; if(F0) G.flashes=F0; } }catch(_r){}
       try{ var g2=__state(); if(g2&&!g2.over) __endRaid('abandon'); }catch(_e){}
       __topClear(); __cleanProfile();
     }
     return bad.length?bad.join('; '):null; }},
  {v:'24.06',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
