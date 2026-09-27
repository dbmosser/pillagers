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

if ($s.Contains("  {v:'16.21',what:")) { throw "check 16.21 is in the fixture already" }

SubRx @'
  {v:'16.20',what:
'@ @'
  {v:'16.21',what:'the party sees and hears the fight: a round fired in a shared raid goes to the party as a tracer, a tracer from the party flies and is drawn but hurts nothing, a sound goes to the party and one from the party makes a ring here; alone nothing is sent',
   run:function(){
     if(!(window.__resetCfg&&window.__pinDefaults&&window.__startRaid&&window.__cleanProfile)||typeof NET!=='object'||!NET||typeof netOnMsg!=='function') return 'SKIP: this fixture cannot stage a party raid';
     var bad=[], keepN={on:NET.on,role:NET.role,peers:NET.peers,upSeed:NET.upSeed,seat:NET.seat,up:NET.up,roster:NET.roster}, sent=[], peer, p, hp0, r;
     function mk(seat){ return {state:'in',seat:seat,name:'ZQX',timers:[],dc:{readyState:'open',send:function(t){ sent.push(JSON.parse(t)); }}}; }
     try{
       __resetCfg(); __pinDefaults(0); __startRaid({mapIx:0,seed:4242}); keys={}; G.sim=0; G.over=false; p=G.player;
       // ALONE
       NET.on=false; if(typeof netFxShot==='function'&&netFxShot({x:1,y:1,vx:1,vy:1,life:1})) bad.push('control: alone, a round was sent');
       NET.on=true; NET.role='host'; NET.seat=0; peer=mk(1); NET.peers=[peer]; NET.upSeed=G.seed>>>0; NET.up=[];
       NET.roster=[{seat:0,pid:'me',name:'HOST',host:true},{seat:1,pid:'zqxmate',name:'ZQX MATE'}];
       sent.length=0;
       G.bullets.push({x:p.x,y:p.y,vx:1180,vy:0,dmg:1,life:0.5,player:true,owner:p,tint:'#ffd48a',thru:0});
       if(typeof netFxShot!=='function'||!netFxShot(G.bullets[G.bullets.length-1])||!sent.some(function(m){ return m.t==='fx'&&m.k==='b'; })) bad.push('a round fired in a shared raid was not sent to the party');
       sent.length=0; if(typeof netFxNoise==='function') netFxNoise('shot',p.x+200,p.y,''); try{ if(typeof netFxStep==='function') netFxStep(0.2); }catch(e1){}   // the fixture's own sfx is silent and skips the relay line, so the relay is called as sfx calls it
       if(!sent.some(function(m){ return m.t==='fx'&&m.k==='n'; })) bad.push('a sound in a shared raid was not sent to the party');
       // FROM THE PARTY
       NET.role='join'; NET.seat=1; peer=mk(0); NET.peers=[peer]; G.fxBullets=[]; hp0=p.hp;
       r=netOnMsg(peer,JSON.stringify({t:'fx',k:'b',s:0,b:[Math.round(p.x-100),Math.round(p.y),1180,0,0.4,'#ffd48a']}));
       if(!G.fxBullets||G.fxBullets.length!==1) bad.push('a round from the party was not taken as a tracer ('+r+')');
       else { try{ netFxStep(0.05); }catch(e2){} if(!(G.fxBullets.length&&G.fxBullets[0].x>p.x-100)&&G.fxBullets.length) bad.push('the tracer did not fly'); }
       if(p.hp!==hp0) bad.push('a tracer hurt him ('+hp0+' to '+p.hp+')');
       G.noiseRings=[];
       var sp=null; for(var a=0;a<G.ents.length;a++){ if(G.ents[a]){ sp=G.ents[a]; break; } }
       r=netOnMsg(peer,JSON.stringify({t:'fx',k:'n',s:0,n:[['shot',Math.round(p.x+Math.cos(p.face+Math.PI)*300),Math.round(p.y+Math.sin(p.face+Math.PI)*300),'']]}));
       if(r!=='fx:n') bad.push('a sound from the party was not taken ('+r+')');
       else if(CFG.noiseSee!==0&&!(G.noiseRings&&G.noiseRings.length)) bad.push('a sound from the party behind him drew no ring');
     }
     finally{
       try{ keys={}; NET.fxQ=[]; NET.fxIn=false; if(G) G.fxBullets=[]; }catch(_k){}
       try{ NET.on=keepN.on; NET.role=keepN.role; NET.peers=keepN.peers||[]; NET.upSeed=keepN.upSeed; NET.seat=keepN.seat; NET.up=keepN.up||[]; NET.roster=keepN.roster||[]; }catch(_n){}
       try{ G=null; }catch(_g){}
       try{ __resetCfg(); }catch(_rc){}
       try{ __cleanProfile(); }catch(_cp){}
     }
     return bad.length?bad.join('; '):null; }},
  {v:'16.20',what:
'@


$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
