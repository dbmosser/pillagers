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

if ($s.Contains("  {v:'35.68',what:")) { throw "check 35.68 is in the fixture already" }

SubRx @'
  {v:'35.67',what:
'@ @'
  {v:'35.68',what:'cw-diffmul, his order of 2026-10-28: every Settings row set harder than its default pays 5 percent more sp a step (pillager bots, machines, how hard they hit, extraction heat), superhot off pays a step, and the rows multiply (x1.54 at the hardest); a raid keeps the rows it was built with and reads superhot live; kills, style bonuses, goals and vaults pay sp with it in',
   run:function(){
     if(!(window.__deploy&&window.__state&&window.__endRaid&&window.__runPrep&&window.__resetCfg&&window.__pinDefaults&&window.__cleanProfile)) return 'SKIP: this fixture cannot deploy';
     if(typeof careerKill!=='function'||typeof scoreBonus!=='function'||typeof arcadeKillPts!=='function') return 'SKIP: no career score here';
     if(typeof diffMul!=='function'||typeof diffMulOf!=='function'||typeof spMul!=='function') return 'there is no settings score multiplier in this build';
     var bad=[], g, p, c0=(typeof CAREER_ON==='number')?CAREER_ON:0, d0=DMUL_ON, K=['superhot','nRaider','nSentry','eDmg','siegeVol'], sv={}, i, s0, v, base;
     function o(sh,n,s,d,h){ return {superhot:sh,nRaider:n,nSentry:s,eDmg:d,siegeVol:h}; }
     function near(a,b){ return Math.abs(a-b)<0.0051; }
     for(i=0;i<K.length;i++) sv[K[i]]=CFG[K[i]];
     try{
       __topClear(); __runPrep(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       DMUL_ON=1;
       // ONE: the rows. Defaults (Few, Few, Standard, Light) with superhot on pay nothing; superhot off pays one step
       if(!near(diffMulOf(o(1,5,12,1,0.6)),1)) bad.push('the defaults with superhot on pay x'+diffMulOf(o(1,5,12,1,0.6)));
       if(!near(diffMulOf(o(0,5,12,1,0.6)),1.05)) bad.push('superhot off pays x'+diffMulOf(o(0,5,12,1,0.6))+', not x1.05');
       if(!near(diffMulOf(o(1,10,12,1,0.6)),1.05)||!near(diffMulOf(o(1,15,12,1,0.6)),1.10)) bad.push('pillager bots standard and many do not pay x1.05 and x1.10');
       if(!near(diffMulOf(o(1,5,20,1,0.6)),1.05)||!near(diffMulOf(o(1,5,28,1,0.6)),1.10)) bad.push('machines standard and many do not pay x1.05 and x1.10');
       if(!near(diffMulOf(o(1,5,12,1.2,0.6)),1.05)||!near(diffMulOf(o(1,5,12,1.4,0.6)),1.10)) bad.push('hardened and brutal hits do not pay x1.05 and x1.10');
       if(!near(diffMulOf(o(1,5,12,1,1)),1.05)||!near(diffMulOf(o(1,5,12,1,1.4)),1.10)) bad.push('standard and heavy extraction heat do not pay x1.05 and x1.10');
       if(!near(diffMulOf(o(1,0,12,0.7,0.6)),1)) bad.push('easier rows take sp away');
       v=diffMulOf(o(0,15,28,1.4,1.4)); if(!(Math.abs(v-1.05*1.1*1.1*1.1*1.1)<0.0002)) bad.push('the hardest game pays x'+v+', the rows do not multiply');
       // TWO: a career raid takes its rows at the build, superhot live
       CAREER_ON=1; CFG.superhot=0; CFG.nRaider=10; CFG.nSentry=20; CFG.siegeVol=1; CFG.eDmg=1.4;
       base=diffMulOf(CFG,1);
       __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       g=__state(); if(!g||g.over||!g.player) return 'SKIP: staging: no raid';
       if(!g.career||!g.cs) return 'SKIP: staging: not a career raid';
       p=g.player;
       if(!(typeof g.dmul==='number'&&near(g.dmul,base))) bad.push('the raid did not keep the rows it was built with ('+g.dmul+' vs '+base+')');
       v=diffMul(); if(!near(v,Math.round(base*1.05*100)/100)) bad.push('the raid pays x'+v+', not x'+Math.round(base*1.05*100)/100);
       CFG.eDmg=1; CFG.nRaider=5; if(!near(diffMul(),v)) bad.push('a row moved after the build changed this raid multiplier');
       CFG.superhot=1; if(!near(diffMul(),Math.round(base*100)/100)) bad.push('superhot on did not take its step off at once'); CFG.superhot=0;
       if(!(v>1.3)) bad.push('staging: the raid multiplier is only x'+v);
       // THREE: the sp paid with it in
       g.cs.streak=null; s0=g.cs.s|0; careerKill('crawler',0,0,p.x+40,p.y);
       if((g.cs.s|0)-s0!==Math.round(50*v)) bad.push('a crawler kill paid '+((g.cs.s|0)-s0)+' sp, not '+Math.round(50*v));
       if(arcadeKillPts('sentry',0,0)!==Math.round(100*v)) bad.push('a demo sentry kill is worth '+arcadeKillPts('sentry',0,0)+', not '+Math.round(100*v));
       s0=g.cs.s|0; i=scoreBonus(100,p.x,p.y,'LONG SHOT');
       if(i!==Math.round(100*v)||(g.cs.s|0)-s0!==i) bad.push('a 100 sp bonus paid '+((g.cs.s|0)-s0)+' (said '+i+'), not '+Math.round(100*v));
       if(typeof flowChip==='function'){ s0=g.cs.s|0; i=flowChip(200,'GOAL DONE','goal'); if(i!==Math.round(200*v)||(g.cs.s|0)-s0!==i) bad.push('a 200 sp goal paid '+((g.cs.s|0)-s0)+', not '+Math.round(200*v)); }
       if(typeof arcadeVaultPay==='function'&&typeof ARCADE_VAULT_PAY==='number'){ s0=g.cs.s|0; arcadeVaultPay({doorX:p.x,doorY:p.y}); if((g.cs.s|0)-s0!==Math.round(ARCADE_VAULT_PAY*v)) bad.push('a vault paid '+((g.cs.s|0)-s0)+', not '+Math.round(ARCADE_VAULT_PAY*v)); }
       // FOUR: the fixture switch pays x1
       DMUL_ON=0; s0=g.cs.s|0; scoreBonus(100,p.x,p.y,'LONG SHOT'); if((g.cs.s|0)-s0!==100) bad.push('with the multiplier off a 100 sp bonus paid '+((g.cs.s|0)-s0));
     }catch(err){ bad.push('threw: '+(err&&err.message||err)); }
     finally{
       DMUL_ON=d0; CAREER_ON=c0; keys={};
       for(i=0;i<K.length;i++) CFG[K[i]]=sv[K[i]];
       try{ var g2=__state(); if(g2&&!g2.over) __endRaid('abandon'); }catch(_e){}
       __topClear();
     }
     return bad.length?bad.join('; '):null; }},
  {v:'35.67',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
