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

# v12.58 CHECK, inserted before the v12.57 entry. It counts the calls to the
# picker itself rather than inferring waste from a number downstream, because
# the whole finding is that nothing downstream shows it. The picker is wrapped
# for the length of the run and put back afterwards. The control is the same
# expired clock with the weather NOT pinned: the picker must be asked and a
# turn must actually happen, or a zero above would only mean this check cannot
# see a call.
SubRx @'
  {v:'12.57',what:'walking into a second open extraction point does not move the pointer off the one he called: the countdown, the banner and the warning all stay with his own extraction, while with nothing running the pointer still follows him and a deliberate call at the second point still moves it (2026-09-06 in-raid audit)',
'@ @'
  {v:'12.58',what:'a weather pinned in Settings stops asking to change: with the turn clock expired the picker is not called at all, instead of thirteen seeded draws every frame for the rest of the raid, while an unpinned weather in the same state still asks and still turns (2026-09-06 in-raid audit, developer-facing)',
   run:function(){
     if(!(window.__deploy&&window.__state&&window.__endRaid&&window.__P)) return 'SKIP: this fixture cannot deploy a raid';
     if(typeof wxTick!=='function'||typeof pickWeather!=='function'||typeof WEATHER==='undefined') return 'SKIP: this build has no weather turn to drive';
     var bad=[], P2=__P(), keepPick=P2.wxPick, realPick=pickWeather;
     // The weather is named outright, so the pin is unmistakable and the control
     // arm has the whole table to choose from instead.
     var PIN='fog', i, wI=-1;
     for(i=0;i<WEATHER.length;i++) if(WEATHER[i].id===PIN) wI=i;
     if(wI<0) return 'SKIP: this build has no fog to pin';
     function run(pin,frames){
       __topClear(); __runPrep(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       __deploy({kit:[],mapIx:0,seed:4242});
       var g=__state(); if(!g) return null;
       P2.wxPick=pin;
       g.over=false; g.wx=WEATHER[wI]; g.wxNext=null; g.wxT=0;
       g.wxTurnsLeft=3; g.wxAt=0;             // the clock is expired, which is the state
       var calls=0;
       pickWeather=function(){ calls++; return realPick.apply(null,arguments); };
       try{ for(var f=0;f<frames;f++) wxTick(0.05); }
       finally{ pickWeather=realPick; }
       return {calls:calls,left:g.wxTurnsLeft,next:!!g.wxNext,at:g.wxAt};
     }
     try{
       // CONTROL FIRST: nothing pinned, the same expired clock. The picker MUST
       // be asked, or a zero in the finding arm would only say this check cannot
       // see a call at all.
       var C=run('any',1);
       if(!C) return 'SKIP: no live raid to turn the weather in';
       if(!(C.calls>0)) return 'SKIP: with nothing pinned the picker was not asked even once on an expired clock, so this check cannot see a call and proves nothing';
       // THE FINDING: pinned, and sixty frames of an expired clock.
       var A=run(PIN,60);
       if(A.calls>0)
         bad.push('a weather pinned in Settings asked the picker '+A.calls+' times in sixty frames of an expired turn clock, about '+Math.round(A.calls/60)+' seeded draws every frame, for a question that can only have one answer: nothing on screen shows it and it moves the seeded stream, so a paired measurement taken with the weather held still is comparing two different streams');
       // AND IT MUST NOT HAVE TURNED INTO ANYTHING, since it cannot.
       if(A.next) bad.push('the pinned weather turned into something else, so the pin is not holding');
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{
       try{ pickWeather=realPick; }catch(_r){}
       try{ P2.wxPick=keepPick; }catch(_p){}
       try{ var g2=__state(); if(g2&&!g2.over) __endRaid('abandon'); }catch(_e){}
       __topClear(); __resetCfg(); __cleanProfile();
     }
     return bad.length?bad.join('; '):null; }},
  {v:'12.57',what:'walking into a second open extraction point does not move the pointer off the one he called: the countdown, the banner and the warning all stay with his own extraction, while with nothing running the pointer still follows him and a deliberate call at the second point still moves it (2026-09-06 in-raid audit)',
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
