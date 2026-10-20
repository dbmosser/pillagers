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

if ($s.Contains("  {v:'32.99',what:")) { throw "check 32.99 is in the fixture already" }

SubRx @'
  {v:'32.98',what:
'@ @'
  {v:'32.99',what:'the experimental menu: one Settings row opens a page with an on/off row per newer feature, every switch starts on, and a switch that is off keeps its feature from running (run goals, golden enemy, strongholds, power-ups) while on it runs',
   run:function(){
     if(typeof xfSnap!=='function'||typeof expPage!=='function') return 'there is no experimental menu in this build';
     if(typeof arcadeDeploy!=='function'||typeof ARCADE!=='object'||typeof goalsTick!=='function'||typeof goldTick!=='function'||typeof shTick!=='function'||typeof pwrKill!=='function') return 'SKIP: no arcade features here';
     var bad=[], ks=['xfGoals','xfGold','xfHold','xfPwr'], i, k, host, b, rs=say, own=false, on=null, off=null;
     function runRaid(isOff){
       var j, g2, p2, S2;
       __topClear(); __runPrep(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       for(j=0;j<ks.length;j++) CFG[ks[j]]=isOff?0:1;
       if(!arcadeDeploy({mapIx:0,seed:4242})) return null;
       g2=__state(); if(!g2||g2.over||!g2.player) return null;
       p2=g2.player; keys={}; ARCADE.holdT=0; g2.t=4;
       goalsTick(0.1); goldTick(0.5); shTick(0.1);
       S2=pwrS(); for(j=0;j<300;j++){ S2.lastDrop-=1; pwrKill('crawler',0,false,p2.x+60,p2.y,null); }
       return {goals:(flowS().goals||[]).length, tries:(goldS().tries|0), sites:Array.isArray(shS().sites), kn:(pwrS().kn|0), snap:ks.map(function(q){ return XF[q]; }).join('')};
     }
     try{
       __topClear(); __runPrep(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       // ONE: every switch is a row on the experimental page, on by default, and the main list holds only the open row
       SETSUB='exp'; renderSettings(); host=document.getElementById('setlist');
       if(!document.getElementById('exp_back')) bad.push('ONE: the experimental page has no back button');
       for(i=0;i<ks.length;i++){
         k=ks[i]; b=document.getElementById('go_'+k);
         if(!b){ bad.push('ONE: no row for '+k); continue; }
         if(String(b.textContent).toLowerCase()!=='on'||CFG[k]!==1||gameOptIx(k)!==0) bad.push('ONE: '+k+' does not start on');
       }
       b=document.getElementById('go_xfGoals');
       if(b){ b.onclick(); if(CFG.xfGoals!==0||!P.gameOpts||P.gameOpts.xfGoals!==1) bad.push('ONE: a click did not switch run goals off and save it');
         b=document.getElementById('go_xfGoals'); if(b){ b.onclick(); if(CFG.xfGoals!==1) bad.push('ONE: a second click did not switch run goals back on'); } }
       SETSUB=''; renderSettings();
       if(!document.getElementById('exp_open')) bad.push('ONE: the main list has no experimental row');
       if(document.getElementById('go_xfGoals')) bad.push('ONE: a switch row shows on the main list');
       // TWO: all on, every feature runs
       say=function(){}; own=true;
       on=runRaid(false);
       try{ if(typeof ARCADE==='object'&&ARCADE.on) arcadeLeave(); }catch(_l1){}
       try{ if(__state()&&!__state().over) __endRaid('abandon'); }catch(_e1){}
       if(!on) return 'SKIP: no arcade raid';
       if(on.goals!==3) bad.push('TWO: with run goals on the raid made '+on.goals+' goals, not 3');
       if(on.tries<1) bad.push('TWO: with golden enemy on it never tried to gild a body');
       if(!on.sites) bad.push('TWO: with strongholds on none were laid out');
       if(on.kn<300) bad.push('TWO: with power-ups on only '+on.kn+' of 300 kills were counted');
       if(on.snap!=='1111') bad.push('TWO: the snapshot of an all-on raid is '+on.snap);
       // THREE: all off from the raid start, none of them runs
       off=runRaid(true);
       if(!off) bad.push('THREE: no raid with the switches off');
       else {
         if(off.goals!==0) bad.push('THREE: with run goals off the raid made '+off.goals+' goals');
         if(off.tries!==0) bad.push('THREE: with golden enemy off it still tried to gild a body');
         if(off.sites) bad.push('THREE: with strongholds off a layout was made');
         if(off.kn!==0) bad.push('THREE: with power-ups off '+off.kn+' kills were counted');
         if(off.snap!=='0000') bad.push('THREE: the snapshot of an all-off raid is '+off.snap);
       }
     } catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{
       if(own) say=rs;
       SETSUB='';
       for(i=0;i<ks.length;i++){ try{ if(P.gameOpts) delete P.gameOpts[ks[i]]; }catch(_d){} }
       try{ if(typeof ARCADE==='object'&&ARCADE.on) arcadeLeave(); }catch(_l){}
       try{ if(__state()&&!__state().over) __endRaid('abandon'); }catch(_e){}
       __topClear(); __resetCfg(); xfSnap(); __cleanProfile();
     }
     return bad.length?bad.join('; '):null; }},
  {v:'32.98',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
