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

if ($s.Contains("  {v:'16.27',what:")) { throw "check 16.27 is in the fixture already" }

SubRx @'
  {v:'16.26',what:
'@ @'
  {v:'16.27',what:'pause and superhot in co-op: paused with the teammate not up top the world stops; paused with the teammate up top and playing it runs; with superhot on and nobody acting time stops, and a teammate acting keeps it running',
   run:function(){
     if(!(window.__resetCfg&&window.__pinDefaults&&window.__startRaid&&window.__cleanProfile&&window.__loop)||typeof NET!=='object'||!NET) return 'SKIP: this fixture cannot stage a party raid';
     var bad=[], keepN={on:NET.on,role:NET.role,peers:NET.peers,upSeed:NET.upSeed,seat:NET.seat,up:NET.up,roster:NET.roster}, keepSt=state, TS=11000, t0;
     function frames(n){ for(var i=0;i<n;i++){ TS+=16; __loop(TS); if(NET.up[1]) NET.up[1].age=0; } }
     try{
       __resetCfg(); __pinDefaults(0); __startRaid({mapIx:0,seed:4242}); keys={}; state='raid'; G.sim=0; G.over=false; CFG.superhot=0;
       NET.on=true; NET.role='host'; NET.seat=0; NET.peers=[{state:'in',seat:1,name:'ZQX',timers:[],dc:{readyState:'open',send:function(){}}}]; NET.upSeed=G.seed>>>0; NET.up=[];
       NET.roster=[{seat:0,pid:'me',name:'HOST',host:true},{seat:1,pid:'zqxmate',name:'ZQX MATE'}];
       G.paused=true; t0=G.t; frames(10);
       if(G.t!==t0) bad.push('paused with the teammate not up top, the world still ran');
       NET.up[1]={seat:1,x:G.player.x+300,y:G.player.y,f:0,tx:G.player.x+300,ty:G.player.y,tf:0,n:5,age:0,dn:0,sd:NET.upSeed>>>0,pz:0,sa:1};
       t0=G.t; frames(10);
       if(!(G.t>t0)) bad.push('control: paused with the teammate up top and playing, the world stopped for him');
       G.paused=false; CFG.superhot=1; NET.up[1].sa=0;
       t0=G.t; frames(10);
       if(G.t!==t0) bad.push('superhot with nobody acting: time still ran');
       NET.up[1].sa=1; t0=G.t; frames(10);
       if(!(G.t>t0)) bad.push('superhot with the teammate acting: time stood still');
     }
     finally{
       try{ keys={}; if(G) G.paused=false; CFG.superhot=0; }catch(_k){}
       try{ NET.on=keepN.on; NET.role=keepN.role; NET.peers=keepN.peers||[]; NET.upSeed=keepN.upSeed; NET.seat=keepN.seat; NET.up=keepN.up||[]; NET.roster=keepN.roster||[]; }catch(_n){}
       try{ G=null; state=keepSt; }catch(_g){}
       try{ if(typeof state==='undefined'||state!=='hub') __hubEnter(); }catch(_he){}
       try{ __resetCfg(); }catch(_rc){}
       try{ __cleanProfile(); }catch(_cp){}
     }
     return bad.length?bad.join('; '):null; }},
  {v:'16.26',what:
'@


SubRx @'
       NET.on=party; NET.role=party?'host':null; NET.seat=0; NET.peers=party?[peer]:[]; NET.upSeed=party?(G.seed>>>0):0;
'@ @'
       NET.on=party; NET.role=party?'host':null; NET.seat=0; NET.peers=party?[peer]:[]; NET.upSeed=party?(G.seed>>>0):0;
       if(party){ NET.roster=[{seat:0,pid:'me',name:'HOST',host:true},{seat:1,pid:'zqxmate',name:'ZQX MATE'}]; NET.up=[]; NET.up[1]={seat:1,x:G.player.x+300,y:G.player.y,f:0,tx:G.player.x+300,ty:G.player.y,tf:0,n:5,age:0,dn:0,sd:NET.upSeed>>>0,pz:0,sa:1}; }   // v16.27: the world runs under a pause only while a teammate is up top and playing; this one is, acting
'@

SubRx @'
       party('host'); G.wx=W1; G.paused=true; G.strikes=[{x:p.x+900,y:p.y,t:0.05,hit:0,id:5}];
'@ @'
       party('host'); G.wx=W1; G.paused=true; G.strikes=[{x:p.x+900,y:p.y,t:0.05,hit:0,id:5}];
       NET.roster=[{seat:0,pid:'me',name:'HOST',host:true},{seat:1,pid:'zqxmate',name:'ZQX MATE'}]; NET.up=[]; NET.up[1]={seat:1,x:p.x+300,y:p.y,f:0,tx:p.x+300,ty:p.y,tf:0,n:5,age:0,dn:0,sd:NET.upSeed>>>0,pz:0,sa:1};   // v16.27: a teammate up top and playing
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
