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

if ($s.Contains("  {v:'16.20',what:")) { throw "check 16.20 is in the fixture already" }

SubRx @'
  {v:'16.19',what:
'@ @'
  {v:'16.20',what:'when the whole party pauses the game pauses: the state word carries the pause; with this player paused and the teammate paused the world stands still; with the teammate playing it runs on',
   run:function(){
     if(!(window.__resetCfg&&window.__pinDefaults&&window.__startRaid&&window.__cleanProfile&&window.__loop)||typeof NET!=='object'||!NET||typeof netOnMsg!=='function') return 'SKIP: this fixture cannot stage a party raid';
     var bad=[], keepN={on:NET.on,role:NET.role,peers:NET.peers,upSeed:NET.upSeed,seat:NET.seat,up:NET.up,roster:NET.roster}, keepSt=state, TS=7000, peer, t0, p;
     function frames(n){ for(var i=0;i<n;i++){ TS+=16; __loop(TS); if(NET.up[1]) NET.up[1].age=0; } }
     try{
       __resetCfg(); __pinDefaults(0); __startRaid({mapIx:0,seed:4242}); keys={}; state='raid'; G.sim=0; G.over=false; CFG.superhot=0; p=G.player;
       NET.on=true; NET.role='host'; NET.seat=0; peer={state:'in',seat:1,name:'ZQX MATE',timers:[],dc:{readyState:'open',send:function(){}}}; NET.peers=[peer]; NET.upSeed=G.seed>>>0; NET.up=[];
       NET.roster=[{seat:0,pid:'me',name:'HOST',host:true},{seat:1,pid:'zqxmate',name:'ZQX MATE'}];
       netOnMsg(peer,JSON.stringify({t:'st',k:'r',sd:NET.upSeed>>>0,x:p.x+300,y:p.y,f:0,m:0,r:0,c:0,sp:0,dn:0,w:'',pz:1}));
       if(!NET.up[1]) return 'SKIP: the staged state word was not filed';
       if(NET.up[1].pz!==1) bad.push('the state word does not carry that the teammate is paused');
       NET.up[1].n=5; NET.up[1].age=0;
       G.paused=true; t0=G.t; frames(10);
       if(G.t!==t0) bad.push('with the whole party paused the world still ran ('+t0+' to '+G.t+')');
       NET.up[1].pz=0; t0=G.t; frames(10);
       if(!(G.t>t0)) bad.push('control: with the teammate playing, the pause stopped the world for him');
     }
     finally{
       try{ keys={}; if(G) G.paused=false; }catch(_k){}
       try{ NET.on=keepN.on; NET.role=keepN.role; NET.peers=keepN.peers||[]; NET.upSeed=keepN.upSeed; NET.seat=keepN.seat; NET.up=keepN.up||[]; NET.roster=keepN.roster||[]; }catch(_n){}
       try{ G=null; state=keepSt; }catch(_g){}
       try{ if(typeof state==='undefined'||state!=='hub') __hubEnter(); }catch(_he){}
       try{ __resetCfg(); }catch(_rc){}
       try{ __cleanProfile(); }catch(_cp){}
     }
     return bad.length?bad.join('; '):null; }},
  {v:'16.19',what:
'@


$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
