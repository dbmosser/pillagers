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
  {v:'14.48',what:
'@ @'
  {v:'14.49',what:'a crash repeating every frame with a changing number is one entry: ten errors that differ only in the key they read become one crash counted ten times and save the profile at most twice, while a different error still gets its own entry (report audit finding 1)',
   run:function(){
     if(typeof noteCrash!=='function'||typeof PLOADED==='undefined') return 'SKIP: no crash catcher in this build';
     if(!PLOADED) return 'SKIP: the profile has not loaded, so crashes go to the boot list';
     var bad=[], saves=0, _sp=saveProfile, keep=P.crashes, keepAt=noteCrash.savedAt, keepTold=crashTold;
     try{
       P.crashes=[]; noteCrash.savedAt=0;
       saveProfile=function(){ saves++; };
       var Q=String.fromCharCode(39);
       for(var i=0;i<10;i++) noteCrash('error','Cannot read properties of undefined (reading '+Q+(37+i)+Q+')','zqx:1:1');
       noteCrash('error','zqx a different fault entirely','zqx:2:2');
       var ours=P.crashes.filter(function(c){ return /reading/.test(c.msg); });
       // CONTROL: the different fault has its own entry.
       if(!P.crashes.some(function(c){ return /different fault/.test(c.msg); })) bad.push('control: a different crash did not get its own entry');
       if(ours.length!==1) bad.push('ten frames of one error with a changing key made '+ours.length+' crash entries instead of one');
       else if(ours[0].n!==10) bad.push('the merged crash counted '+ours[0].n+' repeats, not 10');
       if(saves>2) bad.push('eleven crash reports in a burst saved the whole profile '+saves+' times');
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{ saveProfile=_sp; P.crashes=keep; noteCrash.savedAt=keepAt; try{ crashTold=keepTold; }catch(_t){} }
     return bad.length?bad.join('; '):null; }},
  {v:'14.48',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
