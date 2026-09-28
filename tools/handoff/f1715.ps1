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

if ($s.Contains("  {v:'17.15',what:")) { throw "check 17.15 is in the fixture already" }

SubRx @'
  {v:'17.14',what:
'@ @'
  {v:'17.15',what:'a plain left click on a spare armoury gun on the Stash screen leaves it in the armoury: a press and release in place with no movement moves nothing into the stash and says nothing, while a real drag of the same gun onto the stash grid still moves it into the stash (stash hunt finding)',
   run:function(){
     if(typeof rackToStash!=='function'||typeof grabbable!=='function'||typeof renderHub!=='function'||typeof grabEnd!=='function') return 'SKIP: no armoury drag in this build';
     if(!(window.__P&&window.__applyLoaded&&window.__hubEnter)) return 'SKIP: this fixture cannot reach the Stash screen and restore the profile';
     var zone=document.getElementById('stashgrid'), hub=document.getElementById('hub');
     if(!zone||!hub) return 'SKIP: no stash grid in this document';
     if(G&&!G.over) return 'SKIP: a raid is running';
     var D=document, gA=null, gB=null, k;
     for(k in WEAPONS){ if(k==='fists'||!ITEMS['gun_'+k]) continue; if(!gA) gA=k; else if(!gB){ gB=k; break; } }
     if(!gA||!gB) return 'SKIP: fewer than two guns with an item form to stage';
     var nm=WEAPONS[gB].name, bad=[], got=[], _s2=say2, gsk=GRABSKIP, snap=null, hubWas=hub.classList.contains('on');
     var efpOwn=Object.prototype.hasOwnProperty.call(D,'elementFromPoint'), efp=D.elementFromPoint;
     function ev(t,x,y,el){ (el||D).dispatchEvent(new MouseEvent(t,{bubbles:true,cancelable:true,clientX:x,clientY:y,button:0})); }
     // Gun A in gun 1, gun B a spare in the armoury, nothing in the stash, the GUNS tab.
     function stage(){
       var q=__P(); q.weapons=[gA,gB]; q.equipped=gA; q.equippedSec='none'; q.stash=[]; q.kit=[]; q.hotAssign={}; q.freeKit=0; q.stashTab='gun';
       renderHub();
       var cs=[].slice.call(zone.querySelectorAll('.cell'));
       for(var i=0;i<cs.length;i++) if(cs[i].style.cursor==='grab'&&String(cs[i].title||'').split('\n')[0]===nm) return cs[i];
       return null;
     }
     function where(){ var q=__P(); return ((q.weapons||[]).indexOf(gB)>=0?'in the armoury':'not in the armoury')+' and '+((q.stash||[]).indexOf('gun_'+gB)>=0?'in the stash':'not in the stash'); }
     try{
       __topClear(); __cleanProfile();
       snap=JSON.parse(JSON.stringify(__P()));
       try{ __hubEnter(); }catch(_h){}
       var cell=stage();
       if(!cell) return 'SKIP: the Stash screen drew no armoury cell for the '+nm;
       if(typeof zone.__grabDrop!=='function') return 'SKIP: the stash grid is not a drop zone here (no __grabDrop)';   // set when the Undercroft is entered
       // The release point is the armoury cell itself, whatever the pane is laid out as.
       D.elementFromPoint=function(){ return cell; };
       say2=function(t){ got.push(String(t)); };
       // CONTROL: a press on the armoury gun picks it up, so the release below reaches the drop.
       ev('mousedown',200,200,cell);
       if(!(typeof GRAB!=='undefined'&&GRAB&&GRAB.key==='gun_'+gB&&GRAB.from==='rack')) bad.push('control: a press on the armoury '+nm+' picked nothing up');
       // THE FIX: let go where it was pressed, with no movement, it is a click and moves nothing.
       ev('mouseup',200,200);
       if(typeof GRAB!=='undefined'&&GRAB) bad.push('the click left the '+nm+' picked up');
       if((__P().weapons||[]).indexOf(gB)<0||(__P().stash||[]).indexOf('gun_'+gB)>=0) bad.push('a plain click on the armoury '+nm+' moved it: it is now '+where());
       if(got.length) bad.push('a plain click on an armoury gun said: '+got.join(' / '));
       // CONTROL: a real drag of the same gun onto the stash grid still puts it in the stash.
       cell=stage(); got.length=0;
       if(!cell) bad.push('control: the armoury cell was not drawn again for the drag');
       else{
         D.elementFromPoint=function(){ return cell; };
         ev('mousedown',200,200,cell); ev('mousemove',230,200); ev('mouseup',230,200);
         if((__P().weapons||[]).indexOf(gB)>=0||(__P().stash||[]).indexOf('gun_'+gB)<0) bad.push('control: a real drag of the armoury '+nm+' onto the stash grid did not move it: it is '+where());
       }
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{
       try{ if(typeof GRAB!=='undefined'&&GRAB) grabEnd(); }catch(_g){}
       try{ if(efpOwn) D.elementFromPoint=efp; else delete D.elementFromPoint; }catch(_ef){}
       say2=_s2; GRABSKIP=gsk;
       try{ if(snap) __applyLoaded(snap); }catch(_r){}
       try{ if(hubWas){ renderHub(); hub.classList.add('on'); } else hub.classList.remove('on'); }catch(_hb){}
       try{ __topClear(); __cleanProfile(); }catch(_c){}
     }
     return bad.length?bad.join('; '):null; }},
  {v:'17.14',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
