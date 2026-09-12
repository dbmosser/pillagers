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

# v12.93 CHECK, inserted before the v12.92 entry.
#
# IT STAGES THE EXACT SHAPE THE AUDIT DESCRIBED: a ring he has called, and a
# NEARER ring he has not. That is the arrangement in which the old line sent him
# the wrong way, and it is the only arrangement where naming the nearest open ring
# and naming his own ride give different answers, so a check that did not build it
# would be green either way.
#
# THE VERB MATTERS AS MUCH AS THE DESTINATION. Standing on a landed ship, holding E
# extracts; the old line said it would CALL one. So the landed wording is required
# to say extract and required not to say call.
#
# THE CONTROL IS THAT NOTHING CHANGES WHEN NOTHING IS CALLED. Both original
# sentences are required back word for word, because the easiest way to pass every
# arm above is to rewrite the line for all cases and quietly retire two good ones.
SubRx @'
  {v:'12.92',what:'on a controller every Undercroft station prompt
'@ @'
  {v:'12.93',what:'the last-minute warnings name the extraction he actually called: standing on a landed ship it says hold E to extract rather than to call one, waiting for an inbound ship it says how long, and with a nearer ring uncalled it still names his own ride, while with nothing called both original sentences are unchanged (audit finding 7, 2026-09-11)',
   run:function(){
     if(!(window.__deploy&&window.__state)) return 'SKIP: this fixture cannot deploy a raid';
     if(typeof outHint!=='function') return 'SKIP: this build has no way-out hint to read';
     var bad=[];
     try{
       __topClear(); __runPrep(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       var g=__state();
       if(!g||!g.zones||g.zones.length<2) return 'SKIP: this map has fewer than two rings, so the wrong-ring case cannot be staged';
       var p=g.player, mine=g.zones[0], other=g.zones[1], i;
       for(i=0;i<g.zones.length;i++){ g.zones[i].open=true; g.zones[i].beaconT=null; g.zones[i].hold=null; }
       g.active=null; g.beaconT=null;
       // NOTHING CALLED. Both original sentences, word for word.
       p.x=mine.x; p.y=mine.y;
       var inNone=outHint(1);
       if(inNone!=='You are standing in the way out. Hold E to call it.')
         bad.push('control: with nothing called, standing in a ring no longer says the line it has always said; it says ['+inNone+']');
       p.x=mine.x+mine.r+900; p.y=mine.y;
       var outNone=outHint(1);
       if(!/^Nearest way out \d+m [a-z ]+\. Stand in it and hold E\.$/.test(outNone))
         bad.push('control: with nothing called, standing away from every ring no longer says the line it has always said; it says ['+outNone+']');
       // A SHIP INBOUND, and he is standing in the ring he called.
       mine.beaconT=17; mine.hold=null; g.active=mine; g.beaconT=17;
       p.x=mine.x; p.y=mine.y;
       var inb=outHint(1);
       if(/[Hh]old E to call/.test(inb))
         bad.push('with a ship already inbound to the ring he is standing in, the warning still tells him to hold E to call one');
       if(inb.indexOf('17')<0)
         bad.push('the warning does not tell him how long his ride is: it says ['+inb+'] with 17 seconds to go');
       // THE SHIP IS DOWN. Holding E here extracts, so the line must say extract.
       mine.beaconT=0; mine.hold=12; mine.holdMax=30;
       var land=outHint(1);
       if(/[Hh]old E to call/.test(land))
         bad.push('standing on a landed ship the warning tells him to hold E to CALL an extraction, which is not what holding E there does: it extracts him, so the line names a different action than the one that happens');
       if(!/extract/i.test(land))
         bad.push('standing on a landed ship the warning never says the word extract: it says ['+land+']');
       if(land.indexOf('12')<0)
         bad.push('standing on a landed ship the warning does not say how long the window has left: it says ['+land+'] with 12 seconds on it');
       if(land===inb)
         bad.push('the warning says exactly the same thing whether the ship is down or still coming, which are opposite instructions');
       // THE WRONG-RING CASE: his ride is called, and a ring he has not called is
       // NEARER. This is the shape that used to walk him away from the ship he had
       // already paid for.
       other.open=true; other.beaconT=null; other.hold=null;
       p.x=other.x+other.r*0.4; p.y=other.y;
       var far=Math.sqrt((p.x-mine.x)*(p.x-mine.x)+(p.y-mine.y)*(p.y-mine.y));
       var near=Math.sqrt((p.x-other.x)*(p.x-other.x)+(p.y-other.y)*(p.y-other.y));
       if(near<far){
         var wrong=outHint(1);
         if(/Stand in it and hold E/.test(wrong)||/[Hh]old E to call/.test(wrong))
           bad.push('with his own ship already called, the warning points him at the nearer ring he has NOT called and tells him to start a second wait there, while the arrow beside it points the other way at the ride he has: it says ['+wrong+']');
       }
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{
       try{ var g2=__state();
            if(g2&&g2.zones){ for(var z=0;z<g2.zones.length;z++){ g2.zones[z].beaconT=null; g2.zones[z].hold=null; } }
            if(g2){ g2.active=null; g2.beaconT=null; }
            if(g2&&!g2.over){ g2.player.downed=false; __endRaid('abandon'); } }catch(_e){}
       try{ __topClear(); __resetCfg(); __cleanProfile(); }catch(_c){}
     }
     return bad.length?bad.join('; '):null; }},
  {v:'12.92',what:'on a controller every Undercroft station prompt
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
