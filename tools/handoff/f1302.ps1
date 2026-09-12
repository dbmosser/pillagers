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

# v13.02 CHECK, inserted before the v13.01 entry.
#
# THE RULE IT ASSERTS NAMES NO LINE. If his edit is landing, the ORIGINAL sentence can
# never be on screen; his replacement is there instead. So any raw key visible on a
# drawn panel, with his replacement absent from that panel, is an edit that has stopped
# working. That holds for every line he has ever edited and for every line he edits
# next, without this row knowing any of them.
#
# HIS REPLACEMENT MUST BE ABSENT TOO, and that is not a detail. Several of his edits
# keep the original and add to it, so the raw text is a prefix of his own replacement
# and would flag every run. The pair is the test: original present AND replacement
# missing.
#
# IT DRIVES THE REWRITE PASS. Panels write their raw sentences and his wording is put
# over them by a mutation observer, which is a microtask; reading in the same
# synchronous turn sees the raw text on a perfectly good build.
#
# THE CONTROL IS THAT THE SWEEP CAN SEE AT ALL. A sweep that drew nothing, or read an
# empty panel, would report no failures for the same reason a working build does.
SubRx @'
  {v:'13.01',what:'the bar blurb he rewrote still shows his words
'@ @'
  {v:'13.02',what:'no screen shows the original of a line he has rewritten: six panels are drawn and swept against his own baked edits, so rewording an edited sentence can no longer delete his version of it without a sound (the guard for the v12.98 defect found at v13.01)',
   run:function(){
     if(typeof TXPANELS==='undefined'||!TXPANELS||!TXPANELS.length)
       return 'the harness cannot see his edits at all: there is no list of panels a check can draw, so a build that reworded a line he had rewritten would delete his version of it and nothing would notice';
     if(!(window.__tx&&window.__tx.ship)) return 'SKIP: this fixture cannot read his baked edits';
     var M=null; try{ M=__tx.ship(); }catch(_m){}
     if(!M) return 'SKIP: his baked edits are not readable here';
     var bad=[], keys=Object.keys(M), mine=0, drew=0;
     try{
       __topClear(); __runPrep(); __resetCfg(); __cleanProfile();
       var P2=window.__P?__P():null;
       if(P2){ P2.credits=1000000; P2.buzz=[]; }
       for(var pi=0;pi<TXPANELS.length;pi++){
         var spec=TXPANELS[pi], el=document.getElementById(spec.id);
         if(!el) continue;
         var wasOn=el.classList.contains('on');
         var txt='';
         try{
           el.classList.add('on');
           spec.fn();
           // What the observer would do a moment later.
           try{ if(typeof txDom==='function') txDom(document.getElementById('root')); }catch(_d){}
           txt=el.textContent||'';
         }catch(_p){ }
         finally{ try{ if(!wasOn) el.classList.remove('on'); }catch(_c){} }
         if(!txt.replace(/\s+/g,'').length) continue;
         drew++;
         for(var ki=0;ki<keys.length;ki++){
           var k=keys[ki], v=String(M[k]||'');
           if(k.replace(/\s+/g,'').length<12) continue;   // too short to identify a line
           if(txt.indexOf(v)>=0){ mine++; continue; }     // his words are there: nothing to report
           if(txt.indexOf(k)>=0)
             bad.push('the '+spec.id.replace('modal','')+' screen shows the original of a line he rewrote, and his version of it is not there: ['+k.replace(/\s+/g,' ').slice(0,70)+']. His wording is matched on the whole sentence, so a word added to that line or a number joined onto it deletes what he wrote with no error and nothing red');
         }
       }
       if(!drew)
         bad.push('control: not one of the panels drew any text, so this sweep would report nothing on a build that had lost every one of his edits');
       if(!mine)
         bad.push('control: not one of his replacements was found on any of the panels drawn, so the sweep cannot see his wording and its silence means nothing');
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{
       try{ __topClear(); __resetCfg(); __cleanProfile(); }catch(_c2){}
     }
     return bad.length?bad.join('; '):null; }},
  {v:'13.01',what:'the bar blurb he rewrote still shows his words
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
