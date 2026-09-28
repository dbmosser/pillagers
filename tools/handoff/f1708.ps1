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

if ($s.Contains("  {v:'17.08',what:")) { throw "check 17.08 is in the fixture already" }

SubRx @'
  {v:'17.07',what:
'@ @'
  {v:'17.08',what:'a bandage from a teammate that cannot raise him, because his own bandage is winding up or already running to 85, is not poured into his heal but goes back to the teammate, whose window puts it back in the backpack; with nothing running it still heals him',
   run:function(){
     if(!(window.__resetCfg&&window.__pinDefaults&&window.__startRaid&&window.__cleanProfile)||typeof NET!=='object'||!NET||typeof netOnMsg!=='function'||typeof startPrep!=='function'||typeof applyHeal!=='function'||typeof healReach!=='function'||typeof healCeil!=='function') return 'SKIP: this fixture cannot stage a party raid';
     if(!ITEMS.bandage||!(ITEMS.bandage.hot>0)) return 'SKIP: this build has no bandage that heals over time';
     var bad=[], keepN={on:NET.on,role:NET.role,peers:NET.peers,upSeed:NET.upSeed,seat:NET.seat,up:NET.up,roster:NET.roster}, sent=[], peer, p, q0, r, n0, hc;
     function mk(seat){ return {state:'in',seat:seat,name:'ZQX',timers:[],dc:{readyState:'open',send:function(x){ sent.push(JSON.parse(x)); }}}; }
     function cnt(){ var c=0; for(var i=0;i<G.bag.length;i++) if(G.bag[i]==='bandage') c++; return c; }
     function fresh(h){ p.hp=h; p.maxhp=100; p.healQ=0; p.healRate=0; p.healCap=undefined; p.healHi=0; p.healLo=undefined; p.healAmt0=0; p.prep=null; p.prepA=null; p.downed=0; sent.length=0; }
     function back(){ return sent.some(function(m){ return m.t==='aidx'&&m.s===0&&m.k==='bandage'; }); }
     try{
       __resetCfg(); __pinDefaults(0); __startRaid({mapIx:0,seed:4242}); keys={}; G.sim=0; G.over=false; p=G.player;
       hc=healCeil(ITEMS.bandage); if(!(hc<100)) return 'SKIP: the bandage has no ceiling under full health in this build';
       NET.on=true; NET.role='join'; NET.seat=1; peer=mk(0); NET.peers=[peer]; NET.upSeed=G.seed>>>0; NET.up=[];
       NET.roster=[{seat:0,pid:'zqxhost',name:'ZQX HOST',host:true},{seat:1,pid:'me',name:'ZQX MATE'}];
       fresh(40);
       r=netOnMsg(peer,JSON.stringify({t:'aid',s:1,by:0,k:'bandage'}));
       if(!(p.healQ>0||p.hp>40)) bad.push('control: a bandage from a teammate did not heal him at 40 with nothing running ('+r+')');
       if(back()) bad.push('control: a bandage he could use was sent back');
       fresh(hc-10); applyHeal('bandage');
       if(!(healReach(p)>=hc-0.01)) return 'SKIP: staging: his own bandage from '+(hc-10)+' does not reach '+hc+' ('+healReach(p)+')';
       q0=p.healQ;
       r=netOnMsg(peer,JSON.stringify({t:'aid',s:1,by:0,k:'bandage'}));
       if(p.healQ!==q0) bad.push('running heal: the teammate bandage was poured into a heal that already stops at '+hc+' (queue '+q0+' to '+p.healQ+', '+r+')');
       if(!back()) bad.push('running heal: the teammate bandage was not sent back ('+r+')');
       fresh(hc-10); startPrep('heal','bandage');
       r=netOnMsg(peer,JSON.stringify({t:'aid',s:1,by:0,k:'bandage'}));
       if(p.healQ>0) bad.push('winding up: the teammate bandage went in ahead of his own, which then lands on it for nothing (queue '+p.healQ+', '+r+')');
       if(!back()) bad.push('winding up: the teammate bandage was not sent back ('+r+')');
       fresh(hc-10); NET.role='host'; NET.seat=0; peer=mk(1); NET.peers=[peer];
       NET.roster=[{seat:0,pid:'me',name:'ZQX HOST',host:true},{seat:1,pid:'zqxmate',name:'ZQX MATE'}];
       n0=cnt();
       r=netOnMsg(peer,JSON.stringify({t:'aidx',s:0,f:1,k:'bandage',w:'full'}));
       if(cnt()!==n0+1) bad.push('the bandage sent back did not come back to the healer backpack ('+r+')');
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{
       try{ keys={}; if(G&&G.player){ G.player.prep=null; G.player.prepA=null; } }catch(_k){}
       try{ NET.on=keepN.on; NET.role=keepN.role; NET.peers=keepN.peers||[]; NET.upSeed=keepN.upSeed; NET.seat=keepN.seat; NET.up=keepN.up||[]; NET.roster=keepN.roster||[]; }catch(_n){}
       try{ G=null; }catch(_g){}
       try{ __resetCfg(); }catch(_rc){}
       try{ __cleanProfile(); }catch(_cp){}
     }
     return bad.length?bad.join('; '):null; }},
  {v:'17.07',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
