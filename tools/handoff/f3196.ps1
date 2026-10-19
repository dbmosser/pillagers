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

if ($s.Contains("  {v:'31.96',what:")) { throw "check 31.96 is in the fixture already" }

SubRx @'
  {v:'31.95',what:
'@ @'
  {v:'31.96',what:'the what is new card note lines say more than the bare headline (no line is just "polish pass 31.") and the X sits above the title rule (the critic on 40)',
   run:function(){
     if(!(window.__hubEnter)) return 'SKIP: this fixture cannot open the floor';
     if(typeof drawHubHUD!=='function'||typeof ctx==='undefined'||!ctx) return 'SKIP: no floor HUD in this build';
     var bad=[], seq=[], realF=null, realR=null, ownF=false, ownR=false, wn0=WNSEEN, pr0=null, t, k, ruleY=-1, ww;
     function shut(){ var a=document.querySelectorAll('.modal.on'), j; for(j=0;j<a.length;j++) a[j].classList.remove('on'); }
     try{
       __topClear(); __runPrep(); __cleanProfile();
       t=document.getElementById('title'); if(t) t.classList.remove('on');
       __hubEnter(); shut();
       if(state!=='hub') return 'SKIP: the Undercroft floor did not open';
       pr0=P.runs; P.runs=1; WNSEEN=0; WNX=null;
       ownF=Object.prototype.hasOwnProperty.call(ctx,'fillText'); realF=ctx.fillText;
       ownR=Object.prototype.hasOwnProperty.call(ctx,'fillRect'); realR=ctx.fillRect;
       ctx.fillText=function(s,x,y){ seq.push(String(s)); return realF.apply(this,arguments); };
       ctx.fillRect=function(x,y,w,h){ if(h===1&&w>200&&w<0.6*(W/Math.max(1,(typeof hudRes==='function')?hudRes():1))&&ruleY<0) ruleY=y; return realR.apply(this,arguments); };
       drawHubHUD(0,0);
       for(k=0;k<seq.length;k++) if(/^\d\. polish pass \d+\.$/i.test(seq[k])) bad.push('the line "'+seq[k]+'" is only the bare headline');
       if(!WNX) bad.push('the card has no X box');
       else if(ruleY>0){ var hr=(typeof hudRes==='function')?hudRes():1; if(WNX.y+WNX.h>ruleY*hr+0.5) bad.push('the X bottom '+Math.round(WNX.y+WNX.h)+' runs past the title rule '+Math.round(ruleY*hr)); }
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{
       try{ if(realF){ if(ownF) ctx.fillText=realF; else delete ctx.fillText; } }catch(_f){}
       try{ if(realR){ if(ownR) ctx.fillRect=realR; else delete ctx.fillRect; } }catch(_r){}
       try{ WNSEEN=wn0; WNX=null; if(pr0!==null) P.runs=pr0; }catch(_w){}
       shut(); __topClear(); __cleanProfile();
     }
     return bad.length?bad.join('; '):null; }},
  {v:'31.95',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
