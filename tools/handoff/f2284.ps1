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

if ($s.Contains("  {v:'22.84',what:")) { throw "check 22.84 is in the fixture already" }

SubRx @'
  {v:'22.83',what:
'@ @'
  {v:'22.84',what:'errors leave the screen: two crashes in a raid put their raw text in the crash log and in no line the player can see, and the screen shows exactly one system row saying the error was saved to the run report',
   run:function(){
     if(!(window.__deploy&&window.__state&&window.__endRaid)) return 'SKIP: this fixture cannot deploy';
     if(typeof noteCrash!=='function'||typeof PLOADED==='undefined'||!PLOADED) return 'SKIP: no loaded crash catcher in this build';
     var bad=[], g, i, j, L, s, _sp=saveProfile, keep=P.crashes, keepAt=noteCrash.savedAt, keepTold=crashTold, NE='zq'+'boom', rows=0, inLog=false, tr=null;
     try{
       __topClear(); __runPrep(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       g=__state(); if(!g||g.over||!g.player) return 'SKIP: staging: no raid';
       saveProfile=function(){}; P.crashes=[]; noteCrash.savedAt=0; crashTold=false; g.errSaid=0;
       g.msgT=0; g.msg=''; g.feed=[]; g.msgQ=[]; g.msgQM=[]; g.alert=null; g.alertQ=[]; g.msgLog=[];
       noteCrash('error','zq '+NE+' one','zq:1:1');
       noteCrash('error','zq '+NE+' two words apart','zq:2:2');
       for(i=0;i<P.crashes.length;i++) if(String(P.crashes[i].msg).indexOf(NE)>=0) inLog=true;
       if(!inLog) bad.push('the crash log does not hold the error text');
       L=g.msgLog||[];
       for(i=0;i<L.length;i++){
         s=String(L[i].m)+' '+String(L[i].sub||'');
         if(L[i].k!=='log'&&s.indexOf(NE)>=0) bad.push('a '+L[i].k+' line the player sees carries the raw error: '+s);
         if(L[i].k!=='log'&&s.indexOf(NE)<0&&(/RUN REPORT/i).test(s)) rows++;
       }
       if(rows!==1) bad.push('two crashes showed '+rows+' rows saying the error was saved, not 1');
       try{ tr=__textTrace(function(){ try{ drawHUD(); }catch(_h){} }); }catch(_t){ tr=null; }
       if(tr) for(j=0;j<tr.length;j++) if(String(tr[j].t).indexOf(NE)>=0){ bad.push('the HUD drew the raw error: '+tr[j].t); break; }
       if(g.alert&&String(g.alert.m+' '+g.alert.sub).indexOf(NE)>=0) bad.push('the alert lane holds the raw error');
     }catch(err){ bad.push('threw: '+(err&&err.message||err)); }
     finally{
       saveProfile=_sp; P.crashes=keep; noteCrash.savedAt=keepAt; try{ crashTold=keepTold; }catch(_t2){}
       try{ var g2=__state(); if(g2){ g2.errSaid=0; g2.msgT=0; g2.msg=''; g2.feed=[]; g2.msgQ=[]; g2.msgQM=[]; g2.alert=null; g2.alertQ=[]; g2.pick=[]; } if(g2&&!g2.over){ g2.player.downed=false; g2.player.iv=0; __endRaid('abandon'); } }catch(_e){}
       __topClear();
     }
     return bad.length?bad.join('; '):null; }},
  {v:'22.83',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
