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
  {v:'14.37',what:
'@ @'
  {v:'14.38',what:'wearing or unlocking a look makes a sound: the rare find voice plays oscillators while the old cosmetic voice name plays nothing, and no call in the game still asks for that name (audio audit finding 4)',
   run:function(){
     if(typeof sfx!=='function'||typeof AC==='undefined') return 'SKIP: no sfx or audio context holder in this build';
     if(typeof G!=='undefined'&&G&&G.sim) return 'SKIP: a sim is running';
     var bad=[], LOG=[], _AC=AC, _BUS=(typeof BUS!=='undefined')?BUS:null;
     var OLD=['ca','che'].join('');
     function MK(path){ var f=function(){}; return new Proxy(f,{get:function(t,k){ if(k==='currentTime') return 1; if(k==='sampleRate') return 44100; if(k==='state') return 'running'; if(k==='length') return 340; if(typeof k==='symbol') return k===Symbol.toPrimitive?function(){ return 1; }:undefined; if(k==='then'||k==='toJSON') return undefined; return MK(path+'.'+k); }, set:function(){ return true; }, apply:function(t,s2,a){ LOG.push(path); return MK(path+'()'); }}); }
     var voices=function(){ return LOG.filter(function(p){ return /create(Oscillator|BufferSource)$/.test(p); }).length; };
     try{
       __topClear();
       AC=MK('AC'); try{ BUS=null; }catch(_b){}
       // CONTROLS: the rare find voice sounds, and the old name has no voice behind it.
       // The fixture silences sfx and blip at the source and keeps the real blip aside; sfx hands its voice name to blip.
       var BL=(typeof _realBlip==='function')?_realBlip:blip;
       LOG.length=0; BL('pickRare'); var rare=voices();
       if(!rare) return 'SKIP: the rare find voice made no sound source here, so a sound cannot be seen';
       LOG.length=0; BL(OLD); var old=voices();
       if(old) return 'SKIP: the old cosmetic voice name does make a sound in this build ('+old+' sources)';
       // THE FIX: nothing in the game still asks for the voice that does not exist.
       var needle=['sfx(',String.fromCharCode(39),OLD,String.fromCharCode(39),')'].join(''), cnt=0;
       Array.prototype.forEach.call(document.querySelectorAll('script'),function(sc){ var tx=sc.textContent||'', at=tx.indexOf(needle); while(at>=0){ cnt++; at=tx.indexOf(needle,at+1); } });
       if(cnt) bad.push(cnt+' call'+(cnt>1?'s':'')+' in the game still ask for a sound that does not exist, so wearing or unlocking a look is silent');
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{ AC=_AC; try{ BUS=_BUS; }catch(_b2){} }
     return bad.length?bad.join('; '):null; }},
  {v:'14.37',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
