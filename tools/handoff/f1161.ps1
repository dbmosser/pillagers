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

# v11.61 HOOK: the identity ids a merc can be hired as, so a check can hire one.
SubRx @'
window.__loadProfile=function(){ return loadProfile(); };
'@ @'
window.__loadProfile=function(){ return loadProfile(); };
window.__identityIds=function(){ var o=[]; try{ for(var i=0;i<IDENTITIES.length;i++) o.push(IDENTITIES[i].id); }catch(e){} return o; };
'@

# v11.61 CHECK, inserted before the v11.60 entry.
SubRx @'
  {v:'11.60',what:'Wirt Buy delivers the lot that was named and priced on the card, even if the five-minute window rolled between the card being drawn and the click',
'@ @'
  {v:'11.61',what:'a hired merc has a roster row, so when he boards an earlier ship and you extract, the card says he extracted earlier and pays your ten percent instead of saying he was left out there',
   run:function(){
     if(!(window.__identityIds&&window.__deploy&&window.__state&&window.__endRaid&&window.__P)) return 'SKIP: this fixture cannot hire a merc and end a raid';
     __topClear(); __runPrep(); __resetCfg(); __pinDefaults(0); __cleanProfile();
     var ids=window.__identityIds(); if(!ids.length) return 'SKIP: no identities to hire';
     var P=window.__P(), bad=[];
     P.merc=ids[0]; P.credits=1000;
     __deploy({kit:[],safe:null,mapIx:0,seed:4242});
     var g=__state(), M=null, i;
     for(i=0;i<g.ents.length;i++){ if(g.ents[i].merc){ M=g.ents[i]; break; } }
     if(!M){ __cleanProfile(); return 'SKIP: the hired merc did not spawn'; }
     var row=null; for(i=0;i<(g.roster||[]).length;i++){ if(g.roster[i].ref===M){ row=g.roster[i]; break; } }
     // THE FIX: he is on the roster at all.
     if(!row) bad.push('the hired merc has no roster row, so boarding cannot stamp his haul and endRaid cannot pay your cut');
     else {
       // He fled low and boarded an earlier ship: the boarding code stamps the
       // row and removes him from the world. Then you extract.
       row.out=true; row.outAt=0; row.val=1234;
       var ix=g.ents.indexOf(M); if(ix>=0) g.ents.splice(ix,1);
       var c0=P.credits;
       try{ __endRaid('extract'); }catch(e){ bad.push('endRaid threw: '+String(e&&e.message||e).slice(0,80)); }
       var txt=''; try{ txt=(document.getElementById('outcome')||{}).innerText||''; }catch(e2){}
       if(!/extracted earlier/i.test(txt)) bad.push('the card did not say he extracted earlier (it says: '+txt.replace(/\s+/g,' ').slice(0,90)+')');
       if(!(P.credits-c0>=123)) bad.push('your ten percent of his 1,234 was not paid (credits moved '+(P.credits-c0)+')');
     }
     __topClear(); __cleanProfile();
     return bad.length?bad.join('; '):null; }},
  {v:'11.60',what:'Wirt Buy delivers the lot that was named and priced on the card, even if the five-minute window rolled between the card being drawn and the click',
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
