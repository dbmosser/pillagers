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

if ($s.Contains("  {v:'23.34',what:")) { throw "check 23.34 is in the fixture already" }

SubRx @'
  {v:'23.33',what:
'@ @'
  {v:'23.34',what:'arcade12, his order 2026-10-11: in the arcade an upgrade never replaces the gun in hand, it takes the stowed slot, or the backpack on key 3 or 4, or is scrapped for points',
   run:function(){
     var bad=[], g, p, A, k, cp=function(id){ var w=WEAPONS[id], c={}, q; for(q in w) if(Object.prototype.hasOwnProperty.call(w,q)) c[q]=w[q]; return c; },
         onKey=function(ik,lo){ var kk; for(kk in g.hotAssign) if(g.hotAssign[kk]===ik&&(+kk)>=lo) return +kk; return -1; }, m0, b0;
     try{
       __topClear(); __runPrep();
       if(typeof arcadeDeploy!=='function'||typeof ARCADE!=='object') return 'no arcadeDeploy in this build';
       if(ARCADE.on) return 'SKIP: the arcade is on after __topClear';
       if(!arcadeDeploy({mapIx:0,seed:4242})) return 'SKIP: arcadeDeploy built no arcade raid';
       g=__state(); p=g.player;
       if(!WEAPONS.chatter||!WEAPONS.smg||!WEAPONS.lance||!ITEMS.gun_lance||!ITEMS.gun_smg||!ITEMS.gun_rifle||!ITEMS.gun_pistol) return 'SKIP: a gun this check names is missing';
       p.wep=cp('chatter'); p.sec=cp('smg'); p.ammo=p.wep.mag; p.secAmmo=p.sec.mag;
       p.wepIssued=false; p.secIssued=false; p.wepFromArmory=false; p.secFromArmory=false; p.swapped=false; p.reloading=0;
       g.bag=g.bag.filter(function(b){ return !(ITEMS[b]&&ITEMS[b].use==='gun'); });
       g.hotAssign={}; g.hotAuto={}; gunKeysSettle({deploy:1});
       grantLoot({x:p.x,y:p.y,loot:[]},['gun_lance']);
       if(!p.wep||p.wep.id!=='chatter') bad.push('the gun in hand became '+(p.wep&&p.wep.id)+', not chatter');
       if(!p.sec||p.sec.id!=='lance') bad.push('the stowed slot holds '+(p.sec&&p.sec.id)+', not lance');
       if(g.bag.indexOf('gun_smg')<0) bad.push('the old stowed smg is not in the backpack');
       if(g.bag.indexOf('gun_lance')>=0) bad.push('the lance also went into the backpack');
       k=onKey('gun_smg',2); if(k!==2&&k!==3) bad.push('no key 3 or 4 holds gun_smg ('+JSON.stringify(g.hotAssign)+')');
       if(!bad.length){
         grantLoot({x:p.x,y:p.y,loot:[]},['gun_rifle']);
         if(p.wep.id!=='chatter'||p.sec.id!=='lance') bad.push('a rifle moved a gun in the hands ('+p.wep.id+'/'+p.sec.id+')');
         if(g.bag.indexOf('gun_rifle')<0) bad.push('a rifle, better than the worst gun carried, is not in the backpack');
         else { k=onKey('gun_rifle',2); if(k!==2&&k!==3) bad.push('no key 3 or 4 holds gun_rifle ('+JSON.stringify(g.hotAssign)+')'); }
         m0=ARCADE.mine|0; b0=g.bag.length;
         grantLoot({x:p.x,y:p.y,loot:[]},['gun_pistol']);
         if(g.bag.indexOf('gun_pistol')>=0||g.bag.length!==b0) bad.push('a pistol, worse than every gun carried, went into the backpack');
         if(!((ARCADE.mine|0)>m0)) bad.push('a scrapped pistol scored nothing ('+m0+' to '+ARCADE.mine+')');
         if(p.wep.id!=='chatter'||p.sec.id!=='lance') bad.push('a pistol moved a gun in the hands');
       }
     }catch(x){ bad.push('threw: '+(x&&x.message||x)); }
     finally{
       keys={};
       try{ if(typeof ARCADE==='object'&&ARCADE.on) arcadeLeave(); }catch(_l){}
       try{ if(__state()&&!__state().over) __endRaid('abandon'); }catch(_e){}
       __topClear();
     }
     return bad.length?bad.join('; '):null; }},
  {v:'23.33',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
