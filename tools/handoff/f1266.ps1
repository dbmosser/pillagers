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

# v12.66 CHECK, inserted before the v12.65 entry. It claims ONE card and reads
# the DRAWN line, because the whole finding is a number printed under the wrong
# name. A HARD card is used on purpose: it is the smallest claim whose weight
# and whose count differ, so a line that prints either one can be told apart.
# The control is the gate itself, which must not have moved, because the credit
# is what opens harder work and this build is only about what is said.
SubRx @'
  {v:'12.65',what:'a haul contract counts what the run brought back and not what the lift carried up: staging an expensive gun out of his own stash and walking straight out no longer finishes it, while the same value found in the raid still does (2026-09-08 audit)',
'@ @'
  {v:'12.66',what:'the contract board counts contracts: after one HARD claim the line reads one contract completed rather than the weighted two, and the gate under it asks for credits in its own words while the credit itself is unchanged (2026-09-08 audit, my own wording)',
   run:function(){
     if(!window.__P) return 'SKIP: this fixture cannot read the profile';
     if(typeof claimContractAt!=='function'||typeof cstand!=='function'||typeof renderHub!=='function') return 'SKIP: this build has no contract board to claim at';
     if(typeof CTIER==='undefined'||!CTIER.hard||CTIER.hard.w!==2) return 'SKIP: a HARD card no longer counts two, so the two numbers cannot be told apart here';
     if(!document.getElementById('contracts')) return 'SKIP: this build has no contract list to draw';
     var bad=[], P2=__P();
     var keep={contracts:(P2.contracts||[]).slice(),cstand:P2.cstand,cdone:P2.cdone,credits:P2.credits,stash:(P2.stash||[]).slice()};
     function hintText(){
       renderHub();
       var cl=document.getElementById('contracts'), kids=cl?cl.querySelectorAll('.hint'):[], i;
       for(i=0;i<kids.length;i++){ var t=String(kids[i].textContent||'');
         if(t.indexOf('ontracts completed')>=0) return t; }
       return '';
     }
     try{
       __topClear(); __runPrep(); __resetCfg(); __cleanProfile();
       P2.cstand=0; P2.cdone=0; P2.credits=0; P2.stash=[];
       // One HARD card, finished, and nothing else on the board.
       P2.contracts=[{type:'kill',tgt:'sentry',n:1,prog:1,reward:100,tier:'hard',desc:'card staged by check 12.66'}];
       var before=hintText();
       if(before.indexOf('0')<0) bad.push('staging: a clean profile does not read zero on the board line ['+before+']');
       var got=claimContractAt(0);
       if(!got) return 'SKIP: the staged card would not claim, so there is nothing here to count';
       // THE FINDING: one card claimed, so the line must say one contract.
       var after=hintText();
       if(!after) return 'SKIP: the board drew no completed line, so what he reads cannot be checked here';
       if((P2.cdone||0)!==1)
         bad.push('claiming one contract left the count at '+(P2.cdone||0)+', so the board has no true count to print');
       if(/completed\s*2\b/.test(after.replace(/\s+/g,' ')))
         bad.push('the board says two contracts completed after one HARD card was claimed: it is printing the credit, which a HARD card is worth two of, under the word completed ['+after+']');
       if(!/completed\s*1\b/.test(after.replace(/\s+/g,' ')))
         bad.push('the board does not say one contract completed after one claim ['+after+']');
       // CONTROL: the gate itself must be untouched. A HARD card is still worth
       // two credits and the line must still say what harder work needs.
       if(cstand()!==2)
         bad.push('control: the credit that opens harder work moved to '+cstand()+' on one HARD claim, so this build has changed the gate rather than what is said about it');
       if(after.indexOf('credit')<0)
         bad.push('control: the gate line no longer names what it is asking for ['+after+']');
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{
       try{ P2.contracts=keep.contracts; P2.cstand=keep.cstand; P2.cdone=keep.cdone;
            P2.credits=keep.credits; P2.stash=keep.stash; saveProfile(); }catch(_p){}
       __topClear(); __resetCfg(); __cleanProfile();
     }
     return bad.length?bad.join('; '):null; }},
  {v:'12.65',what:'a haul contract counts what the run brought back and not what the lift carried up: staging an expensive gun out of his own stash and walking straight out no longer finishes it, while the same value found in the raid still does (2026-09-08 audit)',
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
