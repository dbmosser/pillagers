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
  {v:'10.95',what:'every word drawn on the canvas is set in one family
'@ @'
  {v:'10.96',what:'pausing in the Undercroft offers exactly his two choices, and the second one really does go back to the character screen',
   run:function(){
     if(typeof togglePauseBox!=='function') return 'SKIP: this build has no pause box';
     if(!(window.__hubEnter&&window.__P)) return 'SKIP: this fixture cannot reach the Undercroft';
     var bad=[], pb=document.getElementById('pausebox'), ti=document.getElementById('title');
     if(!pb) return 'SKIP: there is no pause box in this document';
     if(!ti) return 'SKIP: there is no character screen in this document';
     var prof=__P(), credits0=prof.credits, runs0=prof.runs, name0=prof.pname;
     var titleWas=ti.classList.contains('on');
     function shownBtns(){
       var out=[], all=pb.querySelectorAll('button');
       for(var i=0;i<all.length;i++){
         var st=window.getComputedStyle(all[i]);
         if(st.display==='none'||st.visibility==='hidden') continue;
         out.push({id:all[i].id,txt:(all[i].textContent||'').trim()});
       }
       return out;
     }
     try{
       __runPrep(); __resetCfg(); __pinDefaults(0);
       // ON THE FLOOR. The raid has to be gone, or the box correctly decides it
       // is pausing a raid and shows the raid controls, and this would be
       // testing the wrong half.
       G=null;
       __hubEnter();
       ti.classList.remove('on');
       togglePauseBox(true);
       if(!pb.classList.contains('on')) return 'SKIP: the pause box would not open on the floor';
       var floor=shownBtns();
       // 1. EXACTLY TWO, AND THEY ARE HIS TWO. His words: "actually RETURN TO
       //    THE UNDERCROFT and RETURN TO CHARACTER SELECTION should be the 2
       //    choices".
       if(floor.length!==2)
         bad.push('the Undercroft pause box offers '+floor.length+' buttons, not two: '+floor.map(function(b){return b.txt;}).join(' / '));
       var joined=floor.map(function(b){ return b.txt.toUpperCase(); }).join(' | ');
       if(joined.indexOf('RETURN TO THE UNDERCROFT')<0)
         bad.push('nothing on the floor pause box says RETURN TO THE UNDERCROFT, it says '+joined);
       if(joined.indexOf('RETURN TO CHARACTER SELECTION')<0)
         bad.push('nothing on the floor pause box says RETURN TO CHARACTER SELECTION, it says '+joined);
       // 2. AND THE SECOND ONE WORKS. A button with the right words on it that
       //    does nothing is the same bug wearing a label.
       var back=null;
       for(var i=0;i<floor.length;i++) if(floor[i].txt.toUpperCase().indexOf('CHARACTER')>=0) back=document.getElementById(floor[i].id);
       if(back){
         if(ti.classList.contains('on')) bad.push('control: the character screen was already up before the button was pressed, so pressing it proves nothing');
         back.click();
         if(!ti.classList.contains('on')) bad.push('RETURN TO CHARACTER SELECTION leaves you exactly where you were');
         if(pb.classList.contains('on')) bad.push('RETURN TO CHARACTER SELECTION leaves the pause box open over the character screen');
         // AND IT DOES NOT COST HIM THE CHARACTER. Going back to the front door
         // is not the same as throwing the save away.
         var pr2=__P();
         if(pr2.credits!==credits0||pr2.runs!==runs0||pr2.pname!==name0)
           bad.push('going back to the character screen changed the save: credits '+credits0+' to '+pr2.credits+', runs '+runs0+' to '+pr2.runs);
       }
       // 3. CONTROL: THE RAID PAUSE IS UNTOUCHED. The same box serves both, so a
       //    change made for the floor is one edit away from taking Abandon run
       //    off a live raid.
       ti.classList.remove('on');
       togglePauseBox(false);
       __resetCfg(); __pinDefaults(0);
       __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       var g=__state(); g.ents.length=0; g.player.hp=g.player.maxhp; g.player.downed=false;
       togglePauseBox(true);
       if(!pb.classList.contains('on')) bad.push('control: the pause box would not open in a raid, so the raid half is untested');
       else {
         var raid=shownBtns(), rj=raid.map(function(b){ return b.txt.toUpperCase(); }).join(' | ');
         if(rj.indexOf('ABANDON')<0) bad.push('control: the raid pause box no longer offers a way to abandon the run: '+rj);
         if(rj.indexOf('RESUME')<0) bad.push('control: the raid pause box no longer offers a way to resume: '+rj);
         if(rj.indexOf('CHARACTER')>=0) bad.push('the raid pause box offers to go back to the character screen mid-raid: '+rj);
       }
       togglePauseBox(false);
     } finally {
       try{ togglePauseBox(false); }catch(_e1){}
       try{ ti.classList.toggle('on',titleWas); }catch(_e2){}
       try{ __resetCfg(); }catch(_e3){}
     }
     return bad.length?bad.join('; '):null; }},
  {v:'10.95',what:'every word drawn on the canvas is set in one family
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
