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
  {v:'15.23',what:
'@ @'
  {v:'15.24',what:'the raid clock warns in its own voice and no frame can skip a warning: live frames over thirty seconds, over a jump from 31.2 to 28.9 and over ten seconds say the line and play the clock siren or the tick, not the machine alarm, and the siren starts louder than that alarm (his note: killed by the timer with no sound warning)',
   run:function(){
     if(!(window.__deploy&&window.__state&&window.__endRaid&&window.__loop&&window.__keysRef)) return 'SKIP: this fixture cannot deploy and step a live frame';
     if(typeof blip!=='function'||typeof say!=='function'||typeof AC==='undefined'||typeof lastTs!=='number') return 'SKIP: no blip, say, audio context holder or frame clock in this build';
     if(typeof G!=='undefined'&&G&&G.sim) return 'SKIP: a sim is running';
     var bad=[], g=null, _blip=blip, _say=say, _AC=AC, _BUS=(typeof BUS!=='undefined')?BUS:null, _REV=(typeof REV!=='undefined')?REV:null;
     var keepTs=lastTs, heard=[], lines=[], LOG=[];
     // A later control that cannot run keeps a failure already found, so the old build fails rather than skips.
     var skip=function(m){ return bad.length?(bad.join('; ')+' (then SKIP: '+m+')'):('SKIP: '+m); };
     var has=function(t){ return heard.indexOf(t)>=0; };
     var said=function(head){ for(var i=0;i<lines.length;i++) if(lines[i].indexOf(head)===0) return lines[i]; return null; };
     // One real frame of 0.016 s through the loop. The clock the frame before was prev and the frame lands on land. Each build
     // reads its own memory of the frame before, so both are staged: warnPrev here, the last whole second on the old build.
     var frame=function(prev,land){
       var K=__keysRef(), k; for(k in K) K[k]=false;
       g.ents.length=0; g.waveT=-1e9; g.player.iv=99;
       g.warnPrev=prev; g.lastWarn=Math.ceil(prev); g.timeLeft=land+0.016;
       heard.length=0; lines.length=0;
       __loop(lastTs+16);
       return Math.abs(g.timeLeft-land)<0.004;
     };
     var MK=function(path){ var f=function(){}; return new Proxy(f,{get:function(t,k){ if(k==='currentTime') return 1; if(k==='sampleRate') return 44100; if(k==='state') return 'running'; if(k==='length') return 340; if(typeof k==='symbol') return k===Symbol.toPrimitive?function(){ return 1; }:undefined; if(k==='then'||k==='toJSON') return undefined; return MK(path+'.'+k); }, set:function(){ return true; }, apply:function(t,s2,a){ LOG.push({p:path,a:Array.prototype.slice.call(a)}); return MK(path+'()'); }}); };
     var loud=function(){ var m=0; for(var i=0;i<LOG.length;i++){ var L=LOG[i]; if((/gain\.setValueAtTime$/).test(L.p)&&typeof L.a[0]==='number') m=Math.max(m,L.a[0]); } return m; };
     var voices=function(){ return LOG.filter(function(L){ return (/create(Oscillator|BufferSource)$/).test(L.p); }).length; };
     try{
       __topClear(); __runPrep(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       g=__state(); if(!g||!g.player) return 'SKIP: no live raid';
       // CONTROL: this raid runs a clock, so its warnings are live.
       if(!(CFG.raidSec>0)||g.raidLen===0) return 'SKIP: the raid clock is off here, so nothing warns';
       blip=function(t){ heard.push(String(t)); try{ return _blip.apply(null,arguments); }catch(_b){} };
       say=function(m){ lines.push(String(m)); try{ return _say.apply(null,arguments); }catch(_s){} };
       // CONTROL: a live frame at 100 seconds runs the clock and warns of nothing.
       if(!frame(100.02,100)) return skip('the live frame did not run the raid clock here ('+g.timeLeft+')');
       if(has('clockwarn')||has('clocktick')||said('THIRTY')) return skip('a frame at 100 seconds already warned here ('+heard.join(',')+')');
       // CONTROL: a frame that walks the clock over thirty seconds says the thirty second line, on either build.
       if(!frame(30.02,29.99)) return skip('the live frame did not run the raid clock at thirty seconds here');
       if(!said('THIRTY SECONDS.')) return skip('a frame over thirty seconds said no thirty second line here, so the warning cannot be read from a frame');
       // THE FIX, ONE: the sound under that line is a clock siren, not the alarm a machine raises when it spots him.
       if(!has('clockwarn')) bad.push('the thirty second warning plays '+(has('alarm')?'the machine alarm, the same short quiet sound a machine or a pillager makes when it raises an alarm,':'no sound')+' and no clock siren of its own');
       // THE FIX, TWO: a frame that carries the clock from 31.2 past the mark to 28.9 still warns.
       if(!frame(31.2,28.9)) return skip('the live frame did not run the raid clock at 31.2 seconds here');
       if(!said('THIRTY SECONDS.')||!has('clockwarn')) bad.push('a frame that carried the clock from 31.2 to 28.9 seconds '+(said('THIRTY SECONDS.')?'said the thirty second line with no siren':'gave no thirty second warning at all')+' ('+(heard.join(',')||'no sound')+')');
       // THE FIX, THREE: the last ten seconds tick, and ten is said.
       if(!frame(10.4,9.6)) return skip('the live frame did not run the raid clock at ten seconds here');
       if(!has('clocktick')) bad.push('the clock crossing ten seconds made no tick ('+(heard.join(',')||'no sound')+')');
       if(!said('TEN SECONDS.')) bad.push('the clock crossing ten seconds said nothing');
       // THE FIX, FOUR: the siren starts louder than the machine alarm, read off a stand-in audio context. The fixture silences
       // blip at the source and keeps the real one aside.
       blip=_blip; say=_say;
       var BL=(typeof _realBlip==='function')?_realBlip:null;
       if(!BL) return skip('the fixture keeps no real blip here, so the siren level cannot be read');
       AC=MK('AC'); try{ BUS=null; }catch(_b0){}
       LOG.length=0; BL('alarm'); var al=loud();
       // CONTROL: the machine alarm starts at its 0.06, so a level can be read here.
       if(Math.abs(al-0.06)>0.0005) return skip('the machine alarm started at '+al+', not 0.06, so a level cannot be read here');
       LOG.length=0; BL('clockwarn'); var cw=loud(), cwv=voices();
       if(!cwv) bad.push('the clock siren makes no sound at all');
       else if(!(cw>=al*1.5)) bad.push('the clock siren starts at '+cw+', not clearly louder than the machine alarm at '+al);
       LOG.length=0; BL('clocktick');
       if(!voices()) bad.push('the clock tick makes no sound at all');
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{
       blip=_blip; say=_say; AC=_AC;
       try{ BUS=_BUS; }catch(_b2){}
       try{ REV=_REV; }catch(_r2){}
       try{ lastTs=keepTs; }catch(_t){}
       try{ if(g&&!g.over){ if(g.raidLen>0) g.timeLeft=g.raidLen; __endRaid('abandon'); } }catch(_e){}
       try{ __topClear(); __resetCfg(); __cleanProfile(); }catch(_c){}
     }
     return bad.length?bad.join('; '):null; }},
  {v:'15.23',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
