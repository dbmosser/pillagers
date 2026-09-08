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

# v12.54 CHECK, inserted before the v12.53 entry. The stale figure is 7777,
# which no bag in the game can produce, so a pass can never come from the two
# numbers happening to agree. The pillager makes the call himself through the
# real state machine rather than having the line called for him. The control is
# the same ring with the same stale figure and the call shut off: the figure
# must SURVIVE, or something else is clearing it and this check would be
# crediting the wrong line.
SubRx @'
  {v:'12.53',what:'a machine searching for him gives up on a point it can never reach instead of pushing at the nearest wall for the rest of the raid, and the scatter that chooses that point no longer picks somewhere a body cannot stand; a search of open ground still ends by arriving (2026-09-07 audit)',
'@ @'
  {v:'12.54',what:'a pillager calling extraction throws away the figure the siege is sized from, so it is read again from the bag actually being carried instead of keeping whatever an earlier call at that point left behind (2026-09-07 audit)',
   run:function(){
     if(!(window.__deploy&&window.__state&&window.__ents&&window.__endRaid)) return 'SKIP: this fixture cannot deploy a raid and step the pillagers';
     if(typeof greedOf!=='function'||typeof tickExtractPoints!=='function') return 'SKIP: this build has no siege size to read or no ticker to read it with';
     var bad=[];
     var STALE=7777;   // a figure no bag in the game can produce
     function stage(open){
       __topClear(); __runPrep(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       __deploy({kit:[],mapIx:0,seed:4242});
       var g=__state(); if(!g||!g.player||!g.zones||!g.zones.length) return null;
       var p=g.player, i, e=null;
       for(i=0;i<g.ents.length&&!e;i++) if(g.ents[i].kind==='raider'&&!g.ents[i].downed&&!g.ents[i].finished&&!g.ents[i].merc) e=g.ents[i];
       if(!e) return {none:'no pillager on this map and seed to call an extraction'};
       g.ents.length=0; g.ents.push(e);
       var z=g.active||g.zones[0];
       g.active=z; z.open=!!open; z.beaconT=null; z.hold=null; z.pullT=null;
       z.siegeGreed=STALE;                     // what an earlier call left behind
       g.beaconT=null; g.shipHold=null;
       g.bag=[];                               // and the bag he is holding NOW is empty
       p.downed=false; p.iv=99; p.x=z.x+2200; p.y=z.y+2200;
       e.state='extract'; e.kind='raider'; e.downed=false; e.finished=false;
       e.x=z.x; e.y=z.y; e.rcallT=0; e.extracting=0; e.hp=e.maxhp||e.hp;
       return {g:g,e:e,z:z,p:p};
     }
     function run(st,secs){
       var i, z=st.z;
       for(i=0;i<Math.round(secs/0.1);i++){
         __ents(0.1);
         if(z.beaconT!==null&&z.beaconT!==undefined) return {called:true,secs:i*0.1};
       }
       return {called:false,secs:secs};
     }
     try{
       var A=stage(1);
       if(!A) return 'SKIP: no live raid with an extraction point to call';
       if(A.none) return 'SKIP: '+A.none;
       var r=run(A,12);
       if(!r.called) return 'SKIP: the pillager did not call the extraction in twelve seconds, so the call under test never happened';
       if(A.z.siegeGreed===STALE)
         bad.push('the pillager called the extraction and the ring kept the figure your own earlier call left behind: the siege will be sized on a bag you are no longer carrying');
       // And once the ticker has read it, it must be the bag he is holding now.
       tickExtractPoints(0.01);
       var want=greedOf();
       if(A.z.siegeGreed!==want)
         bad.push('after the pillager call the ring sizes its siege on '+A.z.siegeGreed+' rather than the '+want+' the bag actually in hand is worth');
       // CONTROL: the same ring, the same stale figure, and no call at all. It
       // must SURVIVE, or something else is clearing it and this check would be
       // crediting a line that did nothing.
       var B=stage(0);
       if(B&&!B.none){
         var r2=run(B,12);
         if(r2.called) bad.push('control: the pillager called a closed extraction point, so this staging does not isolate the call');
         else if(B.z.siegeGreed!==STALE) bad.push('control: the stale figure was cleared with no call made at all, so something other than the call is doing it and this check proves nothing');
       }
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{
       try{ var gz=__state(); if(gz){ if(gz.ents) gz.ents.length=0; if(gz.player) gz.player.iv=0; } }catch(_a){}
       try{ var g2=__state(); if(g2&&!g2.over) __endRaid('abandon'); }catch(_e){}
       __topClear(); __resetCfg(); __cleanProfile();
     }
     return bad.length?bad.join('; '):null; }},
  {v:'12.53',what:'a machine searching for him gives up on a point it can never reach instead of pushing at the nearest wall for the rest of the raid, and the scatter that chooses that point no longer picks somewhere a body cannot stand; a search of open ground still ends by arriving (2026-09-07 audit)',
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
