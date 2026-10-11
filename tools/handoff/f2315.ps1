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

if ($s.Contains("  {v:'23.15',what:")) { throw "check 23.15 is in the fixture already" }

SubRx @'
  {v:'23.14',what:
'@ @'
  {v:'23.15',what:'two teammates down are two alerts: with TEAMMATE DOWN up for one teammate, a second teammate going down takes the slot and the first alert waits in the alert queue with its own REVIVE detail, rather than the second overwriting the first in place',
   run:function(){
     if(!(window.__deploy&&window.__state&&window.__endRaid)||typeof alertSay!=='function'||typeof alertUp!=='function') return 'SKIP: no alert lane here';
     var bad=[], g=null, i, got=[], hA=function(){ return true; }, hB=function(){ return true; };
     try{
       __topClear(); __runPrep(); __resetCfg(); __pinDefaults(0); __cleanProfile(); keys={};
       __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       g=__state(); if(!g||g.over||!g.player) return 'SKIP: staging: no raid';
       g.paused=false; g.alert=null; g.alertQ=[]; g.msg=''; g.msgT=0; g.feed=[]; g.msgQ=[]; g.msgQM=[];
       say('TEAMMATE DOWN','crit',{sub:'REVIVE ZQXA',key:'tmdown1',icon:'party',hold:hA});
       g.t=(g.t||0)+1.0;
       say('TEAMMATE DOWN','crit',{sub:'REVIVE ZQXB',key:'tmdown2',icon:'party',hold:hB});
       var a=alertUp(); if(a) got.push(a.m+' | '+a.sub+' | '+a.key);
       for(i=0;i<(g.alertQ||[]).length;i++){ var e=g.alertQ[i]; got.push(e.m+' | '+((e.o&&e.o.sub)||'')+' | '+(e.key||'')); }
       for(i=0;i<(g.msgQ||[]).length;i++) got.push(String(g.msgQ[i])+' | '+String((g.msgQM[i]&&g.msgQM[i].o&&g.msgQM[i].o.sub)||'')+' | feedq');
       if(g.msgT>0&&g.msg) got.push(String(g.msg)+' | '+String(g.msgSub||'')+' | feed');
       if(!a||a.sub!=='REVIVE ZQXB') bad.push('the second teammate down does not show in the alert slot ('+JSON.stringify(got)+')');
       if(!got.some(function(t){ return t.indexOf('TEAMMATE DOWN | REVIVE ZQXA')===0; })) bad.push('the first teammate down alert is gone, overwritten by the second ('+JSON.stringify(got)+')');
       g.alert=null; g.alertQ=[];
       say('ZQXO CALL','warn',{sub:'one',key:'zqxo'}); say('ZQXO CALL','warn',{sub:'two',key:'zqxo'});
       a=alertUp();
       if(!a||a.sub!=='two'||(g.alertQ||[]).length) bad.push('an alert said again under the same key no longer refreshes in place');
     }catch(err){ bad.push('threw: '+(err&&err.message||err)); }
     finally{
       keys={};
       try{ var g2=__state(); if(g2){ g2.alert=null; g2.alertQ=[]; g2.feed=[]; g2.msgQ=[]; g2.msgQM=[]; g2.msgT=0; if(!g2.over){ g2.player.downed=false; __endRaid('abandon'); } } }catch(_e){}
       __topClear(); __cleanProfile();
     }
     return bad.length?bad.join('; '):null; }},
  {v:'23.14',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
