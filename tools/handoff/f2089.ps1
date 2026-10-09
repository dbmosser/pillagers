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

if ($s.Contains("  {v:'20.89',what:")) { throw "check 20.89 is in the fixture already" }

SubRx @'
  {v:'20.88',what:
'@ @'
  {v:'20.89',what:'the answer line in a station window sits clear of its panels: in Fashion (and the shop, where its grid reaches the footer) the line box starts below the bottom edge of the panels, stays off CLOSE and stays on the screen',
   run:function(){
     if(typeof __station!=='function'||typeof __hubEnter!=='function'||typeof hubToast!=='function') return 'SKIP: no stations here';
     var bad=[], t, el=document.getElementById('hubtoast'), T, R, C, cases=[['mirror','appearmodal','.hubgrid','closeappear'],['trader','tradermodal','#tpane_buy .vend','closetrader']], i, cs, m, pn, cl, n=0;
     if(!el) return 'SKIP: no answer line here';
     function hit(a,b){ return a.left<b.right&&b.left<a.right&&a.top<b.bottom&&b.top<a.bottom; }
     function shut(){ var a=document.querySelectorAll('.modal.on'), k; for(k=0;k<a.length;k++) a[k].classList.remove('on'); }
     try{
       __topClear(); __runPrep(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       t=document.getElementById('title'); if(t) t.classList.remove('on');
       __hubEnter();
       for(i=0;i<cases.length;i++){
         cs=cases[i]; shut(); __station(cs[0],'KeyE');
         m=document.getElementById(cs[1]);
         if(!m||!m.classList.contains('on')){ bad.push('the '+cs[0]+' station opened no window'); continue; }
         hubToast('Zq the answer line, measured');
         T=el.getBoundingClientRect(); pn=m.querySelector(cs[2]); cl=document.getElementById(cs[3]);
         if(!pn||!cl||!(T.height>4)) continue;
         R=pn.getBoundingClientRect(); C=cl.getBoundingClientRect();
         if(R.bottom<T.top-T.height) continue;   // this panel ends well above the line at this window size: nothing to overlap
         n++;
         if(T.top<R.bottom+T.height*0.1) bad.push('in '+cs[1]+' the line box starts '+Math.round(R.bottom-T.top)+' px above the bottom edge of the panel');
         if(hit(T,C)) bad.push('in '+cs[1]+' the line covers CLOSE');
         if(T.bottom>window.innerHeight+1) bad.push('in '+cs[1]+' the line runs off the bottom of the screen');
       }
       if(!n&&!bad.length) return 'SKIP: no panel reached the footer at this window size';
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{
       try{ el.classList.remove('on'); if(HUBTOAST_T){ clearTimeout(HUBTOAST_T); HUBTOAST_T=null; } }catch(_t){}
       shut(); __topClear(); __cleanProfile();
     }
     return bad.length?bad.join('; '):null; }},
  {v:'20.88',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
