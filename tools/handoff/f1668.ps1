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

if ($s.Contains("  {v:'16.68',what:")) { throw "check 16.68 is in the fixture already" }

SubRx @'
  {v:'16.67',what:
'@ @'
  {v:'16.68',what:'a teammate pick-up is called revived only once his own word shows him up with health: a teammate who stays down is never called revived, and E held on over him starts a fresh pick-up when the answer is overdue',
   run:function(){
     if(typeof netRevHold!=='function'||typeof updatePlayer!=='function'||typeof netSend!=='function'||typeof NET!=='object'||!NET||!window.__deploy||!window.__endRaid) return 'SKIP: this build has no teammate pick-up';
     var keep={on:NET.on,role:NET.role,seat:NET.seat,upSeed:NET.upSeed,up:NET.up,peers:NET.peers,roster:NET.roster},
         oSend=netSend, oSay=say, oBlip=blip, k0=keys, bad=[], said=[], sent=[], p=null, i, n, k;
     function step(){ keys['KeyE']=true; updatePlayer(0.05); if(G.netRevEat){ G.netRevEat=0; keys['KeyE']=true; } }
     function revs(){ return sent.filter(function(m){ return m&&m.t==='rev'; }).length; }
     function told(){ return said.filter(function(m){ return m.indexOf('ZQX MATE revived')>=0; }).length; }
     function mate(dn){ NET.up[1]={seat:1,x:p.x+30,y:p.y,f:0,tx:p.x+30,ty:p.y,tf:0,n:5,age:0,dn:dn?1:0,hp:dn?0:40,mh:100,sd:NET.upSeed>>>0}; }
     try{
       __runPrep(); __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       p=G.player; keys={}; G.sim=0; G.over=false; p.downed=false; p.roll=0;
       netSend=function(q,m){ sent.push(m); return true; }; say=function(m){ said.push(String(m)); }; blip=function(){};
       NET.on=true; NET.role='host'; NET.seat=0; NET.upSeed=G.seed>>>0; NET.up=[]; NET.peers=[{state:'in',seat:1}];
       NET.roster=[{seat:0,pid:'zqxhost',name:'ZQX HOST',host:true},{seat:1,pid:'zqxmate',name:'ZQX MATE'}];
       mate(true);
       for(i=0;i<70;i++) step();
       if(revs()!==1) return 'SKIP: staging: E held 3.5 s beside a downed teammate sent '+revs()+' pick-ups, not one';
       if(told()) bad.push('the teammate was called revived the moment the pick-up was sent, before his window took it');
       // HIS WINDOW REFUSED IT: he stays down and E is still held
       for(i=0;i<140;i++) step();
       if(G.over||p.downed) return 'SKIP: staging: the raid ended or he went down while holding E';
       if(told()) bad.push('a teammate who stayed down was called revived');
       if(revs()<2) bad.push('E held 7 s more over a teammate who stayed down started no fresh pick-up ('+revs()+' sent in 10.5 s)');
       // THIS ONE TOOK: his word shows him up with health
       n=told(); mate(false); step();
       if(told()!==n+1) bad.push('the teammate word showing him up did not bring the revived line');
     } finally {
       netSend=oSend; say=oSay; blip=oBlip; keys=k0;
       for(k in keep) NET[k]=keep[k];
       try{ if(G){ G.netRevEat=0; G.netRevWait=-1; G.netRevDone=-1; G.netRevT=0; G.netRevS=-1; } __endRaid('abandon'); __topClear(); }catch(e){}
     }
     return bad.length?bad.join('; '):null; }},
  {v:'16.67',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
