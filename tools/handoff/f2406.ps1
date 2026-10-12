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

if ($s.Contains("  {v:'24.06',what:")) { throw "check 24.06 is in the fixture already" }

SubRx @'
  {v:'24.05',what:
'@ @'
  {v:'24.06',what:'his answer 27 b: music plays on the title and on the demo attract only, the Undercroft floor and a raid are silent, and the piece is THE ASCENT with a kick on the downbeat and a snare on the backbeat',
   run:function(){
     if(typeof musicWanted!=='function'||typeof musTrk!=='function'||typeof NET!=='object'||!NET) return 'SKIP: no music gate here';
     var bad=[], NK={}, k, g0=G, pr0=pendingRun, own=!!(P&&Object.prototype.hasOwnProperty.call(P,'music')), mu0=P?P.music:undefined,
         ti=document.getElementById('title'), ti0=!!(ti&&ti.classList.contains('on')), ar0=(typeof ARCADE==='object'&&ARCADE)?ARCADE.on:undefined, at0=(typeof ATT==='object'&&ATT)?ATT.on:undefined, trk0=MUS.trk, mg0=MUS.g, T, made=[], fa, r0, r1;
     for(k in NET) NK[k]=NET[k];
     try{
       G=null; pendingRun=null; if(P) P.music='hub'; NET.same='';
       if(ti) ti.classList.remove('on'); if(typeof ARCADE==='object'&&ARCADE) ARCADE.on=false; if(typeof ATT==='object'&&ATT) ATT.on=false;
       if(musicWanted()) bad.push('the Undercroft floor still plays music');
       if(ti){ ti.classList.add('on'); if(!musicWanted()) bad.push('the title plays no music'); }
       G={over:false}; if(musicWanted()) bad.push('a raid plays music'); G=null;
       if(ti) ti.classList.remove('on');
       if(typeof ARCADE==='object'&&ARCADE&&typeof ATT==='object'&&ATT){ ARCADE.on=true; ATT.on=true; if(!musicWanted()) bad.push('the demo attract plays no music'); ARCADE.on=false; ATT.on=false; }
       MUS.trk=null; T=musTrk();
       if(!T||T.name!=='THE ASCENT') bad.push('the title plays '+(T?T.name:'nothing')+', not THE ASCENT');
       if(typeof musDrum!=='function') bad.push('the title piece has no kit (no musDrum)');
       else {
         function mk(kind){ var o={kind:kind,connect:function(){},start:function(){},stop:function(){},frequency:{value:0,setValueAtTime:function(){},exponentialRampToValueAtTime:function(){}},gain:{value:0,setValueAtTime:function(){},exponentialRampToValueAtTime:function(){}},Q:{value:0}}; made.push(o); return o; }
         fa={sampleRate:44100,createOscillator:function(){ return mk('osc'); },createGain:function(){ return mk('gain'); },createBiquadFilter:function(){ return mk('filter'); },createBufferSource:function(){ return mk('src'); },createBuffer:function(c,l){ return {getChannelData:function(){ return new Float32Array(l); }}; }};
         MUS.g=mk('mg');
         r0=musDrum(fa,1,0,38); r1=musDrum(fa,1,4,38);
         if(!(r0&1)) bad.push('no kick on the downbeat');
         if(!(r1&2)) bad.push('no snare on the backbeat');
         if(!made.some(function(x){ return x.kind==='src'; })) bad.push('the snare plays no noise');
       }
     }catch(x){ bad.push('threw: '+(x&&x.message||x)); }
     finally{
       G=g0; pendingRun=pr0; MUS.trk=trk0; MUS.g=mg0;
       if(P){ if(own) P.music=mu0; else delete P.music; }
       if(ti){ if(ti0) ti.classList.add('on'); else ti.classList.remove('on'); }
       if(typeof ARCADE==='object'&&ARCADE) ARCADE.on=ar0; if(typeof ATT==='object'&&ATT) ATT.on=at0;
       for(k in NET) if(!(k in NK)) delete NET[k];
       for(k in NK) NET[k]=NK[k];
     }
     return bad.length?bad.join('; '):null; }},
  {v:'24.05',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
