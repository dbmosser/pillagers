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

# ==== THE TWO HALVES OF v9.25 CANNOT BE MEASURED FROM THE SAME SEAT.
# ==== Measured, not assumed: this pillager's reach is 187 units and a peaceful
# ==== raider turns hostile on proximity alone inside 180. So "he is still
# ==== peaceful when the round lands" needs more than 180 and "he shoots back"
# ==== needs less than his reach, and for this man there is no distance that is
# ==== both. Standing at 190 he takes the round while peaceful and the notoriety
# ==== charge fires, 0 to 1, but he cannot reach back. Standing at 110 he fights
# ==== back exactly as he should, and the charge correctly declines because he
# ==== was already hostile before the round arrived.
# ==== So the check takes two seats. CLOSE proves he fights back, which is his
# ==== report and the thing v9.25 fixed. FAR proves the charge, from zero. Each
# ==== assertion is made at the range where it can be true, and neither is asked
# ==== to stand in for the other. It was one seat before, and green only because
# ==== the charge was read as a banked total rather than a rise.
SubRx @'
         // v10.68: AND FAR ENOUGH AWAY THAT HE IS STILL PEACEFUL. Inside 180
         // units a raider turns hostile on proximity alone, so the old ladder,
         // which started at 110, had him fighting before the round arrived and
         // the notoriety charge correctly declined to fire. The control never
         // saw that because it read the profile's banked total instead of a rise.
         var _rmax=Math.max(150,Math.min(400,(tgt.rng||300)-45));
         var RS=[], ok=false;
         for(var _rr=190;_rr<=_rmax;_rr+=8) RS.push(_rr);
'@ @'
         // v10.68: TWO SEATS, because no single one can answer both questions.
         // CLOSE is inside his reach so he can fire back, and he is already
         // hostile there from proximity. FAR is outside the 180 unit temper so
         // he is still peaceful when the round lands and the charge can fire;
         // he cannot reach back from there and is not asked to.
         var _rmax=Math.max(150,Math.min(400,(tgt.rng||300)-45));
         var RS=[], ok=false;
         if(mode==='far'){ for(var _rr=190;_rr<=280;_rr+=8) RS.push(_rr); }
         else RS=[110, 150, 90, Math.round(_rmax*0.58), _rmax];
'@

SubRx @'
       if(!_stood) return {noStand:true,rmax:Math.max(150,Math.min(400,(tgt.rng||300)-45))};
'@ @'
       if(!_stood) return {noStand:true,mode:mode,rng:Math.round(tgt.rng||0)};
'@

SubRx @'
     var a=shoot('peaceful');
     if(!a) return 'no peaceful pillager on this map and seed';
     if(a.noStand) return 'SKIP: nowhere sighted to stand outside his 180 unit temper and inside his '+a.rmax+' unit reach';
     if(a.landed<1) return 'SKIP: could not land a round on him in 520 frames';
     if(a.hostileAt<0)
       bad.push('shot once from 400 units and watched '+a.watched+' frames: he never turned on you');
     else if(a.backAt<0)
       bad.push('he turned hostile but never fired back in '+a.watched+' frames');
     // CONTROL 1: the notoriety charge for shooting a man who was not fighting
     // you must survive. notoAggress only fires while he is still peaceful, so
     // setting the flag one line too early would delete the penalty in silence.
     if(a.noto<1) bad.push('control: shooting a peaceful pillager cost no notoriety, starting from zero');
'@ @'
     // SEAT ONE, CLOSE: he fights back. This is his report and the thing v9.25
     // fixed, and it is only answerable from inside his reach.
     var a=shoot('peaceful');
     if(!a) return 'no peaceful pillager on this map and seed';
     if(a.noStand) return 'SKIP: nowhere sighted to stand inside his '+a.rng+' unit reach';
     if(a.landed<1) return 'SKIP: could not land a round on him in 520 frames';
     if(a.hostileAt<0)
       bad.push('shot once and watched '+a.watched+' frames: he never turned on you');
     else if(a.backAt<0)
       bad.push('he turned hostile but never fired back in '+a.watched+' frames');
     // SEAT TWO, FAR: the notoriety charge for shooting a man who was not
     // fighting you. notoAggress only fires while he is still peaceful, so
     // setting the hostile flag one line too early would delete the penalty in
     // silence. It has to be read as a RISE FROM ZERO and from outside the 180
     // unit temper, or a proximity aggro answers the question before the bullet.
     var far=shoot('far');
     if(!far) bad.push('control: no peaceful pillager for the notoriety seat');
     else if(far.noStand) bad.push('control: nowhere sighted to stand outside his 180 unit temper');
     else if(far.landed<1) bad.push('control: could not land a round on him from outside 180 units');
     else if(far.noto<1) bad.push('control: shooting a peaceful pillager cost no notoriety, starting from zero');
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
