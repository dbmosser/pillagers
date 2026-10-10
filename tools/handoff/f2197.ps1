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

if ($s.Contains("  {v:'21.97',what:")) { throw "check 21.97 is in the fixture already" }

SubRx @'
  {v:'21.96',what:
'@ @'
  {v:'21.97',what:'kid mode and kid firing stay with player 2 when he takes the raid over after the host link is gone, and a solo raid never gets them',
   run:function(){
     if(!window.__deploy||!window.__endRaid||typeof NET!=='object'||!NET||typeof netHostGone!=='function'||typeof netAfOn!=='function'||typeof damagePlayer!=='function') return 'SKIP: no raid or party in this fixture';
     var NK={}, k, bad=[], oSwf=sayWhenFree, oSay=say, oVg=voxGrunt, g, p, hk=Object.prototype.hasOwnProperty, hasKd=false, hasAf=false, kd0, af0, full=0, lost=0;
     for(k in NET) NK[k]=NET[k];
     try{
       NET.on=false; NET.role=null; NET.peers=[];
       __topClear(); __runPrep(); __cleanProfile();
       hasKd=hk.call(P,'kidDmg'); kd0=P.kidDmg; hasAf=hk.call(P,'p2Auto'); af0=P.p2Auto;
       P.kidDmg=1; P.p2Auto=0;
       __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       g=__state(); if(!g||g.over||!g.player) return 'SKIP: staging: no raid';
       p=g.player;
       sayWhenFree=function(){}; say=function(){}; voxGrunt=function(){};
       NET.kidHost=0.05; NET.afHost=1;
       if(netAfOn()) bad.push('a solo raid has kid firing from a host value left over');
       p.iv=0; p.armor=0; p.plates=0; p.hp=100; p.downed=false;
       damagePlayer(20,'test','ZQX KIDTEST');
       full=100-p.hp;
       if(!(full>4)) return 'SKIP: staging: a solo hit of 20 took '+full;
       NET.on=true; NET.role='join'; NET.seat=1; NET.max=4; NET.peers=[{seat:0,state:'in'}]; NET.upSeed=g.seed>>>0;
       if(!netAfOn()) return 'SKIP: staging: kid firing is off even while linked';
       if(!netHostGone('lost')) return 'SKIP: staging: the takeover did not run';
       NET.on=false; NET.role=null; NET.seat=-1; NET.peers=[];   // what the reset after a lost link or a bye does to the link
       if(!netAfOn()) bad.push('kid firing switched off when player 2 took the raid over');
       p.iv=0; p.armor=0; p.plates=0; p.hp=100; p.downed=false;
       damagePlayer(20,'test','ZQX KIDTEST');
       lost=100-p.hp;
       if(!(lost<full*0.5)) bad.push('after the takeover a hit took '+lost.toFixed(1)+' where a full hit takes '+full.toFixed(1)+', so the kid mode cut is gone');
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{
       sayWhenFree=oSwf; say=oSay; voxGrunt=oVg;
       try{ if(hasKd) P.kidDmg=kd0; else delete P.kidDmg; if(hasAf) P.p2Auto=af0; else delete P.p2Auto; }catch(_p){}
       for(k in NET) if(!(k in NK)) delete NET[k];
       for(k in NK) NET[k]=NK[k];
       try{ var g2=__state(); if(g2&&!g2.over){ g2.player.downed=false; __endRaid('abandon'); } }catch(_e){}
       __topClear(); __cleanProfile();
     }
     return bad.length?bad.join('; '):null; }},
  {v:'21.96',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
