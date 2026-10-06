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

if ($s.Contains("  {v:'18.46',what:")) { throw "check 18.46 is in the fixture already" }

SubRx @'
  {v:'18.45',what:
'@ @'
  {v:'18.46',what:'floor crates are safe: a crate dropped at the stash lands outside the stash reach and E beside it takes it, the dropper cannot take his own crate while linked, a party ending returns his crate to his stash, and a crate owed at load comes back',
   run:function(){
     if(typeof floorDropsRestore!=='function'||typeof hubDropMake!=='function') return 'floor crates can be lost or doubled';
     var bad=[], keep={on:NET.on,role:NET.role,peers:NET.peers,roster:NET.roster,seat:NET.seat}, oSend=netSend, st0=P.stash.slice(), fd0=P.floorDrops, px0, py0, dr0, st=null, d, k, peer={state:'in',seat:1,dc:{readyState:'open',send:function(){}}}, hub=document.getElementById('hub'), was=hub&&hub.classList.contains('on'), tt=document.getElementById('title'), ttw=tt&&tt.classList.contains('on');
     try{
       if(typeof titleSceneReady==='function') titleSceneReady();
       if(!HB||!HB.player) return 'SKIP: no floor';
       for(k=0;k<HB.stations.length;k++) if(HB.stations[k].id==='stash'||/stash/i.test(String(HB.stations[k].name||''))) st=HB.stations[k];
       if(!st) st=HB.stations[0];
       netSend=function(){ return true; };
       NET.on=true; NET.role='host'; NET.seat=0; NET.peers=[peer]; NET.roster=[{seat:0,name:'HOST'},{seat:1,name:'KID'}];
       dr0=HB.drops; HB.drops=[]; P.floorDrops=[]; px0=HB.player.x; py0=HB.player.y;
       HB.player.x=st.x; HB.player.y=st.y-(st.r||46)+10; HB.player.face=Math.PI/2;
       P.stash=['bandage','frag'];
       hubDropMake('bandage'); d=HB.drops[0];
       if(!d) return 'control: no crate was made';
       if(Math.hypot(d.x-st.x,d.y-st.y)<(st.r||46)+10) bad.push('the crate landed '+Math.round(Math.hypot(d.x-st.x,d.y-st.y))+' from the station centre, inside its reach');
       if(!(P.floorDrops&&P.floorDrops.length===1)) bad.push('the crate was not written down');
       if(hubDropTake(d)) bad.push('the dropper took his own crate back while linked');
       if(hub) hub.classList.remove('on'); if(tt) tt.classList.remove('on'); try{ var ms=document.querySelectorAll('.modal.on'); for(var mi=0;mi<ms.length;mi++) ms[mi].classList.remove('on'); }catch(_m){}
       HB.drops.push({id:'t9',k:'frag',x:d.x+60,y:d.y,by:1}); HB.player.x=d.x+60; HB.player.y=d.y; HB.eLock=false; keys={}; keys['KeyE']=true;
       updateHubWorld(0.016); keys={};
       if(P.stash.filter(function(q){ return q==='frag'; }).length!==2) bad.push('E beside a teammate crate did not take it');
       floorDropsRestore();
       if(P.stash.indexOf('bandage')<0) bad.push('the party ending did not return his own crate');
       if(HB.drops.length) bad.push('crates were left on the floor after the party ended');
       P.floorDrops=[{id:'z1',k:'medkit'}]; floorDropsRestore();
       if(P.stash.indexOf('medkit')<0) bad.push('a crate owed at load did not come back');
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{ netSend=oSend; NET.on=keep.on; NET.role=keep.role; NET.peers=keep.peers; NET.roster=keep.roster; NET.seat=keep.seat; keys={}; try{ if(HB){ HB.drops=dr0||[]; HB.nearDrop=null; HB.eLock=true; if(px0!==undefined){ HB.player.x=px0; HB.player.y=py0; } } }catch(_h){} P.stash=st0; P.floorDrops=fd0; try{ saveProfile(); }catch(_s){} try{ refreshInv(); }catch(_r){} if(was&&hub) hub.classList.add('on'); if(ttw&&tt) tt.classList.add('on'); try{ __topClear(); }catch(_t){} }
     return bad.length?bad.join('; '):null; }},
  {v:'18.45',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
