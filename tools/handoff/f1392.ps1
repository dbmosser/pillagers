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
  {v:'13.91',what:
'@ @'
  {v:'13.92',what:'your hire is not also a stranger on the map: across sixteen seeds with a hire, no pillager other than the hire carries his identity, while the same seeds with no hire do put that identity on the map (contracts, notoriety and waves audit 2026-09-14, finding 1)',
   run:function(){
     if(!(window.__deploy&&window.__state&&window.__endRaid&&window.__P)) return 'SKIP: this fixture cannot deploy';
     if(typeof IDENTITIES==='undefined'||!IDENTITIES.length) return 'SKIP: no pillager identities in this build';
     var bad=[], P2=__P(), keep={merc:P2.merc,riv:JSON.stringify(P2.rivals||{})};
     var ID=null, SEEDS=[], i;
     for(i=1;i<=16;i++) SEEDS.push(i*977);
     function eid(e){ return (e.ident&&e.ident.id)||e.ident; }
     function scan(id,hired){
       var stranger=0, hire=0;
       for(var si=0;si<SEEDS.length;si++){
         __topClear(); __runPrep(); __resetCfg(); __pinDefaults(0); __cleanProfile();
         P2.merc=hired?id:null; P2.rivals={};
         __deploy({kit:[],safe:null,mapIx:0,seed:SEEDS[si]});
         var g=__state(); if(!g) continue;
         for(var k=0;k<g.ents.length;k++){ var e=g.ents[k]; if(e.kind!=='raider'||eid(e)!==id) continue; if(e.merc) hire++; else stranger++; }
         if(!g.over) __endRaid('abandon');
       }
       return {stranger:stranger,hire:hire};
     }
     try{
       // Pick the identity that most often appears as a stranger with no hire, so the control has teeth.
       var best=-1;
       for(i=0;i<Math.min(6,IDENTITIES.length);i++){ var r0=scan(IDENTITIES[i].id,false); if(r0.stranger>best){ best=r0.stranger; ID=IDENTITIES[i].id; } }
       // CONTROL: with no hire, that identity walks the map as a stranger on some seeds.
       if(!(best>0)) return 'SKIP: none of the first identities appeared on these seeds, so there is nothing to measure';
       // THE FINDING: hire him, and no stranger carries his identity.
       var A=scan(ID,true);
       if(!(A.hire>0)) return 'SKIP: the hired identity never spawned as the hire on these seeds';
       if(A.stranger>0) bad.push('with '+ID+' hired, '+A.stranger+' strangers across '+SEEDS.length+' seeds also carried his identity');
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{
       try{ P2.merc=keep.merc; P2.rivals=JSON.parse(keep.riv); saveProfile(); }catch(_s){}
       try{ var g2=__state(); if(g2&&!g2.over) __endRaid('abandon'); }catch(_e){}
       __topClear(); __resetCfg(); __cleanProfile();
     }
     return bad.length?bad.join('; '):null; }},
  {v:'13.91',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
