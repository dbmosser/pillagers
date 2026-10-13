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

if ($s.Contains("  {v:'25.09',what:")) { throw "check 25.09 is in the fixture already" }

SubRx @'
  {v:'25.08',what:
'@ @'
  {v:'25.09',what:'his order: a crawler that catches you hangs on and keeps biting while you sprint and roll away, and stops when it is killed',
   run:function(){
     if(!window.__deploy||!window.__endRaid||!window.__sim) return 'SKIP: no raid here';
     var bad=[], g, p, all, e, drops=[], mh, x0, y0, hp0, fr=0, lastHp, i;
     try{
       __topClear(); __runPrep(); __resetCfg(); __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       g=__state(); p=g.player; if(!g||g.over) return 'SKIP: no live raid';
       all=g.ents.slice(); e=all.filter(function(x){ return x.kind==='crawler'&&x.hp>0; })[0];
       if(!e) return 'SKIP: no crawler on this map';
       g.ents=[e]; mh=p.maxhp; p.maxhp=100000; p.hp=100000; p.iv=0; p.armor=0; p.downed=false; p.stam=100;
       for(var k in keys) keys[k]=false;
       // the open way out: the first of eight headings with 700 clear units of ground ahead of him
       var dirs=[[1,0,['KeyD']],[-1,0,['KeyA']],[0,1,['KeyS']],[0,-1,['KeyW']],[.7071,.7071,['KeyD','KeyS']],[-.7071,.7071,['KeyA','KeyS']],[.7071,-.7071,['KeyD','KeyW']],[-.7071,-.7071,['KeyA','KeyW']]], dir=null;
       for(i=0;i<dirs.length&&!dir;i++){ var _ok=true; for(var _s=1;_s<=7&&_ok;_s++){ var _tx=p.x+dirs[i][0]*100*_s, _ty=p.y+dirs[i][1]*100*_s; if(!losClear(p.x,p.y,_tx,_ty,G.map.segs)||inWater(_tx,_ty)) _ok=false; } if(_ok) dir=dirs[i]; }
       if(!dir) return 'SKIP: no open ground around the spawn';
       e.x=p.x-dir[0]*(e.r+(p.r||11)+2); e.y=p.y-dir[1]*(e.r+(p.r||11)+2); e.state='chase'; e.alert=2.4; e.tx=p.x; e.ty=p.y; e.cd=0; e.elite=false;
       lastHp=p.hp;
       var step=function(){ __sim(1/60); fr++; if(p.hp<lastHp-0.01) drops.push(fr/60); lastHp=p.hp; };
       for(i=0;i<30;i++) step();
       if(!drops.length) bad.push('the crawler touching him never bit in half a second');
       x0=p.x; y0=p.y; dir[2].forEach(function(kk){ keys[kk]=true; }); keys['ShiftLeft']=true;
       // he leaves at 280 a second at least: his own sprint and rolls, and where something in the fixture holds him back (a crouch,
       // an aim, a slow profile), the rest of the stride is put on him along the open heading, so the old crawler cannot keep up either way
       G.crouchTog=false; p.ads=false;
       for(i=0;i<180;i++){ if(i%30===0){ p.stam=100; tryRoll(); } var _px=p.x, _py=p.y; step(); var _adv=(p.x-_px)*dir[0]+(p.y-_py)*dir[1]; if(_adv<280/60){ p.x+=dir[0]*(280/60-_adv); p.y+=dir[1]*(280/60-_adv); } }
       for(var k3 in keys) keys[k3]=false;
       var moved=Math.hypot(p.x-x0,p.y-y0);
       if(moved<250) return 'SKIP: he could not get away from the spot ('+Math.round(moved)+')';
       var run=drops.filter(function(t){ return t>0.5; }), prev=0.5, worst=0;
       for(i=0;i<run.length;i++){ worst=Math.max(worst,run[i]-prev); prev=run[i]; }
       worst=Math.max(worst,3.5-prev);
       if(worst>0.8) bad.push('sprinting and rolling away for 3 s, the crawler went '+worst.toFixed(2)+' s without a bite ('+run.length+' bites, moved '+Math.round(moved)+')');
       e.hp=0; var n0=drops.length;
       for(i=0;i<120;i++) step();
       if(drops.length>n0) bad.push('it kept biting after it was killed ('+(drops.length-n0)+' more)');
     }catch(x){ bad.push('threw: '+(x&&x.message||x)); }
     finally{ for(var k2 in keys) keys[k2]=false; try{ if(all) g.ents=all; var g2=__state(); if(g2&&!g2.over){ g2.player.maxhp=mh||100; g2.player.hp=100; g2.player.downed=false; __endRaid('abandon'); } }catch(_e){} __topClear(); }
     return bad.length?bad.join('; '):null; }},
  {v:'25.08',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
