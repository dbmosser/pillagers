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
  {v:'15.21',what:
'@ @'
  {v:'15.22',what:'the hire is never also a stranger: on THE COLD MILE at Standard, with no hire one stranger wears a given identity, and with that identity hired no stranger wears it (hire audit)',
   run:function(){
     if(!(window.__deploy&&window.__state&&window.__endRaid&&window.__applyLoaded)||typeof FIXED_MAPS==='undefined'||typeof IDENTITIES==='undefined'||!IDENTITIES.length) return 'SKIP: this fixture cannot deploy';
     var mi=-1; for(var i=0;i<FIXED_MAPS.length;i++) if(FIXED_MAPS[i].id==='mile') mi=i;
     if(mi<0) return 'SKIP: no COLD MILE in this build';
     var id=IDENTITIES[Math.min(3,IDENTITIES.length-1)].id, bad=[], snap=null, keepN=CFG.nRaider;
     function probe(merc){
       __topClear(); __runPrep(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       __P().merc=merc; CFG.nRaider=10;
       __deploy({kit:[],safe:null,mapIx:mi,seed:4242});
       var g=__state(), R=(g&&g.roster)||[], str=0, dup=0;
       for(var j=0;j<R.length;j++){ if(R[j].merc) continue; str++; if(R[j].ref&&R[j].ref.ident===id) dup++; }
       try{ if(g&&!g.over) __endRaid('abandon'); }catch(_e){}
       return {str:str,dup:dup};
     }
     try{
       snap=JSON.parse(JSON.stringify(__P()));
       // CONTROL: with no hire, THE COLD MILE at Standard draws more strangers than there are names, and one wears that identity.
       var a=probe(null);
       if(a.str<=IDENTITIES.length) return 'SKIP: THE COLD MILE drew '+a.str+' strangers at Standard here, not more than the '+IDENTITIES.length+' names';
       if(a.dup!==1) return 'SKIP: with no hire '+a.dup+' strangers wore the identity the check follows';
       var b=probe(id);
       if(b.dup>0) bad.push('with '+id+' hired, '+b.dup+' of '+b.str+' strangers on THE COLD MILE wear his identity, and killing one makes him refuse to work');
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{ CFG.nRaider=keepN; try{ if(snap) __applyLoaded(snap); }catch(_r){} try{ __topClear(); __resetCfg(); __cleanProfile(); }catch(_c){} }
     return bad.length?bad.join('; '):null; }},
  {v:'15.21',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
