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

# v12.55 CHECK, inserted before the v12.54 entry. The imported gun is the
# Longshot, which is not in the pool a pillager body can roll, so the range it
# implies can only have come from the import. The control is the same import
# with the gun the body already carries: nothing may move, which is what
# separates carrying the range with the gun from simply rewriting the range.
SubRx @'
  {v:'12.54',what:'a pillager calling extraction throws away the figure the siege is sized from, so it is read again from the bag actually being carried instead of keeping whatever an earlier call at that point left behind (2026-09-07 audit)',
'@ @'
  {v:'12.55',what:'an imported ghost carries his engagement range and his damage with the gun he is handed, instead of keeping the range of the body he arrived in; a ghost handed the gun that body already carries is left exactly as he was (2026-09-07 audit)',
   run:function(){
     if(!(window.__deploy&&window.__state&&window.__endRaid&&window.__P)) return 'SKIP: this fixture cannot deploy a raid';
     if(typeof applyGhost!=='function') return 'SKIP: this build has no ghost to import';
     if(!(WEAPONS&&WEAPONS.sniper&&WEAPONS.sniper.mag)) return 'SKIP: this build has no Longshot to hand him';
     var bad=[], P2=__P(), keepGhost=P2.ghost;
     function body(){
       __topClear(); __runPrep(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       P2.ghost=null;
       __deploy({kit:[],mapIx:0,seed:4242});
       var g=__state(); if(!g) return null;
       var i, e=null;
       for(i=0;i<g.ents.length&&!e;i++) if(g.ents[i].kind==='raider'&&!g.ents[i].merc) e=g.ents[i];
       if(!e) return {none:'no pillager on this map and seed to import a ghost onto'};
       return {g:g,e:e,wep:(e.wep&&e.wep.id)||null,rng:e.rng,dmg:e.dmg};
     }
     function importAs(st,gun){
       P2.ghost={tag:'GHOST SEVEN',wep:gun,rate:10};
       applyGhost();
       var e=st.e;
       return {ghost:!!e.ghost,wep:(e.wep&&e.wep.id)||null,rng:e.rng,dmg:e.dmg};
     }
     try{
       // THE FINDING: a gun the body cannot have rolled, so the range it implies
       // can only have come from the import.
       var A=body();
       if(!A) return 'SKIP: no live raid to import into';
       if(A.none) return 'SKIP: '+A.none;
       if(A.wep==='sniper') return 'SKIP: the pillager this seed built already carries the Longshot, so the import would change nothing to measure';
       var R=importAs(A,'sniper');
       if(!R.ghost) return 'SKIP: the ghost was not imported onto that pillager, so there is nothing here to read';
       if(R.wep!=='sniper') return 'SKIP: the import did not hand him the Longshot at all, so the range cannot be read against it';
       var wantR=Math.min(WEAPONS.sniper.rng*0.72,580);
       if(Math.abs(R.rng-wantR)>0.5)
         bad.push('the imported ghost was handed a Longshot and kept the engagement range of the body he arrived in: he opens fire at '+Math.round(R.rng)+' units with a gun whose rounds die at '+Math.round(WEAPONS.sniper.rng)+', instead of the '+Math.round(wantR)+' the gun is worth');
       if(Math.abs(R.dmg-WEAPONS.sniper.dmg)>0.5)
         bad.push('the imported ghost was handed a Longshot and kept the damage of the body he arrived in ('+R.dmg+' against the gun'+String.fromCharCode(39)+'s '+WEAPONS.sniper.dmg+')');
       // CONTROL: the same import, with the gun the body ALREADY carries. Nothing
       // may move, which is what separates carrying the range with the gun from
       // simply rewriting the range for every ghost.
       var B=body();
       if(B&&!B.none&&B.wep){
         var C=importAs(B,B.wep);
         if(Math.abs(C.rng-B.rng)>0.5) bad.push('control: importing a ghost carrying the gun the body already had moved his engagement range from '+Math.round(B.rng)+' to '+Math.round(C.rng)+', so the range is being rewritten rather than carried with the gun');
         if(Math.abs(C.dmg-B.dmg)>0.5) bad.push('control: importing a ghost carrying the gun the body already had moved his damage from '+B.dmg+' to '+C.dmg);
       }
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{
       try{ P2.ghost=keepGhost; }catch(_p){}
       try{ var g2=__state(); if(g2&&!g2.over) __endRaid('abandon'); }catch(_e){}
       __topClear(); __resetCfg(); __cleanProfile();
     }
     return bad.length?bad.join('; '):null; }},
  {v:'12.54',what:'a pillager calling extraction throws away the figure the siege is sized from, so it is read again from the bag actually being carried instead of keeping whatever an earlier call at that point left behind (2026-09-07 audit)',
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
