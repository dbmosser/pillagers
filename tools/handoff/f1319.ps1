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

# v13.19 CHECK, inserted before the v13.18 entry.
#
# IT WATCHES say() RATHER THAN GUESSING. The fixture overrides say, so the check
# wraps it for the duration and puts it back, which is the only honest way to ask
# whether the game spoke.
#
# THREE ARMS, AND THE SECOND IS THE ONE WITH TEETH. A refused roll must speak. A
# roll that CAN happen must stay silent, or the line is wallpaper. And holding
# the key must not repeat it, because Space is a key people hold down.
SubRx @'
  {v:'13.18',what:'the Limited Time Offer is limited: once bought it is gone from the counter for that window, and pressing Buy again takes nothing more (his note of 2026-09-12)',
'@ @'
  {v:'13.19',what:'a roll refused for stamina says so out loud instead of reading as a dead key, a roll that can happen stays silent, and holding the key does not repeat the line (his report of 2026-09-12)',
   run:function(){
     if(typeof tryRoll!=='function') return 'SKIP: this fixture cannot reach the roll';
     if(!(window.__deploy&&window.__state&&window.__loop&&window.__endRaid))
       return 'SKIP: this fixture cannot drive a live raid';
     var bad=[];
     var _say=say, heard=[];
     var T0=performance.now();
     function frames(k){ for(var f=0;f<(k||6);f++){ T0+=16.7; var st=__state(); if(!st||st.over) return; __loop(T0); } }
     try{
       __topClear(); __runPrep(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       var g=__state();
       if(!g||!g.player) return 'SKIP: no raid to roll in';
       say=function(m){ heard.push(String(m)); try{ return _say.apply(null,arguments); }catch(_s){} };
       var p=g.player;
       p.downed=false; p.roll=0; p.rollCd=0;
       frames(2);

       // ONE: no legs. The refusal must speak.
       p.stam=1; g.rollSayT=0;
       heard.length=0;
       tryRoll();
       if(heard.length===0)
         bad.push('a roll refused because there is no stamina left says nothing at all, so a key that is working reads as a key that is broken, which is exactly the report he sent and then withdrew');
       if(__state().player.roll>0)
         bad.push('a roll happened on an empty stamina bar, so the cost is not being paid');

       // TWO, THE ARM WITH TEETH: a roll that CAN happen must stay silent.
       var p2=__state().player;
       p2.roll=0; p2.rollCd=0; p2.stam=100; __state().rollSayT=0;
       heard.length=0;
       tryRoll();
       if(!(__state().player.roll>0))
         bad.push('a full stamina bar cannot roll, so the roll is broken rather than merely quiet');
       if(heard.length>0)
         bad.push('a roll that actually happened announces itself as refused, so the line is wallpaper rather than an explanation');

       // THREE: holding the key must not repeat it. Space is held.
       var p3=__state().player;
       p3.roll=0; p3.rollCd=0; p3.stam=1; __state().rollSayT=0;
       heard.length=0;
       tryRoll(); tryRoll(); tryRoll(); tryRoll();
       if(heard.length>1)
         bad.push('holding the key repeats the refusal '+heard.length+' times, so a held Space buries every other line the raid is trying to say');
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{
       try{ say=_say; }catch(_r){}
       try{ var g6=__state(); if(g6&&!g6.over){ g6.player.downed=false; __endRaid('abandon'); } }catch(_e){}
       try{ G=null; keys={}; showScreen('hub'); }catch(_q){}
       try{ __topClear(); __resetCfg(); __cleanProfile(); }catch(_c){}
     }
     return bad.length?bad.join('; '):null; }},
  {v:'13.18',what:'the Limited Time Offer is limited: once bought it is gone from the counter for that window, and pressing Buy again takes nothing more (his note of 2026-09-12)',
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
