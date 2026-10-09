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

if ($s.Contains("  {v:'20.84',what:")) { throw "check 20.84 is in the fixture already" }

SubRx @'
  {v:'20.83',what:
'@ @'
  {v:'20.84',what:'the hot ground starts away from the drop point: a disc rolled onto the start is chosen again at least 920 away and inside the map, a disc rolled far away stays where it fell, and the boxes rolled after it do not move',
   run:function(){
     if(typeof buildRaid!=='function'||typeof freeSpot!=='function'||typeof FIXED_MAPS==='undefined'||typeof RNGS==='undefined') return 'SKIP: no raid builder here';
     var bad=[], oFS=freeSpot, oG=G, oMap=P.mapIx, oW=WORLD_W, oH=WORLD_H, oA=AREA, oR=RNGS, oRS=RSEED, S=7346113, g1, g2, g3, st, d2, n60=0, aim=null, far, i, c1, c2;
     function build(){ pendSeed=S; G=null; var b=buildRaid(true); G=null; return b; }
     try{
       __topClear(); __cleanProfile();
       P.mapIx=0;
       g1=build();
       if(!g1||!g1.hotZone||!g1.player||!g1.containers) return 'SKIP: staging: the build has no hot ground';
       st={x:g1.player.x,y:g1.player.y};
       freeSpot=function(m,pad){ var r=oFS(m,pad); if(pad===60&&aim&&++n60===1) return {x:aim.x,y:aim.y}; return r; };
       n60=0; aim={x:st.x+7,y:st.y+5};
       g2=build();
       if(!g2||!g2.hotZone||!g2.player) return 'SKIP: staging: the second build has no hot ground';
       if(Math.abs(g2.player.x-st.x)>0.01||Math.abs(g2.player.y-st.y)>0.01) return 'SKIP: staging: the same seed started somewhere else';
       if(n60<1) return 'SKIP: staging: the hot ground was not placed through freeSpot';
       d2=Math.hypot(g2.hotZone.x-st.x,g2.hotZone.y-st.y);
       if(d2<920) bad.push('a hot ground rolled onto the drop point stayed '+Math.round(d2)+' from it (the disc reaches 620), so the raid can start inside it');
       if(g2.hotZone.x<619.5||g2.hotZone.x>WORLD_W-619.5||g2.hotZone.y<619.5||g2.hotZone.y>WORLD_H-619.5) bad.push('the hot ground chosen again is not wholly inside the map ('+Math.round(g2.hotZone.x)+','+Math.round(g2.hotZone.y)+')');
       if(g2.containers.length!==g1.containers.length) bad.push('the boxes changed in number ('+g1.containers.length+' to '+g2.containers.length+'), so the seeded build moved');
       else for(i=0;i<g1.containers.length;i++){ c1=g1.containers[i]; c2=g2.containers[i]; if(Math.abs(c1.x-c2.x)>0.01||Math.abs(c1.y-c2.y)>0.01){ bad.push('box '+i+' moved, so the seeded build moved'); break; } }
       far={x:(st.x<WORLD_W/2)?WORLD_W-700:700,y:(st.y<WORLD_H/2)?WORLD_H-700:700};
       n60=0; aim=far;
       g3=build();
       if(!g3||!g3.hotZone) bad.push('control: the third build has no hot ground');
       else if(Math.abs(g3.hotZone.x-far.x)>0.5||Math.abs(g3.hotZone.y-far.y)>0.5) bad.push('control: a hot ground rolled far from the drop point was moved anyway, to '+Math.round(g3.hotZone.x)+','+Math.round(g3.hotZone.y));
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{
       freeSpot=oFS; G=oG; P.mapIx=oMap; pendSeed=null; WORLD_W=oW; WORLD_H=oH; AREA=oA; RNGS=oR; RSEED=oRS;
       __topClear(); __cleanProfile();
     }
     return bad.length?bad.join('; '):null; }},
  {v:'20.83',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
