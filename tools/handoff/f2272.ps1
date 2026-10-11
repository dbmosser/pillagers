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

if ($s.Contains("  {v:'22.72',what:")) { throw "check 22.72 is in the fixture already" }

SubRx @'
  {v:'22.71',what:
'@ @'
  {v:'22.72',what:'teammate pick-ups and gifts in the shooter voice: E held beside a downed teammate runs the pick-up with no line repeating the REVIVE prompt, his word showing him up says ZQX MATE IS BACK UP as an ally row and never the old revived sentence, and T taking a waiting offer says TAKING IT',
   run:function(){
     if(typeof netRevHold!=='function'||typeof netGiftKey!=='function'||typeof updatePlayer!=='function'||typeof netSend!=='function'||typeof NET!=='object'||!NET||!window.__deploy||!window.__endRaid) return 'SKIP: this build has no teammate pick-up or gifts';
     var keep={on:NET.on,role:NET.role,seat:NET.seat,upSeed:NET.upSeed,up:NET.up,peers:NET.peers,roster:NET.roster},
         oSend=netSend, oSay=say, oBlip=blip, k0=keys, bad=[], said=[], sent=[], p=null, i, n, k, ran=0, l,
         OLDS=['Reviving','ZQX'].join(' '), OLDR=['MATE','revived'].join(' '), BACK=['ZQX','MATE','IS','BACK','UP'].join(' '), TAKE=['TAKING','IT'].join(' ');
     function step(){ keys['KeyE']=true; updatePlayer(0.05); if(G.netRevEat){ G.netRevEat=0; keys['KeyE']=true; } }
     function revs(){ return sent.filter(function(m){ return m&&m.t==='rev'; }).length; }
     function mate(dn){ NET.up[1]={seat:1,x:p.x+30,y:p.y,f:0,tx:p.x+30,ty:p.y,tf:0,n:5,age:0,dn:dn?1:0,hp:dn?0:40,mh:100,sd:NET.upSeed>>>0}; }
     try{
       __runPrep(); __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       p=G.player; keys={}; G.sim=0; G.over=false; p.downed=false; p.roll=0; G.bagOpen=false;
       netSend=function(q,m){ sent.push(m); return true; }; say=function(m,kd){ said.push({m:String(m),k:kd}); }; blip=function(){};
       NET.on=true; NET.role='host'; NET.seat=0; NET.upSeed=G.seed>>>0; NET.up=[]; NET.peers=[{state:'in',seat:1}];
       NET.roster=[{seat:0,pid:'zqxhost',name:'ZQX HOST',host:true},{seat:1,pid:'zqxmate',name:'ZQX MATE'}];
       mate(true);
       for(i=0;i<70;i++){ step(); if(G.netRevT>0) ran=1; }
       // CONTROL: the pick-up ran and one was sent, on either build.
       if(!ran||revs()!==1) return 'SKIP: staging: E held 3.5 s beside a downed teammate ran the pick-up '+ran+' and sent '+revs()+' pick-ups, not one';
       for(i=0;i<said.length;i++) if(said[i].m.indexOf(OLDS)===0) bad.push('the pick-up said '+JSON.stringify(said[i].m)+' as it started, repeating the [E] REVIVE prompt and the REVIVING bar');
       // his word shows him up with health
       said.length=0; mate(false); step();
       l=null; for(i=0;i<said.length;i++) if(said[i].m.indexOf('ZQX')===0) l=said[i];
       if(!l) bad.push('the teammate word showing him up said nothing');
       else if(l.m!==BACK||l.k!=='ally') bad.push('the teammate up again reads '+JSON.stringify(l.m)+' ('+l.k+'), not '+BACK+' as an ally row');
       for(i=0;i<said.length;i++) if(said[i].m.indexOf(OLDR)>=0) bad.push('the old revived sentence is still said');
       // a waiting offer taken with T
       keys={}; said.length=0; G.netRevDone=-1; G.netRevWait=-1;
       G.giftIn={id:'zq1',from:1,k:'codex',t:G.t};
       netGiftKey();
       if(!G.giftIn||!G.giftIn.yes) bad.push('SKIP: staging: T did not take the waiting offer');
       else if(!said.some(function(q){ return q.m===TAKE; })) bad.push('taking a waiting offer said '+JSON.stringify(said.map(function(q){ return q.m; }))+', not '+TAKE);
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally {
       netSend=oSend; say=oSay; blip=oBlip; keys=k0||{};
       for(k in keep) NET[k]=keep[k];
       try{ if(G){ G.giftIn=null; G.giftOut=null; G.netRevEat=0; G.netRevWait=-1; G.netRevDone=-1; G.netRevT=0; G.netRevS=-1; } __endRaid('abandon'); __topClear(); }catch(e2){}
     }
     return bad.length?bad.join('; '):null; }},
  {v:'22.71',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
