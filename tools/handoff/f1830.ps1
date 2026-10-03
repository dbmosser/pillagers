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

if ($s.Contains("  {v:'18.30',what:")) { throw "check 18.30 is in the fixture already" }

SubRx @'
  {v:'18.29',what:
'@ @'
  {v:'18.30',what:'drag to drop: up top a backpack item let go outside the panel (and off the belt) becomes a pile at his feet, and in the stash screen a DROP HERE target shows while linked and takes a dragged item to the floor',
   run:function(){
     if(typeof hubDropMake!=='function'||typeof dropItem!=='function') return 'SKIP: no dropping here';
     if(!(window.__deploy&&window.__state&&window.__endRaid&&window.__frame)) return 'SKIP: this fixture cannot deploy';
     var bad=[], g, n0, bi, keep={on:NET.on,role:NET.role,peers:NET.peers,roster:NET.roster,seat:NET.seat}, oSend=netSend, peer={state:'in',seat:1,dc:{readyState:'open',send:function(){}}}, fd, st0=P.stash.slice(), dr0, M=window.MouseEvent;
     try{
       // 1. UP TOP: a drag let go off the panel drops the item.
       __topClear(); __runPrep(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       __deploy({kit:['bandage'],safe:null,mapIx:0,seed:4242});
       g=__state(); keys={}; if(g.bag.indexOf('bandage')<0) g.bag.push('bandage');
       g.bagOpen=true; __frame(0.016);
       if(!g.bagPanel) bad.push('control: the backpack panel was not drawn');
       bi=g.bag.indexOf('bandage'); n0=g.containers.length;
       g.drag={key:'bandage',bagIx:bi}; mouse.x=12; mouse.y=Math.round(H*0.3); mouse.down=true;
       window.dispatchEvent(new M('mouseup',{button:0,bubbles:true,cancelable:true}));
       if(g.containers.length!==n0+1) bad.push('letting go off the panel made no pile ('+(g.containers.length-n0)+')');
       else if(!g.containers[g.containers.length-1].dropped) bad.push('the box made is not a dropped pile');
       if(g.drag) bad.push('the drag did not end');
       g.bagOpen=false;
       // 2. THE STASH SCREEN: the floor target shows while linked and takes a dragged item.
       netSend=function(){ return true; };
       NET.on=true; NET.role='host'; NET.seat=0; NET.peers=[peer]; NET.roster=[{seat:0,name:'HOST'},{seat:1,name:'KID'}];
       if(typeof titleSceneReady==='function') titleSceneReady();
       dr0=HB?HB.drops:null; if(HB) HB.drops=[];
       P.stash=['bandage']; try{ renderHub(); }catch(_rh){} try{ refreshInv(); }catch(_ri){}
       fd=document.getElementById('floordrop');
       if(!fd) bad.push('the stash screen has no DROP HERE target');
       else{
         if(fd.style.display==='none') bad.push('the DROP HERE target is hidden while linked');
         if(typeof fd.__grabDrop!=='function') bad.push('the DROP HERE target takes no drop');
         else{ fd.__grabDrop('bandage','stash'); if(!HB||!HB.drops||HB.drops.length!==1) bad.push('a drag onto DROP HERE made no crate'); if(P.stash.indexOf('bandage')>=0) bad.push('the dragged item stayed in the stash'); }
       }
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{
       netSend=oSend; NET.on=keep.on; NET.role=keep.role; NET.peers=keep.peers; NET.roster=keep.roster; NET.seat=keep.seat; keys={}; mouse.down=false;
       try{ if(HB){ HB.drops=dr0||[]; HB.nearDrop=null; } }catch(_h){} P.stash=st0; try{ saveProfile(); }catch(_s){} try{ refreshInv(); }catch(_r){}
       try{ var g2=__state(); if(g2){ g2.drag=null; g2.bagOpen=false; if(!g2.over){ g2.player.downed=false; __endRaid('abandon'); } } }catch(_e){}
       __topClear(); __cleanProfile();
     }
     return bad.length?bad.join('; '):null; }},
  {v:'18.29',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
