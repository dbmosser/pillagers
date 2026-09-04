$ErrorActionPreference = 'Stop'
trap { Write-Output "FAILED: $_"; exit 1 }
$p = 'C:\claudecode\dark raiders\tools\mkfixture.ps1'
$s = [IO.File]::ReadAllText($p)
$n = 0
function SubRx([string]$old, [string]$new) {
  $pat = ($old -split "`n" | ForEach-Object { [regex]::Escape($_.TrimEnd("`r")) }) -join "\r?\n"
  $c = ([regex]::Matches($script:s, $pat)).Count
  if ($c -ne 1) { throw "regex matched $c times: $($old.Substring(0,[Math]::Min(70,$old.Length)))" }
  $script:s = [regex]::Replace($script:s, $pat, { param($m) $new })
  $script:n++
}

# The shell impact, driven directly, so a roof can be tested without waiting two
# seconds of flight time for a machine to decide to fire.
SubRx @'
window.__equipBag=function(ix,slot){ return equipFromBag(ix,slot); };
'@ @'
window.__equipBag=function(ix,slot){ return equipFromBag(ix,slot); };
window.__howlerHit=function(SH){ return howlerImpact(SH); };   // v10.63
window.__buildings=function(){ return (G&&G.map)?(G.map.buildings||[]):[]; };
'@

SubRx @'
  {v:'10.62',what:'a found gun takes the empty weapon slot instead of turning out the gun in hand, and with both slots full it still replaces the one asked for',
'@ @'
  {v:'10.63',what:'a Howler shell that lands on a building bursts on the roof and hurts nobody under it, while the same shell in the open still hurts and one fired from inside still hurts',
   run:function(){
     var bad=[];
     if(!(window.__startRaid&&window.__howlerHit&&window.__buildings&&window.__state)) return 'SKIP: this build cannot drive a Howler shell';
     __resetCfg();
     __startRaid({seed:4242,mapIx:0});
     var G2=__state(); if(!G2||!G2.player) return 'no raid';
     var p=G2.player, B=__buildings();
     if(!B.length) return 'SKIP: no buildings on this map';
     // A building with room to stand well inside it and well outside it.
     var b=null;
     for(var i=0;i<B.length;i++) if(B[i].w>=140&&B[i].h>=140){ b=B[i]; break; }
     if(!b) return 'SKIP: no building big enough to stand inside';
     var inX=b.x+b.w/2, inY=b.y+b.h/2;
     var keep={x:p.x,y:p.y,hp:p.hp,downed:p.downed,ents:G2.ents.length};
     function shot(tx,ty,x0,y0){
       p.hp=100; p.downed=false; p.iv=0; p.hitFlash=0;
       __howlerHit({tx:tx,ty:ty,x0:x0,y0:y0,dmg:35});
       return 100-p.hp;
     }
     try{
       G2.ents.length=0;   // the shell also hurts bodies; this measures him alone
       // 1. HIS CASE: he is inside, the Howler is outside, the shell lands on him.
       p.x=inX; p.y=inY;
       var inside=shot(inX,inY,b.x-300,b.y-300);
       if(inside>0) bad.push('standing inside a building, a shell fired from outside still took '+inside.toFixed(1)+' health off him');
       // 2. CONTROL: the same shell in the open must still hurt, or the check
       //    would pass on a build where the Howler simply stopped working.
       // Open ground beside it, tested here against the building list rather than
       // against the game's own helper, which only exists once the fix is in.
       function _inRect(r,x,y){ return x>r.x&&x<r.x+r.w&&y>r.y&&y<r.y+r.h; }
       function _openAt(x,y){ for(var q=0;q<B.length;q++) if(_inRect(B[q],x,y)) return false; return true; }
       var ox=b.x-260, oy=b.y+b.h/2;
       if(!_openAt(ox,oy)) ox=b.x-420;
       if(!_openAt(ox,oy)) return 'SKIP: no open ground found beside this building';
       p.x=ox; p.y=oy;
       var open=shot(ox,oy,ox-300,oy-300);
       if(open<=0) bad.push('control: in the open the same shell did nothing, so the roof test proves nothing');
       // 3. A Howler that came inside with him is still a Howler.
       p.x=inX; p.y=inY;
       var within=shot(inX,inY,inX+20,inY+20);
       if(within<=0) bad.push('a shell fired from inside the same building did nothing, so the roof now shields him from everything');
       // 4. The roof covers the others under it too.
       p.x=b.x-900; p.y=b.y-900;
       var e={kind:'crawler',x:inX,y:inY,r:10,hp:100,maxhp:100};
       G2.ents.push(e);
       __howlerHit({tx:inX,ty:inY,x0:b.x-300,y0:b.y-300,dmg:35});
       if(e.hp<100) bad.push('a pillager sheltering under the same roof lost '+(100-e.hp).toFixed(1)+' health to a shell on it');
       G2.ents.length=0;
     } finally {
       p.x=keep.x; p.y=keep.y; p.hp=keep.hp; p.downed=keep.downed;
     }
     return bad.length?bad.join('; '):null; }},
  {v:'10.62',what:'a found gun takes the empty weapon slot instead of turning out the gun in hand, and with both slots full it still replaces the one asked for',
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
