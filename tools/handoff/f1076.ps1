$ErrorActionPreference = 'Stop'
trap { Write-Output "FAILED: $_"; exit 1 }
$p = 'C:\claudecode\dark raiders\tools\mkfixture.ps1'
$s = [IO.File]::ReadAllText($p)
$n = 0
function SubRx([string]$old, [string]$new) {
  $pat = ($old -split "`n" | ForEach-Object { [regex]::Escape($_.TrimEnd("`r")) }) -join "\r?\n"
  $c = ([regex]::Matches($script:s, $pat)).Count
  if ($c -ne 1) { throw "regex matched $c times: $($old.Substring(0,[Math]::Min(70,$old.Length)))" }
  $script:s = [regex]::Replace($script:s, $pat, { param($m) $new })
  $script:n++
}

SubRx @'
  {v:'10.75',what:'an extraction point closing is announced by the same letter the map draws on it, not by a number that is nowhere on the map',
'@ @'
  {v:'10.76',what:'his ten stash layouts can be reached again, the button cycles and wraps, and the stash grid really changes when it does',
   run:function(){
     var bad=[];
     if(!window.__P) return 'SKIP: no profile shim';
     if(typeof renderSettings!=='function'||typeof applyStashLayout!=='function') return 'SKIP: no settings or no layouts in this build';
     if(!window.__vpAlive||!__vpAlive()) return 'SKIP: the page is not laid out';
     var P2=__P(), hub=document.getElementById('hub');
     if(!hub) return 'SKIP: this build has no stash screen';
     var keep={lay:P2.stashLayout, stash:(P2.stash||[]).slice(), kit:(P2.kit||[]).slice(),
               hot:P2.hotAssign, safe:P2.safe};
     var wasOn=hub.classList.contains('on');
     var sm=document.getElementById('settingsmodal'), smWasOn=sm&&sm.classList.contains('on');
     try{
       __pinDPR(1); __forceSize(1920,1080);
       // A stash worth arranging, or every layout looks the same.
       var big=[]; ['medkit','bandage','plate','servo','scrap','wire']
         .forEach(function(k){ if(ITEMS[k]) for(var i=0;i<6;i++) big.push(k); });
       if(big.length<12) return 'SKIP: not enough item kinds in this build to fill a stash';
       P2.stash=big.slice(); P2.kit=big.slice(0,8); P2.hotAssign={}; P2.safe=null;
       P2.stashLayout=6;
       try{ saveProfile(); }catch(_s){}
       applyStashLayout();
       renderSettings();
       // 1. THE PICKER EXISTS AND SAYS WHICH ONE IS ON.
       var btn=document.getElementById('set_layout');
       if(!btn) return 'the stash layout cannot be chosen anywhere: there is no picker in Settings';
       var txt=String(btn.textContent||'');
       if(txt.indexOf('6')<0) bad.push('the picker does not say which layout is on (it reads '+JSON.stringify(txt)+' with layout 6 set)');
       if(typeof btn.onclick!=='function') return 'the stash layout picker is not clickable';
       // 2. IT CYCLES AND IT WRAPS, which is what makes all ten reachable.
       var seen={};
       for(var c=0;c<10;c++){ btn=document.getElementById('set_layout'); btn.onclick(); seen[clamp(P2.stashLayout,1,10)]=1; }
       var got=Object.keys(seen).length;
       if(got<10) bad.push('cycling the picker ten times reached only '+got+' of the ten layouts');
       if(clamp(P2.stashLayout,1,10)!==6) bad.push('ten clicks did not come back round to 6 (it is on '+P2.stashLayout+')');
       // 3. THE STASH SCREEN ACTUALLY CHANGES. The attribute is what the CSS
       //    reads, and the grid is what he sees, so both are measured.
       hub.classList.add('on');
       function shape(l){
         P2.stashLayout=l; try{ saveProfile(); }catch(_s2){}
         applyStashLayout();
         try{ renderHub(); }catch(_e){}
         if(typeof applyMenuZoom==='function') applyMenuZoom();
         var sg=document.getElementById('stashgrid');
         var cols=getComputedStyle(sg).gridTemplateColumns;
         var c0=sg.children.length?sg.children[0].getBoundingClientRect():null;
         return {attr:hub.getAttribute('data-slayout'), cols:cols,
                 cell:c0?Math.round(c0.width):null, n:(cols.match(/px/g)||[]).length};
       }
       var wide=shape(6), tight=shape(7);
       if(wide.attr!=='6'||tight.attr!=='7') bad.push('control: the layout attribute does not follow the setting ('+wide.attr+' then '+tight.attr+')');
       if(!(tight.n>wide.n)) bad.push('layout 7 should pack more columns than layout 6 and it draws '+tight.n+' against '+wide.n);
       if(!(wide.cell>tight.cell)) bad.push('the cells do not change size between layouts (6 draws '+wide.cell+', 7 draws '+tight.cell+')');
     } finally {
       P2.stashLayout=keep.lay; P2.stash=keep.stash; P2.kit=keep.kit;
       P2.hotAssign=keep.hot; P2.safe=keep.safe;
       try{ saveProfile(); }catch(_s3){}
       try{ applyStashLayout(); }catch(_e2){}
       if(!wasOn) hub.classList.remove('on');
       if(sm&&!smWasOn) sm.classList.remove('on');
     }
     return bad.length?bad.join('; '):null; }},
  {v:'10.75',what:'an extraction point closing is announced by the same letter the map draws on it, not by a number that is nowhere on the map',
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
