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

if ($s.Contains("  {v:'16.05',what:")) { throw "check 16.05 is in the fixture already" }

SubRx @'
  {v:'16.04',what:
'@ @'
  {v:'16.05',what:'teammate revives: as the host with a linked teammate down beside him, E held for the hire pick-up time sends the pick-up to that seat, and letting go early sends nothing (control: a teammate on his feet is never picked up); as the linked window, down, a pick-up from the host with the teammate beside him puts him on his feet at 40 percent, and one from a teammate far off does not',
   run:function(){
     if(!(window.__resetCfg&&window.__pinDefaults&&window.__startRaid&&window.__cleanProfile)||typeof NET!=='object'||!NET||typeof updatePlayer!=='function'||typeof netOnMsg!=='function') return 'SKIP: this fixture cannot stage a party raid';
     var bad=[], keepN={on:NET.on,role:NET.role,peers:NET.peers,upSeed:NET.upSeed,seat:NET.seat,up:NET.up,roster:NET.roster}, sent=[], p, i, rv, peer;
     function mk(seat){ return {state:'in',seat:seat,name:'ZQX',timers:[],dc:{readyState:'open',send:function(t){ sent.push(JSON.parse(t)); }}}; }
     function hold(sec){ keys['KeyE']=true; for(var t=0;t<sec;t+=0.05) updatePlayer(0.05); keys['KeyE']=false; }
     function mate(seat,x,y,dn){ NET.up[seat]={seat:seat,x:x,y:y,f:0,tx:x,ty:y,tf:0,n:5,age:0,dn:dn?1:0,sd:NET.upSeed>>>0}; }
     try{
       __resetCfg(); __pinDefaults(0); __startRaid({mapIx:0,seed:4242}); keys={};
       p=G.player; G.sim=0; G.over=false;
       NET.on=true; NET.role='host'; NET.seat=0; peer=mk(1); NET.peers=[peer]; NET.upSeed=G.seed>>>0; NET.up=[];
       NET.roster=[{seat:0,name:'HOST',host:true},{seat:1,name:'ZQX MATE'}];
       // CONTROL: on his feet, nothing is sent however long E is held
       mate(1,p.x+30,p.y,false); sent.length=0; hold(4);
       if(sent.some(function(m){ return m.t==='rev'; })) bad.push('control: a teammate on his feet was picked up');
       mate(1,p.x+30,p.y,true); sent.length=0; hold(1.5);
       if(sent.some(function(m){ return m.t==='rev'; })) bad.push('E held 1.5 s picked the teammate up before the 3.2 s a hire takes');
       sent.length=0; hold(3.5);
       rv=sent.filter(function(m){ return m.t==='rev'; });
       if(rv.length!==1||rv[0].s!==1) bad.push('E held 3.5 s beside a downed teammate sent '+JSON.stringify(rv)+', not one pick-up for seat 1');
       // THE DOWNED WINDOW
       NET.role='join'; NET.seat=1; peer=mk(0); NET.peers=[peer]; NET.up=[];
       NET.roster=[{seat:0,name:'ZQX HOST',host:true},{seat:1,name:'ME'}];
       p.downed=true; p.hp=0; G.deathBeat=null;
       mate(0,p.x+500,p.y,false);
       netOnMsg(peer,JSON.stringify({t:'rev',s:1,by:0}));
       if(!p.downed) bad.push('a pick-up from a teammate 500 away put him on his feet');
       mate(0,p.x+30,p.y,false);
       var r2=netOnMsg(peer,JSON.stringify({t:'rev',s:1,by:0}));
       if(p.downed) bad.push('a pick-up from the teammate beside him left him down ('+r2+')');
       else if(p.hp!==Math.round(p.maxhp*0.4)) bad.push('picked up with '+p.hp+' health, not the 40 percent a hire gives');
     }
     finally{
       try{ keys={}; }catch(_k){}
       try{ NET.on=keepN.on; NET.role=keepN.role; NET.peers=keepN.peers||[]; NET.upSeed=keepN.upSeed; NET.seat=keepN.seat; NET.up=keepN.up||[]; NET.roster=keepN.roster||[]; }catch(_n){}
       try{ G=null; }catch(_g){}
       try{ __resetCfg(); }catch(_rc){}
       try{ __cleanProfile(); }catch(_cp){}
     }
     return bad.length?bad.join('; '):null; }},
  {v:'16.04',what:
'@


$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
