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

if ($s.Contains("  {v:'28.71',what:")) { throw "check 28.71 is in the fixture already" }

SubRx @'
  {v:'28.70',what:
'@ @'
  {v:'28.71',what:'his order 2026-10-15 (score as SP): every score figure reads N SP and never a dollar amount, in the CAREER ledger score rows and the Undercroft board SCORE column, while the credits banked, the haul value and the raid total stay in dollars',
   run:function(){
     if(!(window.__deploy&&window.__state&&window.__runPrep&&window.__endRaid&&window.__resetCfg&&window.__pinDefaults&&window.__cleanProfile&&window.__P&&window.__applyLoaded)) return 'SKIP: this fixture cannot deploy';
     if(typeof ocLedger!=='function'||typeof lbCountEnd!=='function'||typeof careerBoardView!=='function'||typeof arcadeCr!=='function') return 'SKIP: no ledger or board here';
     var bad=[], g, c0=(typeof CAREER_ON==='number')?CAREER_ON:0, snap=null, lg, man, rows, i, kills='', h, ht, tx;
     function txt(sel){ var e=lg.querySelector(sel+' b'); return e?e.textContent:''; }
     try{
       snap=JSON.parse(JSON.stringify(__P()));
       if(arcadeCr(1234)!=='1,234 SP') bad.push('a score of 1234 reads '+arcadeCr(1234)+', not 1,234 SP');
       __topClear(); __runPrep(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       CAREER_ON=1;
       __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       g=__state(); if(!g||g.over) return 'SKIP: no live raid';
       if(!g.career||!g.cs) return 'SKIP: no CAREER raid in this build';
       g.player.iv=99; g.player.hp=100; g.player.downed=false;
       g.cs.s=750; g.cs.k=4; g.cs.b={kill:600,style:150};
       __endRaid('extract');
       man=document.getElementById('oc_manifest'); lg=man?man.querySelector('.lg'):null;
       if(!lg) return 'SKIP: the CAREER extraction card has no ledger';
       lbCountEnd(lg);
       if(txt('.sc')!=='1,500 SP') bad.push('RAID SCORE reads '+txt('.sc')+', not 1,500 SP');
       rows=lg.querySelectorAll('.lgr');
       for(i=0;i<rows.length;i++){ var l=rows[i].querySelector('.lgl'); if(l&&l.textContent==='KILLS'){ var b=rows[i].querySelector('b'); kills=b?b.textContent:''; } }
       if(kills!=='600 SP') bad.push('the KILLS row reads '+kills+', not 600 SP');
       if(txt('.cr')!=='+$1,500') bad.push('CREDITS BANKED reads '+txt('.cr')+', not +$1,500 (credits stay dollars)');
       ht=document.getElementById('haultot');
       if(!ht||ht.textContent.charAt(0)!=='$') bad.push('HAUL VALUE reads '+(ht&&ht.textContent)+', not a dollar amount');
       if(txt('.tot').charAt(0)!=='$') bad.push('RAID TOTAL reads '+txt('.tot')+', not a dollar amount');
       if(/\$/.test(txt('.sc'))) bad.push('RAID SCORE still carries a dollar sign');
       __endRaid('abandon');
       P.careerBoard=[{s:900,k:2,m:0,t:1000,n:'OLD'}]; delete P.careerRuns; delete P.careerAll;
       h=document.createElement('div'); careerBoardView(h,{}); lbCountEnd(h); tx=h.textContent||'';
       if(tx.indexOf('900 SP')<0) bad.push('the board SCORE column does not read 900 SP ('+tx.slice(0,80)+')');
       if(tx.indexOf('$900')>=0) bad.push('the board SCORE column still reads $900');
     }catch(x){ bad.push('threw: '+(x&&x.message||x)); }
     finally{
       try{ CAREER_ON=c0; }catch(_r){}
       try{ var g2=__state(); if(g2&&!g2.over) __endRaid('abandon'); }catch(_e){}
       try{ if(snap&&window.__applyLoaded) __applyLoaded(snap); }catch(_s){}
       __topClear(); }
     return bad.length?bad.join('; '):null; }},
  {v:'28.70',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
