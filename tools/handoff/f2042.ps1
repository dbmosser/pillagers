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

if ($s.Contains("  {v:'20.42',what:")) { throw "check 20.42 is in the fixture already" }

SubRx @'
  {v:'20.41',what:
'@ @'
  {v:'20.42',what:'shooting the Peddler leaves his stall where it was and never sets him hunting you, from your own round or from a party round the host takes',
   run:function(){
     if(!window.__deploy||!window.__endRaid||typeof NET!=='object'||!NET||typeof updateBullets!=='function'||typeof netShotTake!=='function'||typeof rayHitG!=='function') return 'SKIP: no raid or party here';
     var NK={}, k, bad=[], g, p, ped=null, i, E0=null, px0=null, py0=null, tx0, ty0, h0, a=0, sx=0, sy=0, ok=false, r, peer={seat:1,state:'in'};
     var inW=function(x,y){ var j, v, W=G.map.walls; for(j=0;j<W.length;j++){ v=W[j]; if(v.win) continue; if(x>v.x-2&&x<v.x+v.w+2&&y>v.y-2&&y<v.y+v.h+2) return true; } return false; };
     for(k in NET) NK[k]=NET[k];
     try{
       NET.on=false; NET.role=null; NET.peers=[];
       __topClear(); __runPrep(); __cleanProfile();
       __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       g=__state(); if(!g||g.over||!g.player) return 'SKIP: staging: no raid';
       for(i=0;i<g.ents.length;i++) if(g.ents[i]&&g.ents[i].kind==='peddler'&&g.ents[i].hp>0){ ped=g.ents[i]; break; }
       if(!ped) return 'SKIP: staging: no Peddler in this raid';
       p=g.player; px0=p.x; py0=p.y; tx0=ped.tx; ty0=ped.ty;
       for(i=0;i<16&&!ok;i++){ a=i*Math.PI/8; sx=ped.x-Math.cos(a)*20; sy=ped.y-Math.sin(a)*20; if(!inW(sx,sy)&&rayHitG(sx,sy,Math.cos(a),Math.sin(a),32)>=32) ok=true; }
       if(!ok) return 'SKIP: staging: no clear line to the Peddler';
       p.x=ped.x+311.5; p.y=ped.y-177.25;
       E0=g.ents; g.ents=[ped]; h0=ped.hp;
       g.bullets.push({x:sx,y:sy,vx:Math.cos(a)*1180,vy:Math.sin(a)*1180,dmg:2,life:1,player:true,owner:p,tint:'#ffd48a',thru:0});
       updateBullets(0.02);
       g.ents=E0; E0=null;
       if(!(ped.hp<h0)) bad.push('control: the round never reached the Peddler');
       if(Math.abs(ped.tx-tx0)>0.5||Math.abs(ped.ty-ty0)>0.5) bad.push('your round moved his stall '+Math.round(Math.hypot(ped.tx-tx0,ped.ty-ty0))+' to where you fired from');
       if(ped.state==='chase') bad.push('your round left him hunting you');
       ped.tx=tx0; ped.ty=ty0; ped.state='idle'; ped.alert=0;
       NET.on=true; NET.role='host'; NET.seat=0; NET.max=4; NET.peers=[peer]; NET.upSeed=g.seed>>>0; NET.entMap={}; NET.entMap[77]=ped;
       r=netShotTake(peer,{t:'shot',id:77,dmg:3,x:ped.x-233.5,y:ped.y+141.25,a:0});
       if(r!=='shot') bad.push('the host did not take the party round ('+r+')');
       else{
         if(Math.abs(ped.tx-tx0)>0.5||Math.abs(ped.ty-ty0)>0.5) bad.push('a party round moved his stall '+Math.round(Math.hypot(ped.tx-tx0,ped.ty-ty0))+' to where it was fired from');
         if(ped.state==='chase') bad.push('a party round left him hunting');
       }
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{
       try{ if(E0&&G) G.ents=E0; }catch(_r){}
       for(k in NET) if(!(k in NK)) delete NET[k];
       for(k in NK) NET[k]=NK[k];
       try{ if(G&&G.player&&px0!==null){ G.player.x=px0; G.player.y=py0; } }catch(_p){}
       try{ var g2=__state(); if(g2&&!g2.over){ g2.player.downed=false; __endRaid('abandon'); } }catch(_e){}
       __topClear(); __cleanProfile();
     }
     return bad.length?bad.join('; '):null; }},
  {v:'20.41',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
