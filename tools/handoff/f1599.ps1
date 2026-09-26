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
  {v:'15.98',what:
'@ @'
  {v:'15.99',what:'the sector map header names the weather it is leaving, and the CONDITIONS row says night at night: in a live raid staged at noon under rain, with a turn from Rainy to Storming a quarter of the way through the sector map header reads Rainy, the arrow, Storming and 25%, and three quarters of the way through, when the live blend already carries the storm name, it still reads Rainy on the left of the arrow and Storming at 75% on the right; and by day the CONDITIONS row reads noon and Rainy, at NIGHT it reads night (in either case) and Rainy and no row reads the noon hour, and back by day the noon hour is on it again (weather audit finding)',
   run:function(){
     if(!(window.__deploy&&window.__state&&window.__endRaid&&window.__P&&window.__applyLoaded)) return 'SKIP: this fixture cannot deploy';
     if(typeof drawHUD!=='function'||typeof drawMapOverlay!=='function'||typeof isDay!=='function'||typeof wx!=='function'||typeof TODS==='undefined'||typeof WEATHER==='undefined') return 'SKIP: no HUD draw, sector map, day test, weather blend or weather tables in this build';
     if(typeof ctx==='undefined'||!ctx) return 'SKIP: no HUD canvas in this build';
     if(!window.innerWidth||!window.innerHeight) return 'SKIP: the pane is 0x0, so nothing is drawn';
     var bad=[], snap=null, g=null, keep=null, got=[], realFT=null, ownFT=false, i;
     var OWN=Object.prototype.hasOwnProperty, ARROW='\u2192';
     // The night word is assembled from pieces, so the check never finds its own source; the hour and the weathers are read
     // off the tables the game draws from.
     var NIGHT=['NI','GHT'].join('');
     var rain=null, storm=null, noon=null;
     for(i=0;i<WEATHER.length;i++){ if(WEATHER[i].id==='rain') rain=WEATHER[i]; if(WEATHER[i].id==='storm') storm=WEATHER[i]; }
     for(i=0;i<TODS.length;i++) if(TODS[i].id==='noon') noon=TODS[i];
     if(!rain||!storm||!noon||!rain.name||!storm.name||!noon.name) return 'SKIP: no rain, storm or noon in the tables to stage';
     // A later control that cannot run keeps a failure already found, so the old build fails rather than skips.
     var skip=function(m){ return bad.length?(bad.join('; ')+' (then SKIP: '+m+')'):('SKIP: '+m); };
     // One HUD frame with the sector map shut, and one sector map frame: every string each one drew.
     function hud(){ got.length=0; g.mapOpen=false; drawHUD(); return got.slice(); }
     function map(){ got.length=0; drawMapOverlay(); return got.slice(); }
     function first(list,head){ for(var k=0;k<list.length;k++) if(list[k].indexOf(head)===0) return list[k]; return null; }
     function firstNoCase(list,head){ var h=head.toUpperCase(); for(var k=0;k<list.length;k++) if(list[k].toUpperCase().indexOf(h)===0) return list[k]; return null; }
     function arrowed(list){ for(var k=0;k<list.length;k++) if(list[k].indexOf(ARROW)>=0) return list[k]; return null; }
     // The strings that name a weather, for the report: the CONDITIONS row is the only HUD string that names one.
     function wxRows(list){ var o=[]; for(var k=0;k<list.length;k++) if(list[k].indexOf(rain.name)>=0||list[k].indexOf(storm.name)>=0) o.push(list[k]); return '['+o.join(' | ')+']'; }
     try{
       __topClear(); __runPrep(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       snap=JSON.parse(JSON.stringify(__P()));
       __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       g=__state(); if(!g||!g.player||g.over||g.sim||!g.wx) return 'SKIP: no live raid with a weather';
       keep={tod:g.tod,wx:g.wx,wxNext:g.wxNext,wxT:g.wxT,mapOpen:g.mapOpen};
       // The CONDITIONS panel open, so its rows are drawn where the check reads. The profile snapshot puts this back.
       var HP=__P().hud; if(HP&&HP.cond) HP.cond.c=false;
       ownFT=OWN.call(ctx,'fillText'); realFT=ctx.fillText;
       ctx.fillText=function(t){ got.push(String(t)); return realFT.apply(this,arguments); };
       // THE STAGE: noon under rain, no turn running, by day.
       __P().cond='day'; g.tod=noon; g.wx=rain; g.wxNext=null; g.wxT=0;
       if(!isDay()) return 'SKIP: the surface did not read as day here';
       // CONTROL: by day the CONDITIONS row names the noon hour and the rain, so the row is drawn where the check reads, on either build.
       var h0=hud();
       if(!h0.length) return 'SKIP: the HUD drew no text here';
       if(!first(h0,noon.name+'   '+rain.name)) return 'SKIP: by day the CONDITIONS row did not read the noon hour and the rain, the weather rows drawn were '+wxRows(h0)+', so the row cannot be found here';
       // THE FIX, ONE: at NIGHT the row says NIGHT, and never the hidden daylight hour.
       __P().cond='night';
       if(isDay()) return 'SKIP: the surface did not read as night here';
       var h1=hud();
       var rowHour=first(h1,noon.name+'   '+rain.name), rowNight=firstNoCase(h1,NIGHT+'   '+rain.name);
       if(rowHour) bad.push('at NIGHT the CONDITIONS row still reads ['+rowHour+'], the hidden daylight hour, on a raid he sent up in the dark');
       else if(!rowNight) bad.push('at NIGHT the CONDITIONS row does not read '+NIGHT+' beside the rain, the weather rows drawn were '+wxRows(h1));
       // CONTROL: back by day, the noon hour is on the row again.
       __P().cond='day';
       if(!first(hud(),noon.name+'   '+rain.name)) bad.push('back by day the CONDITIONS row no longer names the noon hour and the rain');
       // THE TURN: rain turning to storm, a quarter of the way through.
       g.wxNext=storm; g.wxT=0.25;
       var want25=noon.name+'  '+rain.name+'  '+ARROW+' '+storm.name+'  25%';
       var a0=arrowed(map());
       if(!a0) return skip('the sector map header drew no arrow while the weather turned here');
       // CONTROL: a quarter of the way through, the header names the rain, the arrow, the storm and 25 percent, on either build.
       if(a0!==want25) return skip('a quarter of the way through the turn the sector map header read ['+a0+'] rather than ['+want25+'], so the header cannot be read here');
       // CONTROL: three quarters of the way through, the live blend itself already carries the storm name, which is what the header used to print.
       g.wxT=0.75;
       var W2=wx();
       if(!W2||W2.name!==storm.name) return skip('three quarters of the way through the turn the live weather blend does not carry the storm name, so the turn staging did not take');
       // THE FIX, TWO: the header still names the rain on the left of the arrow, the weather the turn is leaving.
       var want75=noon.name+'  '+rain.name+'  '+ARROW+' '+storm.name+'  75%';
       var a1=arrowed(map());
       if(!a1) bad.push('three quarters of the way through the turn the sector map header drew no arrow');
       else if(a1.indexOf(noon.name+'  '+storm.name+'  '+ARROW)===0) bad.push('three quarters of the way through a turn from rain to storm the sector map header reads ['+a1+'], the coming weather on both sides of the arrow, while the CONDITIONS row still says '+rain.name);
       else if(a1!==want75) bad.push('three quarters of the way through the turn the sector map header reads ['+a1+'] rather than ['+want75+']');
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{
       try{ if(realFT){ if(ownFT) ctx.fillText=realFT; else delete ctx.fillText; } }catch(_f){}
       try{ if(g&&keep){ g.tod=keep.tod; g.wx=keep.wx; g.wxNext=keep.wxNext; g.wxT=keep.wxT; g.mapOpen=keep.mapOpen; } }catch(_g){}
       try{ if(g&&!g.over) __endRaid('abandon'); }catch(_e){}
       try{ if(snap) __applyLoaded(snap); }catch(_r){}
       try{ __topClear(); __resetCfg(); __cleanProfile(); }catch(_c){}
     }
     return bad.length?bad.join('; '):null; }},
  {v:'15.98',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
