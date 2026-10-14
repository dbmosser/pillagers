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

if ($s.Contains("  {v:'26.11',what:")) { throw "check 26.11 is in the fixture already" }

SubRx @'
  {v:'26.10',what:
'@ @'
  {v:'26.11',what:'a pillager at no health does not heal himself out of his fall: with a heal running and a medkit in his bag, his lethal blow still puts him down',
   run:function(){
     if(!window.__deploy||!window.__endRaid||!window.__sim||!window.__state) return 'SKIP: no raid here';
     var bad=[], g=null, p=null, all=null, A=null, B=null, keepP=null, rs, kk;
     function lay(e){ e.x=p.x+220; e.y=p.y; e.hostile=true; e.hp=0; e.byPlayer=true; e.downed=0; e.finished=0; g.ents=[e]; if(g.bullets) g.bullets.length=0; __sim(1/60); }
     try{
       __topClear(); __runPrep(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       g=__state(); if(!g||g.over||!g.player) return 'SKIP: no live raid';
       if(CFG.raiderDown===0||CFG.raiderKit===0) return 'SKIP: pillagers die outright or use no kit here';
       p=g.player; all=g.ents.slice();
       rs=all.filter(function(x){ return x.kind==='raider'&&!x.merc&&!x.friendlyPC&&x.hostile===true&&x.hp>0&&!x.downed&&!x.finished; });
       if(rs.length<2) return 'SKIP: fewer than two hostile pillagers on this map';
       A=rs[0]; B=rs[1];
       for(kk in keys) keys[kk]=false;
       keepP={hp:p.hp,iv:p.iv}; p.iv=1e6;
       B.bag=[]; B.healQ=0;
       lay(B);
       if(B.downed!==1) return 'SKIP: a pillager on no health with no heal did not go down here (downed '+B.downed+')';
       A.bag=['medkit','medkit']; A.healQ=40; A.healRate=9;
       lay(A);
       if(A.downed!==1||A.state!=='down') bad.push('a pillager on no health with a heal running did not go down (downed '+A.downed+', state '+A.state+', health '+Number(A.hp).toFixed(2)+')');
     }catch(x){ bad.push('threw: '+(x&&x.message||x)); }
     finally{
       try{ if(g&&all) g.ents=all.filter(function(x){ return x!==A&&x!==B; }); if(g&&g.bullets) g.bullets.length=0; if(p&&keepP){ p.hp=keepP.hp; p.iv=keepP.iv; } }catch(_r){}
       try{ var g2=__state(); if(g2&&!g2.over){ g2.player.downed=false; __endRaid('abandon'); } }catch(_e){}
       try{ __topClear(); __resetCfg(); __cleanProfile(); }catch(_c){}
     }
     return bad.length?bad.join('; '):null; }},
  {v:'26.10',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
