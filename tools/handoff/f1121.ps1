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
  {v:'11.20',what:'a body never stands still on a route: the waypoint it is steering at counts as reached at one step, the same step seekPoint calls arriving, so a coarse step cannot deadlock the two',
'@ @'
  {v:'11.21',what:'on THE COLD MILE the robot never stands still on a route either, and the two arms of the paired run are the same raid on two rule sets there too',
   run:function(){
     if(!(window.__simTraceSeed&&window.__deploy)) return 'SKIP: this fixture cannot replay a seeded sim raid';
     var bad=[], i;
     // THREE SEEDED RAIDS ON THE MILE with the shipping rules: never fifteen
     // seconds standing still with a route in hand and health left.
     var seeds=[9001,9002,9003], moved=0, samples=0;
     for(var q=0;q<seeds.length;q++){
       __runPrep(); __resetCfg(); __pinDefaults(1); __P().mapIx=1;
       var r=__simTraceSeed(seeds[q]), S=r.samples, run=0, worst=0, at=null;
       for(i=1;i<S.length;i++){ var c=S[i]; moved+=c[3]; if(c[3]===0&&c[7]>0&&c[5]>0){ run++; if(run>worst){ worst=run; at=c[0]; } } else run=0; }
       samples+=S.length;
       if(worst>=3) bad.push('on the mile the bot stood still with a route in hand for '+(worst*5)+' seconds ending at '+at+' seconds into seed '+seeds[q]);
     }
     // CONTROL ONE: the raids really ran.
     if(samples<30||moved<1500) bad.push('control: three mile raids ran '+samples+' samples and moved '+moved+' units between them, so nothing here was measured');
     // CONTROL TWO: the two arms build the same raid. Entities and containers
     // identical with the seven rules off and on, at the mile fingerprint.
     function arm(off){
       __runPrep(); __resetCfg(); __pinDefaults(1);
       if(off) __cfg({winWalk:0,furnDoor:0,navBody:0,doorClear:0,furnIDoor:0,furnGap:0,partDoor:0});
       __deploy({kit:[],safe:null,mapIx:1,seed:4242});
       var g=__state(); return {ents:g.ents.length,cont:(g.containers||[]).length,walls:g.map.walls.length};
     }
     var on=arm(false), off=arm(true);
     if(on.ents!==off.ents||on.cont!==off.cont) bad.push('the mile arms differ in entities or containers, '+off.ents+'/'+off.cont+' against '+on.ents+'/'+on.cont+', so a paired seed there is not the same raid on two rule sets');
     if(on.walls===off.walls) bad.push('control: the seven rules off build the same walls on the mile as the rules on, '+on.walls+', so the old arm is not the old world');
     if(on.ents!==374||on.cont!==593) bad.push('THE COLD MILE at seed 4242 holds '+on.ents+' entities and '+on.cont+' containers rather than 374 and 593');
     return bad.length?bad.join('; '):null; }},
  {v:'11.20',what:'a body never stands still on a route: the waypoint it is steering at counts as reached at one step, the same step seekPoint calls arriving, so a coarse step cannot deadlock the two',
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
