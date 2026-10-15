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

if ($s.Contains("  {v:'27.92',what:")) { throw "check 27.92 is in the fixture already" }

SubRx @'
  {v:'27.91',what:
'@ @'
  {v:'27.92',what:'his order (i do not like the idea, get rid of it): the magnet power-up is gone: not in the drop table, it never drops in three thousand kills, no effect function or constants, no picture, no note, a stale magnet timer pulls nothing; the other five power-ups still drop and are drawn',
   run:function(){
     if(!(window.__state&&window.__endRaid&&window.__runPrep)) return 'SKIP: no raid here';
     if(typeof arcadeDeploy!=='function'||typeof ARCADE!=='object'||typeof pwrS!=='function'||typeof pwrKill!=='function'||typeof pwrTick!=='function') return 'SKIP: no arcade or power-ups here';
     var bad=[], g=null, p, own=false, rs=say, S, i, kinds={}, five=['clip','dmg','rapid','shield','pulse'], nm, x0, key, hit;
     try{
       __topClear(); __runPrep(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       if(ARCADE.on) return 'SKIP: the arcade is on after __topClear';
       if(!arcadeDeploy({mapIx:0,seed:4242})) return 'SKIP: arcadeDeploy built no arcade raid';
       g=__state(); if(!g||g.over||!g.player) return 'SKIP: no live raid';
       p=g.player; keys={}; say=function(){}; own=true; ARCADE.holdT=0;
       g.pwr=null; S=pwrS();
       // ONE: the drop table is exactly the other five kinds, and there is no MAGNET anywhere in it
       nm=PWR_KINDS.map(function(q){ return q.k; });
       if(nm.join(',')!==five.join(',')) bad.push('ONE: the drop table is '+nm.join(',')+', not the five other kinds');
       if(PWR_KINDS.some(function(q){ return /^magnet$/i.test(q.n); })||pwrDef('m'+'ag')) bad.push('ONE: the magnet is still in the drop table');
       // TWO: three thousand kills never drop it, and the five all still do
       for(i=0;i<3000;i++){ S.lastDrop-=1; S.items.length=0; pwrKill('crawler',0,false,p.x+60,p.y,null); }
       S.log.forEach(function(w){ kinds[w.split(':')[1]]=1; });
       S.log.length=0;
       if(kinds['m'+'ag']) bad.push('TWO: the magnet dropped in three thousand kills');
       five.forEach(function(k){ if(!kinds[k]) bad.push('TWO: '+k+' never dropped in three thousand kills'); });
       // THREE: no effect function, no constants, no note, no picture
       if(typeof pwrMagnet!=='undefined') bad.push('THREE: the magnet effect function is still in the build');
       if(typeof PWRX==='object'){ for(key in PWRX) if(/^mag/.test(key)) bad.push('THREE: the constant PWRX.'+key+' is still in the build'); }
       if(typeof PWR_SND==='object'&&PWR_SND['m'+'ag']) bad.push('THREE: the magnet note is still in the build');
       if(typeof pwrGlyph==='function'&&String(pwrGlyph).indexOf("'m"+"ag'")>=0) bad.push('THREE: the magnet picture is still in pwrGlyph');
       if(typeof SNDA_GEN==='object'&&SNDA_GEN&&SNDA_GEN['pwrGetMa'+'gnet']) bad.push('THREE: the magnet pickup sound is still adopted');
       if(typeof SPK_PWR==='object'&&SPK_PWR['m'+'ag']) bad.push('THREE: the magnet pickup sound is still in the lookup');
       // FOUR: a stale magnet timer pulls nothing, a pickup on the floor stays where it is
       S.items.length=0; S.act={}; S.act['m'+'ag']=20; S.items.push({k:'dmg',x:p.x+400,y:p.y,t:0,life:16,id:1});
       for(i=0;i<60;i++) pwrTick(p,0.05);
       if(!S.items.length||Math.abs(S.items[0].x-(p.x+400))>0.5) bad.push('FOUR: a pickup 400 away moved under a stale magnet timer');
       S.items.length=0; S.act={};
     }catch(x){ bad.push('threw: '+(x&&x.message||x)); }
     finally{
       if(own) say=rs;
       keys={};
       try{ if(typeof ARCADE==='object'&&ARCADE.on) arcadeLeave(); }catch(_l){}
       try{ if(__state()&&!__state().over) __endRaid('abandon'); }catch(_e){}
       try{ if(typeof ARCADE==='object'){ ARCADE.mine=0; ARCADE.waveT=0; ARCADE.holdT=0; } }catch(_h){}
       __topClear(); __cleanProfile();
     }
     return bad.length?bad.slice(0,8).join('; '):null; }},
  {v:'27.91',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
