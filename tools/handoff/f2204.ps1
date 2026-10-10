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

if ($s.Contains("  {v:'22.04',what:")) { throw "check 22.04 is in the fixture already" }

SubRx @'
  {v:'22.03',what:
'@ @'
  {v:'22.04',what:'a round player 2 puts into an armoured pillager goes to the host whole with an armour flag and the host takes it off the plate it keeps, back shots after the soak, while a blow with no flag is not soaked',
   run:function(){
     if(!window.__deploy||!window.__endRaid||typeof NET!=='object'||!NET||typeof netShotTake!=='function'||typeof netEntsInit!=='function'||typeof updateBullets!=='function'||typeof armorById!=='function') return 'SKIP: no raid or party here';
     var NK={}, k, bad=[], oSend=netSend, sent=[], g, e=null, i, c, r, sk, ex, pa={state:'in',seat:1}, ha={state:'in',seat:0}, e0=null, b0=null, s;
     for(k in NET) NK[k]=NET[k];
     try{
       NET.on=false; NET.role=null; NET.peers=[];
       __topClear(); __runPrep(); __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       g=__state(); if(!g||g.over||!g.player) return 'SKIP: no live raid';
       sk=armorById('heavy').absorb||0;
       if(!(sk>0)||armorById('heavy').id!=='heavy') return 'SKIP: no Breacher Plate here';
       netSend=function(q,m){ sent.push({q:q,m:JSON.parse(JSON.stringify(m))}); return true; };
       NET.specG=null; NET.on=true; NET.role='host'; NET.seat=0; NET.upSeed=g.seed>>>0; NET.peers=[pa]; NET.up=[];
       netEntsInit(g);
       for(i=0;i<g.ents.length;i++){ c=g.ents[i]; if(c&&c.kind==='raider'&&!c.merc&&!c.friendlyPC&&!c.downed&&!c.finished&&c.hp>0&&c.nid){ e=c; break; } }
       if(!e) return 'SKIP: staging: no pillager';
       e.rig='heavy'; e.armor=84; e.hp=500; e.roll=0; e.hostile=true;
       r=netShotTake(pa,{t:'shot',id:e.nid,dmg:30,ar:1});
       ex=30-Math.min(84,30*sk);
       if(r!=='shot') bad.push('the host refused the round ('+r+')');
       else if(Math.abs((500-e.hp)-ex)>0.01) bad.push('a 30 round from player 2 into a Breacher Plate took '+(+(500-e.hp).toFixed(2))+' health, not '+(+ex.toFixed(2)));
       if(Math.abs(e.armor-(84-30*sk))>0.01) bad.push('the plate the host keeps went from 84 to '+(+(+e.armor).toFixed(2))+' for that round');
       e.armor=84; e.hp=500; e.roll=0;
       netShotTake(pa,{t:'shot',id:e.nid,dmg:45,ar:1.5});
       ex=(30-Math.min(84,30*sk))*1.5;
       if(Math.abs((500-e.hp)-ex)>0.01) bad.push('a 45 back shot from player 2 took '+(+(500-e.hp).toFixed(2))+' health, not '+(+ex.toFixed(2))+' (the plate first, then the bonus)');
       e.armor=84; e.hp=500; e.roll=0;
       netShotTake(pa,{t:'shot',id:e.nid,dmg:30});
       if(Math.abs((500-e.hp)-30)>0.01||e.armor!==84) bad.push('a blow with no armour flag was soaked ('+(+(500-e.hp).toFixed(2))+' health, plate '+e.armor+')');
       NET.role='join'; NET.seat=1; NET.peers=[ha];
       if(!netEntsPeer()) return 'SKIP: staging: the window does not read as player 2 up top';
       e.armor=50; e.rig='heavy'; e.hp=500; e.roll=0; e.downed=0; e.finished=0; e.hostile=true; e.face=Math.PI;
       sent.length=0; e0=g.ents; b0=g.bullets;
       g.ents=[e];
       g.bullets=[{x:e.x-6,y:e.y,vx:1180,vy:0,dmg:37,life:0.5,player:true,owner:g.player,tint:'#ffd48a',thru:0}];
       updateBullets(0.004);
       g.ents=e0; g.bullets=b0; e0=null;
       s=sent.filter(function(w){ return w.m&&w.m.t==='shot'; });
       if(s.length!==1) bad.push('player 2 round into the pillager sent '+s.length+' shot words, not 1');
       else {
         if(s[0].m.ar!==1) bad.push('the round went to the host with no armour flag ('+JSON.stringify(s[0].m)+')');
         if(Math.abs(s[0].m.dmg-37)>0.01) bad.push('the round went to the host as '+s[0].m.dmg+', soaked by the copy in this window, not whole at 37');
       }
       if(e.armor!==50) bad.push('the copy of the plate in the player 2 window went from 50 to '+(+(+e.armor).toFixed(2)));
     }catch(ex2){ bad.push('threw: '+(ex2&&ex2.message||ex2)); }
     finally{
       netSend=oSend;
       try{ if(e0&&g){ g.ents=e0; g.bullets=b0; } }catch(_r){}
       for(k in NET) if(!(k in NK)) delete NET[k];
       for(k in NK) NET[k]=NK[k];
       try{ var g2=__state(); if(g2&&!g2.over){ g2.player.downed=false; __endRaid('abandon'); } }catch(_e){}
       __topClear();
     }
     return bad.length?bad.join('; '):null; }},
  {v:'22.03',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
