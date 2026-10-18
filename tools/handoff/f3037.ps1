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

if ($s.Contains("  {v:'30.37',what:")) { throw "check 30.37 is in the fixture already" }

SubRx @'
  {v:'30.36',what:
'@ @'
  {v:'30.37',what:'the pause menu has a problem-report text box (his Q9): text typed in it and the Feedback button save the note with the version and a screenshot through the same save the Feedback window uses, and the pause menu stays up',
   run:function(){
     if(!window.__deploy||!window.__endRaid||typeof togglePauseBox!=='function') return 'SKIP: this fixture cannot run a raid';
     var ta=document.getElementById('pausefb'), fb=document.getElementById('fbbtn'), m=document.getElementById('fbmodal'), pb=document.getElementById('pausebox');
     if(!ta) return 'the pause menu has no problem-report text box (no #pausefb)';
     if(typeof pauseFbSend!=='function') return 'the pause box has no send (no pauseFbSend)';
     var bad=[], kS=fbSave, got=[], g, r, cs;
     try{
       __runPrep(); __topClear(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       __deploy({kit:[],safe:null,mapIx:0,seed:4242}); g=__state();
       if(!g||!g.player) return 'SKIP: no raid';
       fbSave=function(n,p){ got.push({n:n,p:p}); return 'downloaded'; };
       togglePauseBox(true);
       if(!pauseOpen) return 'SKIP: the pause box did not open';
       r=ta.getBoundingClientRect(); cs=getComputedStyle(ta);
       if(!pb.contains(ta)) bad.push('the box is not inside the pause menu');
       if(cs.display==='none'||r.height<56||r.width<300) bad.push('the box is not shown on the pause menu ('+Math.round(r.width)+'x'+Math.round(r.height)+')');
       ta.value='ZQX PAUSE NOTE 4243'; ta.dispatchEvent(new Event('input'));
       if(!/send/i.test(fb.textContent)) bad.push('the Feedback button does not offer to send the typed note ("'+fb.textContent+'")');
       fb.click();
       if(m&&m.classList.contains('on')) bad.push('the Feedback window opened instead of sending the typed note');
       if(got.length!==1) bad.push('the typed note was saved '+got.length+' times');
       else {
         if(String(got[0].n).indexOf('ZQX PAUSE NOTE 4243')<0) bad.push('the saved note is not the typed text');
         if(String(got[0].p).indexOf('data:image/png')!==0) bad.push('the note has no screenshot');
       }
       if(ta.value!=='') bad.push('the box is not cleared after sending');
       if(!pauseOpen) bad.push('sending shut the pause menu');
       if(/send/i.test(fb.textContent)) bad.push('the button still says send after sending');
       return bad.length?bad.join('; '):null;
     } finally {
       fbSave=kS; try{ if(m) m.classList.remove('on'); ta.value=''; pauseFbLabel(); }catch(_t){}
       try{ __endRaid('abandon'); }catch(_e){}
       __topClear();
     } }},
  {v:'30.36',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
