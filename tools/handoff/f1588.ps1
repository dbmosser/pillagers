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
  {v:'15.87',what:
'@ @'
  {v:'15.88',what:'the sector card counts every run he has made there: with the run log holding sixty records, the two oldest on the second sector and fifty-eight on the first, the cards read you: 58 runs here and you: 2 runs here, and after three more first-sector runs are committed the way the outcome card commits them, which pushes the two second-sector records out of the sixty-run log, the first card reads you: 61 runs here and the second still reads you: 2 runs here rather than YOU HAVE NEVER RAIDED HERE, and a restore code made then carries the 61 through a restore over a profile holding 5 (sector audit finding)',
   run:function(){
     if(typeof renderSector!=='function'||typeof commitRun!=='function'||typeof restoreMake!=='function'||typeof restoreApply!=='function'||typeof FIXED_MAPS==='undefined'||FIXED_MAPS.length<2||!window.__P||!window.__applyLoaded) return 'SKIP: no sector page, run commit, restore codes or profile loader in this build';
     var host=document.getElementById('sectorlist'); if(!host) return 'SKIP: there is no sector list to draw into';
     var bad=[], snap=null, N0=String(FIXED_MAPS[0].name), N1=String(FIXED_MAPS[1].name);
     // The never-raided sentence is assembled from pieces so the check does not match its own source.
     var NEVER=['YOU HAVE ','NEVER RAIDED',' HERE'].join('');
     function you(n){ return 'you: '+n+' run'+(n===1?'':'s')+' here'; }
     function card(ix){ renderSector(); var el=host.querySelector('.sectorpick[data-map="'+ix+'"]'); return el?String(el.textContent||'').replace(/\s+/g,' '):null; }
     function rec(nm){ return {mapName:nm,outcome:'extract',haul:0,containers:0,dist:0,carriedIn:0,kills:{}}; }
     function left(){ var c=0; for(var i=0;i<P.log.length;i++) if(P.log[i]&&P.log[i].mapName===N1) c++; return c; }
     try{
       __topClear(); __cleanProfile();
       snap=JSON.parse(JSON.stringify(__P()));
       // The stage: a sixty-record log, the two oldest on the second sector, and no tally yet, so the first commit seeds one from the log.
       var L=[], i;
       for(i=0;i<2;i++) L.push({mapName:N1,outcome:'extract',_committed:1});
       for(i=0;i<58;i++) L.push({mapName:N0,outcome:'extract',_committed:1});
       P.log=L; delete P.mapRunN;
       // CONTROL: under the cap both cards count what the log holds, on either build.
       var c0=card(0), c1=card(1);
       if(c0===null||c1===null) return 'SKIP: the sector page drew no card for both sectors here';
       if(c0.indexOf(you(58))<0||c1.indexOf(you(2))<0) return 'SKIP: with 58 and 2 runs in the log the cards read "'+c0.slice(0,80)+'" and "'+c1.slice(0,80)+'", so the count cannot be read here';
       // Three more runs on the first sector, committed the way the outcome card commits them: the log stays at sixty and its two oldest records, the second-sector runs, age out.
       for(i=0;i<3;i++) if(commitRun(rec(N0))!==true) return 'SKIP: commitRun refused a fresh record here';
       // CONTROL: the commits took and the aging happened, on either build.
       if(P.log.length!==60||left()!==0) return 'SKIP: after three commits the log holds '+P.log.length+' records with '+left()+' on '+N1+', so nothing aged out here';
       // THE FIX: the cards count every run, not only the sixty the log still holds.
       c0=card(0); c1=card(1);
       if(c0.indexOf(you(61))<0) bad.push('after 61 runs on '+N0+' its card reads "'+c0.slice(0,80)+'" rather than '+you(61));
       if(c1.indexOf(you(2))<0) bad.push('after its two runs aged out of the sixty-run log the card for '+N1+' reads "'+c1.slice(0,80)+'" rather than '+you(2)+(c1.indexOf(NEVER)>=0?' (it says '+NEVER+')':''));
       // THE FIX, CARRIED: a restore code made now brings the tally with it over a profile holding another.
       var o=JSON.parse(JSON.stringify(restoreMake()));
       P.mapRunN={}; P.mapRunN[N0]=5;
       if(restoreApply(o)===false) bad.push('restoreApply refused a code made a moment ago');
       else { var t=(P.mapRunN&&P.mapRunN[N0])|0; if(t!==61) bad.push('a restore code made with 61 runs on '+N0+', restored over a profile holding 5, left the tally at '+t); }
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{
       try{ if(snap) __applyLoaded(snap); }catch(_r){}
       try{ renderSector(); }catch(_m){}
       try{ __topClear(); __cleanProfile(); }catch(_c){}
     }
     return bad.length?bad.join('; '):null; }},
  {v:'15.87',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
