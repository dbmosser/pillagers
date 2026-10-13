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

if ($s.Contains("  {v:'25.12',what:")) { throw "check 25.12 is in the fixture already" }

SubRx @'
  {v:'25.11',what:
'@ @'
  {v:'25.12',what:'his order: a search picked back up says nothing (no Search resumed line) and its progress carries on',
   run:function(){
     if(!(window.__deploy&&window.__state&&window.__endRaid)||typeof updatePlayer!=='function') return 'SKIP: this fixture cannot deploy and step';
     var bad=[], said=[], realSay=say, g, p, ct=null, i, n, atStop=0, k1=0, srch=[].slice.call(document.scripts).map(function(s){ return s.textContent||''; }).join('\n');
     try{
       __topClear(); __runPrep(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       g=__state(); p=g.player; if(!g||g.over) return 'SKIP: no live raid';
       say=function(m){ said.push(String(m)); return realSay.apply(null,arguments); };
       for(i=0;i<g.containers.length&&!ct;i++) if(g.containers[i]&&g.containers[i].time>0&&!g.containers[i].done&&g.containers[i].loot&&g.containers[i].loot.length) ct=g.containers[i];
       if(!ct) return 'SKIP: no searchable container on the map';
       p.x=ct.x+18; p.y=ct.y; p.hp=100; ct.prog=0; g.searching=null; g.searchT=0;
       // hold E until the search is about six percent in
       keys={}; keys['KeyE']=true;
       for(n=0;n<3000&&(ct.prog||0)<ct.time*0.06;n++){ p.x=ct.x+18; p.y=ct.y; updatePlayer(0.016); }
       if(g.searching!==ct||(ct.prog||0)<ct.time*0.05) return 'SKIP: the hold did not start a search on this box (prog '+(ct.prog||0).toFixed(3)+' of '+ct.time+')';
       // let go: the search is interrupted
       keys={}; for(n=0;n<5;n++){ p.x=ct.x+18; p.y=ct.y; updatePlayer(0.016); }
       if(g.searching===ct){ g.searching=null; g.searchT=0; }
       atStop=ct.prog||0;
       if(atStop<ct.time*0.05) bad.push('the progress did not survive letting go ('+atStop.toFixed(3)+')');
       // pick it back up
       said.length=0; keys['KeyE']=true;
       for(n=0;n<4;n++){ p.x=ct.x+18; p.y=ct.y; updatePlayer(0.016); }
       keys={};
       if(said.some(function(t){ return /esum|% ?done/i.test(t); })) bad.push('picking the search back up still says '+said.filter(function(t){ return /esum|% ?done/i.test(t); }).join(' | ').slice(0,90));
       if(g.searching!==ct) bad.push('control: the second hold did not pick the search back up');
       if(!((ct.prog||0)>atStop)) bad.push('the progress did not carry on after picking it back up ('+atStop.toFixed(3)+' to '+(ct.prog||0).toFixed(3)+')');
       k1=srch.split('say('+'\'Search res'+'umed').length-1;
       if(k1) bad.push('the page still holds '+k1+' Search resumed say call(s)');
     }catch(err){ bad.push('threw: '+(err&&err.message||err)); }
     finally{ say=realSay; keys={}; try{ var g2=__state(); if(g2&&!g2.over){ g2.searching=null; g2.searchT=0; g2.player.downed=false; g2.player.hp=100; __endRaid('abandon'); } }catch(_e){} __topClear(); __cleanProfile(); }
     return bad.length?bad.join('; '):null; }},
  {v:'25.11',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
