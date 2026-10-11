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

if ($s.Contains("  {v:'22.44',what:")) { throw "check 22.44 is in the fixture already" }

SubRx @'
  {v:'22.43',what:
'@ @'
  {v:'22.44',what:'a displaced alert is never lost: after a call for extraction EXTRACTION CALLED shows for at least 1.5 s in all, and a held crit another crit replaces comes back while its condition holds and is gone once it ends',
   run:function(){
     if(!(window.__deploy&&window.__state&&window.__endRaid&&window.__loop&&window.__keysRef)) return 'SKIP: this fixture cannot deploy or step';
     if(window.__vpAlive&&!__vpAlive()) return 'SKIP: the pane has no layout, so the frame loop cannot draw';
     var bad=[], g, p, z=null, bd=1e9, d, i, t0, f=0, K, a, realSay=say, XC=['EXTRACTION','CALLED'].join(' '), HL=['ZQ','HELD'].join(' '), NX=['ZQ','NEXT'].join(' '), shown=0, held=true, back=false, q;
     function step(ms){ __loop(t0+(f+=ms)); }
     function clr(){ g.msgT=0; g.msg=''; g.msgQ=[]; g.msgQM=[]; g.feed=[]; g.msgAt=undefined; g.msgKey=''; g.alert=null; g.alertQ=[]; }
     try{
       __topClear(); __runPrep(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       g=__state(); if(!g||g.over||!g.player) return 'SKIP: staging: no raid';
       p=g.player; p.iv=99; p.maxhp=100000; p.hp=100000; g.ents.length=0; g.waveT=-1e9; g.mapOpen=false; g.bagOpen=false; clr();
       for(i=0;i<g.zones.length;i++){ if(g.zones[i].open===false) continue; d=Math.hypot(g.zones[i].x-p.x,g.zones[i].y-p.y); if(d<bd){ bd=d; z=g.zones[i]; } }
       if(!z) return 'SKIP: no open extraction ring here';
       t0=Math.max(performance.now(),(typeof lastTs==='number'&&isFinite(lastTs))?lastTs:0);
       K=__keysRef(); for(var k0 in K) delete K[k0];
       p.x=z.x; p.y=z.y; K['KeyE']=true;
       for(i=0;i<200&&(z.beaconT===null||z.beaconT===undefined);i++){ p.x=z.x; p.y=z.y; g.ents.length=0; step(16.7); if(g.over) break; }
       for(var k1 in K) delete K[k1];
       if(z.beaconT===null||z.beaconT===undefined) return 'SKIP: holding E in the ring did not call for extraction here';
       for(i=0;i<180&&!g.over;i++){ p.x=z.x; p.y=z.y; g.ents.length=0; step(50); a=g.alert; if(a&&a.T>0&&a.m===XC) shown+=0.05; }
       if(shown<1.5) bad.push(XC+' showed for '+shown.toFixed(2)+' s in all in the 9 s after the call, not at least 1.5 s');
       if(!g.over) __endRaid('abandon');
       __topClear(); __runPrep(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       g=__state(); if(!g||g.over||!g.player) return 'SKIP: staging: no second raid';
       p=g.player; p.iv=99; g.ents.length=0; g.waveT=-1e9; g.mapOpen=false; g.bagOpen=false; clr();
       say=function(m){ if(String(m).indexOf('ZQ')===0) return realSay.apply(this,arguments); };
       t0=Math.max(performance.now(),(typeof lastTs==='number'&&isFinite(lastTs))?lastTs:0); f=0;
       say(HL,'crit',{sub:'zq held',hold:function(){ return held; }});
       for(i=0;i<20&&!g.over;i++){ g.ents.length=0; step(50); }   // 1 s
       a=g.alert; if(!(a&&a.T>0&&a.m===HL)) bad.push('SKIP: staging: the held line is not the alert after 1 s');
       else {
         say(NX,'crit',{sub:'zq next'});
         a=g.alert; if(!(a&&a.m===NX)) bad.push('a crit did not take the alert at once ('+JSON.stringify(a&&a.m)+')');
         for(i=0;i<120&&!g.over;i++){ g.ents.length=0; step(50); a=g.alert; if(a&&a.T>0&&a.m===HL) back=true; }   // 6 s, past the 4.5 s of the new crit
         if(!back) bad.push('a held crit line replaced by another crit never came back while its condition still held (alert '+JSON.stringify(g.alert&&{m:g.alert.m,T:g.alert.T})+')');
         held=false;
         for(i=0;i<100&&!g.over;i++){ g.ents.length=0; step(50); }   // 5 s
         a=g.alert;
         if(a&&a.T>0&&a.m===HL) bad.push('5 s after its condition ended the held line still shows');
         q=g.alertQ||[];
         for(i=0;i<q.length;i++) if(q[i].m===HL) bad.push('the held line still waits in the alert queue after its condition ended');
       }
     }catch(err){ bad.push('threw: '+(err&&err.message||err)); }
     finally{
       say=realSay; held=false;
       try{ var K2=__keysRef(); for(var k2 in K2) delete K2[k2]; }catch(_k){}
       try{ var g2=__state(); if(g2){ g2.msgT=0; g2.msg=''; g2.feed=[]; g2.msgQ=[]; g2.msgQM=[]; g2.msgKey=''; g2.alert=null; g2.alertQ=[]; } if(g2&&!g2.over){ g2.player.downed=false; g2.player.iv=0; __endRaid('abandon'); } }catch(_e){}
       __topClear();
     }
     for(i=0;i<bad.length;i++) if(bad[i].indexOf('SKIP: ')===0&&bad.length===1) return bad[0];
     return bad.length?bad.join('; '):null; }},
  {v:'22.43',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
