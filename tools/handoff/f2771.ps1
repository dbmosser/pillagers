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

if ($s.Contains("  {v:'27.71',what:")) { throw "check 27.71 is in the fixture already" }

SubRx @'
  {v:'27.70',what:
'@ @'
  {v:'27.71',what:'cloud-menus-restore-keeps-codex: a restore code brings back the ARMORY codex and the kills with each gun in one field, and leaves none of the replaced character ones',
   run:function(){
     if(!window.__P||typeof restoreCode!=='function'||typeof restoreRead!=='function'||typeof restoreApply!=='function'||typeof codexGuns!=='function'||typeof codexHas!=='function') return 'SKIP: no restore or codex here';
     var L=codexGuns(); if(L.length<3) return 'SKIP: fewer than three codex guns';
     var P2=__P(), snap=JSON.parse(JSON.stringify(P2)), bad=[], o, oC, k, A=L[0], B=L[1], C=L[2], T=1700000000000;
     try{
       __topClear(); __cleanProfile();
       P2.codex={}; P2.codex[A]=T; P2.codex[B]=T+1; P2.gunKills={}; P2.gunKills[A]=120; P2.credits=771144;
       o=restoreRead(restoreCode());
       if(!o) return 'SKIP: restoreRead refused a code made a moment ago';
       if('cx' in o) bad.push('the code still writes a separate codex list (cx)');
       P2.codex={}; P2.codex[C]=T; P2.gunKills={}; P2.gunKills[C]=150; P2.credits=5;
       if(restoreApply(o)!==true) return 'SKIP: restoreApply refused a code made a moment ago';
       if(P2.credits!==771144) return 'SKIP: the code did not round-trip its credits ('+P2.credits+')';
       if(!codexHas(A)||!codexHas(B)) bad.push('the coded codex entries did not come back: '+JSON.stringify(P2.codex));
       if(codexHas(C)) bad.push('the replaced character codex entry '+C+' stayed on the restored one');
       if(!P2.gunKills||(+P2.gunKills[A])!==120) bad.push('the coded 120 kills with '+A+' did not come back: '+JSON.stringify(P2.gunKills));
       if(P2.gunKills&&(B in P2.gunKills)) bad.push('a found gun with no kills ('+B+') came back with a kill entry: '+JSON.stringify(P2.gunKills));
       if(P2.gunKills&&P2.gunKills[C]) bad.push('the replaced character kills with '+C+' stayed on the restored one');
       oC=JSON.parse(JSON.stringify(o)); delete oC.gk;
       P2.codex={}; P2.codex[C]=T; P2.gunKills={}; P2.gunKills[C]=150;
       if(restoreApply(oC)!==true) return 'SKIP: restoreApply refused an older code';
       if(codexHas(C)) bad.push('an older code kept the replaced character codex entry');
       if(P2.gunKills&&P2.gunKills[C]) bad.push('an older code kept the replaced character gun kills');
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{
       try{ for(k in P2) if(!(k in snap)) delete P2[k]; for(k in snap) P2[k]=snap[k]; saveProfile(); }catch(_r){}
       try{ __topClear(); __cleanProfile(); }catch(_c){}
     }
     return bad.length?bad.join('; '):null; }},
  {v:'27.70',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
