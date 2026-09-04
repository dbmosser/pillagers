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
  {v:'10.43',what:'the Depot and the outcome card name the next piece on the racks and how far off it is',
'@ @'
  {v:'10.44',what:'the outcome card names every piece the racks gained during the raid, and nothing when none did',
   run:function(){
     var bad=[];
     if(!__vpAlive()) return 'SKIP: the pane has no layout';
     if(typeof COSMETICS==='undefined'||!cosFind('spartan')) return 'SKIP: no Spartan helmet on the racks in this build';
     __pinDPR(1); __forceSize(1920,1080); __resetCfg(); __pinDefaults(0); __cleanProfile();
     var P2=__P(); var keep={runs:P2.runs,ext:P2.ext,kills:P2.kills,xpLevel:P2.xpLevel,spClaimed:P2.spClaimed,nightExt:P2.nightExt,bestStreak:P2.bestStreak,extStreak:P2.extStreak};
     // Every gate but the extraction count is already past, so the only piece a
     // raid can earn is one the twentieth extraction earns. (The first draft
     // started from zero and the second raid earned a run-gated face.)
     P2.runs=500; P2.ext=19; P2.kills={warden:99,crawler:999}; P2.xpLevel=99; P2.spClaimed=(typeof SEASON_TIERS!=='undefined')?SEASON_TIERS.map(function(t,i){ return i; }):[];
     P2.nightExt=99; P2.bestStreak=99; P2.extStreak=99;
     // ONE: the twentieth extraction earns the Spartan helmet, and the card says so.
     __deploy({kit:[],safe:null,mapIx:0,seed:4242});
     var g=__state(); if(!g) return 'SKIP: no raid';
     g.ents.length=0;
     P2.ext=19;
     __endRaid('extract');
     var el=document.getElementById('oc_earned');
     // THE FINDING. On v10.43 the card had no earned line at all.
     if(!el) return 'the outcome card has no earned line';
     var txt=el.textContent||'';
     if((P2.ext||0)<20) bad.push('staging: the extraction did not move the counter ('+P2.ext+')');
     else if(txt.indexOf('EARNED THIS RAID')<0||txt.indexOf('SPARTAN HELMET')<0) bad.push('the card does not name the helmet the extraction earned: "'+txt+'"');
     if(/OLIVE DRAB|BLACK BOOTS|SLATE/.test(txt)) bad.push('the card lists pieces owned from the start: "'+txt+'"');
     var ob=document.getElementById('oc_btn'); if(ob) ob.click();
     // CONTROL: the next raid earns nothing new, and the line is empty. It ends in
     // a death, which always writes a card; an abandon with nothing looted writes
     // no card at all and would leave the last one's text standing.
     __deploy({kit:[],safe:null,mapIx:0,seed:4242});
     g=__state(); if(g) g.ents.length=0;
     __endRaid('dead');
     var el2=document.getElementById('oc_earned'), txt2=el2?el2.textContent:'';
     if(txt2.replace(/\s/g,'').length) bad.push('control: a raid that earned nothing still lists "'+txt2+'"');
     var ob2=document.getElementById('oc_btn'); if(ob2) ob2.click();
     for(var k in keep) P2[k]=keep[k];
     return bad.length?bad.join('; '):null; }},
  {v:'10.43',what:'the Depot and the outcome card name the next piece on the racks and how far off it is',
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
