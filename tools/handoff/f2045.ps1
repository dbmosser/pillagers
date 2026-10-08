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

if ($s.Contains("  {v:'20.45',what:")) { throw "check 20.45 is in the fixture already" }

SubRx @'
  {v:'20.44',what:
'@ @'
  {v:'20.45',what:'ending a same machine party puts the sound back in both speakers: with player 1 panned hard left by SPLIT SPEAKERS, ending the party leaves the pan in the middle and the master gain at 1',
   run:function(){
     if(typeof NET!=='object'||!NET||typeof netSameStop!=='function'||typeof netSndApply!=='function'||typeof netSndWho!=='function'||typeof netSndSplitOn!=='function') return 'SKIP: no same machine party sound here';
     var NK={}, k, bad=[], oWho=netSndWho, oSplit=netSndSplitOn, gN={gain:{value:1}}, pN={pan:{value:0}};
     for(k in NET) NK[k]=NET[k];
     try{
       // A same machine party, this window player 1, world sound in both windows and SPLIT SPEAKERS on, read through stand-ins
       // so the shared setting in the browser is never written.
       NET.bc=null; NET.same='host'; NET.pair='zq7731'; NET.mode='coop';
       NET.sndG=gN; NET.sndP=pN; NET.sndAc=null;
       netSndWho=function(){ return 'both'; };
       netSndSplitOn=function(){ return !!NET.same; };
       netSndApply();
       if(Math.abs(pN.pan.value+1)>0.01) return 'SKIP: staging: SPLIT SPEAKERS did not pan player 1 to the left here ('+pN.pan.value+')';
       gN.gain.value=0.37;
       netSameStop();
       if(NET.same) return 'SKIP: ending the party left this window in it';
       if(Math.abs(pN.pan.value)>0.01) bad.push('after the party ended every sound is still panned to '+pN.pan.value+' (minus 1 is the left speaker only)');
       if(Math.abs(gN.gain.value-1)>0.01) bad.push('after the party ended the master gain is '+gN.gain.value+', not 1');
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{
       netSndWho=oWho; netSndSplitOn=oSplit;
       for(k in NET) if(!(k in NK)) delete NET[k];
       for(k in NK) NET[k]=NK[k];
     }
     return bad.length?bad.join('; '):null; }},
  {v:'20.44',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
