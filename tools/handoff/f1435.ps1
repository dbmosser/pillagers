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
try{ tickMachineVoices=function(){}; }catch(e){}
'@ @'
try{ window.__realTickMachineVoices=tickMachineVoices; tickMachineVoices=function(){}; }catch(e){}
'@
SubRx @'
  {v:'14.34',what:
'@ @'
  {v:'14.35',what:'the sound of the machines draws no seeded numbers: with a working audio context, a crawler voicing through its timers and a hunting skitter burst make no draw from the seeded stream, while a seeded draw is still counted (audio audit finding 1)',
   run:function(){
     if(!(window.__deploy&&window.__state&&window.__endRaid)) return 'SKIP: this fixture cannot deploy';
     if(typeof tickMachineVoices!=='function'||typeof blip!=='function'||typeof rr!=='function'||typeof VOICE==='undefined'||!VOICE.crawler) return 'SKIP: no machine voices in this build';
     // The fixture silences sound at the source; the real voice tick and the real blip are kept aside for checks like this.
     var TMV=window.__realTickMachineVoices, BL=(typeof _realBlip==='function')?_realBlip:null;
     if(typeof TMV!=='function'||!BL) return 'SKIP: the real voice tick or blip was not kept aside by this fixture';
     var bad=[], g0=null, draws=0, _rr=rr, _AC=AC, _BUS=BUS;
     function MK(path){ var f=function(){}; return new Proxy(f,{get:function(t,k){ if(k==='currentTime') return 1; if(k==='sampleRate') return 44100; if(k==='state') return 'running'; if(k==='length') return 340; if(typeof k==='symbol') return k===Symbol.toPrimitive?function(){ return 1; }:undefined; if(k==='then'||k==='toJSON') return undefined; return MK(path+'.'+k); }, set:function(){ return true; }, apply:function(){ return MK(path+'()'); }}); }
     try{
       __topClear(); __runPrep(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       var g=__state(), p=g&&g.player; if(!g||!p) return 'SKIP: no live raid';
       g0=g; g.ents.length=0; p.iv=99;
       AC=MK('AC'); BUS=null;
       rr=function(){ draws++; return _rr(); };
       // CONTROL: a seeded draw through rnd is counted, so the counter can see one.
       draws=0; rnd(0,1);
       if(draws!==1) return 'SKIP: a seeded draw through rnd was not counted ('+draws+'), so this check cannot see the stream';
       // THE FIX: a crawler within earshot voices through both timers, and a hunting skitter burst plays.
       var cr={kind:'crawler',x:p.x+120,y:p.y,state:'patrol',alert:0,hp:30,maxhp:30};
       g.ents.push(cr);
       VOICE_BUDGET=6; draws=0;
       TMV(0.016);                         // the first timer
       cr.vT=-1; VOICE_BUDGET=6;
       TMV(0.016);                         // the next timer, and the voice itself
       BL('skitter',120,0,true);           // the hunting burst
       if(draws) bad.push('a crawler voicing and a skitter burst made '+draws+' draws from the seeded stream, so a raid with sound plays differently from the same seed without it');
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{
       rr=_rr; AC=_AC; BUS=_BUS;
       try{ if(g0){ g0.ents.length=0; if(g0.player) g0.player.iv=0; if(!g0.over) __endRaid('abandon'); } }catch(_e){}
       try{ __topClear(); __resetCfg(); __cleanProfile(); }catch(_c){}
     }
     return bad.length?bad.join('; '):null; }},
  {v:'14.34',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
