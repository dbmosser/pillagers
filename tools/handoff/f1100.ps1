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
  {v:'10.99',what:'a pillager wears the hat, the beard and the tattoo his look rolled
'@ @'
  {v:'11.00',what:'he picks the weather on the way up, the hard ones pay his bonus, and pinning one does not move the seeded map',
   run:function(){
     if(!(window.__deploy&&window.__state&&window.__P)) return 'SKIP: this fixture cannot deploy';
     if(typeof WEATHER==='undefined') return 'SKIP: this build has no weather table';
     var bad=[], prof=__P(), keepPick=prof.wxPick, keepXp=prof.xp, keepLvl=prof.xpLevel, i;
     try{
       __runPrep(); __resetCfg(); __pinDefaults(0);
       // 1. THE CONTROL IS ON THE PAGE, in the same shape as his SURFACE row.
       var host=document.getElementById('sectorwx');
       if(!host) return 'the sector page has no weather control at all, which is his note';
       var btns=host.querySelectorAll('.wxb');
       if(btns.length<5) bad.push('the weather row offers only '+btns.length+' choices');
       var ids={}, j;
       for(j=0;j<btns.length;j++) ids[btns[j].getAttribute('data-wx')]=btns[j];
       if(!ids.any) bad.push('there is no way to leave the weather to the roll, which was the old behaviour and has to stay reachable');
       // 2. PRESSING ONE PINS IT, and the raid comes up in it. Driven through the
       //    button, not by writing the profile, because the button is the thing
       //    he presses.
       var want=null;
       for(j=0;j<btns.length;j++){ var id=btns[j].getAttribute('data-wx'); if(id&&id!=='any'){ want=id; btns[j].click(); break; } }
       if(!want) bad.push('control: the weather row offers nothing to pin, so nothing below is tested');
       else {
         if(prof.wxPick!==want) bad.push('pressing '+want+' did not stick, the profile says '+prof.wxPick);
         __deploy({kit:[],safe:null,mapIx:0,seed:4242});
         var got=(__state().wx&&__state().wx.id)||'none';
         if(got!==want) bad.push('he asked for '+want+' and the raid came up '+got);
       }
       // 3. AND EVERY OTHER PINNABLE WEATHER LANDS TOO.
       for(j=0;j<btns.length;j++){
         var w2=btns[j].getAttribute('data-wx'); if(!w2||w2==='any') continue;
         prof.wxPick=w2;
         __deploy({kit:[],safe:null,mapIx:0,seed:4242});
         var g2=(__state().wx&&__state().wx.id)||'none';
         if(g2!==w2) bad.push(w2+' cannot be chosen, the raid came up '+g2);
       }
       // 4. THE ONE THAT WOULD HAVE BEEN INVISIBLE. The weather is ONE DRAW from
       //    the seeded stream. An implementation that skips the roll when a
       //    weather is pinned moves every roll after it, and the map, the loot
       //    and the bodies all change without a word. Same seed, same map, three
       //    different pins: the counts must be identical.
       function fingerprint(pick){
         prof.wxPick=pick;
         __deploy({kit:[],safe:null,mapIx:0,seed:4242});
         var g=__state();
         return g.ents.length+'/'+(g.containers?g.containers.length:-1)+'/'+(g.map&&g.map.walls?g.map.walls.length:-1);
       }
       var f0=fingerprint('any'), fA=fingerprint('storm'), fB=fingerprint('clear');
       if(fA!==f0) bad.push('pinning storm changed the map itself: '+f0+' became '+fA+', so the seeded roll was skipped rather than overridden');
       if(fB!==f0) bad.push('pinning clear changed the map itself: '+f0+' became '+fB);
       // 5. HIS 1.1x, AND ONLY FOR THE HARD ONES.
       if(typeof wxHardId!=='function'||typeof wxXpMul!=='function')
         bad.push('the build has no idea which weather is hard, so nothing can pay for it');
       else {
         var HARD=['rain','fog','blackout','storm'], EASY=['clear','partly'];
         for(i=0;i<HARD.length;i++) if(!wxHardId(HARD[i])) bad.push(HARD[i]+' does not count as hard going and it cuts your sight or your lamps');
         for(i=0;i<EASY.length;i++) if(wxHardId(EASY[i])) bad.push('control: '+EASY[i]+' counts as hard going, so every weather pays and the bonus means nothing');
         if(!(wxXpMul()>1)) bad.push('control: the weather bonus is '+wxXpMul()+', so there is no bonus to test');
         // AND IT REACHES THE PAYOUT, not just the table. Two identical runs, one
         // hard and one not, through the real progress path.
         if(typeof addProgress==='function'){
           function rec(hard){ return {outcome:'extract',haul:2000,carriedIn:0,dur:120,kills:0,night:0,wxHard:hard,
                                       cont:1,items:3,mapIx:0,wx:hard?'fog':'clear'}; }
           var r0=rec(0), r1=rec(1);
           prof.xp=0; addProgress(r0);
           prof.xp=0; addProgress(r1);
           if(!(r0.xpBase>0)) bad.push('control: a clear run paid '+r0.xpBase+' XP, so there is nothing for the bonus to multiply');
           else {
             var ratio=r1.xpBase/r0.xpBase;
             if(Math.abs(ratio-wxXpMul())>0.03)
               bad.push('a hard weather run paid '+r1.xpBase+' against '+r0.xpBase+' for a clear one, a ratio of '+ratio.toFixed(3)+' and not the '+wxXpMul()+' he asked for');
           }
         }
       }
     } finally {
       prof.wxPick=keepPick; prof.xp=keepXp; prof.xpLevel=keepLvl;
       try{ __resetCfg(); }catch(_rc){}
     }
     return bad.length?bad.join('; '):null; }},
  {v:'10.99',what:'a pillager wears the hat, the beard and the tattoo his look rolled
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
