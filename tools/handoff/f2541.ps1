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

if ($s.Contains("  {v:'25.41',what:")) { throw "check 25.41 is in the fixture already" }

SubRx @'
  {v:'25.40',what:
'@ @'
  {v:'25.41',what:'his order (add minimap): the minimap marks extractions in their state, the seal, teammates, and only the enemies you can see',
   run:function(){
     if(!(window.__deploy&&window.__state&&window.__endRaid)||typeof drawHUD!=='function'||typeof render2D!=='function'||typeof ctx==='undefined') return 'SKIP: no raid HUD here';
     if(typeof drawMinimap!=='function'||typeof MMAP!=='object') return 'SKIP: no minimap in this build';
     if(typeof mmMarks!=='function') return 'the minimap draws no markers';
     var bad=[], g, p, i, j, k, Z, sv={}, mate=null, oldShown=netUpShown, A=null, B=null, OWN=Object.prototype.hasOwnProperty, names=['fillRect','fill','stroke','drawImage','fillText','strokeText','strokeRect'], own={}, real={}, n=0;
     function wrap(){ names.forEach(function(k2){ own[k2]=OWN.call(ctx,k2); real[k2]=ctx[k2]; ctx[k2]=function(){ n++; return real[k2].apply(this,arguments); }; }); }
     function unwrap(){ names.forEach(function(k2){ if(!(k2 in real)) return; if(own[k2]) ctx[k2]=real[k2]; else delete ctx[k2]; }); real={}; }
     function foe(e){ return e&&!e.dead&&!(e.hp<=0)&&!e.merc&&!e.friendly&&!e.friendlyPC&&!e.neutral&&e.kind!=='peddler'&&e.kind!=='stray'&&e.kind!=='raider'; }
     try{
       __topClear(); __runPrep(); __deploy({kit:['gun_carbine'],seed:4242,mapIx:0});
       g=__state(); if(!g||g.over) return 'SKIP: no live raid';
       p=g.player; p.face=0;
       render2D(0);
       if(!g.zones||g.zones.length<2) return 'SKIP: fewer than two extraction points';
       // two machines: one in plain sight ahead, one behind a wall inside the minimap
       var fs=g.ents.filter(foe); if(fs.length<2) return 'SKIP: fewer than two machines to stage';
       A=fs[0]; B=fs[1]; sv.A={x:A.x,y:A.y}; sv.B={x:B.x,y:B.y};
       var vis=null, hid=null;
       for(k=60;k<=260&&!vis;k+=20) for(j=-2;j<=2&&!vis;j++){ var vx=p.x+Math.cos(j*0.15)*k, vy=p.y+Math.sin(j*0.15)*k; if(canSee(p.x,p.y,p.face,vx,vy,g.vseg)) vis={x:vx,y:vy}; }
       for(k=140;k<=440&&!hid;k+=30) for(j=0;j<24&&!hid;j++){ var hx=p.x+Math.cos(j*0.2618)*k, hy=p.y+Math.sin(j*0.2618)*k; if(!losClear(p.x,p.y,hx,hy,g.vseg)) hid={x:hx,y:hy}; }
       if(!vis||!hid) return 'SKIP: no open and walled spots near the spawn';
       A.x=vis.x; A.y=vis.y; B.x=hid.x; B.y=hid.y;
       // the zones: one closed, one called
       sv.z0={open:g.zones[0].open}; sv.z1={b:g.zones[1].beaconT};
       g.zones[0].open=false; g.zones[1].beaconT=12;
       // a teammate far off, so he pins to the edge
       netUpShown=function(q){ return !!q&&q.mmTest===1; };
       mate={mmTest:1,x:p.x+3000,y:p.y,f:0,dn:0,seat:7}; NET.up.push(mate);
       render2D(0);
       var got=MMAP.got;
       if(!got||!MMAP.box) bad.push('a raid frame drew no minimap markers');
       else {
         if(got.foes.indexOf(A)<0) bad.push('an enemy in plain sight is not on the minimap');
         if(got.foes.indexOf(B)>=0) bad.push('an enemy behind a wall is on the minimap');
         for(i=0;i<got.foes.length;i++) if(VIS.indexOf(got.foes[i])<0){ bad.push('the minimap shows an enemy the world does not'); break; }
         if(got.zones.length!==g.zones.length) bad.push('the minimap marked '+got.zones.length+' of '+g.zones.length+' extraction points');
         if(got.zones[0]!=='closed') bad.push('a closed extraction reads '+got.zones[0]);
         if(got.zones[1]!=='inbound') bad.push('a called extraction reads '+got.zones[1]);
         if(g.seal&&!g.seal.done&&!got.seal) bad.push('the seal is not on the minimap');
         if(got.mates!==1) bad.push('the teammate is not on the minimap ('+got.mates+')');
         if(!(got.pins>=1)) bad.push('nothing out of range pinned to the edge');
       }
       n=0; wrap(); try{ drawMinimap(); } finally { unwrap(); }
       if(n>90) bad.push('the minimap made '+n+' draw calls in one frame');
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{
       try{ unwrap(); }catch(_u){}
       netUpShown=oldShown;
       try{ if(mate){ var mi=NET.up.indexOf(mate); if(mi>=0) NET.up.splice(mi,1); } }catch(_m){}
       try{ if(A&&sv.A){ A.x=sv.A.x; A.y=sv.A.y; } if(B&&sv.B){ B.x=sv.B.x; B.y=sv.B.y; } if(sv.z0) g.zones[0].open=sv.z0.open; if(sv.z1) g.zones[1].beaconT=sv.z1.b; }catch(_r){}
       try{ var g2=__state(); if(g2&&!g2.over) __endRaid('abandon'); }catch(_e){} try{ __topClear(); }catch(_c){}
     }
     return bad.length?bad.join('; '):null; }},
  {v:'25.40',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
