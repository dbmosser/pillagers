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

# ==== AND THE NOTORIETY CONTROL WAS STANDING TOO CLOSE THE WHOLE TIME.
# ==== With the control finally starting from zero it went red, so I measured it
# ==== rather than trusting either side. A peaceful pillager turns hostile on
# ==== PROXIMITY ALONE inside 180 units, which the game says in as many words,
# ==== and the stand ladder started at 110. Driven by hand: at 110 he turns
# ==== hostile at frame 4, the round lands later, and notoAggress declines the
# ==== charge because by then he was already fighting. That is the game being
# ==== right. At 150 the round and the aggro land together and the charge fires.
# ==== The window is 180 up to his sight less the 45 unit margin: measured rng
# ==== 259 and rmax 214 for the pillager this check picks, with legal sighted
# ==== stands at 190, 200 and 210. The ladder now walks that window and says so
# ==== rather than guessing when the window is empty. v9.26, which has the same
# ==== shape, already stands at 300 and is not affected.
SubRx @'
       try{ __P().notoriety=0; }catch(_nz){}
       var g=__state(), p=g.player, tgt=null;
       for(var i=0;i<g.ents.length;i++){ var e=g.ents[i];
         if(e.kind==='raider'&&e.hostile===false&&!e.merc&&!e.friendlyPC&&!e.downed){ tgt=e; break; } }
       if(!tgt) return null;
       if(mode==='ally') tgt.friendlyPC=true;
'@ @'
       try{ __P().notoriety=0; }catch(_nz){}
       var g=__state(), p=g.player, tgt=null;
       for(var i=0;i<g.ents.length;i++){ var e=g.ents[i];
         if(e.kind==='raider'&&e.hostile===false&&!e.merc&&!e.friendlyPC&&!e.downed){ tgt=e; break; } }
       if(!tgt) return null;
       var _stood=false;
       if(mode==='ally') tgt.friendlyPC=true;
'@

SubRx @'
         var _rmax=Math.max(150,Math.min(400,(tgt.rng||300)-45));
         var RS=[110, 150, 90, Math.round(_rmax*0.58), _rmax], ok=false;
'@ @'
         // v10.68: AND FAR ENOUGH AWAY THAT HE IS STILL PEACEFUL. Inside 180
         // units a raider turns hostile on proximity alone, so the old ladder,
         // which started at 110, had him fighting before the round arrived and
         // the notoriety charge correctly declined to fire. The control never
         // saw that because it read the profile's banked total instead of a rise.
         var _rmax=Math.max(150,Math.min(400,(tgt.rng||300)-45));
         var RS=[], ok=false;
         for(var _rr=190;_rr<=_rmax;_rr+=8) RS.push(_rr);
'@

SubRx @'
         if(!ok){ p.x=tgt.x+400; p.y=tgt.y; }
       })();
'@ @'
         _stood=ok;
       })();
       // No fallback stand any more. The old one dropped him at 400 units, which
       // is outside this pillager's reach, so "he never fired back" would have
       // been the harness reporting its own bad seat as the game failing.
       if(!_stood) return {noStand:true,rmax:Math.max(150,Math.min(400,(tgt.rng||300)-45))};
'@

SubRx @'
     var a=shoot('peaceful');
     if(!a) return 'no peaceful pillager on this map and seed';
'@ @'
     var a=shoot('peaceful');
     if(!a) return 'no peaceful pillager on this map and seed';
     if(a.noStand) return 'SKIP: nowhere sighted to stand outside his 180 unit temper and inside his '+a.rmax+' unit reach';
'@

SubRx @'
     var b2=shoot('ally');
     if(b2&&b2.landed>=1&&b2.tgt.hostile)
'@ @'
     var b2=shoot('ally');
     if(b2&&!b2.noStand&&b2.landed>=1&&b2.tgt.hostile)
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
