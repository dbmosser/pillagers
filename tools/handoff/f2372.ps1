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

if ($s.Contains("  {v:'23.72',what:")) { throw "check 23.72 is in the fixture already" }

SubRx @'
  {v:'23.71',what:
'@ @'
  {v:'23.72',what:'his #6: a body that steps across an armed Tripwire Mine sets it off; a player never does and is never hurt by it',
   run:function(){
     if(!window.__deploy||!window.__endRaid||typeof tripArm!=='function'||typeof rayHitG!=='function') return 'SKIP: no raid here';
     if(typeof tickTrips!=='function'||typeof tripBlast!=='function') return 'no tickTrips or tripBlast: a wire is never set off';
     var bad=[], g, p, i, a, best=null, e=null, ex0, ey0, eh0, est0, px0, py0, ph0, mx, my, T, ux, uy;
     try{
       __topClear(); __runPrep(); __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       g=__state(); if(!g||g.over||!g.player) return 'SKIP: no live raid';
       p=g.player; px0=p.x; py0=p.y; p.iv=0;
       for(a=0;a<16&&!best;a++){
         var an=a*Math.PI/8, cx=Math.cos(an), cy=Math.sin(an), lx=p.x+cx*300, ly=p.y+cy*300;
         if(rayHitG(p.x,p.y,cx,cy,380)>=379&&rayHitG(lx,ly,-cy,cx,130)>=129&&rayHitG(lx,ly,cy,-cx,130)>=129) best={ux:cx,uy:cy};
       }
       if(!best) return 'SKIP: staging: no clear lane at the spawn';
       ux=best.ux; uy=best.uy;
       for(i=0;i<g.ents.length;i++){ var c=g.ents[i]; if(c&&c.kind==='crawler'&&c.hp>0&&!c.finished){ e=c; break; } }
       if(!e) return 'SKIP: staging: no crawler in this raid';
       ex0=e.x; ey0=e.y; eh0=e.hp; est0=e.state;
       g.trips=[];
       T=tripArm({sx:p.x,sy:p.y,tx:p.x+ux*300,ty:p.y+uy*300}); T.arm=0;
       mx=p.x+ux*300; my=p.y+uy*300;
       p.x=mx-ux*60; p.y=my-uy*60; ph0=p.hp;
       e.hp=500; e.x=mx-ux*20; e.y=my-uy*20;
       tickTrips(0.016);
       if(g.trips.length!==1) bad.push('the wire went off before anything crossed it');
       e.x=mx+ux*20; e.y=my+uy*20;
       tickTrips(0.016);
       if(g.trips.length!==0) bad.push('a crawler stepped across an armed wire and it did not go off');
       if(!(e.hp<=500-100)) bad.push('the blast took '+Math.round(500-e.hp)+' from a crawler 20 from it, not 100 or more');
       if(p.hp!==ph0) bad.push('the blast hurt the player 60 from it ('+ph0+' to '+p.hp+')');
       g.trips=[];
       T=tripArm({sx:p.x,sy:p.y,tx:mx,ty:my}); T.arm=0;
       p.x=mx-ux*20; p.y=my-uy*20; tickTrips(0.016); p.x=mx+ux*20; p.y=my+uy*20; tickTrips(0.016);
       if(g.trips.length!==1) bad.push('a player walking across a wire set it off');
       e.hp=500; e.x=mx-ux*20; e.y=my-uy*20; T.arm=0.6; tickTrips(0.016); e.x=mx+ux*20; e.y=my+uy*20; tickTrips(0.016);
       if(g.trips.length!==1||e.hp!==500) bad.push('a wire still arming went off');
       g.trips=[];
       T=tripArm({sx:p.x,sy:p.y,tx:mx,ty:my}); T.arm=0;
       e.hp=40; e.byPlayer=false; e.x=mx-ux*10; e.y=my-uy*10; tickTrips(0.016); e.x=mx+ux*10; e.y=my+uy*10; tickTrips(0.016);
       if(!(e.hp<=0)) bad.push('a 40 hp crawler on the wire lived');
       else if(e.byPlayer!==true) bad.push('the kill of the wire owner is not his (byPlayer '+e.byPlayer+')');
     }catch(x){ bad.push('threw: '+(x&&x.message||x)); }
     finally{
       try{ if(e){ e.x=ex0; e.y=ey0; e.hp=eh0; e.state=est0; e.byPlayer=false; } var g2=__state(); if(g2&&!g2.over){ g2.trips=[]; g2.player.x=px0; g2.player.y=py0; __endRaid('abandon'); } }catch(_e){}
       __topClear(); }
     return bad.length?bad.join('; '):null; }},
  {v:'23.71',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
