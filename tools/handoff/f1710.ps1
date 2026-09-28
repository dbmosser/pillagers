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

if ($s.Contains("  {v:'17.10',what:")) { throw "check 17.10 is in the fixture already" }

SubRx @'
  {v:'17.09',what:
'@ @'
  {v:'17.10',what:'a heal for a teammate is never lost: his window sends it back when he is down, in his death beat or out of the raid; the healer skips a teammate whose raid has ended and keeps the item, and one the host could not pass to anyone is kept or sent back',
   run:function(){
     if(!(window.__resetCfg&&window.__pinDefaults&&window.__startRaid&&window.__cleanProfile)||typeof NET!=='object'||!NET||typeof netOnMsg!=='function'||typeof netAidFinish!=='function'||typeof netAidTarget!=='function') return 'SKIP: this fixture cannot stage a party raid';
     if(typeof netUpGone!=='function') return 'SKIP: this build does not mark a seat whose raid ended';
     var bad=[], keepN={on:NET.on,role:NET.role,peers:NET.peers,upSeed:NET.upSeed,seat:NET.seat,up:NET.up,roster:NET.roster,upOut:NET.upOut}, sent=[], peer, p, r, n0, t;
     function mk(seat){ return {state:'in',seat:seat,name:'ZQX',timers:[],dc:{readyState:'open',send:function(x){ sent.push(JSON.parse(x)); }}}; }
     function cnt(){ var c=0; for(var i=0;i<G.bag.length;i++) if(G.bag[i]==='bandage') c++; return c; }
     function back(){ return sent.some(function(m){ return m.t==='aidx'&&m.s===0&&m.k==='bandage'; }); }
     function out(){ return sent.some(function(m){ return m.t==='aid'; }); }
     function aid(){ return netOnMsg(peer,JSON.stringify({t:'aid',s:1,by:0,k:'bandage'})); }
     function fin(){ sent.length=0; return netAidFinish({t:1.5,max:1.5,kind:'heal',key:'bandage',aid:1}); }
     try{
       __resetCfg(); __pinDefaults(0); __startRaid({mapIx:0,seed:4242}); keys={}; G.sim=0; G.over=false; p=G.player; p.face=0; p.prep=null; p.prepA=null;
       NET.on=true; NET.role='join'; NET.seat=1; peer=mk(0); NET.peers=[peer]; NET.upSeed=G.seed>>>0; NET.up=[]; NET.upOut={};
       NET.roster=[{seat:0,pid:'zqxhost',name:'ZQX HOST',host:true},{seat:1,pid:'me',name:'ZQX MATE'}];
       p.hp=40; p.healQ=0; p.dying=false; p.downed=0; sent.length=0; r=aid();
       if(!(p.healQ>0||p.hp>40)) bad.push('control: a bandage from a teammate did not heal him standing at 40 ('+r+')');
       if(back()) bad.push('control: a bandage he took was also sent back');
       p.hp=40; p.healQ=0; p.downed=1; sent.length=0; r=aid();
       if(!back()) bad.push('a bandage that reached him while he was down was not sent back ('+r+')');
       p.downed=0; p.dying=true; p.hp=0; p.healQ=0; sent.length=0; r=aid();
       if(p.healQ>0||p.hp>0) bad.push('a bandage that reached him in his death beat went into a dead man (queue '+p.healQ+')');
       if(!back()) bad.push('a bandage that reached him in his death beat was not sent back ('+r+')');
       p.dying=false; p.hp=40; p.healQ=0; G.over=true; sent.length=0; r=aid(); G.over=false;
       if(!back()) bad.push('a bandage that reached him after his raid ended was not sent back ('+r+')');
       NET.role='host'; NET.seat=0; peer=mk(1); NET.peers=[peer]; p.hp=100; p.healQ=0;
       NET.roster=[{seat:0,pid:'me',name:'ZQX HOST',host:true},{seat:1,pid:'zqxmate',name:'ZQX MATE'}];
       NET.up[1]={seat:1,x:p.x+40,y:p.y,f:0,tx:p.x+40,ty:p.y,tf:0,n:5,age:0,dn:0,sd:NET.upSeed>>>0,hp:40,mh:100,ar:0,ac:100};
       t=netAidTarget(p,true); if(t!==1) return 'SKIP: staging: the hurt teammate beside him was not picked ('+t+')';
       n0=cnt(); fin();
       if(!out()) bad.push('control: the bandage for a teammate beside him was not sent');
       if(cnt()!==n0) bad.push('control: a bandage that went out also stayed in the backpack');
       NET.upOut[1]=NET.upSeed>>>0;
       if(netAidTarget(p,true)!==-1) bad.push('a teammate whose raid has ended was still picked for a heal');
       n0=cnt(); fin();
       if(out()) bad.push('the bandage was sent to a teammate whose raid has ended');
       if(cnt()!==n0+1) bad.push('the bandage for a teammate whose raid has ended did not come back to the backpack');
       NET.upOut={}; sent.length=0; r=netOnMsg(peer,JSON.stringify({t:'aid',s:2,k:'bandage'}));
       if(!sent.some(function(m){ return m.t==='aidx'&&m.s===1&&m.k==='bandage'; })) bad.push('a bandage a friend sent to a seat the host could not reach was not sent back to him ('+r+')');
       NET.peers=[]; n0=cnt(); fin();
       if(cnt()!==n0+1) bad.push('a bandage the host could not pass to anyone was lost');
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{
       try{ keys={}; if(G&&G.player){ G.player.prep=null; G.player.prepA=null; G.player.dying=false; } }catch(_k){}
       try{ NET.on=keepN.on; NET.role=keepN.role; NET.peers=keepN.peers||[]; NET.upSeed=keepN.upSeed; NET.seat=keepN.seat; NET.up=keepN.up||[]; NET.roster=keepN.roster||[]; NET.upOut=keepN.upOut||{}; }catch(_n){}
       try{ G=null; }catch(_g){}
       try{ __resetCfg(); }catch(_rc){}
       try{ __cleanProfile(); }catch(_cp){}
     }
     return bad.length?bad.join('; '):null; }},
  {v:'17.09',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
