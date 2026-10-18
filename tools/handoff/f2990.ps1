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

if ($s.Contains("  {v:'29.90',what:")) { throw "check 29.90 is in the fixture already" }

SubRx @'
  {v:'29.89',what:
'@ @'
  {v:'29.90',what:'the What is new card sits on a scrim as a 720px flat panel with a left title and one Got it primary (critic: no scrim, 1560px slab, centred amber title, no primary; screen 40)',
   run:function(){
     if(!window.__hubEnter) return 'SKIP: this fixture cannot open the floor';
     if(typeof drawHubHUD!=='function'||typeof ctx==='undefined'||!ctx) return 'SKIP: no floor HUD in this build';
     if(typeof G!=='undefined'&&G&&G.sim) return 'SKIP: a sim is running';
     var bad=[], seq=[], realF=null, realR=null, ownF=false, ownR=false, wn0=(typeof WNSEEN!=='undefined')?WNSEEN:null, pr0=null, t, k, sc=-1, pn=-1, ti=-1, gi=-1, ww, r;
     function shut(){ var a=document.querySelectorAll('.modal.on'), j; for(j=0;j<a.length;j++) a[j].classList.remove('on'); }
     try{
       __topClear(); __runPrep(); __cleanProfile();
       t=document.getElementById('title'); if(t) t.classList.remove('on');
       __hubEnter(); shut();
       if(typeof state==='undefined'||state!=='hub'||!HB) return 'SKIP: the Undercroft floor did not open';
       if(wn0===null) return 'SKIP: no card stamp here';
       pr0=P.runs; P.runs=1; WNSEEN=0;
       ownF=Object.prototype.hasOwnProperty.call(ctx,'fillText'); realF=ctx.fillText;
       ownR=Object.prototype.hasOwnProperty.call(ctx,'fillRect'); realR=ctx.fillRect;
       ctx.fillText=function(s,x,y){ seq.push({k:'t',s:String(s),a:this.textAlign,x:x}); return realF.apply(this,arguments); };
       ctx.fillRect=function(x,y,w,h){ seq.push({k:'r',w:w,h:h,st:String(this.fillStyle)}); return realR.apply(this,arguments); };
       drawHubHUD(0,0);
       ww=W/Math.max(1,(typeof hudRes==='function')?hudRes():1);
       for(k=0;k<seq.length;k++){ r=seq[k];
         if(r.k==='t'&&/new in/i.test(r.s)&&ti<0) ti=k;
         if(r.k==='t'&&/got it/i.test(r.s)&&gi<0) gi=k;
         if(r.k==='r'&&sc<0&&/^rgba\(6, 7, 8,/.test(r.st)&&r.w>=ww-1) sc=k;
         if(r.k==='r'&&pn<0&&(r.st==='#16191b'||r.st==='rgb(22, 25, 27)')&&r.w>200&&r.w<0.6*ww&&r.h>150) pn=k;
       }
       if(ti<0) return 'SKIP: the card was not drawn here';
       if(sc<0||sc>ti) bad.push('no scrim under the card');
       if(pn<0||pn>ti) bad.push('the card is not a flat panel under 60 percent of the screen width');
       if(seq[ti].a!=='left') bad.push('the title is '+seq[ti].a+' aligned, not left');
       if(gi<0) bad.push('no Got it primary on the card');
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{
       try{ if(realF){ if(ownF) ctx.fillText=realF; else delete ctx.fillText; } }catch(_f){}
       try{ if(realR){ if(ownR) ctx.fillRect=realR; else delete ctx.fillRect; } }catch(_r){}
       try{ if(wn0!==null) WNSEEN=wn0; if(pr0!==null) P.runs=pr0; }catch(_w){}
       shut(); __topClear(); __cleanProfile();
     }
     return bad.length?bad.join('; '):null; }},
  {v:'29.89',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
