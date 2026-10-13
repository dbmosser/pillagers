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

if ($s.Contains("  {v:'24.50',what:")) { throw "check 24.50 is in the fixture already" }

SubRx @'
  {v:'24.49',what:
'@ @'
  {v:'24.50',what:'his answer 38: the pause box in a raid has FEEDBACK, which takes a screenshot and opens a note window; SAVE hands the typed note (with the version) and the png on and shuts the window, the pause box stays up and the save is not touched',
   run:function(){
     if(!window.__deploy||!window.__endRaid||typeof togglePauseBox!=='function') return 'SKIP: this fixture cannot run a raid';
     var fb=document.getElementById('fbbtn');
     if(!fb) return 'the pause box has no FEEDBACK button: a note can only go into the run report, with no picture';
     if(typeof fbFiles!=='function'||typeof fbSave!=='function') return 'FEEDBACK has no save (no fbSave)';
     var bad=[], g, kF=fbFiles, kP=fbPost, got=[], m=document.getElementById('fbmodal'), ta=document.getElementById('fbnote'), p0, rs=say, ownS=false;
     try{
       __topClear(); __runPrep(); __deploy({kit:[],safe:null,mapIx:0,seed:4242}); g=__state();
       if(!g||!g.player) return 'SKIP: no live raid';
       say=function(){}; ownS=true;
       fbFiles=function(t,p,s){ got.push({t:t,p:p,s:s}); return 'downloaded'; };
       fbPost=function(u,b){ got.push({u:u,t:b,p:''}); return null; };
       togglePauseBox(true);
       if(!pauseOpen) return 'SKIP: the pause box did not open';
       if(getComputedStyle(fb).display==='none') bad.push('FEEDBACK is hidden in the raid pause box');
       p0=JSON.stringify({r:P.runs,f:(P.floorNotes||[]).length,k:(P.kit||[]).length});
       fb.click();
       if(!m||!m.classList.contains('on')) bad.push('FEEDBACK did not open its window');
       if(String(FB.png).indexOf('data:image/png')!==0) bad.push('FEEDBACK took no screenshot ('+String(FB.png).slice(0,24)+')');
       if(ta) ta.value='ZQX NOTE 4242';
       document.getElementById('fbsave').click();
       if(m&&m.classList.contains('on')) bad.push('SAVE left the feedback window open');
       if(!got.length) bad.push('SAVE handed nothing on');
       else {
         if(String(got[0].t).indexOf('ZQX NOTE 4242')<0) bad.push('the saved text does not carry the typed note');
         if(String(got[0].t).indexOf('VERSION')<0) bad.push('the saved text does not name the version');
         if(got[0].u===undefined&&String(got[0].p).indexOf('data:image/png')!==0) bad.push('the screenshot was not saved with the note');
       }
       if(!pauseOpen) bad.push('saving feedback closed the pause box');
       if(JSON.stringify({r:P.runs,f:(P.floorNotes||[]).length,k:(P.kit||[]).length})!==p0) bad.push('saving feedback changed the save');
       fb.click(); document.getElementById('fbcancel').click();
       if(m&&m.classList.contains('on')) bad.push('CANCEL left the feedback window open');
       if(got.length!==1) bad.push('CANCEL saved something');
       if(ta){ fb.click(); ta.dispatchEvent(new KeyboardEvent('keydown',{code:'Escape',key:'Escape',bubbles:true,cancelable:true})); if(m&&m.classList.contains('on')) bad.push('ESC in the note field left the feedback window open'); else if(!pauseOpen) bad.push('ESC in the note field also shut the pause box'); if(got.length!==1) bad.push('ESC in the note field saved something'); }
     }catch(x){ bad.push('threw: '+(x&&x.message||x)); }
     finally{
       fbFiles=kF; fbPost=kP; if(ownS) say=rs;
       try{ if(m) m.classList.remove('on'); if(typeof FB==='object') FB.png=''; }catch(_m){}
       try{ if(pauseOpen) togglePauseBox(false); }catch(_t){}
       try{ var g2=__state(); if(g2&&!g2.over) __endRaid('abandon'); }catch(_e){}
       __topClear();
     }
     return bad.length?bad.join('; '):null; }},
  {v:'24.49',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
