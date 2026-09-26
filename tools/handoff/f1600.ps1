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
  {v:'15.99',what:
'@ @'
  {v:'16.00',what:'rain and fog draw at night strength on every night raid: in a live raid staged under rain and then under fog, by day on the noon hour the rain hairlines and the fog haze draw at their full strength, by day on the 8pm hour each draws clearly dimmer, at NIGHT on the same noon hour each draws at that same 8pm figure and not at the full noon strength of the hidden hour, and back by day at noon the rain is at full strength again (weather audit finding)',
   run:function(){
     if(!(window.__deploy&&window.__state&&window.__endRaid&&window.__P&&window.__applyLoaded)) return 'SKIP: this fixture cannot deploy';
     if(typeof render2D!=='function'||typeof isDay!=='function'||typeof wx!=='function'||typeof TODS==='undefined'||typeof WEATHER==='undefined') return 'SKIP: no world draw, day test, weather blend or weather tables in this build';
     if(typeof wc==='undefined'||!wc) return 'SKIP: no world canvas in this build';
     if(!window.innerWidth||!window.innerHeight) return 'SKIP: the pane is 0x0, so nothing is drawn';
     var bad=[], snap=null, g=null, keep=null, i;
     var OWN=Object.prototype.hasOwnProperty, realStroke=null, ownStroke=false, realFill=null, ownFill=false;
     var rain=null, fog=null, noon=null, dusk=null;
     for(i=0;i<WEATHER.length;i++){ if(WEATHER[i].id==='rain') rain=WEATHER[i]; if(WEATHER[i].id==='fog') fog=WEATHER[i]; }
     for(i=0;i<TODS.length;i++){ if(TODS[i].id==='noon') noon=TODS[i]; if(TODS[i].id==='dusk') dusk=TODS[i]; }
     if(!rain||!fog||!noon||!dusk||!(rain.rain>0)||!(fog.fog>0)) return 'SKIP: no rain, fog, noon or 8pm in the tables to stage';
     if(!(noon.lights<dusk.lights)) return 'SKIP: the 8pm hour is not darker than noon in the table, so the two hours cannot be told apart here';
     // A later control that cannot run keeps a failure already found, so the old build fails rather than skips.
     var skip=function(m){ return bad.length?(bad.join('; ')+' (then SKIP: '+m+')'):('SKIP: '+m); };
     // The hairlines are one stroke in the rain colour and the haze one full screen fill in the fog colour; the alpha of each
     // is read off the style at the moment it is drawn, in whatever form the canvas hands the style back.
     var RAIN_RX=/rgba\(\s*176\s*,\s*196\s*,\s*232\s*,\s*([0-9.]+)\s*\)/, FOG_RX=/rgba\(\s*200\s*,\s*210\s*,\s*222\s*,\s*([0-9.]+)\s*\)/;
     var seen={rain:null,fog:null};
     function grab(rx,style){ var m=rx.exec(String(style)); return m?parseFloat(m[1]):null; }
     // Close enough: within 12 percent of the larger, which covers the canvas rounding the alpha to a byte and nothing else.
     function near(a,b){ return a!==null&&b!==null&&Math.abs(a-b)<=0.12*Math.max(a,b); }
     function dimmer(a,b){ return a!==null&&b!==null&&b<0.8*a; }
     function fmt(v){ return v===null?'nothing':String(v); }
     // One world frame on the staged surface, hour and weather: what the rain stroke and the fog haze drew at.
     function frame(day,hour,weather){
       __P().cond=day?'day':'night'; g.tod=hour; g.wx=weather; g.wxNext=null; g.wxT=0;
       seen.rain=null; seen.fog=null;
       try{ render2D(0.016); }catch(e){ return {rain:null,fog:null,err:'threw: '+(e&&e.message||e)}; }
       return {rain:seen.rain,fog:seen.fog,err:null};
     }
     try{
       __topClear(); __runPrep(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       snap=JSON.parse(JSON.stringify(__P()));
       __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       g=__state(); if(!g||!g.player||g.over||g.sim||!g.wx) return 'SKIP: no live raid with a weather';
       keep={tod:g.tod,wx:g.wx,wxNext:g.wxNext,wxT:g.wxT};
       ownStroke=OWN.call(wc,'stroke'); realStroke=wc.stroke;
       wc.stroke=function(){ var a=grab(RAIN_RX,this.strokeStyle); if(a!==null) seen.rain=a; return realStroke.call(this); };
       ownFill=OWN.call(wc,'fillRect'); realFill=wc.fillRect;
       wc.fillRect=function(x,y,w,h){ var a=grab(FOG_RX,this.fillStyle); if(a!==null) seen.fog=a; return realFill.call(this,x,y,w,h); };
       // THE STAGE: by day on the noon hour under rain.
       var d0=frame(true,noon,rain);
       if(d0.err) return 'SKIP: the world draw '+d0.err+' by day, so no frame can be read here';
       if(!isDay()) return 'SKIP: the surface did not read as day here';
       if(d0.rain===null) return 'SKIP: by day under rain no stroke was drawn in the rain colour, so the hairlines cannot be read here';
       // CONTROL: by day the 8pm hour dims the rain, so the darkness figure is read where this check looks, on either build.
       var d1=frame(true,dusk,rain);
       if(d1.err||d1.rain===null) return 'SKIP: by day on the 8pm hour the rain drew '+(d1.err||'no stroke in the rain colour');
       if(!dimmer(d0.rain,d1.rain)) return 'SKIP: by day the rain drew at '+d0.rain+' at noon and '+d1.rain+' at 8pm, so the hour does not dim it where this check looks';
       // THE FIX, ONE: at NIGHT on the noon hour the rain draws at the 8pm figure, the night figure, never at the noon daylight strength.
       var n0=frame(false,noon,rain);
       if(isDay()) return 'SKIP: the surface did not read as night here';
       if(n0.err) bad.push('at NIGHT under rain the world draw '+n0.err);
       else if(n0.rain===null) bad.push('at NIGHT under rain no stroke was drawn in the rain colour');
       else if(!near(n0.rain,d1.rain)) bad.push('at NIGHT on a raid whose hidden hour is noon the rain draws at '+n0.rain+(near(n0.rain,d0.rain)?', the full noon daylight strength,':',')+' rather than '+d1.rain+', the strength the same rain has at night on an 8pm hour');
       // THE FIX, TWO, under fog: the haze by day at noon and at 8pm (CONTROL: dimmer), then at NIGHT on the noon hour.
       var f0=frame(true,noon,fog), f1=frame(true,dusk,fog);
       if(f0.err||f1.err||f0.fog===null||f1.fog===null) return skip('by day under fog the haze drew '+(f0.err||f1.err||'no fill in the fog colour'));
       if(!dimmer(f0.fog,f1.fog)) return skip('by day the fog haze drew at '+f0.fog+' at noon and '+f1.fog+' at 8pm, so the hour does not dim it where this check looks');
       var n1=frame(false,noon,fog);
       if(n1.err) bad.push('at NIGHT under fog the world draw '+n1.err);
       else if(n1.fog===null) bad.push('at NIGHT under fog no fill was drawn in the fog colour');
       else if(!near(n1.fog,f1.fog)) bad.push('at NIGHT on a raid whose hidden hour is noon the fog haze draws at '+n1.fog+(near(n1.fog,f0.fog)?', the full noon daylight strength,':',')+' rather than '+f1.fog+', the strength the same haze has at night on an 8pm hour');
       // CONTROL: back by day at noon the rain is at its full strength again.
       var d2=frame(true,noon,rain);
       if(d2.err||!near(d2.rain,d0.rain)) bad.push('back by day at noon the rain drew at '+(d2.err||fmt(d2.rain))+' rather than '+d0.rain+' again');
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{
       try{ if(realStroke){ if(ownStroke) wc.stroke=realStroke; else delete wc.stroke; } }catch(_s){}
       try{ if(realFill){ if(ownFill) wc.fillRect=realFill; else delete wc.fillRect; } }catch(_f){}
       try{ if(g&&keep){ g.tod=keep.tod; g.wx=keep.wx; g.wxNext=keep.wxNext; g.wxT=keep.wxT; } }catch(_g){}
       try{ if(g&&!g.over) __endRaid('abandon'); }catch(_e){}
       try{ if(snap) __applyLoaded(snap); }catch(_r){}
       try{ __topClear(); __resetCfg(); __cleanProfile(); }catch(_c){}
     }
     return bad.length?bad.join('; '):null; }},
  {v:'15.99',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
