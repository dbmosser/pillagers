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
  {v:'11.39',what:'with the controls list off, the "H controls" hint draws clear of the bottom-left corner (where the vitals panel is), above the panel, at 1080p and at 1440p',
'@ @'
  {v:'11.40',what:'a vented Pillbox holds its stun for the full lockout, the same span a vented sentry holds, not the half-length it drained to before',
   run:function(){
     if(!(window.__deploy&&window.__state&&window.__rawStep)) return 'SKIP: this fixture cannot step a raid';
     var bad=[];
     var LOCK=7.0;
     function lockout(kind){
       __topClear(); __runPrep(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       var g=__state(), p=g.player, E=null, i;
       for(i=0;i<g.ents.length;i++){ if(g.ents[i].kind===kind){ E=g.ents[i]; break; } }
       if(!E) return null;
       // parked far from the player and asleep so its own AI never re-heats it
       E.x=p.x+2000; E.y=p.y+2000; E.state='patrol'; E.alert=0; E.sang=0;
       E.overheat=4.0; E.htImmune=LOCK; E.cd=0;
       var dt=0.15, frames=0;
       for(var s=0;s<300;s++){ E.x=p.x+2000; E.y=p.y+2000; __rawStep(dt); frames++; if(E.htImmune<=0) break; }
       return frames*dt;
     }
     var choir=lockout('choir');
     if(choir===null) return 'SKIP: no Pillbox on this map';
     var sentry=lockout('sentry');
     if(sentry===null) return 'SKIP: no sentry to compare against';
     // THE FIX: the Pillbox holds its stun for the full lockout, within a frame
     // or two of the dial and of the sentry. Before, it drained to about 5.5s.
     if(choir<LOCK-0.6) bad.push('the Pillbox vent stun cleared in '+choir.toFixed(2)+'s, short of the '+LOCK+'s lockout, so it is still draining fast');
     if(Math.abs(choir-sentry)>0.6) bad.push('the Pillbox stun ('+choir.toFixed(2)+'s) and the sentry stun ('+sentry.toFixed(2)+'s) differ by more than a couple of frames');
     // CONTROL: the sentry itself clears at about the lockout, so the ruler is
     // sound and a Pillbox matching it means something.
     if(sentry<LOCK-0.6||sentry>LOCK+0.6) bad.push('control: the sentry vent stun cleared in '+sentry.toFixed(2)+'s rather than about '+LOCK+'s, so the measurement is off');
     __topClear();
     return bad.length?bad.join('; '):null; }},
  {v:'11.39',what:'with the controls list off, the "H controls" hint draws clear of the bottom-left corner (where the vitals panel is), above the panel, at 1080p and at 1440p',
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
