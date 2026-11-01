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

if ($s.Contains("  {v:'37.24',what:")) { throw "check 37.24 is in the fixture already" }

SubRx @'
  {v:'37.23',what:
'@ @'
  {v:'37.24',what:'cw-m1mkt3, the critic on v37.22 (P1): the wanted strip in the stash header was 14px (12.9px at 1080p) with prices in the warn colour; it is 16px now, the label in the warn colour, names in tx-2, prices in tx-1, 24px between items, and it still costs the grid no height',
   run:function(){
     if(!(window.__runPrep&&window.__resetCfg&&window.__pinDefaults&&window.__cleanProfile&&window.__hubEnter&&window.__station)) return 'SKIP: this fixture cannot stage the stash';
     if(typeof mktWanted!=='function'||typeof renderHub!=='function') return 'SKIP: no market here';
     var bad=[], el, gr, h1, h2, nm, pr, lb, i, fs, saved=P;
     function need(ok,msg){ if(!ok) bad.push(msg); }
     try{
       __runPrep(); __topClear(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       __hubEnter(); __station('term','KeyE'); renderHub();
       el=document.getElementById('wanted'); gr=document.getElementById('stashgrid');
       if(!el||!gr) return 'no wanted strip or stash grid here';
       if(!(gr.getBoundingClientRect().height>0)) return 'SKIP: the stash did not open here';
       nm=el.querySelectorAll('[data-want] > span'); pr=el.querySelectorAll('[data-want] > b'); lb=el.firstElementChild;
       need(nm.length===3&&pr.length===3&&lb,'the strip holds '+nm.length+' names and '+pr.length+' prices');
       fs=parseFloat(getComputedStyle(el).fontSize);
       need(fs>=16,'the strip text is '+fs+'px, under 16');
       for(i=0;i<nm.length;i++) need(/170, 164, 152/.test(getComputedStyle(nm[i]).color),'a wanted name is '+getComputedStyle(nm[i]).color+', not tx-2');
       for(i=0;i<pr.length;i++) need(/239, 233, 220/.test(getComputedStyle(pr[i]).color),'a wanted price is '+getComputedStyle(pr[i]).color+', not tx-1');
       need(lb&&/245, 183, 59/.test(getComputedStyle(lb).color)&&lb.textContent==='wanted +50%','the label is '+(lb?lb.textContent+' in '+getComputedStyle(lb).color:'missing'));
       need(parseFloat(getComputedStyle(el).columnGap||getComputedStyle(el).gap)>=24,'the items sit '+getComputedStyle(el).gap+' apart');
       h1=gr.getBoundingClientRect().height; el.style.display='none'; h2=gr.getBoundingClientRect().height; renderHub();
       need(Math.abs(h1-h2)<=2,'showing the wanted strip takes '+Math.round(h2-h1)+'px from the stash grid');
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{
       try{ __topClear(); }catch(_t){}
       P=saved;
       try{ __resetCfg(); __cleanProfile(); }catch(_c){}
     }
     return bad.length?bad.join('; '):null; }},
  {v:'37.23',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
