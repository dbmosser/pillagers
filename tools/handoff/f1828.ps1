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

if ($s.Contains("  {v:'18.28',what:")) { throw "check 18.28 is in the fixture already" }

SubRx @'
  {v:'18.27',what:
'@ @'
  {v:'18.28',what:'trading on the Undercroft floor: Drop on the floor takes the item out of the stash and puts a crate at his feet that is told to the party, a crate the other window put down shows here, and E beside it takes the item into the stash and tells the party; the stash menu has the Drop row while linked',
   run:function(){
     if(typeof hubDropMake!=='function'||typeof netHubDropTake!=='function'||typeof updateHubWorld!=='function') return 'there is no dropping on the floor';
     var bad=[], keep={on:NET.on,role:NET.role,peers:NET.peers,roster:NET.roster,seat:NET.seat}, oSend=netSend, sent=[], st0=P.stash.slice(), peer={state:'in',seat:1,dc:{readyState:'open',send:function(){}}}, d, rows, has=false, hub=document.getElementById('hub'), was=hub&&hub.classList.contains('on'), px0, py0, dr0;
     try{
       if(typeof titleSceneReady==='function') titleSceneReady();
       if(!HB||!HB.player) return 'SKIP: no floor built';
       netSend=function(q,m){ sent.push(m); return true; };
       NET.on=true; NET.role='host'; NET.seat=0; NET.peers=[peer]; NET.roster=[{seat:0,name:'HOST'},{seat:1,name:'KID'}];
       dr0=HB.drops; HB.drops=[]; px0=HB.player.x; py0=HB.player.y;
       P.stash=['bandage'];
       rows=itemMenuRows('bandage','stash',1); rows.forEach(function(x){ if(x&&x.label==='Drop on the floor') has=true; });
       if(!has) bad.push('the stash menu has no Drop on the floor row while linked');
       if(!hubDropMake('bandage')) bad.push('the drop refused');
       if(P.stash.indexOf('bandage')>=0) bad.push('the item stayed in the stash');
       if(HB.drops.length!==1) bad.push('no crate on the floor ('+HB.drops.length+')');
       if(!sent.some(function(m){ return m&&m.t==='hdrop'&&m.op==='put'&&m.k==='bandage'; })) bad.push('the party was not told of the crate');
       if(netHubDropTake(peer,{t:'hdrop',op:'put',id:'h9',k:'frag',x:HB.player.x+200,y:HB.player.y})!=='put') bad.push('a crate from the other window was refused');
       d=null; HB.drops.forEach(function(q){ if(q.id==='h9') d=q; });
       if(!d) bad.push('the other window crate is not on this floor');
       else{
         if(hub) hub.classList.remove('on'); try{ var ms=document.querySelectorAll('.modal.on'); for(var mi=0;mi<ms.length;mi++) ms[mi].classList.remove('on'); }catch(_m){}
         HB.player.x=d.x; HB.player.y=d.y; HB.eLock=false; keys={}; keys['KeyE']=true; sent.length=0;
         updateHubWorld(0.016);
         if(P.stash.indexOf('frag')<0) bad.push('E beside the crate did not take the item');
         if(HB.drops.some(function(q){ return q.id==='h9'; })) bad.push('the taken crate stayed on the floor');
         if(!sent.some(function(m){ return m&&m.t==='hdrop'&&m.op==='took'&&m.id==='h9'; })) bad.push('the party was not told the crate was taken');
       }
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{ netSend=oSend; NET.on=keep.on; NET.role=keep.role; NET.peers=keep.peers; NET.roster=keep.roster; NET.seat=keep.seat; keys={}; try{ if(HB){ HB.drops=dr0||[]; HB.nearDrop=null; HB.eLock=true; if(px0!==undefined){ HB.player.x=px0; HB.player.y=py0; } } }catch(_h){} P.stash=st0; try{ saveProfile(); }catch(_s){} try{ refreshInv(); }catch(_r){} if(was&&hub) hub.classList.add('on'); try{ __topClear(); }catch(_t){} }
     return bad.length?bad.join('; '):null; }},
  {v:'18.27',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
