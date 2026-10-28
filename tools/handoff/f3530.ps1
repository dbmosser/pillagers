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

if ($s.Contains("  {v:'35.30',what:")) { throw "check 35.30 is in the fixture already" }

SubRx @'
  {v:'35.29',what:
'@ @'
  {v:'35.30',what:'cw-quiettext, his order 2026-10-27 (build the quiet hud, all 5 changes), changes 1 and 5: a warn line said once draws in one place only (the top banner), an info line draws in the left feed and not at the top centre, a money pickup line draws in the right stack and not in the feed, concealed in cover is a status icon at the left and not the right-side word, and a ring badge held at the screen edge draws under the extract distance at the top centre',
   run:function(){
     if(!(window.__deploy&&window.__state&&window.__endRaid)) return 'SKIP: no raid here';
     if(typeof drawHUD!=='function'||typeof render2D!=='function'||typeof txRecord!=='function'||typeof say!=='function'||typeof msgTick!=='function'||typeof w2s!=='function'||typeof zoneBadge!=='function') return 'SKIP: no HUD, text recorder or message lanes here';
     var bad=[], g=null, p=null, all=null, keepHit=null, hadHit=false, Z=null, kz=null, kp=null, i, h, hs, hl, hr, mid, fd, cn, ext, av, avR, avT, lab, s, sx, d;
     var skip=function(m){ return bad.length?(bad.join('; ')+' (then SKIP: '+m+')'):('SKIP: '+m); };
     function hits(){ try{ CONDWRAP={}; CONDWRAPN=0; }catch(_c){} return txRecord(function(){ render2D(0); drawHUD(); }); }
     // the places a text is drawn: a draw the recorder sees twice at one spot is one place
     function said(re){ var r=[], j, k, seen={}; for(j=0;j<hs.length;j++) if(re.test(String(hs[j].o||''))){ k=Math.round(hs[j].x)+','+Math.round(hs[j].y); if(!seen[k]){ seen[k]=1; r.push(hs[j]); } } return r; }
     function at(a){ return a.map(function(q){ return Math.round(q.x)+','+Math.round(q.y); }).join(' '); }
     function quiet(){ g.alert=null; g.alertQ=[]; g.loc=null; g.lore=null; g.pick=[]; g.msg=''; g.msgT=0; g.feed=[]; g.msgQ=[]; g.msgQM=[]; if(g.fd&&g.fd.lines) g.fd.lines.length=0; }
     function pass(){ g.t=(g.t||0)+0.3; msgTick(0.3); }
     try{
       __topClear(); __runPrep(); __resetCfg(); __pinDefaults(0);
       try{ __pinDPR(1); __forceSize(1920,1080); }catch(_fs){}
       __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       g=__state(); if(!g||g.over||!g.player||g.sim) return 'SKIP: no live raid';
       p=g.player; all=g.ents.slice(); g.ents=[]; g.mapOpen=false; g.bagOpen=false; g.paused=false;
       kp={bush:g.pBush,conceal:g.pConceal,crouch:g.pCrouch};
       try{ hadHit=(typeof TXHIT!=='undefined'); if(hadHit) keepHit=TXHIT; }catch(_h){ hadHit=false; }
       // ONE: a warn line said once draws in one place, the top banner
       quiet(); say('QHT ROOF SNIPER','warn'); pass();
       if(!(g.alert&&g.alert.m==='QHT ROOF SNIPER')) bad.push('ONE control: a warn line said did not take the top banner');
       hs=hits(); h=said(/qht roof sniper/i);
       if(h.length!==1) bad.push('ONE: a warn line said once draws in '+h.length+' places ('+at(h)+'), not one');
       else if(!(h[0].y<H*0.35&&h[0].x>W*0.3&&h[0].x<W*0.7)) bad.push('ONE: the warn line draws at '+at(h)+', not in the top banner');
       // TWO: an info line said draws in the left feed and not at the top centre
       quiet(); say('QHT SUPPLY NOTE','info'); pass();
       hs=hits(); h=said(/qht supply note/i);
       fd=h.filter(function(q){ return q.x<W*0.35&&q.y>H*0.4; }); mid=h.filter(function(q){ return q.x>W*0.3&&q.x<W*0.7&&q.y<H*0.4; });
       if(!fd.length) bad.push('TWO: an info line said does not draw in the left feed ('+at(h)+')');
       if(mid.length) bad.push('TWO: an info line said also draws at the top centre ('+at(mid)+')');
       if(h.length!==1) bad.push('TWO: an info line said once draws in '+h.length+' places, not one');
       // THREE: concealed in cover is a status icon at the left, not the word at the right
       quiet(); g.pBush=1; g.pConceal=0.4; g.pCrouch=false;
       hs=hits(); h=said(/in cover/i);
       hl=h.filter(function(q){ return q.x<W*0.35; }); hr=h.filter(function(q){ return q.x>W*0.6; });
       cn=said(/^concealed$/i).filter(function(q){ return q.x<W*0.35; });
       if(hr.length) bad.push('THREE: concealed in cover still draws at the right ('+at(hr)+')');
       if(!cn.length||!hl.length) bad.push('THREE: concealed in cover is not a status icon at the left (name drawn '+cn.length+', reason drawn '+hl.length+')');
       g.pBush=kp.bush; g.pConceal=kp.conceal; g.pCrouch=kp.crouch;
       // FIVE: a pickup line (money carried out) draws in the right-side pickup stack only, not also in the left feed
       quiet(); say('+$4,321','pick',{tag:'CARRIED',c:'gain'}); pass();
       hs=hits(); h=said(/4,321/);
       if(!h.filter(function(q){ return q.x>W*0.6; }).length) bad.push('FIVE control: a money pickup line does not draw in the right stack ('+at(h)+')');
       if(h.filter(function(q){ return q.x<W*0.35; }).length) bad.push('FIVE: a money pickup line also draws in the left feed ('+at(h)+')');
       // FOUR: a ring just off the right edge says its badge under the extract distance at the top centre, not at the edge
       quiet();
       for(i=0;i<g.zones.length;i++) if(g.zones[i].open!==false){ Z=g.zones[i]; break; }
       if(!Z) return skip('no open extraction point here');
       kz={x:Z.x,y:Z.y,beaconT:Z.beaconT,hold:Z.hold,open:Z.open};
       Z.beaconT=null; Z.hold=null; Z.open=true;
       hits(); sx=null;
       for(d=200;d<4000;d+=10){ Z.x=p.x+d; Z.y=p.y; s=w2s(Z.x,Z.r+18,Z.y); if(s&&s.x>W+30){ sx=s; break; } }
       if(!sx||sx.x>W+80||sx.y<40||sx.y>H-40) return skip('could not stand a ring just off the right edge of the screen ('+(sx?Math.round(sx.x)+','+Math.round(sx.y):'none')+')');
       lab=String(zoneBadge(Z)).toUpperCase();
       hs=hits();
       ext=null; for(i=0;i<hs.length;i++) if(/^(EXTRACT|EXTRACTION|WAYPOINT) [\d.,]+m$/i.test(String(hs[i].o||''))){ ext=hs[i]; break; }
       if(!ext) return skip('the extract distance did not draw at the top here');
       av=said({test:function(t){ return String(t).toUpperCase()===lab; }});
       avR=av.filter(function(q){ return q.x>W*0.7; });
       avT=av.filter(function(q){ return Math.abs(q.x-W/2)<3&&q.y>ext.y+2&&q.y<ext.y+H*0.12; });
       if(avR.length) bad.push('FOUR: '+lab+' still draws at the right edge ('+at(avR)+')');
       if(avT.length!==1) bad.push('FOUR: '+lab+' does not draw under the extract distance at the top centre (drawn at '+(at(av)||'nowhere')+', extract distance at '+Math.round(ext.x)+','+Math.round(ext.y)+')');
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{
       try{ if(Z&&kz){ Z.x=kz.x; Z.y=kz.y; Z.beaconT=kz.beaconT; Z.hold=kz.hold; Z.open=kz.open; } }catch(_z){}
       try{ if(g&&kp){ g.pBush=kp.bush; g.pConceal=kp.conceal; g.pCrouch=kp.crouch; } if(g&&all) g.ents=all.slice(); }catch(_g){}
       try{ if(hadHit) TXHIT=keepHit; }catch(_t){}
       try{ if(__state()&&!__state().over) __endRaid('abandon'); }catch(_e){}
       __topClear();
     }
     return bad.length?bad.slice(0,8).join('; '):null; }},
  {v:'35.29',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
