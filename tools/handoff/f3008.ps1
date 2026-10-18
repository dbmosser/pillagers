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

if ($s.Contains("  {v:'30.08',what:")) { throw "check 30.08 is in the fixture already" }

SubRx @'
  {v:'30.07',what:
'@ @'
  {v:'30.08',what:'the What is New card shows the generic polish pass line once, not four times (critic on screen 40)',
   run:function(){
     if(typeof WHATSNEW==='undefined'||typeof WNSEEN==='undefined'||typeof drawHubHUD!=='function'||typeof __hubEnter!=='function') return 'SKIP: no What is New card here';
     var bad=[], seq=[], realF=null, ownF=false, wn0=WNSEEN, pr0=null, t, k, n=0, nl=0, rows=0, lst;
     function shut(){ var a=document.querySelectorAll('.modal.on'), j; for(j=0;j<a.length;j++) a[j].classList.remove('on'); }
     try{
       __topClear(); __runPrep(); __cleanProfile();
       t=document.getElementById('title'); if(t) t.classList.remove('on');
       __hubEnter(); shut();
       if(typeof state==='undefined'||state!=='hub'||!HB) return 'SKIP: the Undercroft floor did not open';
       for(k=0;k<WHATSNEW.length;k++) if(/^POLISH PASS \d+\. MORE FIXES TO THE SCREENS/i.test(String(WHATSNEW[k]))) n++;
       if(n<2) return 'SKIP: fewer than two generic polish lines in the list';
       pr0=P.runs; P.runs=1; WNSEEN=0;
       ownF=Object.prototype.hasOwnProperty.call(ctx,'fillText'); realF=ctx.fillText;
       ctx.fillText=function(s){ seq.push(String(s)); return realF.apply(this,arguments); };
       drawHubHUD(0,0);
       for(k=0;k<seq.length;k++){ if(/^\d+\. polish pass \d+\. more/i.test(seq[k])) nl++; if(/^\d+\. /.test(seq[k])) rows++; }
       if(!rows) return 'SKIP: the card was not drawn here';
       if(nl>1) bad.push('the drawn card shows the generic polish line '+nl+' times');
       if(typeof wnOpen==='function'&&document.getElementById('wnlist')){
         wnOpen(); lst=document.getElementById('wnlist').children; nl=0;
         for(k=0;k<lst.length;k++) if(/^\d+\. polish pass \d+\. more/i.test(lst[k].textContent)) nl++;
         if(nl>1) bad.push('the What is New window shows the generic polish line '+nl+' times');
       }
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{
       try{ if(realF){ if(ownF) ctx.fillText=realF; else delete ctx.fillText; } }catch(_f){}
       try{ WNSEEN=wn0; if(pr0!==null) P.runs=pr0; }catch(_w){}
       shut(); __topClear(); __cleanProfile();
     }
     return bad.length?bad.join('; '):null; }},
  {v:'30.07',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
