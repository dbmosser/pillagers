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

if ($s.Contains("  {v:'21.22',what:")) { throw "check 21.22 is in the fixture already" }

SubRx @'
  {v:'21.21',what:
'@ @'
  {v:'21.22',what:'one Undercroft song follows the players: player 2 plays it while the host is up top, it is centred only with both on the floor and kept to its side otherwise, and ending the party brings it back at full volume',
   run:function(){
     if(typeof musicWanted!=='function'||typeof netSndWho!=='function'||typeof NET!=='object'||!NET) return 'SKIP: no music gate here';
     if(typeof netMusPan!=='function') return 'control: the song does not follow where the players are';
     var NK={}, k, bad=[], g0=G, pr0=pendingRun, oWho=netSndWho, oSplit=netSndSplitOn, own=!!(P&&Object.prototype.hasOwnProperty.call(P,'music')), mu0=P?P.music:undefined, fa, mk;
     for(k in NET) NK[k]=NET[k];
     try{
       G=null; pendingRun=null; if(P) P.music='hub';
       netSndWho=function(){ return 'both'; }; netSndSplitOn=function(){ return true; };
       NET.same='p2'; NET.hostSeed=12345;
       if(!musicWanted()) bad.push('player 2 back on the floor while the host is up top has no music');
       NET.hostSeed=0;
       if(musicWanted()) bad.push('player 2 plays a second song with the host on the floor');
       mk=function(){ return {pan:{value:9},gain:{value:0},connect:function(d){ this.to=d; }}; };
       fa={destination:{name:'dest'},createGain:mk,createStereoPanner:mk};
       NET.same='host'; NET.musG=null; NET.musAc=null; NET.musP=null; NET.sndOn=true; NET.specG={};
       netMusOut(fa); netMusPan();
       if(!NET.musP) bad.push('the music has no panner of its own');
       else if(NET.musP.pan.value!==-1) bad.push('with player 2 still up top the host song is not kept to his side ('+NET.musP.pan.value+')');
       NET.specG=null; netMusPan();
       if(NET.musP&&NET.musP.pan.value!==0) bad.push('with both players on the floor the song is not centred');
       NET.musG.gain.value=0; netSndRelease();
       if(NET.musG.gain.value!==1) bad.push('ending the party left the music at volume '+NET.musG.gain.value);
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{
       G=g0; pendingRun=pr0; netSndWho=oWho; netSndSplitOn=oSplit;
       if(P){ if(own) P.music=mu0; else delete P.music; }
       for(k in NET) if(!(k in NK)) delete NET[k];
       for(k in NK) NET[k]=NK[k];
     }
     return bad.length?bad.join('; '):null; }},
  {v:'21.21',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
