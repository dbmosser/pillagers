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

if ($s.Contains("  {v:'20.64',what:")) { throw "check 20.64 is in the fixture already" }

SubRx @'
  {v:'20.63',what:
'@ @'
  {v:'20.64',what:'a Crier alarm leaves a pillager who is running for the ring running and gives your hire no orders, while a looting man beside them still answers it',
   run:function(){
     if(!window.__deploy||!window.__endRaid||typeof updateEnts!=='function'||typeof dist!=='function') return 'SKIP: no raid in this fixture';
     var NK={}, k, bad=[], g, p, i, q, S=null, R=null, M=null, C=null, keepM=null;
     for(k in NET) NK[k]=NET[k];
     function okR(q){ return q.kind==='raider'&&!q.merc&&!q.friendlyPC&&!q.downed&&!q.finished&&!q.neutral&&q.hp>0; }
     try{
       NET.on=false; NET.role=null; NET.peers=[];
       __topClear(); __runPrep(); __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       g=__state(); if(!g||g.over||!g.player||!g.ents) return 'SKIP: no live raid';
       p=g.player;
       for(i=0;i<g.ents.length;i++){ q=g.ents[i]; if(!S&&q.kind==='snitch'&&!q.downed&&q.hp>0) S=q; }
       for(i=0;i<g.ents.length;i++){ q=g.ents[i]; if(!R&&okR(q)&&dist(q,p)>1800) R=q; }
       if(!S||!R) return 'SKIP: staging: no Crier, or no pillager far from you';
       for(i=0;i<g.ents.length;i++){ q=g.ents[i]; if(q===R||!okR(q)) continue; if(!M) M=q; else if(!C){ C=q; break; } }
       if(!M||!C) return 'SKIP: staging: fewer than three pillagers';
       keepM={merc:M.merc,hostile:M.hostile,friendly:M.friendly};
       g.lightning=0;
       R.state='extract'; R.alert=0; R.hostile=false;
       M.x=R.x; M.y=R.y+36; M.crew=R.crew; M.merc=1; M.hostile=false; M.friendly=1; M.state='loot'; M.alert=0;
       C.x=R.x; C.y=R.y-36; C.crew=R.crew; C.hostile=false; C.state='loot'; C.alert=0;
       S.x=R.x-60; S.y=R.y; S.state='alarm'; S.wind=0.001; S.lost=0; S.markSeat=0; S.markX=R.x+250; S.markY=R.y;
       if(dist(S,p)<1600) return 'SKIP: staging: the Crier is in sight of you';
       updateEnts(0.016);
       if(S.wind!==null) return 'SKIP: staging: the Crier alarm did not go off here ('+S.state+', '+S.wind+')';
       if(!(C.alert>2.3)) return 'SKIP: staging: a looting man beside them never answered the alarm (alert '+C.alert+')';
       if(R.state!=='extract') bad.push('a pillager running for the ring was turned back to the alarm mark ('+R.state+')');
       if(M.alert>2.3) bad.push('the alarm gave your hire its orders (alert '+(+M.alert).toFixed(2)+')');
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{
       try{ if(M&&keepM){ M.merc=keepM.merc; M.hostile=keepM.hostile; M.friendly=keepM.friendly; } }catch(_m){}
       for(k in NET) if(!(k in NK)) delete NET[k];
       for(k in NK) NET[k]=NK[k];
       try{ var g2=__state(); if(g2&&!g2.over){ g2.player.downed=false; __endRaid('abandon'); } }catch(_e){}
       __topClear();
     }
     return bad.length?bad.join('; '):null; }},
  {v:'20.63',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
