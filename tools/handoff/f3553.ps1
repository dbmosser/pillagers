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

if ($s.Contains("  {v:'35.53',what:")) { throw "check 35.53 is in the fixture already" }

SubRx @'
  {v:'35.52',what:
'@ @'
  {v:'35.53',what:'cw-hudsize, his ask 2026-10-27 (the hud messaging is a clusterfuck, make it AAA), the research rule for type at 1080p: the left feed and the answer line at least 20 px, the opened controls list at least 18 px, the danger slot headline about 30 px, and every colour of words on the hud plate at 4.5 to 1 or better over the lightest and the darkest ground',
   run:function(){
     if(!(window.__deploy&&window.__state&&window.__endRaid)) return 'SKIP: this fixture cannot deploy';
     if(typeof drawHUD!=='function'||!window.__textTrace||typeof feedAdd!=='function') return 'SKIP: no hud here';
     var bad=[], g, p, tr, o, i, oL, all=null, cs, bw, bb, nm;
     function find(re){ for(var j=0;j<tr.length;j++) if(re.test(String(tr[j].t))) return tr[j]; return null; }
     function clr(){ g.fd={t:0,seq:0,lines:[]}; g.alert=null; g.alertQ=[]; g.pick=[]; g.ans=null; g.ansSeen={}; }
     try{
       __topClear(); __runPrep(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       try{ __pinDPR(1); __forceSize(1920,1080); }catch(_fs){}
       __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       g=__state(); if(!g||g.over||!g.player||g.sim) return 'SKIP: staging: no raid';
       p=g.player; keys={}; g.mapOpen=false; g.bagOpen=false; g.paused=false; all=g.ents.slice(); g.ents=[]; oL=g.legendOn;
       try{ render2D(0); }catch(_r0){}
       if(typeof hudCR!=='function'||typeof feedFont!=='function') return 'no size floors or contrast reader (feedFont, hudCR)';
       // ONE: the feed at 20 px or more
       clr(); feedAdd([{t:'ZQ FEED LINE',c:null}],'info',{});
       tr=__textTrace(function(){ drawHUD(); }); o=find(/zq feed line/i);
       if(!o) bad.push('control: the feed line did not draw'); else if(!(o.px>=20)) bad.push('the feed is '+o.px.toFixed(1)+' px, under 20');
       // TWO: the answer line at 20 px or more
       if(typeof ansSay==='function'){ clr(); say('HEALTH FULL'); if(g.ans) g.ans.at-=0.5; tr=__textTrace(function(){ drawHUD(); }); o=find(/^health full$/i); if(!o) bad.push('control: the answer line did not draw'); else if(!(o.px>=20)) bad.push('the answer line is '+o.px.toFixed(1)+' px, under 20'); }
       // THREE: the opened controls list at 18 px or more
       clr(); g.legendOn=1; tr=__textTrace(function(){ drawHUD(); }); o=find(/^sprint$/i);
       if(!o) bad.push('control: the opened controls list did not draw'); else if(!(o.px>=18-0.05)) bad.push('the opened controls list is '+o.px.toFixed(1)+' px, under 18');
       g.legendOn=oL;
       // FOUR: the danger slot headline about 30 px
       clr(); say('ZQ DANGER','warn'); g.t=(g.t||0)+0.3; try{ msgTick(0.3); }catch(_mt){} tr=__textTrace(function(){ drawHUD(); }); o=find(/^zq danger$/i);
       if(!o) bad.push('control: the danger line did not draw'); else if(!(o.px>=28&&o.px<=36)) bad.push('the danger slot is '+o.px.toFixed(1)+' px, not about 30');
       // FIVE: words on the plate read at 4.5 to 1 over white and over black ground
       bw=hudOver(HUDC.plate,255); bb=hudOver(HUDC.plate,0);
       cs=[['the cream',HUDC.text],['the grey',HUDC.dim],['the teal','#4de3d0'],['the amber',HUDC.warn],['the red on a plate',(typeof HUDTXT_RED==='string')?HUDTXT_RED:HUDC.danger]];
       for(i=0;i<cs.length;i++){ nm=Math.min(hudCR(cs[i][1],bw),hudCR(cs[i][1],bb)); if(nm<4.5) bad.push(cs[i][0]+' reads '+nm.toFixed(2)+' to 1 on the plate, under 4.5'); }
       if(typeof extPillState==='function'){ var zc={open:false}; if(extPillState(zc,'EXTRACT').col!==HUDTXT_RED) bad.push('a shut exit on the pill is not in the lighter red'); }
     }catch(err){ bad.push('threw: '+(err&&err.message||err)); }
     finally{
       keys={};
       try{ if(g){ g.legendOn=oL; g.ans=null; g.alert=null; g.alertQ=[]; if(all) g.ents=all; } }catch(_z){}
       try{ var g2=__state(); if(g2&&!g2.over){ g2.player.downed=false; __endRaid('abandon'); } }catch(_e){}
       __topClear();
     }
     return bad.length?bad.join('; '):null; }},
  {v:'35.52',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
