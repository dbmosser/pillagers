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

if ($s.Contains("  {v:'22.86',what:")) { throw "check 22.86 is in the fixture already" }

SubRx @'
  {v:'22.85',what:
'@ @'
  {v:'22.86',what:'a line said under the solo pause box shows on it: BACKSPACE with the pause box open in a solo raid puts the cursor line on the answer line over the box and adds no row to the raid feed; with the box shut a system line still goes to the feed',
   run:function(){
     if(!(window.__deploy&&window.__state&&window.__endRaid)) return 'SKIP: this fixture cannot deploy';
     if(typeof togglePauseBox!=='function'||typeof syncPause!=='function'||typeof restoreCursor!=='function') return 'SKIP: no pause box in this build';
     var bad=[], g, el=document.getElementById('hubtoast'), f0, NC='Cursor '+'reset', i, inFeed=false, NZ='ZQ '+'PING';
     if(!el) return 'SKIP: no answer line in this page';
     function feedHas(s){ var F=g.feed||[], j; if(g.msgT>0&&String(g.msg).indexOf(s)>=0) return true; for(j=0;j<F.length;j++) if(F[j]&&F[j].T>0&&String(F[j].m).indexOf(s)>=0) return true; return false; }
     try{
       __topClear(); __runPrep(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       g=__state(); if(!g||g.over||!g.player) return 'SKIP: staging: no raid';
       g.msgT=0; g.msg=''; g.feed=[]; g.msgQ=[]; g.msgQM=[]; g.alert=null; g.alertQ=[];
       el.textContent=''; el.classList.remove('on');
       togglePauseBox(true); syncPause();
       if(!g.paused) return 'SKIP: staging: the pause box did not pause the raid';
       if(netPauseLive()) return 'SKIP: staging: this raid is shared, so its pause is the overlay';
       window.dispatchEvent(new KeyboardEvent('keydown',{code:'Backspace',key:'Backspace',bubbles:true}));
       if(String(el.textContent).indexOf(NC)<0||!el.classList.contains('on')) bad.push('BACKSPACE under the solo pause box did not show the cursor line on the answer line (it reads '+JSON.stringify(el.textContent)+', on '+el.classList.contains('on')+')');
       if(feedHas(NC)) bad.push('BACKSPACE under the solo pause box put the cursor line in the raid feed behind the box');
       // CONTROL: the box shut, a system line goes to the feed as before.
       togglePauseBox(false); syncPause(); g.paused=false;
       el.textContent=''; el.classList.remove('on');
       say(NZ,'sys');
       if(!feedHas(NZ)) bad.push('control: with the box shut a system line did not reach the feed');
       if(String(el.textContent).indexOf(NZ)>=0) bad.push('control: with the box shut a system line went to the answer line');
     }catch(err){ bad.push('threw: '+(err&&err.message||err)); }
     finally{
       try{ togglePauseBox(false); syncPause(); }catch(_c){} try{ pauseOpen=false; }catch(_c2){}
       try{ el.textContent=''; el.classList.remove('on'); if(typeof HUBTOAST_T!=='undefined'&&HUBTOAST_T){ clearTimeout(HUBTOAST_T); HUBTOAST_T=null; } }catch(_t){}
       try{ var g2=__state(); if(g2){ g2.paused=false; g2.msgT=0; g2.msg=''; g2.feed=[]; g2.msgQ=[]; g2.msgQM=[]; g2.alert=null; g2.alertQ=[]; g2.pick=[]; } if(g2&&!g2.over){ g2.player.downed=false; g2.player.iv=0; __endRaid('abandon'); } }catch(_e){}
       __topClear();
     }
     return bad.length?bad.join('; '):null; }},
  {v:'22.85',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
