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

if ($s.Contains("  {v:'21.70',what:")) { throw "check 21.70 is in the fixture already" }

SubRx @'
  {v:'21.69',what:
'@ @'
  {v:'21.70',what:'your hire takes no pile you dropped: on FOLLOW and on LOOT he passes a dropped Medkit by, and still takes the same box when it is not a dropped one',
   run:function(){
     if(!window.__deploy||!window.__endRaid||!window.__identityIds||typeof NET!=='object'||!NET||typeof updateEnts!=='function'||typeof dropItem!=='function') return 'SKIP: no raid or hire in this fixture';
     var ids=__identityIds(), NK={}, k, bad=[], M=null, i, pile=null, E0=null, C0=null, n0, p, oSay=say, m0=P.merc, mo0=P.mercOut;
     if(!ids.length) return 'SKIP: no man to hire';
     function step(order){
       M.x=p.x; M.y=p.y; M.mgoal=null; M.mlootT=0; M.goal=null; M.lootT=0; M.goalT=0; M.skips=null; M.state='loot'; M.downed=false; M.path=null; M.pathFail=false;
       G.mercOrder=order; G.ents=[M]; G.containers=[pile];
       try{ updateEnts(0.016); } finally{ G.ents=E0; G.containers=C0; }
     }
     for(k in NET) NK[k]=NET[k];
     try{
       NET.on=false; NET.role=null; NET.peers=[];
       __topClear(); __runPrep(); __cleanProfile();
       P.merc=ids[0];
       __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       if(!G||G.over||!G.player) return 'SKIP: staging: no raid';
       say=function(){};
       for(i=0;i<G.ents.length;i++){ var e=G.ents[i]; if(e.kind==='raider'&&e.merc&&!e.downed){ M=e; break; } }
       if(!M) return 'SKIP: staging: the hire did not come up';
       p=G.player; n0=G.containers.length;
       G.bag.push('medkit'); dropItem(G.bag.length-1);
       if(G.containers.length!==n0+1) return 'SKIP: staging: the drop made no pile';
       pile=G.containers[G.containers.length-1];
       if(!pile.dropped||pile.opened) return 'SKIP: staging: the new pile is not marked as dropped';
       E0=G.ents; C0=G.containers;
       pile.dropped=0; step('follow');
       if(M.mgoal!==pile) return 'SKIP: staging: on FOLLOW the hire took no box at all';
       pile.dropped=1; step('follow');
       if(M.mgoal===pile) bad.push('on FOLLOW the hire walks over to take the Medkit you dropped');
       pile.dropped=0; step('loot');
       if(M.goal!==pile) return 'SKIP: staging: on LOOT the hire took no box at all';
       pile.dropped=1; step('loot');
       if(M.goal===pile) bad.push('on LOOT the hire goes for the Medkit you dropped');
       if(pile.opened) bad.push('the dropped pile was emptied');
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{
       say=oSay;
       try{ if(E0) G.ents=E0; if(C0) G.containers=C0; }catch(_r){}
       for(k in NET) if(!(k in NK)) delete NET[k];
       for(k in NK) NET[k]=NK[k];
       try{ if(G&&!G.over){ G.player.downed=false; __endRaid('abandon'); } }catch(_e){}
       try{ P.merc=m0; if(mo0===undefined) delete P.mercOut; else P.mercOut=mo0; saveProfile(); }catch(_m){}
       __topClear(); __cleanProfile();
     }
     return bad.length?bad.join('; '):null; }},
  {v:'21.69',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
