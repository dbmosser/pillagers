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

if ($s.Contains("  {v:'27.72',what:")) { throw "check 27.72 is in the fixture already" }

SubRx @'
  {v:'27.71',what:
'@ @'
  {v:'27.72',what:'cloud-menus-restore-keeps-locks: a restore code brings back the stash locks and the trophies (short shapes, older shapes read too), and an older code leaves none of the replaced character ones',
   run:function(){
     if(!window.__P||typeof restoreCode!=='function'||typeof restoreRead!=='function'||typeof restoreApply!=='function'||typeof stashLocked!=='function'||typeof trophyHas!=='function'||!ITEMS.medkit||!ITEMS.scrap) return 'SKIP: no restore, locks or trophies here';
     var P2=__P(), snap=JSON.parse(JSON.stringify(P2)), bad=[], o, oC, oD, k, TG=1700000000000, TO=1700000001000;
     try{
       __topClear(); __cleanProfile();
       P2.keep={medkit:1}; P2.trophies={golden:TG,overseer:TO}; P2.credits=771144;
       o=restoreRead(restoreCode());
       if(!o) return 'SKIP: restoreRead refused a code made a moment ago';
       P2.keep={scrap:1}; P2.trophies={}; P2.credits=5;
       if(restoreApply(o)!==true) return 'SKIP: restoreApply refused a code made a moment ago';
       if(P2.credits!==771144) return 'SKIP: the code did not round-trip its credits ('+P2.credits+')';
       if(!stashLocked('medkit')) bad.push('the locked medkit came back unlocked: '+JSON.stringify(P2.keep));
       if(stashLocked('scrap')) bad.push('the replaced character lock on scrap stayed on the restored one');
       if(!trophyHas('golden')||!trophyHas('overseer')) bad.push('GOLD HUNTER and OVERSEER DOWN did not come back: '+JSON.stringify(P2.trophies));
       else if(new Date(+P2.trophies.golden).toDateString()!==new Date(TG).toDateString()) bad.push('GOLD HUNTER came back on another day: '+new Date(+P2.trophies.golden).toDateString()+' for '+new Date(TG).toDateString());
       if(!Array.isArray(o.kp)) bad.push('the code does not write the locks as a list of item ids: '+JSON.stringify(o.kp));
       if(!o.tr||!(o.tr.golden>0&&o.tr.golden<1e7)) bad.push('the code does not write a trophy as a day number: '+JSON.stringify(o.tr));
       oD=JSON.parse(JSON.stringify(o)); oD.kp={medkit:1}; oD.tr={golden:TG};
       P2.keep={}; P2.trophies={};
       if(restoreApply(oD)!==true) return 'SKIP: restoreApply refused the longer shapes';
       if(!stashLocked('medkit')) bad.push('a code with the locks as an object lost them');
       if((+P2.trophies.golden)!==TG) bad.push('a code with a trophy time in ms did not keep it: '+JSON.stringify(P2.trophies));
       oC=JSON.parse(JSON.stringify(o)); delete oC.kp; delete oC.tr;
       P2.keep={scrap:1}; P2.trophies={golden:5};
       if(restoreApply(oC)!==true) return 'SKIP: restoreApply refused an older code';
       if(stashLocked('scrap')) bad.push('an older code kept the replaced character lock');
       if(trophyHas('golden')) bad.push('an older code kept the replaced character GOLD HUNTER');
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{
       try{ for(k in P2) if(!(k in snap)) delete P2[k]; for(k in snap) P2[k]=snap[k]; saveProfile(); }catch(_r){}
       try{ __topClear(); __cleanProfile(); }catch(_c){}
     }
     return bad.length?bad.join('; '):null; }},
  {v:'27.71',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
