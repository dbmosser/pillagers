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

if ($s.Contains("  {v:'22.18',what:")) { throw "check 22.18 is in the fixture already" }

SubRx @'
  {v:'22.17',what:
'@ @'
  {v:'22.18',what:'once the link to the player 1 window is gone the player 2 window plays the Undercroft song itself, and while linked it still leaves the song to player 1',
   run:function(){
     if(typeof musicWanted!=='function'||typeof netSndWho!=='function'||typeof netDrop!=='function'||typeof NET!=='object'||!NET) return 'SKIP: no music gate or party here';
     var NK={}, k, bad=[], g0=G, pr0=pendingRun, oWho=netSndWho, oP2=NETP2, own=!!(P&&Object.prototype.hasOwnProperty.call(P,'music')), mu0=P?P.music:undefined,
         ownFd=!!(P&&Object.prototype.hasOwnProperty.call(P,'floorDrops')), fd0=P?P.floorDrops:undefined, hb0=(typeof HB==='object'&&HB)?HB.drops:undefined, H;
     for(k in NET) NK[k]=NET[k];
     try{
       G=null; pendingRun=null; if(P){ P.music='hub'; P.floorDrops=[]; }
       netSndWho=function(){ return 'both'; };
       NET.same='';
       if(!musicWanted()) return 'SKIP: the Undercroft music is off in this fixture even with no party';
       NETP2=true;
       H={seat:0,state:'in',name:'ZQX P1WINDOW',timers:[]};
       NET.on=true; NET.role='join'; NET.seat=1; NET.max=4; NET.peers=[H]; NET.same='p2'; NET.hostSeed=0; NET.upSeed=0;
       if(musicWanted()) bad.push('control: linked to the player 1 window on the floor, the player 2 window plays a second song');
       netDrop(H,'closed');
       if(NET.on||NET.peers.length) bad.push('control: the link to the player 1 window did not come down');
       if(NET.same!=='p2') return 'SKIP: staging: this window let go of its player 2 mode';
       if(!musicWanted()) bad.push('with the player 1 window gone the player 2 window Undercroft has no music');
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{
       G=g0; pendingRun=pr0; netSndWho=oWho; NETP2=oP2;
       if(P){ if(own) P.music=mu0; else delete P.music; if(ownFd) P.floorDrops=fd0; else delete P.floorDrops; }
       try{ if(typeof HB==='object'&&HB) HB.drops=hb0; }catch(_h){}
       for(k in NET) if(!(k in NK)) delete NET[k];
       for(k in NK) NET[k]=NK[k];
     }
     return bad.length?bad.join('; '):null; }},
  {v:'22.17',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
