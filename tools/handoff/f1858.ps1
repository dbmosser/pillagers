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

if ($s.Contains("  {v:'18.58',what:")) { throw "check 18.58 is in the fixture already" }

SubRx @'
  {v:'18.57',what:
'@ @'
  {v:'18.58',what:'crates outlive a window coming and going: a teammate leaving takes his crates off the floor, a linking window is told the crates already there, and the dropper takes his own back while nobody is linked',
   run:function(){
     if(typeof hubDropTake!=='function'||typeof netDrop!=='function'||typeof titleSceneReady!=='function') return 'SKIP: no floor crates here';
     if(!titleSceneReady()) return 'SKIP: no Undercroft floor';
     var bad=[], NK={}, k, sent=[], oSend=netSend, oB=netBroadcast, oSay=netSay, oS2=say2, oSave=saveProfile, oClose=netClose, oRef=netRefresh, oSt=P.stash.slice(), oFD=P.floorDrops, oDr=HB.drops, peer, d, sk;
     for(k in NET) NK[k]=NET[k];
     try{
       netSend=function(p,m){ sent.push(m); return true; }; netBroadcast=function(m){ sent.push(m); }; netSay=function(){}; say2=function(){}; saveProfile=function(){}; netClose=function(){}; netRefresh=function(){};
       peer={seat:1,state:'in',name:'ZQ'};
       NET.on=true; NET.role='host'; NET.seat=0; NET.max=4; NET.peers=[peer];
       HB.drops=[{id:'zq-b1',k:'bandage',x:200,y:200,by:1},{id:'zq-a0',k:'bandage',x:240,y:200,by:0}];
       P.floorDrops=[{id:'zq-a0',k:'bandage'}];
       netDrop(peer,'left');
       if(HB.drops.some(function(q){ return q.id==='zq-b1'; })) bad.push('a teammate who left kept his crate on this floor, so it could be taken twice');
       d=HB.drops.filter(function(q){ return q.id==='zq-a0'; })[0];
       if(!d) bad.push('control: this window own crate left the floor with the teammate');
       else {
         sk=P.stash.length;
         hubDropTake(d);
         if(P.stash.length!==sk+1) bad.push('the dropper could not take his own crate back with nobody linked');
       }
       HB.drops=[{id:'zq-c0',k:'bandage',x:200,y:220,by:0},{id:'zq-c1',k:'bandage',x:240,y:220,by:1}]; P.floorDrops=[{id:'zq-c0',k:'bandage'}];
       if(typeof hubDropsTell!=='function') bad.push('a window that links is never told the crates already on the floor');
       else {
         sent.length=0; hubDropsTell({seat:1,state:'in'},false);
         if(sent.filter(function(m){ return m&&m.t==='hdrop'&&m.op==='put'; }).length!==2) bad.push('the host told a linking window '+sent.length+' of 2 crates');
         sent.length=0; NET.role='join'; NET.seat=1; hubDropsTell({seat:0,state:'in'},true);
         if(!(sent.length===1&&sent[0].id==='zq-c0')) bad.push('a teammate told the host '+sent.length+' crates, not just its own one');
       }
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{
       netSend=oSend; netBroadcast=oB; netSay=oSay; say2=oS2; saveProfile=oSave; netClose=oClose; netRefresh=oRef;
       for(k in NET) if(!(k in NK)) delete NET[k];
       for(k in NK) NET[k]=NK[k];
       P.stash=oSt; if(oFD===undefined) delete P.floorDrops; else P.floorDrops=oFD; HB.drops=oDr;
     }
     return bad.length?bad.join('; '):null; }},
  {v:'18.57',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
