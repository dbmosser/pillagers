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

if ($s.Contains("  {v:'34.15',what:")) { throw "check 34.15 is in the fixture already" }

SubRx @'
  {v:'34.14',what:
'@ @'
  {v:'34.15',what:'quality never softens a fixed cadence, proves fill benefit, waits without pumping, and carries raid quality one step better',
   run:function(){
     var d0=JSON.stringify(DRS), c0=JSON.stringify(CFG), q0=JSON.stringify(GFXQ), sess0={raid:DRSSESSION.raid,settled:DRSSESSION.settled}, os=sayWhenFree, bad=[], t=100000, events=[], i, g, k;
     function reset(){ DRSSESSION.settled=null; drsBeginRaid(t); DRS.said=1; events=[]; }
     function feed(gap,ms,work){ var end=t+ms, oq, sc, dir; while(t<end){ t+=gap; oq=DRS.q; sc=DRS.scale; drsTick(gap,t,work); if(oq!==DRS.q||sc!==DRS.scale){ dir=(DRS.q>oq||DRS.scale<sc)?-1:1; events.push({t:t,dir:dir,q:DRS.q,scale:DRS.scale}); } if(DRS.scale<0.75-1e-6) bad.push('under the 75 percent floor'); } }
     try{
       __runPrep(); __topClear(); __resetCfg(); __pinDefaults(0); __cleanProfile(); sayWhenFree=function(){};
       CFG.gfxAuto=1; CFG.gfxScale=1; CFG.fpsCap=0;
       reset(); feed(22,5000,6); if(DRS.q<1) bad.push('45 fps did not shed particles');
       if(events.length&&events[0].t-100000<2000) bad.push('shed before two seconds slow');
       reset(); feed(33.3,60000,6);
       if(DRS.scale!==1) bad.push('30 Hz softened to '+DRS.scale);
       if(DRS.q!==0) bad.push('fixed cadence did not recover the rungs');
       var n=events.length; feed(33.3,30000,6); if(events.length!==n) bad.push('fixed cadence keeps cycling');
       reset(); CFG.fpsCap=144; feed(11,30000,6); if(events.length) bad.push('144 cap shed at 90 fps'); CFG.fpsCap=0;
       reset();
       for(i=0;i<20;i++){ feed(22,3000,6); feed(16,3000,6); }
       for(i=1;i<events.length;i++) if(events[i].dir!==events[i-1].dir&&events[i].t-events[i-1].t<10000) bad.push('opposite moves less than ten seconds apart');
       reset(); while(DRS.q<3&&t<1000000) feed(40,40,6);
       if(DRS.q!==3) bad.push('did not reach the fill rung');
       feed(38,40000,6); if(DRS.scale!==0.75) bad.push('proven fill gain did not use the scale ladder to its floor: '+DRS.scale);
       feed(16,15000,6); if(DRS.scale<=0.75) bad.push('clear frames did not restore sharpness first');
       if(DRS.q!==3) bad.push('clear frames restored a rung before sharpness');
       reset(); DRS.q=1; gfxqApply(); feed(16,12000,6);
       if(DRS.q!==0) bad.push('ten clear seconds did not recover a rung');
       feed(22,14000,6); if(DRS.bounce<1) bad.push('down within 30 seconds of up did not double recovery wait');
       feed(16,15000,6); if(DRS.q===0) bad.push('bounced recovery ignored its doubled wait');
       reset(); DRS.q=1; DRS.bounce=3; DRS.decayAt=t+60000; feed(18,61000,6);
       if(DRS.bounce!==2) bad.push('one quiet minute did not drop exactly one doubling');
       __deploy({kit:[],safe:null,mapIx:0,seed:4242}); g=__state(); gfxqRaidSync(t);
       DRS.q=3; DRS.scale=0.85; DRS.fillOK=true; drsRemember(); __endRaid('abandon'); gfxqRaidSync(t);
       __deploy({kit:[],safe:null,mapIx:0,seed:4242}); gfxqRaidSync(t+1000);
       if(DRS.q!==3||Math.abs(DRS.scale-0.9)>1e-6) bad.push('next raid did not start at rung 3 / 0.90');
       return bad.length?bad.join('; '):null;
     }finally{
       try{ __endRaid('abandon'); }catch(_e){} sayWhenFree=os;
       DRSSESSION.raid=sess0.raid; DRSSESSION.settled=sess0.settled;
       var ds=JSON.parse(d0), cs=JSON.parse(c0), qs=JSON.parse(q0);
       for(k in DRS) if(!(k in ds)) delete DRS[k]; for(k in ds) DRS[k]=ds[k]; for(k in cs) CFG[k]=cs[k]; for(k in qs) GFXQ[k]=qs[k];
       gfxqApply(); try{ resize(); }catch(_r){} __topClear();
     } }},
  {v:'34.14',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
