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

# CHECK 13.05, HARNESS ONLY. It closes the gap named in the v13.02 entry.
#
# v13.02 sweeps six DOM panels and v13.04 sweeps the outcome card. Everything painted
# on a canvas was still unguarded, which is the Undercroft floor he walks around and
# the HUD he reads for the whole raid. v13.03 swept one sign there by hand; this is the
# same instrument pointed at every string those two surfaces draw.
#
# THE RECORDER KEEPS BOTH HALVES of every canvas string: what the code asked for, and
# what was painted after his wording was applied. So the rule needs no list and names
# no line: if the code asked for something he has rewritten, the paint must be his
# version. An edit that has stopped landing shows up as the two halves being equal.
#
# IT CANNOT GO STALE. The keys come from his own map at run time.
SubRx @'
  {v:'13.04',what:'the outcome card carries his wording
'@ @'
  {v:'13.05',what:'the Undercroft floor and the raid HUD paint his wording too: every string those two surfaces draw is compared against his own baked edits, so a line he has rewritten can no longer be repainted in the game words on the screens he spends the most time looking at (closes the canvas gap named in the v13.02 entry)',
   run:function(){
     if(!(window.__tx&&window.__tx.record&&window.__tx.ship)) return 'SKIP: this fixture cannot record what is painted';
     if(!(window.__hubFrame&&window.__showScreen&&window.__hubEnter)) return 'SKIP: this fixture cannot draw the Undercroft floor';
     var M=null; try{ M=__tx.ship(); }catch(_m){}
     if(!M) return 'SKIP: his baked edits are not readable here';
     var bad=[], drew=0;
     function sweep(label,fn){
       var H=[];
       try{ H=__tx.record(fn)||[]; }catch(_r){ bad.push(label+' threw while drawing: '+(_r&&_r.message||_r)); return; }
       if(!H.length) return;
       drew++;
       for(var i=0;i<H.length;i++){
         var h=H[i], raw=String(h.o);
         if(!Object.prototype.hasOwnProperty.call(M,raw)) continue;
         var want=String(M[raw]);
         if(String(h.t)!==want)
           bad.push('the '+label+' paints ['+raw.slice(0,50)+'] where he rewrote that line to say ['+want.slice(0,50)+']: his wording is matched on the whole string, so whatever is drawn there is no longer the sentence his edit was written against and his version has gone off the screen without a sound');
       }
     }
     try{
       __topClear(); __runPrep(); __resetCfg(); __cleanProfile();
       __showScreen('hub'); __hubEnter();
       sweep('Undercroft floor',function(){ __hubFrame(0.016); });
       if(window.__deploy&&window.__frame&&window.__state){
         try{
           __deploy({kit:[],safe:null,mapIx:0,seed:4242});
           sweep('raid HUD',function(){ __frame(0.016); });
         }catch(_d){}
         // A finished raid blocks the floor pause box, so this check leaves none:
         // the game's own return path drops the raid rather than leaving it over.
         try{ var g=__state(); if(g&&!g.over){ g.player.downed=false; __endRaid('abandon'); } }catch(_e){}
         try{ G=null; keys={}; showScreen('hub'); }catch(_q){}
       }
       if(!drew)
         bad.push('control: neither surface painted a single string, so this sweep would report nothing on a build that had lost every one of his edits');
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{
       try{ G=null; keys={}; showScreen('hub'); }catch(_q2){}
       try{ __topClear(); __resetCfg(); __cleanProfile(); }catch(_c){}
     }
     return bad.length?bad.join('; '):null; }},
  {v:'13.04',what:'the outcome card carries his wording
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
