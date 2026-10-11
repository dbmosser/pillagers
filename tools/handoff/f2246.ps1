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

if ($s.Contains("  {v:'22.46',what:")) { throw "check 22.46 is in the fixture already" }

SubRx @'
  {v:'22.45',what:
'@ @'
  {v:'22.46',what:'an alert is up long enough to read: a second extraction alert said 0.7 s after the first waits until the first has shown 2 s, then shows as the alert, and the first comes back after it',
   run:function(){
     if(!(window.__deploy&&window.__state&&window.__endRaid&&window.__loop)) return 'SKIP: this fixture cannot deploy or step';
     if(window.__vpAlive&&!__vpAlive()) return 'SKIP: the pane has no layout, so the frame loop cannot draw';
     var bad=[], g, p, i, t0, f=0, a, realSay=say, ZA=['ZQ','FIRST'].join(' '), ZB=['ZQ','SECOND'].join(' '), aFirst=0, bAt=-1, aBack=false, tt=0;
     function step(ms){ __loop(t0+(f+=ms)); }
     try{
       __topClear(); __runPrep(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       g=__state(); if(!g||g.over||!g.player) return 'SKIP: staging: no raid';
       p=g.player; p.iv=99; g.ents.length=0; g.waveT=-1e9; g.mapOpen=false; g.bagOpen=false;
       g.msgT=0; g.msg=''; g.msgQ=[]; g.msgQM=[]; g.feed=[]; g.msgAt=undefined; g.msgKey=''; g.alert=null; g.alertQ=[];
       say=function(m){ if(String(m).indexOf('ZQ')===0) return realSay.apply(this,arguments); };
       t0=Math.max(performance.now(),(typeof lastTs==='number'&&isFinite(lastTs))?lastTs:0);
       say(ZA,'ext',{sub:'zq a'});
       for(i=0;i<14&&!g.over;i++){ g.ents.length=0; step(50); tt+=0.05; }   // 0.7 s
       say(ZB,'ext',{sub:'zq b'});
       for(i=0;i<160&&!g.over;i++){
         a=g.alert; if(a&&a.T>0){ if(a.m===ZA&&bAt<0) aFirst=tt; if(a.m===ZB&&bAt<0) bAt=tt; if(a.m===ZA&&bAt>=0) aBack=true; }
         g.ents.length=0; step(50); tt+=0.05;
       }
       if(bAt<0) bad.push('the second extraction alert never showed as the alert in 8 s');
       else if(bAt<1.8) bad.push('the second extraction alert took the slot when the first had shown only '+bAt.toFixed(2)+' s, not 2 s');
       if(bAt>=0&&!aBack) bad.push('the first extraction alert never came back after the second');
       if(bAt<0&&aFirst<1.8) bad.push('the first extraction alert showed only '+aFirst.toFixed(2)+' s');
     }catch(err){ bad.push('threw: '+(err&&err.message||err)); }
     finally{
       say=realSay;
       try{ var g2=__state(); if(g2){ g2.msgT=0; g2.msg=''; g2.feed=[]; g2.msgQ=[]; g2.msgQM=[]; g2.msgKey=''; g2.alert=null; g2.alertQ=[]; } if(g2&&!g2.over){ g2.player.iv=0; __endRaid('abandon'); } }catch(_e){}
       __topClear();
     }
     return bad.length?bad.join('; '):null; }},
  {v:'22.45',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
