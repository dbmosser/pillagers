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

if ($s.Contains("  {v:'16.04',what:")) { throw "check 16.04 is in the fixture already" }

SubRx @'
  {v:'16.03',what:
'@ @'
  {v:'16.04',what:'pause, Superhot and the death slow-down in co-op: in a shared party raid with Superhot on and no input the world still runs, paused the world and the clock run on while he stands still with W held, and the death beat runs the world at full speed; control, the same window alone keeps the solo rules (Superhot freezes, pause stops the world)',
   run:function(){
     if(!(window.__resetCfg&&window.__pinDefaults&&window.__startRaid&&window.__cleanProfile&&window.__loop)||typeof NET!=='object'||!NET||typeof netInCount!=='function') return 'SKIP: this fixture cannot stage a party raid';
     var bad=[], keepN={on:NET.on,role:NET.role,peers:NET.peers,upSeed:NET.upSeed,seat:NET.seat}, keepSt=state, TS=1000, peer={state:'in',seat:1,name:'ZQX',timers:[],dc:{readyState:'open',send:function(){}}}, t0, x0, cl0;
     function frames(n){ for(var i=0;i<n;i++){ TS+=16; __loop(TS); } }
     function stage(party){
       __resetCfg(); __pinDefaults(0); __startRaid({mapIx:0,seed:4242});
       state='raid'; G.sim=0; G.over=false; G.deathBeat=null; G.paused=false; pauseOpen=false; keys={};
       CFG.superhot=1;
       NET.on=party; NET.role=party?'host':null; NET.seat=0; NET.peers=party?[peer]:[]; NET.upSeed=party?(G.seed>>>0):0;
       frames(2);
     }
     try{
       // SOLO CONTROL
       stage(false);
       t0=G.t; frames(10); if(G.t!==t0) bad.push('control: alone with Superhot on and no input the world moved ('+t0+' to '+G.t+')');
       CFG.superhot=0; G.paused=true; t0=G.t; frames(10); if(G.t!==t0) bad.push('control: alone and paused the world moved');
       G.paused=false; G.over='abandon';
       // THE PARTY
       stage(true);
       if(!(netEntsHost&&netEntsHost())) return 'SKIP: the staged party raid does not read as the host world';
       t0=G.t; frames(10); if(!(G.t>t0)) bad.push('in a party raid with Superhot on and no input the world stood still, so one player froze it for everyone');
       CFG.superhot=0; G.paused=true; t0=G.t; cl0=G.timeLeft; x0=[G.player.x,G.player.y]; keys['KeyW']=true;
       frames(15);
       if(!(G.t>t0)) bad.push('paused in a party raid the world stood still');
       if(Math.hypot(G.player.x-x0[0],G.player.y-x0[1])>0.5) bad.push('paused in a party raid with W held he walked '+Math.hypot(G.player.x-x0[0],G.player.y-x0[1]).toFixed(1));
       keys={}; G.paused=false;
       G.deathBeat=5; t0=G.t; frames(10);
       if(!(G.t-t0>0.1)) bad.push('in a party raid the death beat slowed the shared world to '+(G.t-t0).toFixed(3)+' s over 10 frames');
       G.deathBeat=null;
     }
     finally{
       try{ keys={}; pauseOpen=false; if(G){ G.paused=false; G.deathBeat=null; } }catch(_k){}
       try{ NET.on=keepN.on; NET.role=keepN.role; NET.peers=keepN.peers||[]; NET.upSeed=keepN.upSeed; NET.seat=keepN.seat; }catch(_n){}
       try{ G=null; state=keepSt; }catch(_g){}
       try{ if(typeof state==='undefined'||state!=='hub') __hubEnter(); }catch(_he){}
       try{ __resetCfg(); }catch(_rc){}
       try{ __cleanProfile(); }catch(_cp){}
     }
     return bad.length?bad.join('; '):null; }},
  {v:'16.03',what:
'@


$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
