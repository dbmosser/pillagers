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

if ($s.Contains("  {v:'31.94',what:")) { throw "check 31.94 is in the fixture already" }

SubRx @'
  {v:'31.93',what:
'@ @'
  {v:'31.94',what:'the what is new card has an X that closes it and shows three short notes, and the haul strip on the extracted card is one row of at most eight tiles (the critic on 40, 76 and 77)',
   run:function(){
     if(!(window.__hubEnter&&window.__deploy&&window.__endRaid&&window.__state)) return 'SKIP: this fixture cannot open the floor or end a raid';
     if(typeof drawHubHUD!=='function'||typeof ctx==='undefined'||!ctx||typeof cv==='undefined') return 'SKIP: no floor HUD in this build';
     var bad=[], seq=[], realF=null, ownF=false, wn0=WNSEEN, pr0=null, t, k, rc, cx, cy, nn=0, oc, st, its, tops={}, g, more;
     function shut(){ var a=document.querySelectorAll('.modal.on'), j; for(j=0;j<a.length;j++) a[j].classList.remove('on'); }
     try{
       __topClear(); __runPrep(); __cleanProfile();
       t=document.getElementById('title'); if(t) t.classList.remove('on');
       __hubEnter(); shut();
       if(state!=='hub') return 'SKIP: the Undercroft floor did not open';
       pr0=P.runs; P.runs=1; WNSEEN=0; WNX=null;
       ownF=Object.prototype.hasOwnProperty.call(ctx,'fillText'); realF=ctx.fillText;
       ctx.fillText=function(s,x,y){ seq.push(String(s)); return realF.apply(this,arguments); };
       drawHubHUD(0,0);
       for(k=0;k<seq.length;k++) if(/^\d\. /.test(seq[k])) nn++;
       if(nn>3) bad.push('the card still draws '+nn+' note lines');
       if(!WNX){ bad.push('the card has no X box'); }
       else {
         rc=cv.getBoundingClientRect(); cx=rc.left+(WNX.x+WNX.w/2)*rc.width/cv.width; cy=rc.top+(WNX.y+WNX.h/2)*rc.height/cv.height;
         cv.dispatchEvent(new MouseEvent('mousedown',{clientX:cx,clientY:cy,button:0,bubbles:true}));
         if(!WNSEEN) bad.push('a click on the card X did not close it');
       }
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{
       try{ if(realF){ if(ownF) ctx.fillText=realF; else delete ctx.fillText; } }catch(_f){}
       try{ WNSEEN=wn0; if(pr0!==null) P.runs=pr0; }catch(_w){}
       shut(); __topClear(); __cleanProfile();
     }
     try{
       __runPrep(); __topClear(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       g=__state(); g.bag.push('core','core','scrap','wire','cell','core','scrap','wire','cell','core');
       __endRaid('extract');
       oc=document.getElementById('outcome'); st=oc&&oc.querySelector('.haulstrip'); its=st?st.querySelectorAll('.haulit'):[];
       if(its.length<2) bad.push('the haul strip has '+its.length+' tiles in the check');
       else {
         if(its.length>8) bad.push('the haul strip shows '+its.length+' tiles, not at most 8');
         for(k=0;k<its.length;k++) tops[Math.round(its[k].getBoundingClientRect().top)]=1;
         if(Object.keys(tops).length!==1) bad.push('the haul tiles sit on '+Object.keys(tops).length+' rows, not one');
       }
     }catch(e2){ bad.push('threw: '+(e2&&e2.message||e2)); }
     finally{ __topClear(); __cleanProfile(); }
     return bad.length?bad.join('; '):null; }},
  {v:'31.93',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
