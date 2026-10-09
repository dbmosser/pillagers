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

if ($s.Contains("  {v:'20.86',what:")) { throw "check 20.86 is in the fixture already" }

SubRx @'
  {v:'20.85',what:
'@ @'
  {v:'20.86',what:'in a same machine mode one window plays the Undercroft music: the player 2 window leaves it to the player 1 window, unless the world sound is set to player 2 only',
   run:function(){
     if(typeof musicWanted!=='function'||typeof netSndWho!=='function'||typeof NET!=='object'||!NET) return 'SKIP: no music gate or same machine sound in this build';
     var NK={}, k, bad=[], g0=G, pr0=pendingRun, oWho=netSndWho, who='both', own=!!(P&&Object.prototype.hasOwnProperty.call(P,'music')), mu0=P?P.music:undefined;
     for(k in NET) NK[k]=NET[k];
     try{
       G=null; pendingRun=null; if(P) P.music='hub';
       netSndWho=function(){ return who; };
       NET.same='';
       if(!musicWanted()) return 'SKIP: the Undercroft music is off in this fixture even with no party';
       NET.same='host'; who='both';
       if(!musicWanted()) bad.push('control: the player 1 window lost its Undercroft music');
       NET.same='p2'; who='both';
       if(musicWanted()) bad.push('with the world sound in both windows the player 2 window plays its own Undercroft song beside the one in the player 1 window');
       who='p1';
       if(musicWanted()) bad.push('with the world sound in player 1 only the player 2 window still runs a song of its own');
       who='p2';
       if(!musicWanted()) bad.push('with the world sound in player 2 only the player 2 window, the one window heard, has no music');
       if(typeof netMusOut!=='function') bad.push('the music still goes through the split panner');
       else{
         var fa={destination:{name:'dest'},createGain:function(){ return {gain:{value:0},connect:function(d){ this.to=d; }}; }};
         NET.same='host'; NET.musG=null; NET.musAc=null; NET.sndOn=true;
         var mg=netMusOut(fa);
         if(!mg||mg.to!==fa.destination) bad.push('in a same machine mode the music does not go straight to the speakers past the split');
         else if(mg.gain.value!==1) bad.push('the music gain does not follow this window sound switch');
       }
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{
       G=g0; pendingRun=pr0; netSndWho=oWho;
       if(P){ if(own) P.music=mu0; else delete P.music; }
       for(k in NET) if(!(k in NK)) delete NET[k];
       for(k in NK) NET[k]=NK[k];
     }
     return bad.length?bad.join('; '):null; }},
  {v:'20.85',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
