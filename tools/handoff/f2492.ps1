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

if ($s.Contains("  {v:'24.92',what:")) { throw "check 24.92 is in the fixture already" }

SubRx @'
  {v:'24.91',what:
'@ @'
  {v:'24.92',what:'his note 2026-10-12: the KIA card no longer tacks on the unused medical hint, while KILLED BY, WITH, the distance and IN CONTACT still show',
   run:function(){
     if(!(window.__deploy&&window.__state&&window.__loop&&window.__keysRef&&window.__endRaid)||typeof damagePlayer!=='function')
       return 'SKIP: this fixture cannot drive a live raid';
     var bad=[];
     var T0=performance.now();
     function frames(k){ for(var f=0;f<(k||6);f++){ T0+=16.7; var st=__state(); if(!st) return; __loop(T0); } }
     function keysOff(){ var K=__keysRef(); for(var kk in K) K[kk]=false; }
     try{
       __topClear(); __runPrep(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       var g=__state();
       if(!g||!g.player||!g.bag||!g.tel) return 'SKIP: no live raid';
       keysOff();
       g.bag.length=0; g.bag.push('bandage'); g.bag.push('bandage');
       g.tel.heals=0;
       g.tel.firstContact=Math.max(0,g.t-7);
       var p=g.player;
       p.hp=12; p.iv=0; p.downed=false; p.pendKiller=null; p.revived=true;
       damagePlayer(400,'sentry','SENTRY');
       var s1=__state();
       if(s1&&s1.player&&s1.player.downed) s1.player.downT=0.01;
       for(var _dw=0;_dw<40;_dw++){ var _st=__state(); if(_st&&_st.over) break; frames(10); }
       var s2=__state();
       if(!s2||!s2.over) return 'SKIP: the hit did not finish him, so there is no card to read';
       frames(6);
       if(!(s2.tel&&s2.tel.diedWithMed)) bad.push('dying with an unused bandage is no longer recorded for the run report (the flag must stay, only the card line goes)');
       var el=document.getElementById('oc_sub');
       var txt=el?String(el.textContent||''):'';
       if(!txt) return 'SKIP: no KIA card line to read';
       if(txt.indexOf('MEDICAL')>=0) bad.push('the KIA card still says he died carrying medical he never used: '+txt.slice(0,160));
       if(txt.indexOf('KILLED BY')<0) bad.push('the KIA card lost KILLED BY: '+txt.slice(0,160));
       if(txt.indexOf('WITH ')<0) bad.push('the KIA card lost WITH (the weapon): '+txt.slice(0,160));
       if(txt.indexOf('FROM EXTRACTION')<0) bad.push('the KIA card lost the distance to extraction: '+txt.slice(0,160));
       if(txt.indexOf('IN CONTACT')<0) bad.push('the KIA card lost IN CONTACT: '+txt.slice(0,160));
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{
       try{ keysOff(); }catch(_k){}
       try{ var g6=__state(); if(g6&&!g6.over){ g6.player.downed=false; __endRaid('abandon'); } }catch(_e){}
       try{ G=null; keys={}; showScreen('hub'); }catch(_q){}
       try{ __topClear(); __resetCfg(); __cleanProfile(); }catch(_c){}
     }
     return bad.length?bad.join('; '):null; }},
  {v:'24.91',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
