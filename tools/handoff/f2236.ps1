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

if ($s.Contains("  {v:'22.36',what:")) { throw "check 22.36 is in the fixture already" }

SubRx @'
  {v:'22.35',what:
'@ @'
  {v:'22.36',what:'the lanes keep time in the death beat and the burn: a line with a second left runs out while the site burns and the burn alert holds, and in the death beat the row clock runs down',
   run:function(){
     if(!(window.__deploy&&window.__state&&window.__endRaid&&window.__loop)) return 'SKIP: this fixture cannot deploy or step';
     if(window.__vpAlive&&!__vpAlive()) return 'SKIP: the pane has no layout, so the frame loop cannot draw';
     if(typeof raidClockOn!=='function'||typeof feedRows!=='function') return 'SKIP: no clock or no rows here';
     var bad=[], g, p, i, t0, f=0, realSay=say, ZX=['zq','x'].join(' '), ZY=['zq','y'].join(' '), BURN=['MERIDIAN','IS','BURNING','THE','SITE'].join(' '), rows, still, a;
     function step(ms){ __loop(t0+(f+=ms)); }
     function clr(){ g.msgT=0; g.msg=''; g.msgQ=[]; g.msgQM=[]; g.feed=[]; g.msgAt=undefined; g.msgKey=''; g.alert=null; g.alertQ=[]; }
     try{
       __topClear(); __runPrep(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       g=__state(); if(!g||g.over||!g.player) return 'SKIP: staging: no raid';
       if(!raidClockOn()||!(g.raidLen>0)) return 'SKIP: the raid clock is off here';
       p=g.player; keys={}; g.mapOpen=false; g.bagOpen=false; g.ents.length=0; g.waveT=-1e9;
       say=function(m){ var s=String(m); if(s.indexOf('zq')===0||s.indexOf('MERIDIAN')===0) return realSay.apply(this,arguments); };
       t0=Math.max(performance.now(),(typeof lastTs==='number'&&isFinite(lastTs))?lastTs:0);
       // ONE, THE BURN: a line with one second left, then the clock runs out with no extraction called
       clr(); say(ZX); g.msgT=1.0;
       for(i=0;i<g.zones.length;i++){ g.zones[i].beaconT=null; g.zones[i].pullT=0; }
       g.beaconT=null; g.timeLeft=0.01; g.warnPrev=0.02;
       step(50);
       if(!g.nuking) return 'SKIP: staging: the clock ran out and the site did not start to burn';
       for(i=0;i<44&&!g.over&&g.nuking;i++){ step(50); g.ents.length=0; }   // 2.2 s of the 2.6 s burn
       if(g.over) bad.push('SKIP: the burn ended the raid before 2.2 s');
       else {
         rows=feedRows(); still=false;
         for(i=0;i<rows.length;i++) if(rows[i].m===ZX) still=true;
         if(still) bad.push('a line with one second left still shows after 2.2 s of the burn (row clock '+(+g.msgT).toFixed(2)+')');
         a=g.alert;
         if(!(a&&a.T>0&&a.m===BURN)) bad.push('the burn line is not the alert 2.2 s into the burn ('+JSON.stringify(a&&{m:a.m,T:a.T})+')');
       }
       if(!g.over) __endRaid('abandon');
       __topClear(); __runPrep(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       // TWO, THE DEATH BEAT: the row clock runs down through it
       __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       g=__state(); if(!g||g.over||!g.player) return 'SKIP: staging: no second raid';
       keys={}; g.ents.length=0; g.waveT=-1e9;
       t0=Math.max(performance.now(),(typeof lastTs==='number'&&isFinite(lastTs))?lastTs:0); f=0;
       clr(); say(ZY);
       if(g.msgT!==3.2) bad.push('SKIP: staging: the probe line did not show for 3.2 s');
       g.deathBeat=1.5;
       for(i=0;i<60&&!g.over;i++) step(16.7);
       if(!(g.msgT<2.4)) bad.push('one second into the death beat the row clock is still '+(+g.msgT).toFixed(2)+', not below 2.4');
     }catch(err){ bad.push('threw: '+(err&&err.message||err)); }
     finally{
       say=realSay; keys={};
       try{ var g2=__state(); if(g2){ g2.msgT=0; g2.msg=''; g2.feed=[]; g2.msgQ=[]; g2.msgQM=[]; g2.alert=null; g2.alertQ=[]; } if(g2&&!g2.over){ g2.deathBeat=null; g2.player.downed=false; __endRaid('abandon'); } }catch(_e){}
       __topClear();
     }
     for(i=0;i<bad.length;i++) if(bad[i].indexOf('SKIP: ')===0&&bad.length===1) return bad[0];
     return bad.length?bad.join('; '):null; }},
  {v:'22.35',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
