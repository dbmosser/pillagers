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

if ($s.Contains("  {v:'16.29',what:")) { throw "check 16.29 is in the fixture already" }

SubRx @'
  {v:'16.28',what:
'@ @'
  {v:'16.29',what:'player 2 hears the game: with no split setting saved, a same machine pair starts split (player 2 window playing, panned right); switched off it stays off',
   run:function(){
     if(typeof NET!=='object'||!NET||typeof netSndOut!=='function'||typeof netSndSplitOn!=='function') return 'SKIP: this build has no split speakers';
     var bad=[], keep={same:NET.same,sndG:NET.sndG,sndAc:NET.sndAc,sndP:NET.sndP,sndOn:NET.sndOn}, v=null, K='salvagerun:samesound:split';
     function node(){ return {gain:{value:1},pan:{value:0},connect:function(){}}; }
     var fake={destination:{},createGain:function(){ return node(); },createStereoPanner:function(){ return node(); }};
     try{ v=localStorage.getItem(K); }catch(e){}
     try{
       try{ localStorage.removeItem(K); }catch(e){}
       NET.same='p2'; NET.sndOn=false; NET.sndG=null; NET.sndAc=null; NET.sndP=null;
       netSndOut(fake);
       if(!NET.sndP) return 'SKIP: no panner was made';
       if(NET.sndG.gain.value!==1||NET.sndP.pan.value!==1) bad.push('with nothing saved the player 2 window starts silent or unpanned (gain '+NET.sndG.gain.value+', pan '+NET.sndP.pan.value+')');
       localStorage.setItem(K,'0'); netSndApply();
       if(NET.sndG.gain.value!==0) bad.push('control: split switched off, the player 2 window with SOUND OFF still plays');
     }
     finally{
       try{ if(v===null) localStorage.removeItem(K); else localStorage.setItem(K,v); }catch(_s){}
       try{ NET.same=keep.same; NET.sndG=keep.sndG; NET.sndAc=keep.sndAc; NET.sndP=keep.sndP; NET.sndOn=keep.sndOn; }catch(_n){}
     }
     return bad.length?bad.join('; '):null; }},
  {v:'16.28',what:
'@


SubRx @'
     var fk=fake(), km;
     try{
'@ @'
     var fk=fake(), km, _splitKeep=null;
     try{ _splitKeep=localStorage.getItem('salvagerun:samesound:split'); localStorage.setItem('salvagerun:samesound:split','0'); }catch(_sk){}   // v16.29: this check reads SOUND ON and OFF with split speakers off
     try{
'@

SubRx @'
       try{ NET.bc=null; NET.same=''; NET.pair=''; NET.mode=''; }catch(_n){}
'@ @'
       try{ NET.bc=null; NET.same=''; NET.pair=''; NET.mode=''; }catch(_n){}
       try{ if(_splitKeep===null) localStorage.removeItem('salvagerun:samesound:split'); else localStorage.setItem('salvagerun:samesound:split',_splitKeep); }catch(_sk2){}
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
