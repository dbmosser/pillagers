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

SubRx @'
  {v:'13.92',what:
'@ @'
  {v:'13.93',what:'killing a ghost does not blame a stranger: the imported ghost killed by the player writes no kill onto any identity in the pillager list, while an ordinary pillager killed the same way does (contracts, notoriety and waves audit 2026-09-14, finding 2)',
   run:function(){
     if(!(window.__deploy&&window.__state&&window.__endRaid&&window.__P)) return 'SKIP: this fixture cannot deploy';
     if(typeof applyGhost!=='function'||typeof updateEnts!=='function'||typeof IDENTITIES==='undefined') return 'SKIP: no ghosts or ledger in this build';
     var bad=[], P2=__P(), keep={gh:P2.ghost,riv:JSON.stringify(P2.rivals||{})};
     function listKills(){ var t=0, r=P2.rivals||{}; for(var i=0;i<IDENTITIES.length;i++){ var q=r[IDENTITIES[i].id]; if(q&&q.kills) t+=q.kills; } return t; }
     function fell(e){ e.hp=0; e.byPlayer=true; e.downed=0; for(var f=0;f<3&&G&&!G.over;f++) updateEnts(0.016); }
     try{
       __topClear(); __runPrep(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       P2.ghost={tag:'PROBE_GHOST_NINE',wep:'pistol',rate:10}; P2.rivals={};
       __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       var g=__state(), p=g.player;
       if(!g||!p) return 'SKIP: no live raid';
       CFG.raiderDown=0;
       var gh=null, k;
       for(k=0;k<g.ents.length;k++) if(g.ents[k].ghost){ gh=g.ents[k]; break; }
       if(!gh){ applyGhost(); for(k=0;k<g.ents.length;k++) if(g.ents[k].ghost){ gh=g.ents[k]; break; } }
       if(!gh) return 'SKIP: no ghost was placed in the raid';
       p.iv=99; p.x=gh.x+2000; p.y=gh.y+2000;
       // THE FINDING: the player kills the ghost.
       fell(gh);
       if(g.ents.indexOf(gh)>=0&&gh.hp>0) return 'SKIP: the ghost did not die on the staged kill';
       var afterGhost=listKills();
       if(afterGhost>0) bad.push('killing the ghost wrote '+afterGhost+' kill(s) onto the record of a pillager identity the player never saw');
       // CONTROL: an ordinary pillager killed the same way records a kill.
       var R=null;
       for(k=0;k<g.ents.length;k++){ var e=g.ents[k]; if(e.kind==='raider'&&!e.ghost&&!e.merc&&e.hp>0&&IDENTITIES.some(function(x){return x.id===e.ident;})){ R=e; break; } }
       if(R){
         var before=listKills();
         fell(R);
         if(!(listKills()>before)) bad.push('control: killing an ordinary pillager recorded no kill on his identity, so this check cannot see a ledger write');
       }
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{
       try{ P2.ghost=keep.gh; P2.rivals=JSON.parse(keep.riv); saveProfile(); }catch(_s){}
       try{ var g2=__state(); if(g2){ if(g2.player) g2.player.iv=0; if(!g2.over) __endRaid('abandon'); } }catch(_e){}
       __topClear(); __resetCfg(); __cleanProfile();
     }
     return bad.length?bad.join('; '):null; }},
  {v:'13.92',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
