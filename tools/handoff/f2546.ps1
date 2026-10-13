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

if ($s.Contains("  {v:'25.46',what:")) { throw "check 25.46 is in the fixture already" }

SubRx @'
  {v:'25.45',what:
'@ @'
  {v:'25.46',what:'his raid text map and his #50: a ring badge held at the right edge at mid height, with the gun card on pickup up, is drawn clear of the card and reads as a short callout of at most 28 characters',
   run:function(){
     if(!(window.__deploy&&window.__state&&window.__endRaid&&window.__frame)||typeof gunCardDraw!=='function'||typeof hudPlate!=='function'||typeof grantLoot!=='function'||typeof zoneBadge!=='function') return 'SKIP: this fixture cannot deploy and draw a gun card';
     if(!ITEMS.gun_dmr) return 'SKIP: no Marksman Rifle item';
     var bad=[], g, Z=null, oW=w2s, oFT=ctx.fillText, oFR=ctx.fillRect, oGC=gunCardDraw, oHP=hudPlate, inGC=0, gc=null, last=null, rec=[], lab='', i, r, d=1;
     function box(x,y,w,h){ var m=ctx.getTransform(); return {l:(m.a*x+m.e)/d,t:(m.d*y+m.f)/d,r:(m.a*(x+w)+m.e)/d,b:(m.d*(y+h)+m.f)/d}; }
     function unstub(){ w2s=oW; gunCardDraw=oGC; hudPlate=oHP; delete ctx.fillText; if(ctx.fillText!==oFT) ctx.fillText=oFT; delete ctx.fillRect; if(ctx.fillRect!==oFR) ctx.fillRect=oFR; }
     try{
       __topClear(); __runPrep(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       try{ __pinDPR(1); }catch(_d){}
       d=(typeof DPR==='number'&&DPR>0)?DPR:1;
       __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       g=__state(); if(!g||!g.player||g.over) return 'SKIP: no live raid';
       g.bagOpen=false; g.mapOpen=false; keys={};
       for(i=0;i<g.zones.length;i++) if(g.zones[i]&&g.zones[i].open){ Z=g.zones[i]; break; }
       if(!Z) return 'SKIP: no open ring';
       grantLoot({x:g.player.x,y:g.player.y,loot:[]},['gun_dmr']);
       if(!g.gunCard) return 'SKIP: picking up a Marksman Rifle raised no gun card';
       lab=String(zoneBadge(Z));
       w2s=function(x,h,y){ if(x===Z.x&&y===Z.y) return {x:W+40,y:H*0.5}; return oW.apply(this,arguments); };
       gunCardDraw=function(){ inGC++; try{ return oGC.apply(this,arguments); } finally{ inGC--; } };
       hudPlate=function(x,y,w,h){ if(inGC&&!gc) gc=box(x,y,w,h); return oHP.apply(this,arguments); };
       ctx.fillRect=function(x,y,w,h){ last=box(x,y,w,h); return oFR.apply(this,arguments); };
       ctx.fillText=function(s,x,y){ if(String(s)===lab&&last) rec.push(last); return oFT.apply(this,arguments); };
       try{ g.gunCard.t0=g.t||0; __frame(0.016); gc=null; rec.length=0; g.gunCard.t0=g.t||0; __frame(0.016); } finally { unstub(); }
       if(!gc) return 'SKIP: the gun card was not drawn';
       if(!rec.length) return 'the badge of a ring just off the right edge was not drawn at all';
       r=rec[rec.length-1];
       if(r.l<gc.r&&r.r>gc.l&&r.t<gc.b&&r.b>gc.t) bad.push('the ring badge ('+Math.round(r.l)+','+Math.round(r.t)+' to '+Math.round(r.r)+','+Math.round(r.b)+') is drawn under the gun card ('+Math.round(gc.l)+','+Math.round(gc.t)+' to '+Math.round(gc.r)+','+Math.round(gc.b)+')');
       if(r.r<W-80) bad.push('the badge left the right edge (it ends at '+Math.round(r.r)+' of '+W+')');
       if(r.t<0||r.b>H) bad.push('the badge was pushed off the screen');
       if(lab.length>28) bad.push('the badge reads "'+lab+'", '+lab.length+' characters');
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{ unstub(); try{ var g2=__state(); if(g2){ g2.gunCard=null; if(!g2.over){ g2.player.downed=false; __endRaid('abandon'); } } }catch(_e){} __topClear(); __cleanProfile(); }
     return bad.length?bad.join('; '):null; }},
  {v:'25.45',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
