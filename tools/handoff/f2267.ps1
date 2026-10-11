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

if ($s.Contains("  {v:'22.67',what:")) { throw "check 22.67 is in the fixture already" }

SubRx @'
  {v:'22.66',what:
'@ @'
  {v:'22.67',what:'one prompt at a time: with a door he holds the key for and a crate both in reach exactly one [key] prompt is drawn, the UNLOCK the held E acts on first, and the crate alone still shows its SEARCH prompt',
   run:function(){
     if(!(window.__deploy&&window.__state&&window.__endRaid&&window.__frame)) return 'SKIP: this fixture cannot deploy and draw';
     if(typeof drawHUD!=='function') return 'SKIP: no HUD here';
     if(window.__vpAlive&&!__vpAlive()) return 'SKIP: the pane has no layout, so nothing is drawn';
     var bad=[], g, p, LK, ct=null, kc=null, oFT=ctx.fillText, seen=[], i, c, k, key=null, bag0=null, pr, z, inRing;
     function draw(){ seen=[]; ctx.fillText=function(t){ seen.push(String(t)); return oFT.apply(this,arguments); }; try{ drawHUD(); }catch(_h){ seen.push('THREW '+_h.message); } finally{ delete ctx.fillText; if(ctx.fillText!==oFT) ctx.fillText=oFT; }
       return seen.filter(function(s){ return (/^\[[^\]]+\] [A-Z]/).test(s)||(/^HOLD \[[^\]]+\] TO /).test(s); }); }
     function clear(){ g.nearContainer=null; g.searching=null; g.nearDown=null; g.nearSeal=null; g.nearDoor=null; g.nearStray=null; g.nearPed=null; g.nearPad=false; }
     try{
       __topClear(); __runPrep(); __resetCfg(); __pinDefaults(0); __cleanProfile(); keys={};
       __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       g=__state(); if(!g||!g.player||g.over) return 'SKIP: no live raid';
       p=g.player; g.ents.length=0; g.bagOpen=false; g.mapOpen=false; p.downed=false; p.iv=99; g.waveT=-1e9;
       LK=(g.map&&g.map.locked&&g.map.locked[0])||null; if(!LK) return 'SKIP: no locked door on this map';
       for(k in ITEMS) if(ITEMS[k]&&ITEMS[k].use==='key'&&ITEMS[k].door===LK.id){ key=k; break; }
       if(!key) return 'SKIP: no key item opens this door';
       for(i=0;i<g.containers.length;i++){ c=g.containers[i]; if(c&&!c.opened&&!c.fallen&&!c.dropped&&!c.mercSrc&&c.loot&&c.loot.length&&(c.type==='crate'||c.type==='locker')){ ct=c; break; } }
       if(!ct) return 'SKIP: no plain crate on this seed';
       kc={x:ct.x,y:ct.y}; bag0=g.bag.slice();
       p.x=LK.doorX; p.y=LK.doorY+30;
       for(k=0;k<6;k++) __frame(0.05);
       inRing=false; for(i=0;i<g.zones.length;i++){ z=g.zones[i]; if(Math.hypot(p.x-z.x,p.y-z.y)<z.r) inRing=true; }
       if(inRing) return 'SKIP: staging: the door is inside an extraction ring';
       ct.x=p.x+14; ct.y=p.y;
       clear(); g.nearContainer=ct; pr=draw();
       if(pr.length!==1||pr[0].indexOf('SEARCH')<0) return 'SKIP: staging: the crate alone drew '+JSON.stringify(pr)+', not one SEARCH prompt';
       g.bag.push(key);
       clear(); g.nearDoor=LK; g.nearContainer=ct; pr=draw();
       if(pr.length!==1) bad.push('with a door he holds the key for and a crate both in reach '+pr.length+' prompts are drawn: '+JSON.stringify(pr));
       else if(pr[0].indexOf('UNLOCK')<0||pr[0].indexOf(LK.name)<0) bad.push('with a door he holds the key for and a crate both in reach the one prompt is '+JSON.stringify(pr[0])+', not the UNLOCK a held E acts on first');
       g.bag.length=0; for(i=0;i<bag0.length;i++) g.bag.push(bag0[i]);
       clear(); g.nearDoor=LK; g.nearContainer=ct; pr=draw();
       if(pr.length!==1||pr[0].indexOf('SEARCH')<0) bad.push('with no key the locked door and a crate drew '+JSON.stringify(pr)+', not the one SEARCH prompt E acts on');
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{
       try{ delete ctx.fillText; if(ctx.fillText!==oFT) ctx.fillText=oFT; }catch(_f){}
       try{ if(ct&&kc){ ct.x=kc.x; ct.y=kc.y; } }catch(_k){}
       try{ if(g&&bag0){ g.bag.length=0; for(i=0;i<bag0.length;i++) g.bag.push(bag0[i]); } }catch(_b){}
       try{ var g2=__state(); if(g2){ g2.nearDoor=null; g2.nearContainer=null; if(!g2.over){ g2.player.downed=false; g2.player.iv=0; __endRaid('abandon'); } } }catch(_e){}
       keys={}; __topClear(); __cleanProfile();
     }
     return bad.length?bad.join('; '):null; }},
  {v:'22.66',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
