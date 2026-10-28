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

if ($s.Contains("  {v:'35.79',what:")) { throw "check 35.79 is in the fixture already" }

SubRx @'
  {v:'35.78',what:
'@ @'
  {v:'35.79',what:'night, hard weather and each signed condition multiply SP by 1.05, with no condition cash or XP',
   run:function(){
     var d0=DMUL_ON, c0=CAREER_ON, g, q, bad=[], day, night, wet, signed, host, guest, all, k;
     function rec(n,w,t){ return {outcome:'extract',haul:10000,carriedIn:0,containers:4,kills:{crawler:2},dist:2000,night:n,wxHard:w,termPay:t}; }
     function one(cond,weather,terms,own,how){
       __runPrep(); __topClear(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       DMUL_ON=1; CAREER_ON=1; q=__P(); q.cond=cond; q.wxPick=weather; q.terms=terms.slice(); q.merc='';
       __deploy({kit:[],safe:null,mapIx:0,seed:4242}); g=__state();
       if(!g||!g.player||g.over) throw new Error('no live raid');
       g.terms=terms.slice(); q.terms=own===undefined?terms.slice():own.slice();
       g.career=1; g.cs={s:1000,k:0,b:{kill:1000}}; g.bag=['core']; g.carriedIn=0; g.pedCarry=0;
       g.wx=WEATHER.filter(function(w){return w.id===weather;})[0];
       g.player.downed=false; g.player.hp=100; q.credits=10000; q.racks=0; q.arrays=0;
       var factor=raidConditionMul();
       __endRaid(how||'extract');
       return {cash:q.credits-10000,score:g.careerLb&&g.careerLb.score,factor:factor,paid:g.careerPaid,html:document.getElementById('oc_manifest').innerHTML};
     }
     try{
       __runPrep(); __topClear(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       var xp=xpBaseFor(rec(0,0,0));
       if(xpBaseFor(rec(1,1,1.4))!==xp) return 'night, weather or Terms still multiply XP';
       if(typeof raidConditionMul!=='function') return 'raid conditions have no SP-only multiplier';
       day=one('day','clear',[]);
       night=one('night','clear',[]);
       wet=one('day','fog',[]);
       signed=one('day','clear',['known']);
       host=one('night','fog',['known']);
       guest=one('night','fog',['known'],[]);
       all=one('night','fog',TERMS.map(function(t){return t.id;}),[]);
       if(day.score!==2000) bad.push('day control score '+day.score);
       if(night.score!==2100||wet.score!==2100||signed.score!==2100) bad.push('one condition does not pay 1.05x SP');
       if(guest.score!==Math.round(2000*Math.pow(1.05,3))) bad.push('guest did not score host raid conditions');
       if(guest.score!==host.score||guest.cash!==host.cash) bad.push('host and guest settlement differ');
       if(all.score!==Math.round(2000*Math.pow(1.05,7))) bad.push('all seven conditions do not stack multiplicatively');
       var cases=[night,wet,signed,host,guest,all];
       for(k=0;k<cases.length;k++) if(cases[k].cash!==day.cash) bad.push('condition '+k+' paid extra cash');
       if(/hazard pay/i.test(all.html)) bad.push('the card still promises hazard cash');
       if(!/x1.05/.test(night.html)) bad.push('the score panel omits the night factor');
       var credits=q.credits; careerSettle('extract',[]); if(q.credits!==credits) bad.push('settlement paid twice');
       var dead=one('night','fog',['known'],[],'dead');
       if(dead.score!==Math.round(500*Math.pow(1.05,3))) bad.push('death score conditions differ');
       if(dead.cash>0) bad.push('death paid condition cash');
       var abandon=one('night','fog',['known'],[],'abandon');
       if(abandon.cash>0||abandon.score) bad.push('abandon paid score or condition cash');
       return bad.length?bad.join('; '):null;
     } finally {
       try{ if(g&&!g.over){g.player.downed=false; __endRaid('abandon');} }catch(e){}
       DMUL_ON=d0; CAREER_ON=c0; __topClear(); __resetCfg(); __cleanProfile();
     }
   }},
  {v:'35.78',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
