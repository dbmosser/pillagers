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

if ($s.Contains("  {v:'26.65',what:")) { throw "check 26.65 is in the fixture already" }

SubRx @'
  {v:'26.64',what:
'@ @'
  {v:'26.65',what:'feel17, his order: with a throwable in the hand (pin out) the HUD draws a ring on the ground where the throw will land, sized to the blast, with the fuse counting down; the ring is exactly where throwFrom puts the grenade, a wall on the line stops it short, and with nothing in hand there is no ring',
   run:function(){
     if(!(window.__deploy&&window.__state&&window.__endRaid&&window.__frame)) return 'SKIP: no raid or frame here';
     var bad=[], g, p, all, X0, Y0, dx=0, dy=0, ok=false, k, ux, uy, i, oCook, oKind, oCookT, oMx, oMy, oTh, cap=[], proto, oArc, A, m, s, hit, last, pz, hitw, nTh;
     function drawn(){
       cap.length=0; render2D(0);
       proto=CanvasRenderingContext2D.prototype; oArc=proto.arc;
       proto.arc=function(){ cap.push([].slice.call(arguments)); return oArc.apply(this,arguments); };
       try{ drawHUD(); } finally { proto.arc=oArc; }
     }
     function aimAt(wx,wy){ pz=ZOOM(); mouse.x=(wx-g.camX)*pz; mouse.y=(wy-g.camY)*pz; }
     try{
       __topClear(); __runPrep(); __resetCfg(); __pinDefaults(0); __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       g=__state(); if(!g||g.over||!g.player) return 'SKIP: no live raid';
       if(g.sim) return 'SKIP: the fixture raid is a sim raid';
       p=g.player; all=g.ents.slice(); g.ents=[]; X0=p.x; Y0=p.y; oCook=p.cooking; oKind=p.cookKind; oCookT=p.cookT; oMx=mouse.x; oMy=mouse.y; oTh=g.throws.length;
       for(k=0;k<8;k++){ ux=Math.cos(k*0.7854); uy=Math.sin(k*0.7854); if(losClear(X0,Y0,X0+ux*170,Y0+uy*170,g.map.segs)){ dx=ux; dy=uy; ok=true; break; } }
       if(!ok) return 'SKIP: staging: no open line from the drop point';
       render2D(0);
       // ONE: nothing in hand, no ring
       p.cooking=0; aimAt(X0+dx*150,Y0+dy*150); drawn();
       s=w2s(X0+dx*150,0,Y0+dy*150); hit=0; for(i=0;i<cap.length;i++) if(cap[i].length>=5&&Math.abs(cap[i][0]-s.x)<1.5&&Math.abs(cap[i][1]-s.y)<1.5&&cap[i][2]>100) hit++;
       if(hit) bad.push('ONE: a ring was drawn with no throwable in hand');
       // TWO: a frag in hand, the ring is at the landing point, the size of the blast
       p.cooking=1; p.cookKind='frag'; p.cookT=0.4; aimAt(X0+dx*150,Y0+dy*150); drawn();
       m=throwMarker(p);
       if(!m) bad.push('TWO: throwMarker is empty with a frag in hand');
       else {
         if(Math.abs(m.tx-(X0+dx*150))>3||Math.abs(m.ty-(Y0+dy*150))>3) bad.push('TWO: the marker is at '+m.tx.toFixed(0)+','+m.ty.toFixed(0)+', not under the cursor');
         if(Math.abs(m.left-0.7)>0.01) bad.push('TWO: the fuse left reads '+m.left.toFixed(2)+', not 0.70');
         if(Math.abs(m.r-(CFG.fragR===undefined?190:CFG.fragR))>0.5) bad.push('TWO: the ring is '+m.r+' wide, not the blast');
         s=w2s(m.tx,0,m.ty); hit=0; hitw=0;
         for(i=0;i<cap.length;i++) if(cap[i].length>=5&&Math.abs(cap[i][0]-s.x)<1.5&&Math.abs(cap[i][1]-s.y)<1.5){ if(Math.abs(cap[i][2]-m.r*ZOOM())<1.5) hit++; }
         if(!hit) bad.push('TWO: no ring of the blast size was drawn at the landing point ('+cap.length+' arcs)');
       }
       // THREE: the ring is exactly where the throw lands
       nTh=g.throws.length; throwFrom('frag',0.4); last=g.throws[g.throws.length-1];
       if(g.throws.length<=nTh||!last) bad.push('THREE: throwFrom threw nothing');
       else if(m&&(Math.abs(last.tx-m.tx)>0.01||Math.abs(last.ty-m.ty)>0.01)) bad.push('THREE: the grenade lands at '+last.tx.toFixed(1)+','+last.ty.toFixed(1)+', the ring at '+m.tx.toFixed(1)+','+m.ty.toFixed(1));
       // FOUR: aimed far, the reach is never past 270
       aimAt(X0+dx*400,Y0+dy*400); A=throwAim(p);
       if(!(A.rngT>20&&A.rngT<=270.01)) bad.push("FOUR: throwAim reach "+A.rngT);
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{
       try{ if(p){ p.cooking=oCook; p.cookKind=oKind; p.cookT=oCookT; } if(g&&all){ g.ents=all.slice(); g.throws.length=oTh; } if(oMx!==undefined){ mouse.x=oMx; mouse.y=oMy; } }catch(_h){}
       try{ __endRaid('abandon'); }catch(_e){}
       __topClear();
     }
     return bad.length?bad.slice(0,8).join('; '):null; }},
  {v:'26.64',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
