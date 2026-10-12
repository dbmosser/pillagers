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

if ($s.Contains("  {v:'23.63',what:")) { throw "check 23.63 is in the fixture already" }

SubRx @'
  {v:'23.62',what:
'@ @'
  {v:'23.63',what:'his #6 and answer 32: a Tripwire Mine goes on the belt like a grenade and strings a wire across the throw where it lands',
   run:function(){
     if(!window.__deploy||!window.__endRaid||typeof hotbarSlots!=='function'||typeof rayHitG!=='function') return 'SKIP: no raid here';
     if(!ITEMS.trip||THROWKEYS.indexOf('trip')<0||typeof tripArm!=='function') return 'no Tripwire Mine: ITEMS.trip, the trip throw key or tripArm is missing';
     var bad=[], g, p, oMW=mouseWorld, i, a, s0, s1, ti=-1, best=null, n0, T, Ln, dot;
     try{
       __topClear(); __runPrep(); __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       g=__state(); if(!g||g.over||!g.player) return 'SKIP: no live raid';
       p=g.player; p.cooking=0; p.roll=0; p.downed=false;
       g.pouch.trip=0;
       s0=hotbarSlots();
       for(i=0;i<s0.length;i++) if(s0[i]&&s0[i].k==='throw:trip') bad.push('a Tripwire Mine cell shows on key '+(i+1)+' with none carried');
       g.pouch.trip=1;
       s1=hotbarSlots();
       for(i=0;i<s1.length;i++) if(s1[i]&&s1[i].k==='throw:trip') ti=i;
       if(ti<0) bad.push('no Tripwire Mine cell on the belt with one carried');
       if(s1.length!==s0.length) bad.push('the belt changed length: '+s0.length+' to '+s1.length);
       for(i=0;i<s0.length;i++) if(s0[i]&&s0[i].kind!=='empty'&&(!s1[i]||s1[i].k!==s0[i].k)) bad.push('key '+(i+1)+' moved from '+s0[i].k+' to '+(s1[i]&&s1[i].k));
       for(a=0;a<16&&!best;a++){
         var an=a*Math.PI/8, ux=Math.cos(an), uy=Math.sin(an), lx=p.x+ux*200, ly=p.y+uy*200;
         if(rayHitG(p.x,p.y,ux,uy,260)>=259&&rayHitG(lx,ly,-uy,ux,130)>=129&&rayHitG(lx,ly,uy,-ux,130)>=129) best={ux:ux,uy:uy};
       }
       if(!best) return 'SKIP: staging: no clear throw lane at the spawn';
       mouseWorld=function(){ return {x:p.x+best.ux*200,y:p.y+best.uy*200}; };
       g.tsel=THROWKEYS.indexOf('trip');
       n0=(g.trips||[]).length;
       doThrow();
       for(i=0;i<30;i++) updateThrowables(0.05);
       if(!g.trips||g.trips.length!==n0+1) bad.push('the throw strung '+((g.trips||[]).length-n0)+' wires, not 1');
       else {
         T=g.trips[g.trips.length-1]; Ln=Math.sqrt((T.bx-T.ax)*(T.bx-T.ax)+(T.by-T.ay)*(T.by-T.ay));
         if(!(Ln>=150&&Ln<=170)) bad.push('the wire in the open is '+Math.round(Ln)+' long, not 160 (80 each side)');
         dot=((T.bx-T.ax)*best.ux+(T.by-T.ay)*best.uy)/Math.max(1,Ln);
         if(Math.abs(dot)>0.05) bad.push('the wire does not run across the throw (cos '+dot.toFixed(2)+')');
         if(!(T.arm>0)) bad.push('the wire is live the moment it lands (no arming time)');
       }
       if(g.pouch.trip!==0) bad.push('the throw did not spend the mine (pouch '+g.pouch.trip+')');
       if(!(g.tel.thr.trip===1)) bad.push('the run log did not count the mine thrown ('+g.tel.thr.trip+')');
       g.trips.length=0;
       for(i=0;i<4;i++) tripArm({sx:p.x,sy:p.y,tx:p.x+best.ux*200,ty:p.y+best.uy*200});
       if(g.trips.length!==3) bad.push('an owner keeps '+g.trips.length+' wires, not 3');
       g.pouch.smoke=0; g.pouch.decoy=0; g.pouch.frag=0; g.pouch.trip=1; g.tsel=0;
       cycleThrow();
       if(THROWKEYS[g.tsel]!=='trip') bad.push('Q never reaches the Tripwire Mine (it chose '+THROWKEYS[g.tsel]+')');
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{ mouseWorld=oMW; try{ var g2=__state(); if(g2&&!g2.over){ if(g2.trips) g2.trips.length=0; g2.player.cooking=0; __endRaid('abandon'); } }catch(_e){} __topClear(); }
     return bad.length?bad.join('; '):null; }},
  {v:'23.62',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
