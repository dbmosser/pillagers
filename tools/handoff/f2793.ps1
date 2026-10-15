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

if ($s.Contains("  {v:'27.93',what:")) { throw "check 27.93 is in the fixture already" }

SubRx @'
  {v:'27.92',what:
'@ @'
  {v:'27.93',what:'his answer 37: the What is New card is a WHAT IS NEW button on the pause menu: the pause box has the button, it opens a window of the newest notes that CLOSE and ESC shut, and the card no longer shows by itself on the floor',
   run:function(){
     if(!window.__deploy||!window.__endRaid||!window.__state||typeof togglePauseBox!=='function') return 'SKIP: no pause box here';
     var bad=[], g=null, b, m, L, box, i, src='', needle0, needle1, was=pauseOpen;
     try{
       __topClear(); __runPrep(); __resetCfg(); __pinDefaults(0);
       __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       g=__state(); if(!g||g.over||!g.player) return 'SKIP: staging: no raid';
       b=document.getElementById('wnbtn'); m=document.getElementById('wnmodal'); L=document.getElementById('wnlist'); box=document.getElementById('pausebox');
       if(!b||!m||!L) return 'the pause box has no What is New button or window';
       if(!box||!box.contains(b)) bad.push('the What is New button is not in the pause box');
       togglePauseBox(true);
       if(!box.classList.contains('on')) bad.push('staging: the pause box did not open');
       if(getComputedStyle(b).display==='none') bad.push('the What is New button is hidden in the pause box');
       b.click();
       if(!m.classList.contains('on')) bad.push('the button did not open the What is New window');
       if(L.children.length<5) bad.push('the window lists '+L.children.length+' notes, not 5 or more');
       else {
         if(String(L.children[0].textContent).indexOf('1. ')!==0) bad.push('the list does not start with 1. ('+L.children[0].textContent.slice(0,30)+')');
         if(String(L.children[0].textContent).toUpperCase().indexOf('ALPHA')<0) bad.push('the first note is not the alpha line ('+L.children[0].textContent.slice(0,40)+')');
       }
       if(typeof escCloseTopModal==='function'){ escCloseTopModal(); if(m.classList.contains('on')) bad.push('ESC did not close the What is New window'); }
       b.click();
       document.getElementById('wnclose').click();
       if(m.classList.contains('on')) bad.push('CLOSE did not close the What is New window');
       needle0='var WNSE'+'EN=0;'; needle1='var WNSE'+'EN=1;';
       for(i=0;i<document.scripts.length;i++) src+=document.scripts[i].textContent;
       if(src.indexOf(needle0)>=0) bad.push('the card still starts unseen, so it pops up on the floor by itself');
       if(src.indexOf(needle1)<0) bad.push('the card is not marked seen at load');
     }catch(x){ bad.push('threw: '+(x&&x.message||x)); }
     finally{
       try{ var mm=document.getElementById('wnmodal'); if(mm) mm.classList.remove('on'); }catch(_m){}
       try{ if(pauseOpen&&!was) togglePauseBox(false); }catch(_p){}
       try{ var g2=__state(); if(g2&&!g2.over){ g2.player.iv=0; __endRaid('abandon'); } }catch(_e){}
       __topClear();
     }
     return bad.length?bad.join('; '):null; }},
  {v:'27.92',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
