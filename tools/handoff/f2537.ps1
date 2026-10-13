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

if ($s.Contains("  {v:'25.37',what:")) { throw "check 25.37 is in the fixture already" }

SubRx @'
  {v:'25.36',what:
'@ @'
  {v:'25.37',what:'his answer (2026-10-12): CAREER waves are the same as the DEMO waves; a wave in a CAREER raid lands near him with the DEMO kinds, counts in the raid store, draws nothing from the seeded stream, and a wave pillager kill files no grudge in his save',
   run:function(){
     if(!(window.__deploy&&window.__state&&window.__runPrep&&window.__ents&&window.__endRaid)) return 'SKIP: this fixture cannot deploy';
     if(typeof arcadeWaveTick!=='function'||typeof ARCADE!=='object') return 'SKIP: no waves here';
     var bad=[], g, p, i, e, n0, made=0, c0=(typeof CAREER_ON==='number')?CAREER_ON:0, riv0=null, wn0=ARCADE.waveN|0, wv=[], rk, base, k0;
     try{
       __topClear(); __runPrep();
       riv0=JSON.stringify(P.rivals||{});
       CAREER_ON=1;
       __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       g=__state(); if(!g||g.over) return 'SKIP: no live raid';
       if(!g.career||!g.cs) return 'SKIP: no CAREER raid in this build';
       p=g.player; n0=g.ents.length;
       g.cs.s=9000;   // tier 2: crawlers, sentries and raiders
       for(i=0;i<40&&!made;i++){ g.cs.waveT=999; made=arcadeWaveTick(0.016); }
       if(!made) bad.push('no wave landed in a CAREER raid in 40 tries');
       for(i=0;i<g.ents.length;i++) if(g.ents[i]&&g.ents[i].arcWave) wv.push(g.ents[i]);
       if(made&&wv.length!==made) bad.push('the wave made '+made+' but '+wv.length+' bodies carry the wave flag');
       if(made&&(g.cs.waveN|0)!==1) bad.push('the CAREER wave count is '+g.cs.waveN+', not 1');
       if((ARCADE.waveN|0)!==wn0) bad.push('a CAREER wave moved the DEMO wave count');
       // a wave pillager killed by him files nothing
       rk=null; for(i=0;i<wv.length;i++) if(wv[i].kind==='raider'){ rk=wv[i]; break; }
       if(!rk&&typeof arcadeWaveRaider==='function'){ rk=arcadeWaveRaider(p.x+400,p.y); rk.arcWave=1; g.ents.push(rk); }
       if(rk){
         if(String(rk.ident).indexOf('_c'+'w')<0) bad.push('a CAREER wave pillager carries a real identity ('+rk.ident+')');
         base=String(rk.ident).split('_c'+'w')[0]; k0=(P.rivals&&P.rivals[base])?(P.rivals[base].kills|0):0;
         rk.byPlayer=1; rk.hp=0; rk.downed=0; rk.finished=1; for(i=0;i<4&&g.ents.indexOf(rk)>=0;i++) __ents(0.016);
         if(g.ents.indexOf(rk)>=0) bad.push('the wave pillager did not die');
         if(Object.keys(P.rivals||{}).some(function(k){ return k.indexOf('_c'+'w')>=0; })) bad.push('a CAREER wave pillager was filed in his grudge ledger');
         if(((P.rivals&&P.rivals[base])?(P.rivals[base].kills|0):0)!==k0) bad.push('a CAREER wave pillager kill counted as a kill of '+base+' in his grudge ledger');
       }
     }catch(x){ bad.push('threw: '+(x&&x.message||x)); }
     finally{ try{ CAREER_ON=c0; }catch(_r){} try{ if(riv0!==null) P.rivals=JSON.parse(riv0); }catch(_rv){} try{ ARCADE.waveN=wn0; }catch(_w){} try{ var g2=__state(); if(g2&&!g2.over) __endRaid('abandon'); }catch(_e){} __topClear(); }
     return bad.length?bad.join('; '):null; }},
  {v:'25.36',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
