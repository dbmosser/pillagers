$ErrorActionPreference = 'Stop'
trap { Write-Output "FAILED: $_"; exit 1 }
$p = 'C:\claudecode\dark raiders\tools\mkfixture.ps1'
$s = [IO.File]::ReadAllText($p)
$n = 0
function SubRx([string]$old, [string]$new) {
  $pat = ($old -split "`n" | ForEach-Object { [regex]::Escape($_.TrimEnd("`r")) }) -join "\r?\n"
  $c = ([regex]::Matches($script:s, $pat)).Count
  if ($c -ne 1) { throw "regex matched $c times: $($old.Substring(0,[Math]::Min(70,$old.Length)))" }
  $new = $new.Replace("`r`n", "`n")
  $script:s = [regex]::Replace($script:s, $pat, { param($m) $new })
  $script:n++
}

if ($s.Contains("  {v:'20.80',what:")) { throw "check 20.80 is in the fixture already" }

SubRx @'
  {v:'20.79',what:
'@ @'
  {v:'20.80',what:'a machine voice too far behind a wall to be heard spends none of the voice budget: with two crawlers hunting 550 away behind walls and one in plain sight 300 away, the one in sight is the voice that plays',
   run:function(){
     if(!window.__deploy||!window.__endRaid||typeof window.__realTickMachineVoices!=='function'||typeof VOICE_BUDGET==='undefined'||typeof VOICE==='undefined'||!VOICE.crawler||typeof losClear!=='function'||typeof ac!=='function') return 'SKIP: the real machine voice tick was not kept aside by this fixture';
     var TMV=window.__realTickMachineVoices, bad=[], calls=[], oBlip=blip, oAc=ac, oLos=losClear, g0=null, g, p, w1, w2, see, heard, lost;
     try{
       __topClear(); __runPrep(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       g=__state(); p=g&&g.player; if(!g||!p||g.over||g.sim) return 'SKIP: no live raid';
       g0=g; g.ents.length=0; p.iv=99;
       w1={kind:'crawler',name:'ZQXW1',x:p.x+550,y:p.y,state:'hunt',alert:1,hp:30,maxhp:30,vT:-1};
       w2={kind:'crawler',name:'ZQXW2',x:p.x,y:p.y+560,state:'hunt',alert:1,hp:30,maxhp:30,vT:-1};
       see={kind:'crawler',name:'ZQXSEE',x:p.x-300,y:p.y,state:'hunt',alert:1,hp:30,maxhp:30,vT:-1};
       g.ents.push(w1); g.ents.push(w2); g.ents.push(see);
       ac=function(){ return {currentTime:1,state:'running'}; };
       losClear=function(ax,ay,bx,by){ return !((bx===w1.x&&by===w1.y)||(bx===w2.x&&by===w2.y)); };
       blip=function(t,d){ calls.push({t:String(t),d:+d}); };
       VOICE_BUDGET=1.5; calls.length=0; TMV(0.001);
       heard=calls.filter(function(c){ return c.d<882; }); lost=calls.filter(function(c){ return c.d>=882; });
       if(!heard.length) bad.push('the crawler hunting in plain sight 300 away made no sound: the two behind walls, too far to be heard, had used up the voices ('+JSON.stringify(calls)+')');
       else if(!(Math.abs(heard[0].d-300)<1)) bad.push('the voice heard came from '+Math.round(heard[0].d)+', not the crawler in sight 300 away');
       if(lost.length) bad.push(lost.length+' voices behind walls were played at no volume and each spent a voice');
       // CONTROL: a crawler 450 away behind a wall (855 through it) is still heard and still spends a voice.
       w1.x=p.x+450; w1.vT=-1; w2.vT=99; see.vT=99;
       VOICE_BUDGET=1.5; calls.length=0; TMV(0.001);
       if(!(calls.length===1&&Math.abs(calls[0].d-450*1.9)<1)) bad.push('control: a crawler 450 away behind a wall was not heard through it ('+JSON.stringify(calls)+')');
       else if(!(VOICE_BUDGET<1)) bad.push('control: a voice that played spent nothing');
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{
       blip=oBlip; ac=oAc; losClear=oLos; VOICE_BUDGET=0;
       try{ if(g0){ g0.ents.length=0; if(g0.player){ g0.player.iv=0; g0.player.downed=false; } if(!g0.over) __endRaid('abandon'); } }catch(_e){}
       try{ __topClear(); __resetCfg(); __cleanProfile(); }catch(_c){}
     }
     return bad.length?bad.join('; '):null; }},
  {v:'20.79',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
