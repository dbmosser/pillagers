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

if ($s.Contains("  {v:'28.41',what:")) { throw "check 28.41 is in the fixture already" }

SubRx @'
  {v:'28.40',what:
'@ @'
  {v:'28.41',what:'cloud-coop-smg-on-its-key: with no gun plan of his (a fresh save, as player 2 most often is) and the SMG in his hands with a Sniper stowed, the raid starts with the SMG on its own key 2 and up, not on key 1 with key 2 empty; Sniper/SMG, Pistol/Magnum and Rifle/Pistol start as before',
   run:function(){
     if(!(window.__P&&window.__applyLoaded&&window.__deploy)) return 'SKIP: this fixture has no profile';
     if(typeof gunClassKey!=='function'||typeof gunKeysSettle!=='function') return 'SKIP: this build has no class gun keys';
     var bad=[], snap=null, r;
     function one(w1,w2){
       var q, g, o={};
       __topClear(); __runPrep(); __resetCfg(); __cleanProfile();
       q=__P(); q.weapons=['pistol','smg','sniper','rifle','shotgun','magnum']; q.equipped=w1; q.equippedSec=w2; q.hotAssign={}; delete q.gunKeys; q.kit=[];
       __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       g=__state();
       o.A=JSON.stringify(g.hotAssign||{}); o.hot=g.hot; o.demo=!!(g.arcade&&!g.career);
       try{ __endRaid('abandon'); }catch(_e){}
       return o;
     }
     try{
       snap=JSON.parse(JSON.stringify(__P()));
       r=one('smg','sniper');
       if(r.demo) return 'SKIP: the raid was a DEMO raid';
       if(r.A!=='{"1":"gun_smg","7":"gun_sniper"}') bad.push('SMG/Sniper keys read '+r.A+', not the SMG on key 2 and the Sniper on key 8');
       if(r.hot!==1) bad.push('SMG/Sniper starts on key '+(r.hot+1)+', not key 2');
       r=one('sniper','smg');
       if(r.A!=='{"1":"gun_smg","7":"gun_sniper"}'||r.hot!==7) bad.push('Sniper/SMG read '+r.A+' on key '+(r.hot+1));
       r=one('pistol','magnum');
       if(r.A!=='{"0":"gun_pistol","1":"gun_magnum"}'||r.hot!==0) bad.push('Pistol/Magnum read '+r.A+' on key '+(r.hot+1));
       r=one('rifle','pistol');
       if(r.A!=='{"0":"gun_pistol","2":"gun_rifle"}'||r.hot!==2) bad.push('Rifle/Pistol read '+r.A+' on key '+(r.hot+1));
     }catch(x2){ bad.push('threw: '+(x2&&x2.message||x2)); }
     finally{
       try{ if(G&&!G.over&&!G.hubFloor) __endRaid('abandon'); }catch(_a){}
       try{ if(snap) __applyLoaded(snap); }catch(_r){}
       try{ __topClear(); __resetCfg(); __cleanProfile(); }catch(_c){}
     }
     return bad.length?bad.join('; '):null; }},
  {v:'28.40',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
