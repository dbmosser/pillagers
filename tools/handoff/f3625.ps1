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

if ($s.Contains("  {v:'36.25',what:")) { throw "check 36.25 is in the fixture already" }

SubRx @'
  {v:'36.24',what:
'@ @'
  {v:'36.25',what:'active reload pays 5% per stack with three stacks at most: first 1.05, third and fourth 1.15, real bullet damage and +15% damage status in career and arcade for both seats',
   run:function(){
     if(!(window.__deploy&&window.__state&&window.__endRaid))return 'SKIP: this fixture cannot deploy';
     var g,p,side,mode,i,e,d0,d,lo,hi,w0,w1,w2,bad=[],kk=keys,mm=mouse.down,ft=ctx.fillText,words=[],nk={on:NET.on,same:NET.same},arc;
     function near(x,y){return Math.abs(x-y)<0.000001;}
     function hit(){
       keys={};p.hand=null;p.ammo=2;p.reserve=60;p.reloading=p.wep.reload;p.rlTot=0;p.rlArm=0;activeReloadTick(p);
       p.reloading=p.rlTot*0.49;keys.KeyR=true;var ok=activeReloadTick(p);keys={};return ok;
     }
     function shot(){g.bullets.length=0;fireWeapon(p,p.wep,p.x+100,p.y,true);var b=g.bullets[g.bullets.length-1];g.bullets.length=0;return b?b.dmg:NaN;}
     function entry(){statusLive(p);for(var j=0;j<STATUSL.length;j++)if(STATUSL[j].id==='ar')return STATUSL[j];return null;}
     try{
       __runPrep();__topClear();__resetCfg();__pinDefaults(0);__cleanProfile();
       __deploy({kit:['gun_pistol'],safe:null,mapIx:0,seed:4242});g=__state();p=g&&g.player;if(!p||g.over)return 'no live raid';
       arc=g.arcade;g.sim=false;g.mapOpen=false;g.bagOpen=false;g.paused=false;NET.on=false;keys={};mouse.down=false;
       for(mode=0;mode<2;mode++)for(side=0;side<2;side++){
         g.arcade=!!mode;NET.same=side?'p2':'host';
         var tag=(mode?'arcade ':'career ')+NET.same;
         p.wep=cloneObj(WEAPONS.pistol);p.arStk=0;p.arBonus=0;p.arMul=1;p.arGun=null;p.reloading=0;p.ammo=2;
         p.downed=false;p.dying=false;p.roll=0;p.hand=null;d0=shot();w0=arHi(p)-arLo(p);
         if(!(d0>0))return tag+': no control bullet';
         for(i=1;i<=4;i++){
           if(!hit())return tag+': reload '+i+' did not hit the middle';
           var stack=Math.min(i,3),mul=1+0.05*stack;
           if(p.arStk!==stack||!near(p.arMul,mul))bad.push(tag+': reload '+i+' gives stack '+p.arStk+' at '+p.arMul+', expected '+stack+' at '+mul);
           e=entry();if(!e||!e.on||e.nm!=='active reload x'+stack||e.v!=='+'+(5*stack)+'% damage')bad.push(tag+': reload '+i+' status disagrees with damage');
           d=shot();if(!near(d/d0,mul))bad.push(tag+': reload '+i+' bullet ratio '+d/d0+', expected '+mul);
           if(i===1)w1=arHi(p)-arLo(p);
           if(i===2)w2=arHi(p)-arLo(p);
           if(i===3){lo=arLo(p);hi=arHi(p);if(!(w0>w1&&w1>w2&&near(hi-lo,w2)))bad.push(tag+': sweet spot did not narrow to the third tier');}
         }
         if(!near(arLo(p),lo)||!near(arHi(p),hi))bad.push(tag+': fourth reload narrowed the capped spot');
         words=[];ctx.fillText=function(t){words.push(String(t).toLowerCase());return ft.apply(this,arguments);};
         try{drawStatusIcons();}finally{ctx.fillText=ft;}
         if(words.indexOf('active reload x3')<0||words.indexOf('+15% damage')<0)bad.push(tag+': cap status was not drawn as active reload x3, +15% damage');
       }
       return bad.length?bad.slice(0,12).join('; '):null;
     }finally{
       ctx.fillText=ft;if(g)g.arcade=arc;NET.on=nk.on;NET.same=nk.same;keys=kk;mouse.down=mm;
       try{if(p){p.arStk=0;p.arBonus=0;p.arGun=null;p.reloading=0;}__endRaid('abandon');}catch(_e){}__topClear();
     }
   }},
  {v:'36.24',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
