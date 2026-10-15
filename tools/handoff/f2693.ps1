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

if ($s.Contains("  {v:'26.93',what:")) { throw "check 26.93 is in the fixture already" }

SubRx @'
  {v:'26.92',what:
'@ @'
  {v:'26.93',what:'party6, his yes to the party seed (38): NEW PARTY locks a seed and the sector, every demo run after it builds the same raid, a seed passed in still wins, it ends after 12 hours, and the board page names a seeded night',
   run:function(){
     if(typeof arcadeDeploy!=='function'||typeof ARCADE!=='object'||typeof ARCADE_PARTY_KEY!=='string') return 'SKIP: no arcade here';
     if(typeof arcadePartySeed!=='function'||typeof arcadeNewParty!=='function') return 'there is no party seed in this build';
     var bad=[], PK=ARCADE_PARTY_KEY, pk=null, hadK=false, seeds=[], sigs=[], i, g, sd, pg, txt, oMap=ARCADE.mapIx, now=Date.now(), s1;
     function sig(){ var q=__state(), s=0, k; if(!q||!q.containers) return 'none'; for(k=0;k<q.containers.length;k++) s+=Math.round(q.containers[k].x)+Math.round(q.containers[k].y); return q.containers.length+':'+s; }
     try{
       __topClear(); __runPrep();
       if(ARCADE.on) return 'SKIP: the arcade is on after __topClear';
       pk=localStorage.getItem(PK); hadK=true; localStorage.removeItem(PK);
       // ONE: with no party there is no party seed
       if(arcadePartySeed()!==0) bad.push('ONE: a seed with no party');
       if(arcadePartyCode()!=='') bad.push('ONE: a code with no party');
       // TWO: NEW PARTY locks one
       if(!arcadeNewParty()) bad.push('TWO: NEW PARTY failed');
       sd=arcadePartySeed();
       if(!(sd>0)) bad.push('TWO: NEW PARTY left no seed');
       if(!(arcadePartyAt()>0)) bad.push('TWO: NEW PARTY left no start time');
       if(arcadePartyCode().length!==4) bad.push('TWO: the party code is "'+arcadePartyCode()+'"');
       // THREE: every run of the night builds the same raid, and a run with no party does not
       for(i=0;i<2;i++){
         if(!arcadeDeploy({role:'host'})){ bad.push('THREE: no raid was built'); break; }
         g=__state(); seeds.push(g.seed>>>0); sigs.push(sig());
       }
       if(seeds.length===2){
         if(seeds[0]!==sd||seeds[1]!==sd) bad.push('THREE: the runs used seeds '+seeds.join(',')+', not the party seed '+sd);
         if(sigs[0]!==sigs[1]) bad.push('THREE: the two runs built different raids ('+sigs.join(' / ')+')');
       }
       localStorage.removeItem(PK);
       if(arcadeDeploy({role:'host'})){ s1=__state().seed>>>0; if(s1===sd) bad.push('THREE: a run with no party used the old party seed'); }
       // FOUR: a seed passed in still wins
       arcadeNewParty();
       if(arcadeDeploy({role:'host',seed:4242})){ if((__state().seed>>>0)!==4242) bad.push('FOUR: a seed passed in lost to the party seed ('+(__state().seed>>>0)+')'); }
       // FIVE: the sector is the party sector
       if(FIXED_MAPS.length>1){
         localStorage.setItem(PK,JSON.stringify({t:Date.now(),s:777,m:1})); ARCADE.mapIx=0;
         if(arcadeDeploy({role:'host'})){ if(P.mapIx!==1) bad.push('FIVE: the run used sector '+P.mapIx+', not the party sector 1'); }
       }
       // SIX: a night is 12 hours
       localStorage.setItem(PK,JSON.stringify({t:Date.now()-13*3600000,s:777,m:0}));
       if(arcadePartySeed()!==0) bad.push('SIX: a party 13 hours old still locks its seed');
       localStorage.setItem(PK,String(Date.now()));
       if(arcadePartySeed()!==0) bad.push('SIX: an old record with only a time locked a seed');
       if(!(arcadePartyAt()>0)) bad.push('SIX: an old record with only a time stopped reading as a party start');
       // SEVEN: the board page names a seeded night, and only then
       localStorage.removeItem(PK); pg=document.createElement('div'); arcadeAttBoard(pg); txt=pg.textContent;
       if(txt.indexOf('SEEDED'+' NIGHT')>=0) bad.push('SEVEN: the board named a seeded night with no party');
       arcadeNewParty(); pg=document.createElement('div'); arcadeAttBoard(pg); txt=pg.textContent;
       if(txt.indexOf('SEEDED'+' NIGHT')<0) bad.push('SEVEN: the board did not name the seeded night');
       else if(txt.indexOf(arcadePartyCode())<0) bad.push('SEVEN: the board did not show the seed code');
     }catch(x){ bad.push('threw: '+(x&&x.message||x)); }
     finally{
       try{ if(hadK){ if(pk===null) localStorage.removeItem(PK); else localStorage.setItem(PK,pk); } }catch(_rb){}
       try{ ARCADE.mapIx=oMap; }catch(_m){}
       keys={};
       try{ if(typeof ARCADE==='object'&&ARCADE.on) arcadeLeave(); }catch(_l){}
       try{ if(__state()&&!__state().over) __endRaid('abandon'); }catch(_e){}
       try{ if(typeof ARCADE==='object'){ ARCADE.mine=0; ARCADE.waveT=0; ARCADE.holdT=0; } }catch(_h){}
       __topClear();
     }
     return bad.length?bad.slice(0,8).join('; '):null; }},
  {v:'26.92',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
