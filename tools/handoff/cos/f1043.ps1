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
  {v:'10.42',what:'the Depot is a paper doll: a tile per slot on either side of the figure, head things left, body things right, all inside the window',
'@ @'
  {v:'10.43',what:'the Depot and the outcome card name the next piece on the racks and how far off it is',
   run:function(){
     var bad=[];
     if(!__vpAlive()) return 'SKIP: the pane has no layout';
     if(typeof COSMETICS==='undefined'||!cosFind('spartan')) return 'SKIP: no Spartan helmet on the racks in this build';
     // THE FINDING. On v10.42 nothing named the next piece anywhere.
     if(typeof cosNextLine!=='function') return 'nothing names the next piece';
     __pinDPR(1); __forceSize(1920,1080); __resetCfg(); __pinDefaults(0); __cleanProfile();
     var P2=__P(); var keep={runs:P2.runs,ext:P2.ext,kills:P2.kills,xpLevel:P2.xpLevel,spClaimed:P2.spClaimed,nightExt:P2.nightExt,bestStreak:P2.bestStreak,extStreak:P2.extStreak};
     // ONE: with nineteen extractions the Spartan helmet (twenty) is one away and must be the piece named.
     P2.runs=0; P2.ext=19; P2.kills={}; P2.xpLevel=1; P2.spClaimed=[];
     var line=cosNextLine();
     if(line.indexOf('SPARTAN HELMET')<0) bad.push('at nineteen extractions the next piece is not the Spartan helmet: "'+line+'"');
     if(!/1 MORE EXTRACTION\b/.test(line)) bad.push('the distance is not one extraction: "'+line+'"');
     // TWO: the Depot shows it.
     if(window.__hubEnter&&window.__station){
       __hubEnter(); var r=null; try{ r=__station('mirror'); }catch(e1){ r={err:String(e1)}; }
       var an=document.getElementById('appnext');
       if(!r||r.err) bad.push('the Depot did not open');
       else if(!an||an.textContent.indexOf('SPARTAN HELMET')<0) bad.push('the Depot does not name the next piece ("'+(an?an.textContent:'no line')+'")');
       var cl=document.getElementById('closeappear'); if(cl) cl.click();
     }
     // THREE: the outcome card shows it, with the counters this raid moved.
     __deploy({kit:[],safe:null,mapIx:0,seed:4242});
     var g=__state(); if(!g) return 'SKIP: no raid';
     g.ents.length=0;
     P2.ext=19;
     __endRaid('extract');
     var on=document.getElementById('oc_next');
     if(!on) bad.push('the outcome card has no next-piece line');
     else if(on.textContent.indexOf('NEXT ON THE RACKS')<0) bad.push('the outcome card line is empty after an extract');
     else if(on.textContent.indexOf('SPARTAN HELMET')>=0&&(P2.ext||0)>=20) bad.push('the card still names the helmet after the extraction that earned it: "'+on.textContent+'"');
     var ob=document.getElementById('oc_btn'); if(ob) ob.click();
     // CONTROL: with everything earned the line says the racks are complete, not a piece.
     P2.runs=999; P2.ext=999; P2.kills={warden:99,crawler:999}; P2.xpLevel=99; P2.spClaimed=(typeof SEASON_TIERS!=='undefined')?SEASON_TIERS.map(function(t,i){ return i; }):[];
     P2.nightExt=99; P2.bestStreak=99; P2.extStreak=99;   // the play-style gates too, once they exist
     var full=cosNextLine();
     if(full.indexOf('NEXT ON THE RACKS')>=0) bad.push('control: with everything earned it still names a piece: "'+full+'"');
     for(var k in keep) P2[k]=keep[k];
     return bad.length?bad.join('; '):null; }},
  {v:'10.42',what:'the Depot is a paper doll: a tile per slot on either side of the figure, head things left, body things right, all inside the window',
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
