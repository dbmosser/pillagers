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

if ($s.Contains("  {v:'36.17',what:")) { throw "check 36.17 is in the fixture already" }

SubRx @'
  {v:'36.16',what:
'@ @'
  {v:'36.17',what:'active reload status shows each local chain and damage bonus, x2 after two hits, and disappears on the same tick as a miss or an ordinary reload',
   run:function(){
     if(!(window.__deploy&&window.__state&&window.__endRaid)) return 'SKIP: this fixture cannot deploy';
     var g,p,i,side,e,bad=[],kk=keys,mm=mouse.down,nk={on:NET.on,same:NET.same},ft=ctx.fillText,words=[];
     function entry(){ statusLive(p); for(var j=0;j<STATUSL.length;j++) if(STATUSL[j].id==='ar') return STATUSL[j]; return null; }
     function start(){ keys={};p.hand=null;p.ammo=2;p.reserve=60;p.reloading=p.wep.reload;p.rlTot=0;p.rlArm=0;activeReloadTick(p); }
     function tap(f){start();p.reloading=p.rlTot*(1-f);keys.KeyR=true;var hit=activeReloadTick(p);keys={};return hit;}
     function drawn(){words=[];ctx.fillText=function(t){words.push(String(t).toLowerCase());return ft.apply(this,arguments);};try{drawStatusIcons();}finally{ctx.fillText=ft;}return words;}
     try{
       __runPrep();__topClear();__resetCfg();__pinDefaults(0);__cleanProfile();
       __deploy({kit:['gun_pistol'],safe:null,mapIx:0,seed:4242});g=__state();p=g&&g.player;if(!p||g.over)return 'no live raid';
       g.mapOpen=false;g.bagOpen=false;g.paused=false;g.sim=false;mouse.down=false;NET.on=false;
       for(side=0;side<2;side++){
         NET.same=side?'p2':'host';p.wep=cloneObj(WEAPONS.pistol);p.arStk=0;p.arBonus=0;p.downed=false;
         e=entry();if(e&&e.on)bad.push(NET.same+': zero chain has a status');
         if(!tap(0.51)||!tap(0.51)||p.arStk!==2)return NET.same+': staging two active reloads failed';
         e=entry();if(!e||!e.on||e.nm!=='active reload x2'||e.v!=='+25% damage')bad.push(NET.same+': two hits lack active reload x2 and +25% damage');
         drawn();if(words.indexOf('active reload x2')<0||words.indexOf('+25% damage')<0)bad.push(NET.same+': chain or bonus not drawn in the status column');
         p.arBonus=0;e=entry();if(!e||!e.on||e.v!=='chain ready')bad.push(NET.same+': inactive magazine still claims a damage bonus');
         if(tap(0.1)||p.arStk!==0)return NET.same+': staging miss failed';
         e=entry();if(e&&e.on)bad.push(NET.same+': miss kept the status');
         drawn();if(words.some(function(t){return /^active reload x/.test(t);}))bad.push(NET.same+': miss still draws the chain');
         if(!tap(0.51))return NET.same+': staging restart failed';
         start();p.reloading=1;tickReload(0.002);e=entry();if(p.arStk!==0||(e&&e.on))bad.push(NET.same+': ordinary reload kept the status');
         // v28.xx (cw-cx-reloadstatus): alternating player objects must replace the shared list reading immediately.
         p.arStk=3;p.arBonus=0;entry();var other=Object.assign({},p);other.arStk=1;statusLive(other);
         for(i=0;i<STATUSL.length;i++)if(STATUSL[i].id==='ar'&&(!STATUSL[i].on||STATUSL[i].nm!=='active reload x1'))bad.push(NET.same+': another player inherited x3');
         e=entry();if(!e||e.nm!=='active reload x3')bad.push(NET.same+': local x3 was replaced by the other player');
       }
       return bad.length?bad.join('; '):null;
     }finally{
       ctx.fillText=ft;NET.on=nk.on;NET.same=nk.same;keys=kk;mouse.down=mm;
       try{if(p){p.arStk=0;p.arBonus=0;}__endRaid('abandon');}catch(_e){}__topClear();
     }
   }},
  {v:'36.16',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
