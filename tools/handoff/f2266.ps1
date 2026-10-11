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

if ($s.Contains("  {v:'22.66',what:")) { throw "check 22.66 is in the fixture already" }

SubRx @'
  {v:'22.65',what:
'@ @'
  {v:'22.66',what:'one prompt style at the SEARCH size: at 1080p and at 4K the locked-door prompt and the crate prompt are drawn at the same size, each on its own plate, and the seal and the in-ring call row read HOLD [key] TO',
   run:function(){
     if(!(window.__deploy&&window.__state&&window.__endRaid&&window.__frame&&window.__forceSize)) return 'SKIP: this fixture cannot deploy and draw';
     if(typeof hudPlate!=='function'||typeof drawHUD!=='function') return 'SKIP: no plates or HUD here';
     if(window.__vpAlive&&!__vpAlive()) return 'SKIP: the pane has no layout, so nothing is drawn';
     var bad=[], g, p, LK, ct=null, kc=null, oFT=ctx.fillText, oHP=hudPlate, seq=[], i, c, k, a, b, z, res={}, sz;
     function spy(){ seq=[]; hudPlate=function(){ seq.push({plate:1}); return oHP.apply(this,arguments); };
       ctx.fillText=function(t){ var m=ctx.getTransform(), fm=(/([\d.]+)px/).exec(String(ctx.font)); seq.push({s:String(t),px:(fm?parseFloat(fm[1]):0)*Math.abs(m.d)}); return oFT.apply(this,arguments); }; }
     function unspy(){ hudPlate=oHP; delete ctx.fillText; if(ctx.fillText!==oFT) ctx.fillText=oFT; }
     function find(f){ for(var j=0;j<seq.length;j++) if(seq[j].s!==undefined&&f(seq[j].s)) return {s:seq[j].s,px:seq[j].px,plate:j>0&&!!seq[j-1].plate}; return null; }
     function draw(){ spy(); try{ drawHUD(); }catch(_h){ seq.push({s:'THREW '+_h.message}); } finally{ unspy(); } }
     function clear(){ g.nearContainer=null; g.searching=null; g.nearDown=null; g.nearSeal=null; g.nearDoor=null; g.nearStray=null; g.nearPed=null; }
     function pair(tag){
       var k2, d, r;
       p.x=LK.doorX; p.y=LK.doorY+30; clear();
       for(k2=0;k2<8;k2++){ g.nearDoor=LK; __frame(0.05); }
       clear(); g.nearDoor=LK; draw();
       d=find(function(s){ return s.indexOf(LK.name)>=0; });
       ct.x=p.x+14; ct.y=p.y; clear(); g.nearContainer=ct; draw();
       r=find(function(s){ return (/^\[[^\]]+\] SEARCH /).test(s); });
       if(!d||!r) return 'SKIP: staging: at '+tag+' the door or the crate prompt was not drawn';
       if(Math.abs(d.px-r.px)>0.6) bad.push('at '+tag+' the door prompt is '+d.px.toFixed(1)+' px and the crate prompt '+r.px.toFixed(1)+' px');
       if(!d.plate) bad.push('at '+tag+' the door prompt '+JSON.stringify(d.s)+' has no plate of its own');
       if(!r.plate) bad.push('at '+tag+' the crate prompt '+JSON.stringify(r.s)+' has no plate of its own');
       res[tag]={d:d,r:r}; return null;
     }
     try{
       __topClear(); __runPrep(); __resetCfg(); __pinDefaults(0); __cleanProfile(); keys={};
       try{ __pinDPR(1); }catch(_d){}
       __forceSize(1920,1080);
       __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       g=__state(); if(!g||!g.player||g.over) return 'SKIP: no live raid';
       p=g.player; g.ents.length=0; g.bagOpen=false; g.mapOpen=false; p.downed=false; p.iv=99; g.waveT=-1e9;
       LK=(g.map&&g.map.locked&&g.map.locked[0])||null; if(!LK) return 'SKIP: no locked door on this map';
       for(i=0;i<g.containers.length;i++){ c=g.containers[i]; if(c&&!c.opened&&!c.fallen&&!c.dropped&&!c.mercSrc&&c.loot&&c.loot.length&&(c.type==='crate'||c.type==='locker')){ ct=c; break; } }
       if(!ct) return 'SKIP: no plain crate on this seed';
       kc={x:ct.x,y:ct.y};
       sz=pair('1080p'); if(sz) return sz;
       __forceSize(3840,2160); if(!(W>3000)) return 'SKIP: the canvas would not go to 4K';
       sz=pair('4K'); if(sz) return sz;
       __forceSize(1920,1080);
       z=g.zones&&g.zones[0];
       if(z){
         clear(); g.active=z; p.x=z.x; p.y=z.y; g.beaconT=null;
         for(k=0;k<8;k++) __frame(0.05);
         clear(); draw();
         a=find(function(s){ return (/TO CALL FOR EXTRACTION$/).test(s)&&s.indexOf('HOLD')===0; });
         if(!a) bad.push('standing in a ring nothing reads HOLD ... TO CALL FOR EXTRACTION');
         else if(a.s.indexOf('HOLD [')!==0) bad.push('the in-ring call row reads '+JSON.stringify(a.s)+', not HOLD [key] TO');
       }
       if(g.seal&&!g.seal.done){
         clear(); g.nearSeal=g.seal; draw(); g.nearSeal=null;
         b=find(function(s){ return (/ TO CUT THE SEAL$/).test(s); });
         if(!b) bad.push('beside the seal no HOLD TO CUT THE SEAL prompt was drawn');
         else { if(b.s.indexOf('HOLD [')!==0) bad.push('the seal prompt reads '+JSON.stringify(b.s)+', not HOLD [key] TO'); if(!b.plate) bad.push('the seal prompt has no plate'); }
       }
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{
       unspy();
       try{ __forceSize(1920,1080); }catch(_f){}
       try{ if(ct&&kc){ ct.x=kc.x; ct.y=kc.y; } }catch(_k){}
       try{ var g2=__state(); if(g2){ g2.nearDoor=null; g2.nearContainer=null; g2.nearSeal=null; if(!g2.over){ g2.player.downed=false; g2.player.iv=0; __endRaid('abandon'); } } }catch(_e){}
       keys={}; __topClear(); __cleanProfile();
     }
     return bad.length?bad.join('; '):null; }},
  {v:'22.65',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
