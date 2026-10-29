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

if ($s.Contains("  {v:'36.54',what:")) { throw "check 36.54 is in the fixture already" }

SubRx @'
  {v:'36.53',what:
'@ @'
  {v:'36.54',what:'cw-cx-mapnocaches: both seats keep caches off both maps with or without intel, retain objectives, and show just one ring for the Stray reward',
   run:function(){
     var g, bad=[], PR=CanvasRenderingContext2D.prototype, oa=PR.arc, of=PR.fillText, or=PR.fillRect, oi=mapIcon, os=MAPFIRST.skip,
         ow=W, oh=H, oldSeat=seatHere, role=NET.role, seat=NET.seat, online=NET.on, oldFlow=flowMarks, rec=[], cs, c, keep, i, n, f, intel, z;
     function grab(mini){
       rec=[];
       PR.arc=function(x,y,r){rec.push(['arc',x,y,r]);return oa.apply(this,arguments);};
       PR.fillRect=function(x,y,w,h){rec.push(['rect',x,y,w,h]);return or.apply(this,arguments);};
       PR.fillText=function(s,x,y){rec.push(['text',String(s),x,y]);return of.apply(this,arguments);};
       mapIcon=function(x,y,r){rec.push(['icon',x,y,r]);return oi.apply(this,arguments);};
       try{if(mini)mmMarks(mmRect(),mmRect().w/mmSpan(),hudRes());else drawMapOverlay();}
       finally{PR.arc=oa;PR.fillRect=or;PR.fillText=of;mapIcon=oi;}
       return rec.slice();
     }
     function text(a,rx){return a.some(function(v){return v[0]==='text'&&rx.test(v[1]);});}
     function mark(a,c,kind,r){var m=mapProj();return a.filter(function(v){return v[0]===kind&&Math.abs(v[1]-(m.ox+c.x*m.sc))<0.01&&Math.abs(v[2]-(m.oy+c.y*m.sc))<0.01&&Math.abs(v[3]-r)<0.01;}).length;}
     try{
       __runPrep(); __topClear(); __resetCfg(); __pinDefaults(0); __cleanProfile(); MAPFIRST.skip=1;
       __deploy({kit:[],safe:null,mapIx:0,seed:4242});g=__state();if(!g||g.over)return 'SKIP: no raid';
       g.mapOpen=true;g.mapFirst=0;g.bagOpen=false;g.paused=false;keys={};mouse.down=false;NET.on=false;
       cs=g.containers;keep=cs.map(function(v){return [v,v.revealed,v.opened];});
       cs.forEach(function(v){v.revealed=false;});
       c=cs.filter(function(v){return v.cache&&!v.strong&&!v.opened;})[0];
       var sb=cs.filter(function(v){return v.strong&&!v.opened;})[0], rooms=g.map.locked||[];
       if(!c||!sb||rooms.length<2)return 'staging: cache, strongbox or locked rooms missing';
       var roomOpen=rooms.map(function(v){return v.open;});rooms[0].open=false;rooms[1].open=true;
       var opened=cs.filter(function(v){return v.cache&&!v.strong&&v!==c;})[0];if(opened)opened.opened=true;
       for(n=0;n<2;n++){
         NET.role=n?'peer':'host';NET.seat=n;seatHere=(function(s){return function(){return s;};})(n);
         W=n?3840:1920;H=n?2160:1080;z=Math.max(1,hudRes());
         for(f=0;f<2;f++)for(intel=0;intel<2;intel++){
           g.mapFirst=f;g.intel=intel;
           var all=grab(false);
           if(text(all,/^(cache|looted)$/i))bad.push('cache word at seat '+n+' start '+f+' intel '+intel);
           g.containers=cs.filter(function(v){return !v.cache||v.strong;});
           var without=grab(false);g.containers=cs;
           if(JSON.stringify(all)!==JSON.stringify(without))bad.push('cache draw at seat '+n+' start '+f+' intel '+intel);
           if(!mark(all,sb,'arc',10*z)||!mark(all,sb,'icon',15*z))bad.push('strongbox icon lost');
           if(!f&&!text(all,/^strongbox$/i))bad.push('strongbox word lost');
           if(!text(all,/\blocked\b/i)||!text(all,/\bopen\b/i))bad.push('locked/open room words lost');
           if(intel&&(g.intelKeys||[]).some(function(v){return !v.opened&&(v.loot||[]).some(function(k){return String(k).indexOf('key_')===0;});})&&!text(all,/^keycard$/i))bad.push('keycard intel lost');
           c.revealed=true;var told=grab(false);c.revealed=false;
           if(told.length!==all.length+1||!mark(told,c,'arc',6*z)||mark(told,c,'icon',10*z)||text(told,/^(cache|looted)$/i))bad.push('Stray reward is not one plain ring');
         }
         g.mapFirst=0;g.intel=1;
         for(i=0;i<2;i++){
           flowMarks=oldFlow;var base=grab(!!i);
           flowMarks=function(){return oldFlow().concat([{x:c.x,y:c.y,r:0,col:'#ffc04a',shape:'sq',kind:'loot',txt:'CACHE',pin:0,a:1}]);};
           if(JSON.stringify(base)!==JSON.stringify(grab(!!i)))bad.push('event cache mark on '+(i?'minimap':'sector map'));
         }
         flowMarks=oldFlow;
       }
       return bad.length?bad.join('; '):null;
     }finally{
       PR.arc=oa;PR.fillText=of;PR.fillRect=or;mapIcon=oi;flowMarks=oldFlow;seatHere=oldSeat;NET.role=role;NET.seat=seat;NET.on=online;W=ow;H=oh;MAPFIRST.skip=os;
       if(g&&cs)g.containers=cs;if(keep)keep.forEach(function(v){v[0].revealed=v[1];v[0].opened=v[2];});
       if(roomOpen)rooms.forEach(function(v,i){v.open=roomOpen[i];});
       try{if(g){g.mapFirst=0;g.mapOpen=false;}__endRaid('abandon');}catch(e){}__topClear();__resetCfg();__cleanProfile();
     }
   }},
  {v:'36.53',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
