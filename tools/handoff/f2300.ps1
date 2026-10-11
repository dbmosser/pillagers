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

if ($s.Contains("  {v:'23.00',what:")) { throw "check 23.00 is in the fixture already" }

SubRx @'
  {v:'22.99',what:
'@ @'
  {v:'23.00',what:'one way to write numbers in a raid: fmtDur gives 12s below a minute and m:ss from a minute up, a looted item worth 1234 Credits is labelled with $1,234 and no c unit, and the raid clock line from Settings reads RAID CLOCK SET TO m:ss with no min or sec',
   run:function(){
     if(!(window.__deploy&&window.__state&&window.__endRaid)||typeof grantLoot!=='function'||typeof gameOptRaidNow!=='function'||typeof ival!=='function') return 'SKIP: no loot labels or raid clock here';
     var bad=[], g=null, p=null, i, ct=null, lb=null, nm, said=[], realSay=say, ival0=ival, rs0=CFG.raidSec, s, hit=null;
     try{
       if(typeof fmtDur!=='function') bad.push('there is no fmtDur, so raid lines still write 1 min 30 sec');
       else {
         if(fmtDur(90)!=='1:30') bad.push('fmtDur(90) is '+JSON.stringify(fmtDur(90))+', not 1:30');
         if(fmtDur(12)!=='12s') bad.push('fmtDur(12) is '+JSON.stringify(fmtDur(12))+', not 12s');
         if(fmtDur(60)!=='1:00') bad.push('fmtDur(60) is '+JSON.stringify(fmtDur(60))+', not 1:00');
       }
       __topClear(); __runPrep(); __resetCfg(); __pinDefaults(0); __cleanProfile(); keys={};
       __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       g=__state(); if(!g||g.over||!g.player) return 'SKIP: staging: no raid';
       p=g.player;
       if(!ITEMS.codex) return 'SKIP: no Data Core item here';
       for(i=0;i<g.containers.length;i++) if(g.containers[i]&&!g.containers[i].dropped){ ct=g.containers[i]; break; }
       if(!ct) return 'SKIP: staging: no container';
       nm=ITEMS.codex.name;
       g.labels.length=0;
       ival=function(){ return 1234; };
       grantLoot(ct,['codex'],0);
       ival=ival0;
       for(i=0;i<g.labels.length;i++) if(String(g.labels[i].txt).indexOf(nm)===0){ lb=String(g.labels[i].txt); break; }
       if(!lb) return 'SKIP: staging: looting a Data Core pushed no label';
       if(!(/\$1,234$/).test(lb)) bad.push('an item worth 1234 Credits is labelled '+JSON.stringify(lb)+', not with $1,234');
       if((/\dc$/).test(lb)) bad.push('the loot label still ends in the c unit: '+JSON.stringify(lb));
       say=function(m,k,o){ said.push(String(m)+((o&&o.sub)?(' | '+o.sub):'')); return realSay.apply(this,arguments); };
       CFG.raidSec=(rs0>0?rs0:900)*2;
       if(!gameOptRaidNow(rs0>0?rs0:900)) bad.push('the raid clock did not change from Settings in a raid');
       for(i=0;i<said.length;i++) if(/CLOCK/i.test(said[i])) hit=said[i];
       if(!hit) bad.push('changing the raid clock in a raid said no clock line (said: '+JSON.stringify(said)+')');
       else {
         if(/\bmin\b|\bsec\b/.test(hit)) bad.push('the raid clock line still writes min or sec: '+JSON.stringify(hit));
         if(!(/\d+:\d\d/).test(hit)) bad.push('the raid clock line does not write m:ss: '+JSON.stringify(hit));
         if(hit.indexOf('RAID CLOCK '+'SET TO ')!==0) bad.push('the raid clock line is not the caps row RAID CLOCK SET TO m:ss: '+JSON.stringify(hit));
       }
     }catch(err){ bad.push('threw: '+(err&&err.message||err)); }
     finally{
       ival=ival0; say=realSay; CFG.raidSec=rs0; keys={};
       try{ var g2=__state(); if(g2){ g2.labels.length=0; if(!g2.over){ g2.player.downed=false; __endRaid('abandon'); } } }catch(_e){}
       __topClear(); __resetCfg(); __cleanProfile();
     }
     return bad.length?bad.join('; '):null; }},
  {v:'22.99',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
