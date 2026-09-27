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

if ($s.Contains("  {v:'16.84',what:")) { throw "check 16.84 is in the fixture already" }

SubRx @'
  {v:'16.83',what:
'@ @'
  {v:'16.84',what:'hold Y next to a teammate uses the Bandage, Medkit or plate selected on your tactical belt and only that: with a gun selected it says to select one and spends nothing, with the heal slot selected it starts the wind-up for him with that item, and with nobody in reach Y is the ring search',
   run:function(){
     if(typeof pollPad!=='function'||typeof netAidTarget!=='function'||typeof hotbarSlots!=='function'||typeof netSend!=='function'||!window.__deploy||!window.__endRaid||typeof NET!=='object'||!NET) return 'SKIP: this fixture cannot stage a controller party raid';
     if(typeof netAidHold!=='function') return 'this build has no teammate heal on Y (netAidHold)';
     var NGA=navigator.getGamepads, oNS=netSend, oSay=say, keepN={on:NET.on,role:NET.role,peers:NET.peers,upSeed:NET.upSeed,seat:NET.seat,up:NET.up,roster:NET.roster,same:NET.same}, bad=[], said=[], down={}, k0=null, p=null, hi, n0;
     function pad(){ var b=[],q; for(q=0;q<17;q++) b.push({pressed:!!down[q],value:(down[q]?1:0),touched:!!down[q]}); return [{connected:true,id:'check pad',index:0,mapping:'standard',timestamp:Date.now(),buttons:b,axes:[0,0,0,0]}]; }
     function cnt(k){ var c=0; for(var i=0;i<G.bag.length;i++) if(G.bag[i]===k) c++; return c; }
     function pressY(){ down={}; pollPad(); down={3:1}; pollPad(); }
     try{
       __runPrep(); __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       k0=keys; keys={}; navigator.getGamepads=pad;
       netSend=function(){ return true; }; say=function(m){ said.push(String(m)); };
       G.sim=0; G.bagOpen=false; G.mapOpen=false; G.nearContainer=null; G.nearPad=null; G.nearDown=null; G.nearDoor=null; G.nearPed=null;
       p=G.player; p.prep=null; p.prepA=null; p.face=Math.PI;
       NET.on=true; NET.same=''; NET.role='join'; NET.seat=1; NET.peers=[{state:'in',seat:0}];
       NET.upSeed=G.seed>>>0; NET.up=[]; NET.roster=[{seat:0,pid:'zqxhost',name:'ZQX HOST',host:true},{seat:1,pid:'me',name:'KID'}];
       NET.up[0]={seat:0,x:p.x+40,y:p.y,f:0,tx:p.x+40,ty:p.y,tf:0,n:5,age:0,dn:0,sd:NET.upSeed>>>0,hp:40,mh:100,ar:0,ac:100};
       G.bag.push('bandage'); G.bag.push('bandage'); n0=cnt('bandage');
       G.hot=0; said.length=0; pressY();
       if(p.prep) bad.push('Y with a gun selected started a heal');
       if(cnt('bandage')!==n0) bad.push('Y with a gun selected spent a Bandage');
       if(!said.some(function(m){ return m.indexOf('tactical belt')>=0; })) bad.push('Y with a gun selected did not say to select a heal on the tactical belt ('+said.join(' / ')+')');
       hi=hotbarSlots().map(function(q){ return q.kind; }).indexOf('heal');
       if(hi<0) return 'SKIP: staging: the tactical belt shows no heal slot';
       G.hot=hi; down={}; pollPad(); pressY();
       if(!(p.prep&&p.prep.key==='bandage'&&p.prep.aid===0)) bad.push('Y with the heal slot selected beside a hurt teammate did not start a Bandage wind-up for him ('+JSON.stringify(p.prep||null)+')');
       if(cnt('bandage')!==n0-1) bad.push('the Bandage did not come out of the backpack');
       down={}; pollPad(); p.prep=null; NET.up[0].x=p.x+900; NET.up[0].tx=p.x+900; pressY();
       if(p.prep) bad.push('Y with nobody in reach started a heal');
       if(!keys['KeyX']) bad.push('Y with nobody in reach did not hold the ring search');
     } finally { navigator.getGamepads=NGA; netSend=oNS; say=oSay; for(var k in keepN) NET[k]=keepN[k]; try{ down={}; keys=k0||{}; if(p){ p.prep=null; p.prepA=null; } G.hot=0; PAD.yAid=false; __endRaid('abandon'); __topClear(); }catch(e){} }
     return bad.length?bad.join('; '):null; }},
  {v:'16.83',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
