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

if ($s.Contains("  {v:'35.49',what:")) { throw "check 35.49 is in the fixture already" }

SubRx @'
  {v:'35.48',what:
'@ @'
  {v:'35.49',what:'cw-hudstates, his ask 2026-10-27 (the hud messaging is a clusterfuck, make it AAA), the research rule for the bottom corners: revealed, concealed and in cover are small icons beside the stance chip bottom left for as long as they are true, and the hidden pill leaves the status column; under a quarter health the hp bar pulses slowly (under 3 a second) with no text; low ammo pulses the count red; an empty gun with rounds to load shows the reload key cap on the gun card, and a loaded one does not',
   run:function(){
     if(!(window.__deploy&&window.__state&&window.__endRaid)) return 'SKIP: this fixture cannot deploy';
     if(typeof drawHUD!=='function'||!window.__textTrace||typeof concealState!=='function'||typeof statusLive!=='function') return 'SKIP: no hud here';
     var bad=[], g, p, L, i, t, mx, mn, ups, prev, tr, hs, HH, o0={};
     function ids(a){ return a.map(function(e){ return e.id; }).join(','); }
     function capAt(){ var tq=__textTrace(function(){ drawHUD(); }); for(var j=0;j<tq.length;j++) if(String(tq[j].t).toLowerCase()==='r'&&tq[j].x>W*0.6&&tq[j].y>H*0.7) return true; return false; }
     try{
       __topClear(); __runPrep(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       g=__state(); if(!g||g.over||!g.player) return 'SKIP: staging: no raid';
       p=g.player; keys={}; g.mapOpen=false; g.bagOpen=false; g.paused=false;
       o0={hp:p.hp,ammo:p.ammo,res:p.reserve,mk:g.marked,pb:g.pBush,pc:g.pCrouch,cc:g.pConceal};
       if(typeof hudStateList!=='function'||typeof hpPulseA!=='function'||typeof ammoCapOn!=='function') return 'no lasting state icons, hp pulse or reload key cap (hudStateList, hpPulseA, ammoCapOn)';
       // ONE: the icons, beside the stance chip, for as long as they are true
       g.marked=0; g.pBush=0; g.pCrouch=false;
       L=hudStateList(); if(L.length) bad.push('icons drawn with nothing true: '+ids(L));
       g.marked=2; g.pBush=1; g.pConceal=0.2;
       L=hudStateList(); if(ids(L)!=='reveal,conceal,cover') bad.push('revealed and in a bush gives '+ids(L)+', not reveal,conceal,cover');
       drawHUD();
       if(HUDSTBOX.n!==3) bad.push('the row drew '+HUDSTBOX.n+' icons, not 3');
       if(!(HUDSTBOX.x<W*0.25&&HUDSTBOX.y>H*0.75)) bad.push('the icons are not beside the stance chip bottom left (x '+Math.round(HUDSTBOX.x)+', y '+Math.round(HUDSTBOX.y)+')');
       statusLive(p); for(i=0;i<STATUSL.length;i++) if(STATUSL[i].id==='hide'&&STATUSL[i].on) bad.push('the hidden pill is still in the status column');
       tr=__textTrace(function(){ drawHUD(); });
       for(i=0;i<tr.length;i++) if((/concealed|in cover|hidden/i).test(tr[i].t)&&!(tr[i].x<W*0.4&&tr[i].y>H*0.75)) bad.push('"'+tr[i].t+'" still drawn away from the vitals (x '+Math.round(tr[i].x)+', y '+Math.round(tr[i].y)+')');
       g.marked=0; L=hudStateList(); if(ids(L)!=='conceal,cover') bad.push('the revealed icon outlives the mark ('+ids(L)+')');
       g.marked=0; g.pBush=0; drawHUD(); if(HUDSTBOX.n!==0) bad.push('icons stay after the states end');
       // TWO: low health pulses the bar, slowly, with no text line
       mx=0; mn=1; ups=0; prev=0;
       for(t=0;t<=2;t+=0.01){ hs=hpPulseA(10,100,t); if(hs>mx) mx=hs; if(hs<mn) mn=hs; if(prev<0.5&&hs>=0.5) ups++; prev=hs; }
       if(!(mx>0.8&&mn<0.2)) bad.push('the low health pulse does not swing (min '+mn.toFixed(2)+', max '+mx.toFixed(2)+')');
       if(ups/2>=3) bad.push('the low health pulse runs '+(ups/2)+' a second, not under 3');
       if(hpPulseA(60,100,0.4)!==0) bad.push('the bar pulses at 60 health');
       p.hp=10; drawHUD(); if(!HPPULSE.on) bad.push('the hp bar does not pulse at 10 health');
       tr=__textTrace(function(){ drawHUD(); });
       for(i=0;i<tr.length;i++) if((/low health|health low/i).test(tr[i].t)) bad.push('a low health text line');
       p.hp=o0.hp; drawHUD(); if(HPPULSE.on) bad.push('control: the bar still pulses at full health');
       // THREE: an empty gun with rounds to load shows the reload key cap; a loaded or low one does not
       HH=hotbarSlots()[hotSel()];
       if(!(p.wep&&p.wep.mag>0&&(!HH||HH.kind==='gun'))) bad.push('control: no gun in hand');
       else {
         p.reloading=0; p.jam=0; p.reserve=Math.max(24,p.reserve|0);
         p.ammo=0; if(!ammoCapOn(p)) bad.push('ammoCapOn is false for an empty gun with rounds to load');
         if(!capAt()) bad.push('no reload key cap on the gun card of an empty gun');
         p.ammo=1; if(!ammoLow(p)) bad.push('one round left is not low ammo');
         if(capAt()) bad.push('the key cap shows on a gun that still has a round');
         p.ammo=p.wep.mag; if(ammoLow(p)||capAt()) bad.push('a full magazine reads as low or shows the key cap');
       }
     }catch(err){ bad.push('threw: '+(err&&err.message||err)); }
     finally{
       try{ if(p){ p.hp=o0.hp; p.ammo=o0.ammo; p.reserve=o0.res; g.marked=o0.mk; g.pBush=o0.pb; g.pCrouch=o0.pc; g.pConceal=o0.cc; } }catch(_e1){}
       keys={};
       try{ var g2=__state(); if(g2&&!g2.over){ g2.player.downed=false; __endRaid('abandon'); } }catch(_e){}
       __topClear();
     }
     return bad.length?bad.join('; '):null; }},
  {v:'35.48',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
