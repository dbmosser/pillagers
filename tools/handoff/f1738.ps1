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

if ($s.Contains("  {v:'17.38',what:")) { throw "check 17.38 is in the fixture already" }

SubRx @'
  {v:'17.37',what:
'@ @'
  {v:'17.38',what:'on the Stash screen CTRL and a click on a stash item packs one of it into the backpack, and the key bar says so; SHIFT still packs the whole stack',
   run:function(){
     if(typeof renderHub!=='function'||!(window.__P&&window.__applyLoaded&&window.__hubEnter)) return 'SKIP: this fixture cannot reach the Stash screen';
     var zone=document.getElementById('stashgrid'), hub=document.getElementById('hub'), kb=document.getElementById('invkeybar');
     if(!zone||!hub) return 'SKIP: no stash grid in this document';
     if(G&&!G.over) return 'SKIP: a raid is running';
     var nm=ITEMS.scrap&&ITEMS.scrap.name, bad=[], _s2=say2, snap=null, hubWas=hub.classList.contains('on');
     if(!nm) return 'SKIP: no Scrap Metal item';
     function cellOf(){ zone=document.getElementById('stashgrid'); var cs=[].slice.call(zone.querySelectorAll('.cell')), i; for(i=0;i<cs.length;i++) if(String(cs[i].title||'').split('\n')[0].indexOf(nm)===0) return cs[i]; return null; }
     function packed(){ return (__P().kit||[]).filter(function(k){ return k==='scrap'; }).length; }
     function click(el,o){ el.dispatchEvent(new MouseEvent('click',{bubbles:true,cancelable:true,button:0,detail:1,ctrlKey:!!o.ctrl,shiftKey:!!o.shift})); }
     try{
       __topClear(); __cleanProfile();
       snap=JSON.parse(JSON.stringify(__P()));
       try{ __hubEnter(); }catch(_h){}
       say2=function(){};
       var q=__P(); q.stash=['scrap','scrap','scrap','scrap']; q.kit=[]; q.hotAssign={}; q.freeKit=0; delete q.stashTab;
       renderHub();
       var c=cellOf();
       if(!c) return 'SKIP: the Stash screen drew no Scrap Metal cell';
       click(c,{ctrl:true});
       if(packed()!==1) bad.push('CTRL and a click on a stash item packed '+packed()+' of it, not one');
       c=cellOf(); if(c){ click(c,{ctrl:true}); if(packed()!==2) bad.push('a second CTRL click did not pack a second one ('+packed()+')'); }
       if(!kb||!/CTRL/.test(kb.textContent||'')) bad.push('the stash key bar does not name CTRL');
       __P().kit=[]; renderHub(); c=cellOf();
       if(c){ click(c,{shift:true}); if(packed()!==4) bad.push('control: SHIFT no longer packs the whole stack ('+packed()+')'); }
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{
       say2=_s2;
       try{ if(snap) __applyLoaded(snap); }catch(_r){}
       try{ if(hubWas){ renderHub(); hub.classList.add('on'); } else hub.classList.remove('on'); }catch(_hb){}
       try{ __topClear(); __cleanProfile(); }catch(_c){}
     }
     return bad.length?bad.join('; '):null; }},
  {v:'17.37',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
