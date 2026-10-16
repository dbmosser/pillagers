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

if ($s.Contains("  {v:'28.67',what:")) { throw "check 28.67 is in the fixture already" }

SubRx @'
  {v:'28.66',what:
'@ @'
  {v:'28.67',what:'his order 2026-10-15 (score rule): a run that ends dead counts half its score (KIA -50%), in a CAREER raid (board row, ledger KIA row) and in the DEMO (RUN OVER score and plate), where an extraction was already x2',
   run:function(){
     if(!(window.__deploy&&window.__state&&window.__runPrep&&window.__endRaid&&window.__resetCfg&&window.__pinDefaults&&window.__cleanProfile&&window.__P&&window.__applyLoaded)) return 'SKIP: this fixture cannot deploy';
     if(typeof ocLedger!=='function'||typeof arcadeRunEnd!=='function'||typeof arcadeDeploy!=='function'||typeof ARCADE!=='object'||typeof attEl!=='function') return 'SKIP: no ledger or arcade here';
     var bad=[], g, c0=(typeof CAREER_ON==='number')?CAREER_ON:0, snap=null, lg, man, o, c, tx, rs=say, ownS=false, BK=(typeof ARCADE_BOARD_KEY==='string')?ARCADE_BOARD_KEY:'', bk=null, hadB=false;
     function dto(sel){ var e=document.querySelector('#oc_manifest '+sel+' [data-to]'); return e?+e.getAttribute('data-to'):-1; }
     try{
       snap=JSON.parse(JSON.stringify(__P()));
       __topClear(); __runPrep(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       CAREER_ON=1;
       __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       g=__state(); if(!g||g.over) return 'SKIP: no live raid';
       if(!g.career||!g.cs) return 'SKIP: no CAREER raid in this build';
       g.player.iv=99; g.player.hp=100; g.player.downed=false;
       g.cs.s=401; g.cs.k=2; g.cs.b={kill:401};
       __endRaid('dead');
       man=document.getElementById('oc_manifest'); lg=man?man.querySelector('.lg'):null;
       if(!g.careerLb||g.careerLb.score!==200) bad.push('a CAREER death on 401 scored '+(g.careerLb&&g.careerLb.score)+' on the board, not 200 (x0.5)');
       if(!lg) bad.push('the KIA card has no ledger');
       else {
         if(dto('.sc')!==200) bad.push('the KIA RAID SCORE is '+dto('.sc')+', not 200');
         tx=lg.textContent||'';
         if(tx.indexOf('KIA')<0||tx.indexOf('50%')<0) bad.push('the KIA ledger has no KIA -50% row');
       }
       if(g.careerPaid!==0) bad.push('a death paid '+g.careerPaid);
       try{ __endRaid('abandon'); }catch(_e0){}
       __topClear(); __runPrep(); CAREER_ON=0;
       try{ bk=localStorage.getItem(BK); hadB=true; localStorage.removeItem(BK); }catch(_b){}
       say=function(){}; ownS=true;
       if(ARCADE.on) return bad.concat(['SKIP: the arcade is on after __topClear']).join('; ');
       if(!arcadeDeploy({mapIx:0,seed:4242})) return bad.concat(['SKIP: arcadeDeploy built no arcade raid']).join('; ');
       g=__state(); keys={}; ARCADE.holdT=0; ARCADE.waveT=0; ARCADE.ownAt=Date.now(); ARCADE.over=null;
       if(!g||!g.arcade||ARCADE.role!=='host') return bad.concat(['SKIP: no arcade host raid']).join('; ');
       ARCADE.solo=1; ARCADE.mine=1001; ARCADE.mate=0; ARCADE.kills=3;
       arcadeRunEnd('dead');
       o=ARCADE.over;
       if(!o||o.why!=='dead') bad.push('the DEMO death did not end the run');
       else {
         if(o.team!==500) bad.push('a DEMO death on 1001 ended with the score '+o.team+', not 500 (x0.5)');
         try{ arcadeAttShow(); }catch(_as){}
         c=attEl().querySelector('.arcover');
         if(!c||c.textContent.indexOf('KIA')<0||c.textContent.indexOf('50%')<0) bad.push('the RUN OVER card has no KIA -50% plate ('+(c?c.textContent.slice(0,60):'no card')+')');
       }
     }catch(x){ bad.push('threw: '+(x&&x.message||x)); }
     finally{
       if(ownS) say=rs;
       keys={};
       try{ CAREER_ON=c0; }catch(_r){}
       try{ if(typeof ARCADE==='object'&&ARCADE.on) arcadeLeave(); }catch(_l){}
       try{ var g2=__state(); if(g2&&!g2.over) __endRaid('abandon'); }catch(_e){}
       try{ ARCADE.mine=0; ARCADE.mate=0; ARCADE.kills=0; ARCADE.solo=0; ARCADE.holdT=0; ARCADE.waveT=0; ARCADE.over=null; ARCADE.ini=null; }catch(_m){}
       try{ if(hadB){ if(bk===null) localStorage.removeItem(BK); else localStorage.setItem(BK,bk); } }catch(_b2){}
       try{ if(snap&&window.__applyLoaded) __applyLoaded(snap); }catch(_s){}
       __topClear(); }
     return bad.length?bad.join('; '):null; }},
  {v:'28.66',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
