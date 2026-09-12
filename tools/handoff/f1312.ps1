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

# v13.12 CHECK, inserted before the v13.11 entry.
#
# IT REPRODUCES THE FAULT RATHER THAN ARGUING FROM THE CODE. The condition is a
# draw that keeps answering with the sky already overhead, which cannot be forced
# from the page because the picker and the weather table are both inside the
# closure. This check runs inside it, so it can stub the picker, which is the
# honest way to reach a branch that is rare by design and ruinous when it lands.
#
# THE CONTROL IS A NUMBER. It counts draws per frame, so the difference between
# the builds is thirteen against zero rather than a judgement about whether the
# clock looks right.
SubRx @'
  {v:'13.11',what:'the whole way out actually works on a live raid: holding E for 1.6s calls the ship and a shorter hold does not, the call bar fills while it is held, the ship lands, letting go of E cancels the board, and holding it again for 1.4s ends the raid as an extraction',
'@ @'
  {v:'13.12',what:'a weather turn that keeps drawing the sky already overhead costs one round of draws and then waits, instead of redrawing thirteen times every frame for the rest of the raid and pulling two paired runs onto different seeded streams (the unpinned twin of the v12.58 bug)',
   run:function(){
     if(!(window.__deploy&&window.__state&&window.__endRaid))
       return 'SKIP: this fixture cannot drive a live raid';
     if(typeof wxTick!=='function'||typeof pickWeather!=='function'||typeof WEATHER==='undefined')
       return 'SKIP: this fixture cannot reach the weather clock';
     var bad=[];
     var _pick=pickWeather, _picked=(typeof wxPicked==='function')?wxPicked:null, _calls=0;
     try{
       __topClear(); __runPrep(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       var g=__state();
       if(!g) return 'SKIP: no raid to run the clock in';
       // The partly cloudy rule at the bottom of the turn overwrites the draw
       // with rain or storm, so it would walk past the branch under test. Start
       // under any other sky.
       if(g.wx&&g.wx.id==='partly'){
         for(var wi=0;wi<WEATHER.length;wi++) if(WEATHER[wi].id!=='partly'){ g.wx=WEATHER[wi]; break; }
       }
       if(_picked) wxPicked=function(){ return 'any'; };
       pickWeather=function(){ _calls++; return G.wx; };
       g.wxNext=null; g.wxT=0; g.wxTurnsLeft=2; g.wxAt=-0.001;
       var turns0=g.wxTurnsLeft;

       _calls=0; wxTick(0.016);
       var first=_calls;
       if(!(first>1))
         return 'SKIP: the staging never reached the guard loop, so nothing was measured';
       if(!(g.wxAt>0))
         bad.push('a weather turn that comes up with the sky already overhead leaves the clock expired, so the whole turn runs again on the next frame and every frame after it');
       if(g.wxTurnsLeft!==turns0)
         bad.push('a turn that never happened is spent anyway, so a raid quietly loses the sky changes it was owed');

       _calls=0; wxTick(0.016); wxTick(0.016);
       if(_calls>0)
         bad.push('the next frames draw '+_calls+' more times from the seeded stream for a turn that has already failed, which is what pulls two paired runs onto different streams while nothing on screen changes');
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{
       try{ pickWeather=_pick; if(_picked) wxPicked=_picked; }catch(_r){}
       try{ var g6=__state(); if(g6&&!g6.over){ g6.player.downed=false; __endRaid('abandon'); } }catch(_e){}
       try{ G=null; keys={}; showScreen('hub'); }catch(_q){}
       try{ __topClear(); __resetCfg(); __cleanProfile(); }catch(_c){}
     }
     return bad.length?bad.join('; '):null; }},
  {v:'13.11',what:'the whole way out actually works on a live raid: holding E for 1.6s calls the ship and a shorter hold does not, the call bar fills while it is held, the ship lands, letting go of E cancels the board, and holding it again for 1.4s ends the raid as an extraction',
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
