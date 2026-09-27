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

if ($s.Contains("  {v:'16.24',what:")) { throw "check 16.24 is in the fixture already" }

SubRx @'
  {v:'16.23',what:
'@ @'
  {v:'16.24',what:'split speakers: with it on, player 1 window sound is panned hard left and player 2 window hard right and both play even with SOUND OFF; with it off, no pan and SOUND OFF is silent',
   run:function(){
     if(typeof NET!=='object'||!NET||typeof netSndOut!=='function') return 'SKIP: this build has no same machine sound';
     var bad=[], keep={same:NET.same,sndG:NET.sndG,sndAc:NET.sndAc,sndP:NET.sndP,sndOn:NET.sndOn}, v=null, K='salvagerun:samesound:split';
     function node(){ var o={gain:{value:1},pan:{value:0},connect:function(){}}; return o; }
     var fake={destination:{},createGain:function(){ return node(); },createStereoPanner:function(){ return node(); }};
     try{ v=localStorage.getItem(K); }catch(e){}
     try{
       if(typeof netSndSplitOn!=='function') return 'this build has no split speakers';
       NET.same='host'; NET.sndOn=false; NET.sndG=null; NET.sndAc=null; NET.sndP=null;
       try{ localStorage.setItem(K,'0'); }catch(e){}
       netSndOut(fake);
       if(!NET.sndP) return 'SKIP: no panner was made';
       if(NET.sndP.pan.value!==0||NET.sndG.gain.value!==0) bad.push('control: split off, player 1 window with SOUND OFF has pan '+NET.sndP.pan.value+' gain '+NET.sndG.gain.value);
       localStorage.setItem(K,'1'); netSndApply();
       if(NET.sndP.pan.value!==-1||NET.sndG.gain.value!==1) bad.push('split on, player 1 window has pan '+NET.sndP.pan.value+' gain '+NET.sndG.gain.value+', not hard left and playing');
       NET.same='p2'; netSndApply();
       if(NET.sndP.pan.value!==1||NET.sndG.gain.value!==1) bad.push('split on, player 2 window has pan '+NET.sndP.pan.value+' gain '+NET.sndG.gain.value+', not hard right and playing');
     }
     finally{
       try{ if(v===null) localStorage.removeItem(K); else localStorage.setItem(K,v); }catch(_s){}
       try{ NET.same=keep.same; NET.sndG=keep.sndG; NET.sndAc=keep.sndAc; NET.sndP=keep.sndP; NET.sndOn=keep.sndOn; }catch(_n){}
     }
     return bad.length?bad.join('; '):null; }},
  {v:'16.23',what:
'@


SubRx @'
         if(!has(gH.out,fk.destination)) bad.push('the master gain does not connect to the destination');
'@ @'
         if(!(has(gH.out,fk.destination)||(gH.out||[]).some(function(n){ return n&&n.out&&has(n.out,fk.destination); }))) bad.push('the master gain does not connect to the destination');   // v16.24: or through the split speakers panner
'@

SubRx @'
         if(!has(gP.out,fk.destination)) bad.push('the player 2 master gain does not connect to the destination');
'@ @'
         if(!(has(gP.out,fk.destination)||(gP.out||[]).some(function(n){ return n&&n.out&&has(n.out,fk.destination); }))) bad.push('the player 2 master gain does not connect to the destination');   // v16.24: or through the split speakers panner
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
