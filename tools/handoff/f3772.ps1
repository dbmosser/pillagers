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

if ($s.Contains("  {v:'37.72',what:")) { throw "check 37.72 is in the fixture already" }

SubRx @'
  {v:'37.71',what:
'@ @'
  {v:'37.72',what:'stash gun menu marks its source until closing, labels the tenth key 0 without changing its slot, and keeps empty-slot decoration out of inventory and pad controls',
   run:function(){
     if(typeof stashBlankSlots!=='function') return 'no stash empty-space treatment';
     var saved=P, os=saveProfile, ost=storeSet, op=planPut, oldQ=STASH_Q, oldW=W, oldH=H, hub=document.getElementById('hub'), bad=[], probe=null;
     try{
       __runPrep(); __topClear(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       saveProfile=function(){}; storeSet=function(){}; P=JSON.parse(JSON.stringify(saved));
       P.stash=['gun_rifle','servo','board','comp']; P.kit=[]; P.weapons=['pistol']; P.equipped='pistol'; P.freeKit=0; P.keep={}; P.junk={}; P.stashTab='all'; P.stashSort='type'; P.menuZoom=1; STASH_Q='';
       __forceSize(1920,1080); applyMenuZoom(); __showScreen('hub'); __hubEnter(); __station('term','KeyE'); renderHub();
       var grid=document.getElementById('stashgrid'), cells=grid.querySelectorAll('.cell'), cell=grid.querySelector('.c-elite'), snap=JSON.stringify(P);
       if(!cell) return 'no rifle cell';
       stashBlankSlots(); var blanks=grid.querySelectorAll('.stash-space');
       if(!blanks.length||blanks.length>120) bad.push('no bounded empty-slot treatment');
       if(grid.querySelectorAll('.cell').length!==cells.length||JSON.stringify(P)!==snap) bad.push('decoration changed inventory');
       var nav=padFocusables(hub);
       [].forEach.call(blanks,function(e){ if(nav.indexOf(e)>=0||e.getAttribute('aria-hidden')!=='true'||e.tabIndex>=0||e.classList.contains('cell')||e.getAttribute('draggable')==='true'||getComputedStyle(e).pointerEvents!=='none') bad.push('decoration is an inventory control'); });
       var c=cell.getBoundingClientRect(); openItemMenu(c.left+c.width/2,c.top+c.height/2,'gun_rifle','stash',1);
       var m=document.querySelector('.imenu'), z=parseFloat(m.style.zoom)||1, keys2=m.querySelectorAll('.imenukeys button'), selected=grid.querySelectorAll('.stash-selected'), sc=getComputedStyle(cell), r=m.getBoundingClientRect();
       // v28.xx (cw-cx-breakgunfinish): Chrome snaps outline widths at the inherited stash zoom; compare with a real 2px reference in the same grid, as check 33.92 does.
       probe=document.createElement('i'); probe.style.cssText='position:fixed;left:-10000px;top:0;width:8px;height:8px;pointer-events:none';
       probe.style.setProperty('outline','2px solid var(--acc)','important'); grid.appendChild(probe);
       var ref=getComputedStyle(probe), lineMin=parseFloat(ref.outlineWidth), accent=String(ref.outlineColor).replace(/\s/g,''); probe.remove(); probe=null;
       if(!(lineMin>0)) bad.push('could not measure the stash-zoom 2px reference');
       if(selected.length!==1||selected[0]!==cell||m.stashSource!==cell) bad.push('wrong menu source: selected '+selected.length+', expected rifle '+(selected[0]===cell)+', menu source '+(m.stashSource===cell));
       if(sc.outlineStyle!=='solid'||!(parseFloat(sc.outlineWidth)>0)||parseFloat(sc.outlineWidth)+.02<lineMin||String(sc.outlineColor).replace(/\s/g,'')!==accent) bad.push('menu source ring: '+sc.outlineStyle+' '+sc.outlineWidth+' '+sc.outlineColor+', 2px reference '+lineMin+' '+accent);
       if(keys2.length!==10||keys2[9].textContent!=='0') bad.push('tenth key does not match the hotbar');
       if(r.width>401*z) bad.push('action menu is wider than its 400px measure');
       if(/backpack/i.test(document.getElementById('kitn').closest('.loslab').textContent)) bad.push('backpack heading repeats below its tab');
       if(parseFloat(getComputedStyle(document.getElementById('gearbtn')).marginLeft)<16) bad.push('section shortcuts run into filters');
       _trLast=''; syncTopRight(); if(!/^cash\s*\$/.test(document.getElementById('topright').textContent)) bad.push('wallet lacks its cash label');
       var picked=-1; planPut=function(slot){ picked=slot; return null; }; if(keys2[9]) keys2[9].click();
       if(picked!==9) bad.push('0 did not invoke slot nine');
       if(grid.querySelector('.stash-selected')||document.querySelector('.imenu')) bad.push('closing retained the source selection');
       STASH_Q='servo'; stashFilterApply(); if(grid.querySelectorAll('.cell').length!==cells.length||!grid.querySelector('.stash-space')) bad.push('search decoration changed the inventory cells');
       return bad.length?bad.join('; '):null;
     }finally{
       if(probe) probe.remove(); closeItemMenu(); stashCardAt(null); planPut=op; P=saved; STASH_Q=oldQ; saveProfile=os; storeSet=ost; _trLast='';
       try{ __forceSize(oldW,oldH); applyMenuZoom(); __endRaid('abandon'); }catch(e){} __topClear();
     }
   }},
  {v:'37.71',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
