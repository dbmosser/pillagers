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

if ($s.Contains("  {v:'20.63',what:")) { throw "check 20.63 is in the fixture already" }

SubRx @'
  {v:'20.62',what:
'@ @'
  {v:'20.63',what:'a pillager throw and smoke clocks run every frame: 22 seconds after his last charge he throws again, and 15 seconds after his last smoke a hurt man smokes again, with no shot taken in between',
   run:function(){
     if(!window.__deploy||!window.__endRaid||typeof raiderThrow!=='function'||typeof raiderUseKit!=='function'||!ITEMS.frag||!WEAPONS.pistol) return 'SKIP: no pillager kit in this fixture';
     if(CFG.raiderKit===0) return 'SKIP: pillager kit is off in this profile';
     var NK={}, k, bad=[], g=null, p, e, e2, i, n0, s0, r1, r2, f0=0, sm0=0, fR, fd;
     for(k in NET) NK[k]=NET[k];
     function man(nm){ return {kind:'raider',name:nm,x:p.x+2600,y:p.y+2600,r:11,hp:100,maxhp:100,wep:WEAPONS.pistol,dmg:WEAPONS.pistol.dmg,rng:520,bag:[],kitT:0,crew:7,hostile:true,state:'chase',alert:0}; }
     try{
       NET.on=false; NET.role=null; NET.peers=[];
       __topClear(); __runPrep(); __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       g=__state(); if(!g||g.over||!g.player||!g.frags||!g.smokes) return 'SKIP: no live raid';
       p=g.player; f0=g.frags.length; sm0=g.smokes.length;
       fR=(CFG.fragR===undefined?190:CFG.fragR); fd=fR+52+60;
       if(fd>=520) return 'SKIP: the blast radius leaves no distance a pillager throws from';
       e=man('QX THROWER'); e.bag=['frag','frag','frag']; e.thrT=20;
       for(i=0;i<1320;i++) raiderUseKit(e,1/60);
       n0=g.frags.length;
       r1=raiderThrow(e,{x:e.x+fd,y:e.y},fd,1/60);
       if(!r1||g.frags.length!==n0+1) bad.push('22 seconds after his last charge a pillager with 3 more in his pack did not throw (his wait still reads '+(+e.thrT).toFixed(2)+')');
       e2=man('QX SMOKER'); e2.hp=40; e2.smkT=14; e2.thrT=-1;
       for(i=0;i<900;i++) raiderUseKit(e2,1/60);
       s0=g.smokes.length;
       r2=raiderThrow(e2,{x:e2.x+fd,y:e2.y},fd,1/60);
       if(!r2||g.smokes.length!==s0+1) bad.push('15 seconds after his last smoke a hurt pillager did not smoke again (his wait still reads '+(+e2.smkT).toFixed(2)+')');
     }catch(ex){ bad.push('threw: '+(ex&&ex.message||ex)); }
     finally{
       try{ if(g){ if(g.frags&&g.frags.length>f0) g.frags.length=f0; if(g.smokes&&g.smokes.length>sm0) g.smokes.length=sm0; } }catch(_f){}
       for(k in NET) if(!(k in NK)) delete NET[k];
       for(k in NK) NET[k]=NK[k];
       try{ var g2=__state(); if(g2&&!g2.over){ g2.player.downed=false; __endRaid('abandon'); } }catch(_e){}
       __topClear();
     }
     return bad.length?bad.join('; '):null; }},
  {v:'20.62',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
