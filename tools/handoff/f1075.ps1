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
  {v:'10.74',what:'the two buttons at the end of a raid stay inside the card, with a full bag and with an empty one, whether the ledger is scrolled to the top or the bottom',
'@ @'
  {v:'10.75',what:'an extraction point closing is announced by the same letter the map draws on it, not by a number that is nowhere on the map',
   run:function(){
     var bad=[];
     if(!(window.__startRaid&&window.__state&&window.__keysRef&&window.__loop)) return 'SKIP: this build cannot run the raid clock';
     if(typeof extLetter!=='function') return 'SKIP: this build has no letter for an extraction point';
     __resetCfg(); __pinDefaults(0); __pinDPR(1); __forceSize(1920,1080);
     __startRaid({mapIx:0,seed:4242});
     var g=__state();
     if(!g.zones||g.zones.length<2) return 'SKIP: this map has fewer than two extraction points';
     var shuts=0;
     for(var i=0;i<g.zones.length;i++) if(g.zones[i].closeAt!==undefined) shuts++;
     if(!shuts) return 'SKIP: nothing closes on this map and seed, so nothing announces a closure';
     var K=__keysRef(); for(var k in K) K[k]=false;
     var said=[];
     var realSay=(typeof say==='function')?say:null;
     if(!realSay) return 'SKIP: no say to listen to';
     try{
       say=function(m){ said.push(String(m)); return realSay.apply(null,arguments); };
       // Run the clock down past the close times with the real frame loop, so
       // the game announces them itself rather than being told to.
       g.timeLeft=200;
       for(var f=0;f<20;f++) __loop(performance.now()+f*16.7);
     } finally { say=realSay; }
     var lines=said.filter(function(m){ return /extraction/i.test(m)&&/clos/i.test(m); });
     if(!lines.length) return 'SKIP: no closure was announced in the frames driven';
     // THE MAP IS THE AUTHORITY: whatever it draws on the ring is what the
     // message must say. Both come from the same place now, so this reads the
     // letters off the zones rather than assuming A, B, C.
     var letters=[];
     for(var z=0;z<g.zones.length;z++) letters.push(extLetter(g.zones[z]));
     lines.forEach(function(m){
       var num=/Extraction\s+(\d+)\b/i.exec(m);
       if(num) bad.push('a closure is announced as "'+m.trim()+'", and the map draws EXTRACT '+letters.join(', ')+' with no '+num[1]+' on it');
       else{
         var got=/Extraction\s+([A-Z])\b/.exec(m);
         if(!got) bad.push('a closure is announced without naming which point: "'+m.trim()+'"');
         else if(letters.indexOf(got[1])<0) bad.push('a closure names EXTRACT '+got[1]+', which is not one of the letters on the map ('+letters.join(', ')+')');
       }
     });
     // CONTROL: the letters really are what the map paints, read from the same
     // function the map screen calls, so this cannot pass by agreeing with
     // itself about a name neither surface uses.
     if(letters[0]!=='A') bad.push('control: the first extraction point reads as '+letters[0]+' rather than A, so the letters are not what they were');
     return bad.length?bad.join('; '):null; }},
  {v:'10.74',what:'the two buttons at the end of a raid stay inside the card, with a full bag and with an empty one, whether the ledger is scrolled to the top or the bottom',
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
