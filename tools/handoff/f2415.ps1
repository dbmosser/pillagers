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

if ($s.Contains("  {v:'24.15',what:")) { throw "check 24.15 is in the fixture already" }

SubRx @'
  {v:'24.14',what:
'@ @'
  {v:'24.15',what:'his #39 (keyboard first): with the pause box up in a raid the first arrow highlights its first button, RIGHT steps to the next and LEFT back, and ENTER presses the highlighted button (RESUME closes the box)',
   run:function(){
     if(!(window.__state&&window.__runPrep&&window.__endRaid&&window.__deploy)) return 'SKIP: this fixture cannot run a raid';
     if(typeof raidKey!=='function'||typeof togglePauseBox!=='function'||typeof padFocusables!=='function') return 'SKIP: no pause box here';
     var bad=[], g, pb=document.getElementById('pausebox'), list, f0, f1, f2, rb=document.getElementById('resumebtn');
     function ev(){ return {preventDefault:function(){}}; }
     function nm(e){ return e?(e.id||e.textContent):'nothing'; }
     try{
       __topClear(); __runPrep(); __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       g=__state(); if(!g||!g.player) return 'SKIP: no live raid';
       keys={};
       togglePauseBox(true);
       if(!pauseOpen||!pb||!pb.classList.contains('on')) return 'SKIP: the pause box did not open';
       padSetFocus(null); PAD.focus=null;
       list=padFocusables(pb).filter(function(el){ return el.tagName==='BUTTON'; });
       if(list.length<2) return 'SKIP: the pause box shows '+list.length+' buttons';
       raidKey('ArrowRight',false,ev());
       f0=PAD.focus;
       if(f0!==list[0]) bad.push('the first arrow in the pause box highlights '+nm(f0)+', not its first button '+nm(list[0]));
       raidKey('ArrowRight',false,ev()); f1=PAD.focus;
       if(f1!==list[1]) bad.push('RIGHT in the pause box went to '+nm(f1)+', not '+nm(list[1]));
       raidKey('ArrowLeft',false,ev()); f2=PAD.focus;
       if(f2!==list[0]) bad.push('LEFT in the pause box went to '+nm(f2)+', not back to '+nm(list[0]));
       if(keys['ArrowRight']||keys['ArrowLeft']) bad.push('an arrow used in the pause box is left held for the raid');
       if(rb&&list.indexOf(rb)>=0){
         padSetFocus(rb);
         raidKey('Enter',false,ev());
         if(pauseOpen) bad.push('ENTER on RESUME did not close the pause box');
       }
       if(__state()!==g||g.over) bad.push('the pause box keys ended the raid');
     }catch(x){ bad.push('threw: '+(x&&x.message||x)); }
     finally{
       keys={};
       try{ if(pauseOpen) togglePauseBox(false); }catch(_t){}
       try{ padSetFocus(null); PAD.focus=null; }catch(_f){}
       try{ if(__state()&&!__state().over) __endRaid('abandon'); }catch(_e){}
       __topClear();
     }
     return bad.length?bad.join('; '):null; }},
  {v:'24.14',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
