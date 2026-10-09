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

if ($s.Contains("  {v:'20.78',what:")) { throw "check 20.78 is in the fixture already" }

SubRx @'
  {v:'20.77',what:
'@ @'
  {v:'20.78',what:'a light shot tick never cuts a stronger rumble short: a hit buzz plays out, and the next tick plays once it is over',
   run:function(){
     if(typeof padRumble!=='function'||typeof RUMBLE!=='object'||!RUMBLE||typeof performance==='undefined'||!performance) return 'SKIP: no rumble here';
     if(typeof G!=='undefined'&&G&&G.sim) return 'SKIP: a sim raid is up';
     var bad=[], RK={}, k, calls=[], T=50000, ownNow=Object.prototype.hasOwnProperty.call(performance,'now'), oNow=performance.now, chR=false, r1, r2, r3, r4;
     var gp={vibrationActuator:{playEffect:function(type,o){ calls.push({s:o.strongMagnitude,ms:o.duration}); return null; }}};
     for(k in RUMBLE) RK[k]=RUMBLE[k];
     try{
       performance.now=function(){ return T; };
       if(performance.now()!==T) return 'SKIP: the clock cannot be held here';
       if(CFG.rumble===0){ CFG.rumble=1; chR=true; }
       RUMBLE.gp=gp; RUMBLE.usedAt=T-1000; RUMBLE.at=0; RUMBLE.s=0;
       r1=padRumble(0.8,230);
       T+=100; r2=padRumble(0.12,35);
       T+=140; r3=padRumble(0.12,35);
       T+=10;  r4=padRumble(0.12,35);
       if(r1!=='own'||!calls.length||calls[0].s!==0.8) bad.push('the hit buzz did not play ('+r1+')');
       if(r2!=='soon') bad.push('a shot tick 100 ms into a 230 ms hit buzz cut it short ('+r2+')');
       if(r3!=='own') bad.push('the shot tick after the hit buzz was over did not play ('+r3+')');
       if(r4!=='soon') bad.push('two ticks 10 ms apart both played ('+r4+')');
       if(calls.length!==2) bad.push(calls.length+' rumbles played, not 2');
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{
       if(ownNow) performance.now=oNow; else delete performance.now;
       if(chR) CFG.rumble=0;
       for(k in RUMBLE) if(!(k in RK)) delete RUMBLE[k];
       for(k in RK) RUMBLE[k]=RK[k];
     }
     return bad.length?bad.join('; '):null; }},
  {v:'20.77',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
