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

if ($s.Contains("  {v:'20.52',what:")) { throw "check 20.52 is in the fixture already" }

SubRx @'
  {v:'20.51',what:
'@ @'
  {v:'20.52',what:'a bare-hand strike stops at a wall: a machine just the other side of a wall takes nothing, and the same strike across open ground still lands',
   run:function(){
     if(!window.__deploy||!window.__endRaid||typeof fireWeapon!=='function'||typeof losClear!=='function'||typeof WEAPONS!=='object'||!WEAPONS.fists) return 'SKIP: no raid or no bare hands here';
     if(typeof NET==='object'&&NET&&NET.on) return 'SKIP: a party is live';
     var bad=[], g, p, t=null, q, i, j, w, E0=null, px0=null, py0=null, reach, thin, len, A=null, B=null, C=null, ok=false, h0, h1, oSay=say;
     var inW=function(o){ var k, v, W=G.map.walls; for(k=0;k<W.length;k++){ v=W[k]; if(o.x>v.x-3&&o.x<v.x+v.w+3&&o.y>v.y-3&&o.y<v.y+v.h+3) return true; } return false; };
     try{
       __topClear(); __runPrep(); __cleanProfile();
       __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       g=__state(); if(!g||g.over||!g.player) return 'SKIP: staging: no raid';
       say=function(){};
       p=g.player; px0=p.x; py0=p.y;
       for(i=0;i<g.ents.length&&!t;i++){ q=g.ents[i]; if(q&&q.kind==='sentry'&&!q.downed&&!q.finished&&!q.merc&&q.hp>0) t=q; }
       for(i=0;i<g.ents.length&&!t;i++){ q=g.ents[i]; if(q&&q.kind==='crawler'&&!q.downed&&!q.finished&&!q.merc&&q.hp>0) t=q; }
       if(!t) return 'SKIP: staging: no machine in this raid';
       reach=WEAPONS.fists.rng+t.r;
       for(j=0;j<G.map.walls.length&&!ok;j++){
         w=G.map.walls[j]; if(!w||w.win) continue;
         thin=Math.min(w.w,w.h); len=Math.max(w.w,w.h);
         if(thin<8||thin+24>reach-4||len<90) continue;
         if(w.h>=w.w){ A={x:w.x-12,y:w.y+w.h/2}; B={x:w.x+w.w+12,y:w.y+w.h/2}; C={x:w.x-44,y:w.y+w.h/2}; }
         else { A={x:w.x+w.w/2,y:w.y-12}; B={x:w.x+w.w/2,y:w.y+w.h+12}; C={x:w.x+w.w/2,y:w.y-44}; }
         if(inW(A)||inW(B)||inW(C)) continue;
         if(losClear(A.x,A.y,B.x,B.y,G.map.segs)) continue;
         if(!losClear(C.x,C.y,A.x,A.y,G.map.segs)) continue;
         ok=true;
       }
       if(!ok) return 'SKIP: staging: no thin wall with room on both sides';
       E0=g.ents; g.ents=[t];
       p.x=C.x; p.y=C.y; t.x=A.x; t.y=A.y; if(t.maxhp>0) t.hp=t.maxhp; h0=t.hp;
       fireWeapon(p,WEAPONS.fists,t.x,t.y,true);
       if(!(t.hp<h0)) bad.push('control: a strike across open ground did not land');
       p.x=A.x; p.y=A.y; t.x=B.x; t.y=B.y; if(t.maxhp>0) t.hp=t.maxhp; h1=t.hp;
       fireWeapon(p,WEAPONS.fists,t.x,t.y,true);
       if(t.hp<h1) bad.push('a strike hurt a machine '+Math.round(Math.hypot(B.x-A.x,B.y-A.y))+' away through a wall ('+Math.round(h1-t.hp)+' damage)');
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{
       say=oSay;
       try{ if(E0&&G) G.ents=E0; }catch(_r){}
       try{ if(G&&G.player&&px0!==null){ G.player.x=px0; G.player.y=py0; } }catch(_p){}
       try{ var g2=__state(); if(g2&&!g2.over){ g2.player.downed=false; __endRaid('abandon'); } }catch(_e){}
       __topClear(); __cleanProfile();
     }
     return bad.length?bad.join('; '):null; }},
  {v:'20.51',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
