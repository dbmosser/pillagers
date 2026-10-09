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

if ($s.Contains("  {v:'20.72',what:")) { throw "check 20.72 is in the fixture already" }

SubRx @'
  {v:'20.71',what:
'@ @'
  {v:'20.72',what:'a restore code carries the achievements: a code made by a character with LIFER, MACHINE BREAKER and 143 machines gives them back, and a code with none pasted over a character who has them leaves none and never rescans the old run log',
   run:function(){
     if(!window.__P||typeof restoreMake!=='function'||typeof restoreApply!=='function'||typeof ACHS==='undefined') return 'SKIP: no restore or achievements here';
     var P2=__P(), snap=JSON.parse(JSON.stringify(P2)), bad=[], oA, oB, oC, k;
     try{
       __topClear(); __cleanProfile();
       // ARM A: made by a character with achievements, pasted over one with none.
       P2.ach={vet100:12345,mach100:12346}; P2.achN={raider:7,mach:143}; P2.achScan=1; P2.credits=771133;
       oA=JSON.parse(JSON.stringify(restoreMake()));
       P2.ach={}; P2.achN={}; P2.achScan=1; P2.credits=5; P2.gambleLog=['zqxoldroll'];
       if(restoreApply(oA)!==true) return 'SKIP: restoreApply refused a code made a moment ago';
       if(P2.credits!==771133) return 'SKIP: the code did not round-trip its credits ('+P2.credits+')';
       if(!(P2.ach&&P2.ach.vet100&&P2.ach.mach100)) bad.push('a code made by a character with LIFER and MACHINE BREAKER came back with '+JSON.stringify(P2.ach));
       if(!(P2.achN&&(P2.achN.mach|0)===143&&(P2.achN.raider|0)===7)) bad.push('the lifetime kill counts came back as '+JSON.stringify(P2.achN));
       if(P2.gambleLog&&P2.gambleLog.indexOf('zqxoldroll')>=0) bad.push('the replaced character gamble history stayed on the restored one');
       // ARM B: made with none, pasted over a character who has them.
       P2.ach={}; P2.achN={}; P2.achScan=1; P2.credits=662244;
       oB=JSON.parse(JSON.stringify(restoreMake()));
       P2.ach={vet25:1,vet100:2,mach100:3}; P2.achN={raider:30,mach:140}; P2.achScan=1; P2.credits=6;
       if(restoreApply(oB)!==true) return 'SKIP: restoreApply refused the second code';
       if(P2.credits!==662244) return 'SKIP: the second code did not round-trip its credits ('+P2.credits+')';
       if(P2.ach&&(P2.ach.vet25||P2.ach.vet100||P2.ach.mach100)) bad.push('a code with no achievements kept the replaced character ones: '+JSON.stringify(P2.ach));
       if(P2.achN&&((P2.achN.mach|0)||(P2.achN.raider|0))) bad.push('a code with no kills kept the replaced character lifetime counts: '+JSON.stringify(P2.achN));
       // ARM C: an older code with no achievement fields, over a character with a log scan still to come.
       oC=JSON.parse(JSON.stringify(oB)); delete oC.ac; delete oC.an;
       P2.ach={vet100:2}; P2.achN={mach:140}; P2.achScan=0;
       if(restoreApply(oC)!==true) return 'SKIP: restoreApply refused an older code';
       if(P2.ach&&P2.ach.vet100) bad.push('an older code kept the replaced character LIFER');
       if(!P2.achScan) bad.push('after a restore the Mainframe would count the replaced character run log as the restored one');
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{
       try{ for(k in P2) if(!(k in snap)) delete P2[k]; for(k in snap) P2[k]=snap[k]; saveProfile(); }catch(_r){}
       try{ __topClear(); __cleanProfile(); }catch(_c){}
     }
     return bad.length?bad.join('; '):null; }},
  {v:'20.71',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
