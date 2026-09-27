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

if ($s.Contains("  {v:'16.23',what:")) { throw "check 16.23 is in the fixture already" }

SubRx @'
  {v:'16.22',what:
'@ @'
  {v:'16.23',what:'use your bandages and plates on a teammate: facing a hurt teammate beside you picks him, facing away does not; a bandage for him comes out of your backpack, winds up and goes to him; a teammate at full is refused with nothing spent; on his window it heals him and a plate adds armour',
   run:function(){
     if(!(window.__resetCfg&&window.__pinDefaults&&window.__startRaid&&window.__cleanProfile)||typeof NET!=='object'||!NET||typeof netOnMsg!=='function'||typeof tickPrep!=='function') return 'SKIP: this fixture cannot stage a party raid';
     var bad=[], keepN={on:NET.on,role:NET.role,peers:NET.peers,upSeed:NET.upSeed,seat:NET.seat,up:NET.up,roster:NET.roster}, sent=[], peer, p, n0, s, hp0, ar0, t;
     function mk(seat){ return {state:'in',seat:seat,name:'ZQX',timers:[],dc:{readyState:'open',send:function(x){ sent.push(JSON.parse(x)); }}}; }
     function cnt(k){ var c=0; for(var i=0;i<G.bag.length;i++) if(G.bag[i]===k) c++; return c; }
     try{
       __resetCfg(); __pinDefaults(0); __startRaid({mapIx:0,seed:4242}); keys={}; G.sim=0; G.over=false; p=G.player; p.face=0; p.prep=null; p.prepA=null;
       NET.on=true; NET.role='host'; NET.seat=0; peer=mk(1); NET.peers=[peer]; NET.upSeed=G.seed>>>0; NET.up=[];
       NET.roster=[{seat:0,pid:'me',name:'HOST',host:true},{seat:1,pid:'zqxmate',name:'ZQX MATE'}];
       NET.up[1]={seat:1,x:p.x+40,y:p.y,f:0,tx:p.x+40,ty:p.y,tf:0,n:5,age:0,dn:0,sd:NET.upSeed>>>0,hp:40,mh:100,ar:0,ac:100};
       s=(typeof netAidTarget==='function')?netAidTarget(p):-1;
       if(s!==1) bad.push('facing a hurt teammate beside him did not pick the teammate ('+s+')');
       p.face=Math.PI; if(typeof netAidTarget==='function'&&netAidTarget(p)!==-1) bad.push('facing away still picked the teammate'); p.face=0;
       G.bag.push('bandage'); n0=cnt('bandage'); sent.length=0;
       if(typeof netAidStart==='function'&&netAidStart(1,'bandage')){
         if(cnt('bandage')!==n0-1) bad.push('the bandage for the teammate did not come out of the backpack');
         for(t=0;t<40;t++) tickPrep(0.1);
         if(!sent.some(function(m){ return m.t==='aid'&&m.s===1&&m.k==='bandage'; })) bad.push('after the wind-up the bandage was not sent to the teammate');
       } else bad.push('a bandage for a hurt teammate was refused');
       if(typeof netAidStart==='function'){
         NET.up[1].hp=100; G.bag.push('bandage'); n0=cnt('bandage'); p.prep=null;
         if(netAidStart(1,'bandage')) bad.push('a bandage for a teammate at full was started');
         if(cnt('bandage')!==n0) bad.push('a refused bandage was spent');
       }
       // HIS WINDOW
       NET.role='join'; NET.seat=1; peer=mk(0); NET.peers=[peer]; p.hp=40; p.healQ=0; p.armor=0; hp0=p.hp; ar0=p.armor;
       netOnMsg(peer,JSON.stringify({t:'aid',s:1,by:0,k:'bandage'}));
       if(!(p.hp>hp0||p.healQ>0)) bad.push('a bandage from a teammate did not heal him');
       netOnMsg(peer,JSON.stringify({t:'aid',s:1,by:0,k:'plate'}));
       if(!(p.armor>ar0)) bad.push('a plate from a teammate added no armour');
     }
     finally{
       try{ keys={}; if(G&&G.player){ G.player.prep=null; G.player.prepA=null; } }catch(_k){}
       try{ NET.on=keepN.on; NET.role=keepN.role; NET.peers=keepN.peers||[]; NET.upSeed=keepN.upSeed; NET.seat=keepN.seat; NET.up=keepN.up||[]; NET.roster=keepN.roster||[]; }catch(_n){}
       try{ G=null; }catch(_g){}
       try{ __resetCfg(); }catch(_rc){}
       try{ __cleanProfile(); }catch(_cp){}
     }
     return bad.length?bad.join('; '):null; }},
  {v:'16.22',what:
'@


$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
