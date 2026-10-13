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

if ($s.Contains("  {v:'25.44',what:")) { throw "check 25.44 is in the fixture already" }

SubRx @'
  {v:'25.43',what:
'@ @'
  {v:'25.44',what:'his order: a downed pillager with his one self-revive unused gets up on his own, hostile; a second fall kills him; shot while getting up he dies for good; one kill per pillager',
   run:function(){
     if(!window.__deploy||!window.__endRaid||!window.__sim||!window.__state) return 'SKIP: no raid here';
     var bad=[], g=null, p=null, all=null, A=null, B=null, k0=0, i, stood=-1, sawBar=0, keepP=null, mid=0, M;
     var kills=function(){ return (g&&g.tel&&g.tel.kills&&g.tel.kills.raider)|0; };
     var step=function(n){ for(var s=0;s<n;s++) __sim(1/60); };
     var lay=function(e){ if(g.bullets) g.bullets.length=0; e.x=p.x+220; e.y=p.y; e.hostile=true; e.hp=0; e.byPlayer=true; e.downed=0; e.finished=0; g.ents=[e]; step(1); };
     try{
       __topClear(); __runPrep(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       g=__state(); if(!g||g.over||!g.player) return 'SKIP: no live raid';
       if(CFG.raiderDown===0) return 'SKIP: pillagers die outright here';
       p=g.player; all=g.ents.slice();
       var rs=all.filter(function(x){ return x.kind==='raider'&&!x.merc&&!x.friendlyPC&&x.hostile===true&&x.hp>0&&!x.downed&&!x.finished; });
       if(rs.length<2) return 'SKIP: fewer than two hostile pillagers on this map';
       A=rs[0]; B=rs[1];
       for(var kk in keys) keys[kk]=false;
       keepP={hp:p.hp,iv:p.iv}; p.iv=1e6;
       k0=kills();
       lay(A);
       if(A.downed!==1||A.state!=='down') return 'SKIP: a pillager at no health did not go down here (downed '+A.downed+', state '+A.state+')';
       if(kills()!==k0) bad.push('going down paid a kill');
       for(i=0;i<12*60;i++){
         step(1);
         if(A.downed&&A.getUp>0&&typeof netEntFlags==='function'&&(netEntFlags(A)&8388608)) sawBar=1;
         if(g.ents.indexOf(A)<0) break;
         if(!A.downed&&A.hp>0){ stood=i; break; }
       }
       if(stood<0){ bad.push('a downed pillager with his self-revive unused did not get up on his own within 12 s ('+(g.ents.indexOf(A)<0?'dead':'still down, hp '+Math.round(A.hp))+')'); return bad.join('; '); }
       if(!(A.hp>0)||A.hostile!==true||A.state==='down') bad.push('he got up but not hostile and fighting (hp '+A.hp+', hostile '+A.hostile+', state '+A.state+')');
       if(!(A.hp>=Math.round((A.maxhp||100)*0.3))) bad.push('he got up on '+A.hp+' of '+A.maxhp+' health');
       if(!sawBar) bad.push('his get-up never showed on the snapshot a linked window reads');
       if(stood/60<2) bad.push('he was up '+(stood/60).toFixed(2)+' s after going down, too soon to read and punish');
       if(kills()!==k0) bad.push('the fall and the self-revive paid '+(kills()-k0)+' kills');
       // His second fall: no second get-up, he bleeds out and dies.
       lay(A);
       if(A.downed!==1) bad.push('his second fall did not put him down (downed '+A.downed+')');
       for(i=0;i<25*60&&g.ents.indexOf(A)>=0;i++){ step(1); if(g.ents.indexOf(A)>=0&&!A.downed&&A.hp>0){ bad.push('he got up a second time'); break; } }
       if(g.ents.indexOf(A)>=0) bad.push('after his second fall he was still in the raid 25 s later');
       if(kills()!==k0+1) bad.push('the first pillager paid '+(kills()-k0)+' kills, not 1');
       // A fresh one, shot while he gets up: dead for good.
       lay(B);
       if(B.downed!==1) bad.push('the second pillager did not go down (downed '+B.downed+')');
       for(i=0;i<12*60;i++){ step(1); if(g.ents.indexOf(B)<0||!B.downed) break; if(B.getUp>0){ mid=1; break; } }
       if(!mid) bad.push('the second pillager never began to get up');
       else{
         if(typeof netEntMake==='function'&&typeof netEntFlagsApply==='function'&&typeof netEntFlags==='function'){
           M=netEntMake(990777,'raider',B.x,B.y); delete M.net; netEntFlagsApply(M,netEntFlags(B));
           if(!(M.getUp>0)) bad.push('a linked window copy of him did not show the get-up');
         }
         B.hp-=999; B.byPlayer=true; step(2);
         if(g.ents.indexOf(B)>=0) bad.push('shot while getting up he was still in the raid (downed '+B.downed+', hp '+Math.round(B.hp)+')');
         for(i=0;i<6*60&&g.ents.indexOf(B)<0;i++) step(1);
       }
       if(kills()!==k0+2) bad.push('two pillagers paid '+(kills()-k0)+' kills, not 2');
     }catch(x){ bad.push('threw: '+(x&&x.message||x)); }
     finally{
       try{ if(g&&all) g.ents=all.filter(function(x){ return x!==A&&x!==B; }); if(g&&g.bullets) g.bullets.length=0; if(p&&keepP){ p.hp=keepP.hp; p.iv=keepP.iv; } }catch(_r){}
       try{ var g2=__state(); if(g2&&!g2.over){ g2.player.downed=false; __endRaid('abandon'); } }catch(_e){}
       try{ __topClear(); __resetCfg(); __cleanProfile(); }catch(_c){}
     }
     return bad.length?bad.join('; '):null; }},
  {v:'25.43',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
