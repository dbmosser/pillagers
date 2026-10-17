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

if ($s.Contains("  {v:'28.84',what:")) { throw "check 28.84 is in the fixture already" }

SubRx @'
  {v:'28.83',what:
'@ @'
  {v:'28.84',what:'a killed deer leaves a carcass drawn by the deer carcass path (drawDeerCarcass), not the human body (his note: deer becomes a human body)',
   run:function(){
     if(typeof __frame!=='function'||typeof updateBullets!=='function') return 'SKIP: no frame or bullet helper';
     var PR=CanvasRenderingContext2D.prototype, otr=PR.translate, g=null, p, d=null, i, c, ct=null, deerHit=0, manHit=0;
     try{
       __runPrep(); __topClear(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       g=__state(); if(!g||!g.player) return 'SKIP: no raid';
       p=g.player;
       if(!g.wild) g.wild=[];
       for(i=0;i<g.wild.length;i++) if(g.wild[i].k==='deer'&&!g.wild[i].dead){ d=g.wild[i]; break; }
       if(!d){ d={k:'deer',x:0,y:0,vx:0,vy:0,st:'idle',t:1,f:0,z:0,life:0,face:1,hx:0,hy:0,ant:1}; g.wild.push(d); }
       d.x=p.x+34; d.y=p.y+22; d.hx=d.x; d.hy=d.y; d.st='idle'; d.hp=10;
       g.bullets.length=0;
       g.bullets.push({x:d.x,y:d.y,vx:0.01,vy:0,dmg:100,life:0.5,player:true,owner:p,tint:'#ffffff',el:'',thru:0});
       updateBullets(0.001); g.bullets.length=0;
       if(!d.dead) return 'the deer did not die from a 100 damage round';
       for(i=0;i<g.containers.length;i++){ c=g.containers[i]; if(Math.abs(c.x-d.x)<2&&Math.abs(c.y-d.y)<2){ ct=c; break; } }
       if(!ct) return 'a dead deer left no carcass container';
       p.x=d.x-30; p.y=d.y;
       PR.translate=function(x,y){ if(Math.abs(x-ct.x)<0.01&&/drawContS/.test(String(new Error().stack))){ if(/drawDeerCarcass/.test(String(new Error().stack))){ if(Math.abs(y-(ct.y-3))<0.01) deerHit++; } else if(Math.abs(y-(ct.y-2))<0.01) manHit++; } return otr.apply(this,arguments); };
       __frame(); __frame();
       PR.translate=otr;
       if(manHit) return 'a dead deer is drawn as the human body (skin colour drawn by the body path)';
       if(!deerHit) return 'a dead deer is not drawn by the deer carcass path';
       return null;
     } finally {
       PR.translate=otr;
       try{ __endRaid('abandon'); }catch(_e){}
       __topClear();
     } }},
  {v:'28.83',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
