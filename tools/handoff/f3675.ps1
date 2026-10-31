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

if ($s.Contains("  {v:'36.75',what:")) { throw "check 36.75 is in the fixture already" }

SubRx @'
  {v:'36.74',what:
'@ @'
  {v:'36.75',what:'a danger stands at 27 percent of the height; a second danger does not draw over it; the same keyed danger does not show again for 10 s; a danger that waited over 1.5 s is dropped and not fed',
   run:function(){
     if(!(window.__deploy&&window.__state&&window.__endRaid&&typeof __frame==='function')||typeof alertSay!=='function') return 'SKIP: no alert fixture';
     var PR=CanvasRenderingContext2D.prototype, of=PR.fillText, g=null, bad=[], ys=[], second=0, z, i, rows, hit;
     function quiet(){ g.alert=null; g.alertQ=[]; g.alertSeen={}; g.msgLog=[]; g.fd=null; g.msgQ=[]; g.msgQM=[]; g.loc=null; }
     try{
       __runPrep(); __topClear(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       g=__state(); if(!g||g.over||g.sim||!g.player) return 'SKIP: no live raid';
       g.ents=[]; g.bagOpen=false; g.mapOpen=false; g.paused=false;
       // 1. the draw: where the headline stands on the screen
       quiet(); alertSay('TEST DANGER ALPHA','warn',{key:'t-alpha'}); if(g.alert) g.alert.at=(g.t||0)-1;
       PR.fillText=function(s,x,y){ var t=String(s).toLowerCase(), m=this.getTransform();
         if(t==='test danger alpha') ys.push(m.f+y*m.d);
         if(t==='test danger beta') second++;
         return of.apply(this,arguments); };
       __frame(); __frame();
       PR.fillText=of;
       if(!ys.length) bad.push('the danger headline was not drawn');
       else if(ys[0]<H*0.27-6||ys[0]>H*0.27+H*0.08) bad.push('the danger headline stands at '+Math.round(ys[0]/H*100)+' percent of the height, not 27');
       // 2. one at a time: a second danger waits, and a danger replaces extraction news at once
       quiet(); alertSay('TEST DANGER ALPHA','warn',{key:'t-alpha'}); g.alert.at=(g.t||0)-0.5; alertSay('TEST DANGER BETA','warn',{key:'t-beta'});
       if(!g.alert||g.alert.m!=='TEST DANGER ALPHA') bad.push('a second danger drew over the first');
       quiet(); alertSay('TEST EXTRACTION NEWS','ext',{key:'t-ext'}); g.alert.at=(g.t||0)-0.5; alertSay('TEST DANGER BETA','warn',{key:'t-beta'});
       if(!g.alert||g.alert.m!=='TEST DANGER BETA') bad.push('a danger waited behind extraction news');
       // 3. the same keyed danger said again within 10 s shows once
       quiet(); alertSay('TEST DANGER GAMMA','warn',{key:'t-gamma'}); g.alert.T=0; g.t=(g.t||0)+4; alertSay('TEST DANGER GAMMA','warn',{key:'t-gamma'});
       if(alertUp()) bad.push('the same keyed danger showed again 4 s after it');
       g.alertSeen['TEST DANGER GAMMA|t-gamma']=(g.t||0)-11; alertSay('TEST DANGER GAMMA','warn',{key:'t-gamma'});
       if(!alertUp()) bad.push('the same keyed danger did not show again after 11 s');
       // 4. a danger that waited over 1.5 s is dropped and is not in the feed
       quiet(); g.alert={m:'TEST BLOCKER',k:'crit',sub:'',key:'t-blocker',T:20,T0:20,at:g.t||0};
       alertSay('TEST DANGER DELTA','warn',{key:'t-delta'});
       if(!g.alertQ.length) bad.push('the waiting danger was not queued');
       g.t=(g.t||0)+1.6; alertTick(0.01);
       if(g.alertQ.length) bad.push('a danger that waited 1.6 s is still waiting');
       g.t=(g.t||0)+10; alertTick(0.01);
       rows=(g.fd&&g.fd.lines)||[]; hit=false;
       for(i=0;i<rows.length;i++) if(/test danger delta/i.test(String(rows[i].txt))) hit=true;
       if(hit) bad.push('a dropped danger was moved to the feed');
       return bad.length?bad.join('; '):null;
     } finally {
       PR.fillText=of;
       try{ __endRaid('abandon'); }catch(_e){}
       __topClear();
     } }},
  {v:'36.74',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
