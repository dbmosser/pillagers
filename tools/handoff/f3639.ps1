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

if ($s.Contains("  {v:'36.39',what:")) { throw "check 36.39 is in the fixture already" }

SubRx @'
  {v:'36.38',what:
'@ @'
  {v:'36.39',what:'a missed extraction with time left has only its headline in the alert and delayed feed, for keys and pad in both local window roles; short clock still explains no time',
   run:function(){
     if(!(window.__deploy&&window.__state&&window.__endRaid)||typeof tickExtractPoints!=='function'||typeof alertTick!=='function') return 'SKIP: no extraction fixture';
     var g=null, oldLabel=keyLabel, oldP2=NETP2, bad=[], z, i, role, pad;
     function quiet(){ g.alert=null; g.alertQ=[]; g.msgLog=[]; g.fd=null; g.msgQ=[]; g.msgQM=[]; }
     function miss(tl){
       for(i=0;i<g.zones.length;i++){ g.zones[i].beaconT=null; g.zones[i].hold=null; g.zones[i].pullT=null; }
       z.open=true; z.closeAt=undefined; z.warned=1; z.beaconT=-1; z.hold=0.01; z.holdMax=5; z.pullT=null;
       z.siege=0; z.siegeSpawnT=0; z.siegeSpawned=0; g.siege=0; g.active=z; g.timeLeft=tl;
       g.player.x=z.x+300; g.player.y=z.y; tickExtractPoints(0.05);
     }
     function checkLine(m,sub,where){
       if(!/^extraction missed$/i.test(String(m))) bad.push(where+' lost the headline: '+m);
       if(sub) bad.push(where+' has a detail with time left: '+sub);
       if(/call again/i.test(String(m)+' '+String(sub||''))) bad.push(where+' still says call again');
     }
     try{
       __runPrep(); __topClear(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       g=__state(); if(!g||g.over||g.sim||!g.player||!g.zones.length) return 'SKIP: no live raid';
       g.ents=[]; g.bagOpen=false; g.mapOpen=false; g.paused=false; z=g.zones[0];
       for(role=0;role<2;role++) for(pad=0;pad<2;pad++){
         NETP2=!!role; keyLabel=pad?function(){return 'A';}:oldLabel;
         var tag='p'+(role+1)+' '+(pad?'pad':'keys');
         quiet(); miss(200);
         if(!g.alert) bad.push(tag+' no missed alert');
         else checkLine(g.alert.m,g.alert.sub,tag+' alert');
         if(z.hold!==null||z.beaconT!==null||!z.open) bad.push(tag+' did not free the open exit for another call');
         quiet();
         g.alert={m:'test blocker',k:'crit',sub:'',key:'blocker',T:20,T0:20,at:g.t||0};
         miss(200);
         if(!g.alertQ||!g.alertQ.length) bad.push(tag+' missed alert was not queued');
         g.t=(g.t||0)+10; alertTick(0.01);
         var rows=g.fd&&g.fd.lines||[], found=null;
         for(i=0;i<rows.length;i++) if(/extraction missed/i.test(rows[i].txt)) found=rows[i];
         if(!found) bad.push(tag+' no delayed feed copy');
         else checkLine(found.txt,'',tag+' feed');
       }
       NETP2=oldP2; keyLabel=oldLabel;
       quiet(); miss(Math.max(1,Math.floor(CFG.extractWait/2)));
       if(!g.alert||g.alert.sub!=='No time to call again') bad.push('short clock lost the no-time explanation');
       return bad.length?bad.join('; '):null;
     }finally{
       NETP2=oldP2; keyLabel=oldLabel;
       try{ __endRaid('abandon'); }catch(_e){}
       __topClear(); __resetCfg();
     } }},
  {v:'36.38',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
