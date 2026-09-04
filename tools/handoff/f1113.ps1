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
  {v:'11.12',what:'a machine that can see you through a window does not try to walk through it, and comes out of the door instead',
'@ @'
  {v:'11.13',what:'the Undercroft crowd never wears the ghost mask or the Spartan helmet, and still dresses from the rest of the rack',
   run:function(){
     if(!(window.__crowdLook&&window.__cos&&__cos.list)) return 'SKIP: this fixture cannot roll the crowd';
     var bad=[], L=__cos.list(), i, k, hats={}, n=600;
     for(i=0;i<n;i++){ var lk=__crowdLook(); if(!lk) return 'SKIP: the crowd roller returned nothing'; hats[lk.hat]=(hats[lk.hat]||0)+1; }
     // THE FINDING. Measured on v11.12: 182 ghost masks and 172 Spartan helmets
     // in 2,000 rolls, about one in eleven each.
     if(hats.ghostmask) bad.push(hats.ghostmask+' of '+n+' crowd looks wear the ghost mask, which is his');
     if(hats.spartan) bad.push(hats.spartan+' of '+n+' crowd looks wear the Spartan helmet, which is his');
     // CONTROL ONE: the rest of the rack is still worn, or the crowd has stopped
     // dressing rather than skipped two pieces.
     var others=0; for(k in hats) if(k!=='none'&&k!=='ghostmask'&&k!=='spartan') others++;
     if(others<3) bad.push('control: only '+others+' other hats appear in '+n+' rolls, so the crowd has stopped dressing from the rack rather than leaving two pieces alone');
     // CONTROL TWO: both pieces are still on the rack for him to earn.
     var gm=null, sp=null, band=null;
     for(i=0;i<L.length;i++){ if(L[i].id==='ghostmask') gm=L[i]; if(L[i].id==='spartan') sp=L[i]; if(L[i].id==='band') band=L[i]; }
     if(!gm||!sp) bad.push('control: the ghost mask or the Spartan helmet is gone from the rack itself, and they were only ever to come off the crowd');
     // CONTROL THREE: the rule is the flag and not the two names. Bar a third
     // hat for a moment and it must vanish from the crowd too, then come back.
     if(!band) bad.push('control: no sweat band on the rack to bar for the test');
     else {
       var had=Object.prototype.hasOwnProperty.call(band,'crowd'), was=band.crowd, seen=0, back=0;
       band.crowd=0;
       try{ for(i=0;i<300;i++) if(__crowdLook().hat==='band') seen++; }
       finally{ if(had) band.crowd=was; else delete band.crowd; }
       if(seen) bad.push('control: a hat barred from the crowd by its flag was still worn '+seen+' times in 300 rolls, so the roller skips two names and does not read the flag');
       for(i=0;i<300;i++) if(__crowdLook().hat==='band') back++;
       if(!back) bad.push('control: the sweat band did not come back to the crowd after its flag was lifted');
     }
     return bad.length?bad.join('; '):null; }},
  {v:'11.12',what:'a machine that can see you through a window does not try to walk through it, and comes out of the door instead',
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
