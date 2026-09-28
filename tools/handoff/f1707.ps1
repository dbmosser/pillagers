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

if ($s.Contains("  {v:'17.07',what:")) { throw "check 17.07 is in the fixture already" }

SubRx @'
  {v:'17.06',what:
'@ @'
  {v:'17.07',what:'an issued Bandage stays a loaner when it passes between teammates: a dropped one searched up by player 2 arrives issued on his window, one held out to a teammate who walks off comes back still issued, and a finished heal still spends it',
   run:function(){
     if(typeof netContNewWord!=='function'||typeof netContWord!=='function'||typeof netLootTake!=='function'||typeof netAidStart!=='function'||typeof trackIssuedBandages!=='function'||typeof tickPrep!=='function'||!window.__deploy||!window.__endRaid||typeof NET!=='object'||!NET) return 'SKIP: this fixture cannot stage a party raid';
     var keep={on:NET.on,role:NET.role,seat:NET.seat,peers:NET.peers,upSeed:NET.upSeed,up:NET.up,roster:NET.roster,same:NET.same,contMap:NET.contMap,contN:NET.contN,contN0:NET.contN0,holds:NET.holds,srch:NET.srch,srchOwn:NET.srchOwn,status:NET.status},
         oSend=netSend, oSay=say, bad=[], p=null, host={state:'in',seat:0}, pile, m, ct, cid, n0, i, k;
     function cnt(){ var c=0, j; for(j=0;j<G.bag.length;j++) if(G.bag[j]==='bandage') c++; return c; }
     try{
       __runPrep(); __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       netSend=function(){ return true; }; say=function(){};
       p=G.player; p.prep=null; p.prepA=null;
       NET.on=true; NET.same=''; NET.role='join'; NET.seat=1; NET.peers=[host]; NET.upSeed=G.seed>>>0; NET.up=[];
       NET.roster=[{seat:0,pid:'zqxhost',name:'ZQX HOST',host:true},{seat:1,pid:'me',name:'KID'}];
       netContInit(G);
       cid=G.containers.length+37;
       pile={cid:cid,x:p.x+20,y:p.y+10,type:'crate',time:0.6,dropped:1,issuedB:1,loot:['bandage'],opened:false};
       m=JSON.parse(JSON.stringify(netContNewWord(pile)));
       if(netContWord(host,m)!=='cont:new') return 'SKIP: staging: the linked window did not take the pile word';
       ct=netContOf(cid); if(!ct) return 'SKIP: staging: the pile is not on the linked window';
       G.issuedBandages=0; G.bandSeen=undefined; trackIssuedBandages(); n0=cnt();
       netLootTake(host,{t:'loot',cid:cid,items:['bandage']});
       trackIssuedBandages();
       if(cnt()!==n0+1) return 'SKIP: staging: the Bandage from the pile did not reach the backpack';
       if(G.issuedBandages!==1) bad.push('a dropped issued Bandage searched up by player 2 arrived as a find (issued count '+G.issuedBandages+', not 1)');
       for(i=G.bag.length-1;i>=0;i--) if(G.bag[i]==='bandage') G.bag.splice(i,1);
       G.bag.push('bandage'); G.bag.push('bandage');
       G.issuedBandages=2; G.bandSeen=undefined; trackIssuedBandages();
       NET.up[0]={seat:0,x:p.x+40,y:p.y,f:0,tx:p.x+40,ty:p.y,tf:0,n:5,age:0,dn:0,sd:NET.upSeed>>>0,hp:40,mh:100,ar:0,ac:100};
       if(!netAidStart(0,'bandage')||!p.prep) return 'SKIP: staging: the heal for the teammate did not start';
       trackIssuedBandages();
       NET.up[0].x=p.x+900; NET.up[0].tx=p.x+900;
       p.prep.t=p.prep.max; tickPrep(0); trackIssuedBandages();
       if(p.prep||cnt()!==2) return 'SKIP: staging: the Bandage did not come back when the teammate walked off';
       if(G.issuedBandages!==2) bad.push('a loaner Bandage that came back when the teammate walked off counts as a find (issued count '+G.issuedBandages+', not 2)');
       NET.up[0].x=p.x+40; NET.up[0].tx=p.x+40;
       if(!netAidStart(0,'bandage')||!p.prep) return 'SKIP: staging: the second heal for the teammate did not start';
       trackIssuedBandages(); p.prep.t=p.prep.max; tickPrep(0); trackIssuedBandages();
       if(cnt()!==1) bad.push('a finished heal for the teammate did not spend the Bandage');
       else if(G.issuedBandages!==1) bad.push('a finished heal for the teammate with a loaner Bandage left the issued count at '+G.issuedBandages+', not 1');
     } finally { netSend=oSend; say=oSay; for(k in keep) NET[k]=keep[k]; try{ if(p){ p.prep=null; p.prepA=null; } __endRaid('abandon'); __topClear(); }catch(e){} }
     return bad.length?bad.join('; '):null; }},
  {v:'17.06',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
