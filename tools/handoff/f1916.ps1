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

if ($s.Contains("  {v:'19.16',what:")) { throw "check 19.16 is in the fixture already" }

SubRx @'
  {v:'19.15',what:
'@ @'
  {v:'19.16',what:'the FASHION operator panel keeps its frame: scrolling the slot list scrolls an inner box, so the panel itself and its heading do not move',
   run:function(){
     var ap=document.getElementById('appearmodal'), av=document.getElementById('appavatar');
     if(!ap||!av||typeof renderAvatar!=='function') return 'SKIP: no FASHION here';
     var bad=[], pn=av.closest('.panel'), gr=ap.querySelector('.hubgrid'), h0=gr?gr.style.height:'', sc=null, e, h2, t0, t1, was=ap.classList.contains('on');
     if(!pn||!gr) return 'SKIP: no operator panel';
     try{
       ap.classList.add('on');
       try{ renderAvatar('appavatar','appavatarpicker'); }catch(_r){}
       if(typeof applyMenuZoom==='function') applyMenuZoom();
       gr.style.height='260px';
       for(e=av.parentNode;e&&e!==ap;e=e.parentNode){ var ov=getComputedStyle(e).overflowY; if((ov==='auto'||ov==='scroll')&&e.scrollHeight>e.clientHeight+2){ sc=e; break; } }
       if(!sc) return 'SKIP: the slot list does not overflow even in a short window';
       h2=pn.querySelector('h2'); if(!h2) return 'SKIP: the panel has no heading';
       sc.scrollTop=0; t0=h2.getBoundingClientRect().top-pn.getBoundingClientRect().top;
       sc.scrollTop=sc.scrollHeight; t1=h2.getBoundingClientRect().top-pn.getBoundingClientRect().top;
       if(sc===pn||pn.scrollTop>0) bad.push('the operator panel itself scrolls, so its frame line slides through the slot rows');
       if(Math.abs(t1-t0)>1) bad.push('scrolling the slot list moved the Your operator heading by '+Math.round(t0-t1)+' px');
       if(sc.scrollTop<=0) bad.push('control: the slot list did not scroll');
       sc.scrollTop=0;
     }catch(x){ bad.push('threw: '+(x&&x.message||x)); }
     finally{ gr.style.height=h0; pn.scrollTop=0; if(!was) ap.classList.remove('on'); if(typeof applyMenuZoom==='function') applyMenuZoom(); }
     return bad.length?bad.join('; '):null; }},
  {v:'19.15',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
