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

if ($s.Contains("  {v:'22.29',what:")) { throw "check 22.29 is in the fixture already" }

SubRx @'
  {v:'22.28',what:
'@ @'
  {v:'22.29',what:'a teammate kit card says the party goes up without an answer and its way out reads KEEP MY KIT, B on a controller still lands on it, and the host card and the Hire nobody card still decline with Not yet',
   run:function(){
     if(typeof askKit!=='function'||typeof NET_KIT_WAIT!=='number'||typeof padMenu!=='function'||typeof kitExtraHide!=='function'||typeof PAD==='undefined') return 'SKIP: no kit question here';
     var md=document.getElementById('askmodal'), no=document.getElementById('askno'), sub=document.getElementById('asksub'), mc=document.getElementById('mercclear');
     if(!md||!no||!sub||!mc||typeof mc.onclick!=='function') return 'SKIP: no kit card here';
     var bad=[], fired=0, oSave=saveProfile, merc0=P.merc, kit0=P.kit, padK={}, pk, wait=String(NET_KIT_WAIT)+' seconds', t;
     for(pk in PAD) if(Object.prototype.hasOwnProperty.call(PAD,pk)) padK[pk]=PAD[pk];
     padK.prev=(PAD.prev||[]).slice();
     function shut(){ md.classList.remove('on'); ASKYES=null; ASKALT=null; ASKBACK=null; try{ kitExtraHide(); }catch(_k){} }
     try{
       __topClear(); __runPrep();
       saveProfile=function(){};
       // ONE: the card a teammate gets when the host takes the party up
       askKit(function(){ fired++; },true);
       if(!md.classList.contains('on')) return 'SKIP: staging: the kit card did not open';
       t=sub.textContent||'';
       if(t.indexOf(wait)<0) bad.push('the teammate card never says the party goes up within '+wait+' without an answer');
       if((no.textContent||'').trim()!=='KEEP MY KIT') bad.push('the way out of the teammate card reads '+no.textContent+', but the party takes him up anyway');
       // B on a controller lands on that way out, so the card shuts with its own button and RANDOM FROM STASH and TOP GEAR go with it
       PAD.prev=[]; PAD.ax=[0,0,0,0]; PAD.focus=null; PAD.focusMd=null; PAD.yMenuWas=false;
       padMenu(function(n){ return n===1; });
       if(!md.classList.contains('on')){
         if(ASKRAND||ASKTOP) bad.push('B on a controller shut the teammate card without its way out, leaving RANDOM FROM STASH and TOP GEAR armed');
       }
       if(fired) bad.push('B on a controller sent the teammate up');
       shut();
       // TWO: the host card still declines with Not yet and says nothing about a wait
       askKit(function(){ fired++; },false);
       if((no.textContent||'').trim()!=='Not yet') bad.push('the host kit card way out reads '+no.textContent+', not Not yet');
       if((sub.textContent||'').indexOf(wait)>=0) bad.push('the host kit card talks about a wait that is not his');
       shut();
       // THREE: a teammate card the party ascent closed unanswered, then Hire nobody: that card declines with Not yet
       askKit(function(){ fired++; },true);
       md.classList.remove('on');
       P.merc='zqk43hire';
       mc.onclick();
       if(!md.classList.contains('on')) bad.push('the Let them go card did not open');
       else if((no.textContent||'').trim()!=='Not yet') bad.push('the Let them go card way out reads '+no.textContent+', left over from a teammate kit card');
       shut();
       if(fired) bad.push('a kit answer went to the host without a press');
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{
       saveProfile=oSave; P.merc=merc0; P.kit=kit0;
       shut(); no.textContent='Not yet';
       try{ for(pk in PAD) if(Object.prototype.hasOwnProperty.call(PAD,pk)&&!Object.prototype.hasOwnProperty.call(padK,pk)) delete PAD[pk]; for(pk in padK) PAD[pk]=padK[pk]; }catch(_pk){}
       __topClear();
     }
     return bad.length?bad.join('; '):null; }},
  {v:'22.28',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
