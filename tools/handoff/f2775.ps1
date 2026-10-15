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

if ($s.Contains("  {v:'27.75',what:")) { throw "check 27.75 is in the fixture already" }

SubRx @'
  {v:'27.74',what:
'@ @'
  {v:'27.75',what:'cloud-menus-settings-jump-zoom: under the menu zoom a big screen gets, each Settings section chip puts its section at the top of the list and lights its own chip',
   run:function(){
     if(typeof openSettings!=='function'||typeof setSecJump!=='function'||typeof setSecId!=='function'||typeof SETSEC==='undefined') return 'SKIP: this fixture has no Settings section chips';
     var bad=[], md=document.getElementById('settingsmodal'), host=null, oz, bs, bar, zf, i, b, n, h, off, on, wasOn;
     if(!md) return 'SKIP: no Settings window';
     oz=md.style.zoom; wasOn=md.classList.contains('on');
     try{
       __topClear(); md.classList.remove('on');
       openSettings();
       host=document.getElementById('setlist');
       if(!host||!md.classList.contains('on')) return 'SKIP: Settings did not open';
       if(window.__vpAlive&&!__vpAlive()) return 'SKIP: the pane has no layout';
       md.style.zoom='2';   // the zoom applyMenuZoom gives Settings on a 4K screen
       zf=(host.offsetHeight>0)?(host.getBoundingClientRect().height/host.offsetHeight):0;
       if(!(zf>1.5)) return 'SKIP: this browser does not zoom the window ('+zf+')';
       bs=host.querySelectorAll('.setjump button');
       if(bs.length<3) return 'SKIP: only '+bs.length+' section chips drawn';
       for(i=0;i<bs.length;i++){
         b=bs[i]; n=b.getAttribute('data-sec'); h=document.getElementById(setSecId(n));
         if(!h){ bad.push(n+': no section head'); continue; }
         host.scrollTop=0; b.click();
         bar=host.querySelector('.setjump');
         off=Math.round(h.getBoundingClientRect().top-host.getBoundingClientRect().top-(bar?bar.getBoundingClientRect().height:0));
         on=host.querySelector('.setjump button.on');
         if(Math.abs(off)>2) bad.push(n+': the head sat '+off+' px from the top of the list');
         if(!on||on.getAttribute('data-sec')!==n) bad.push(n+': the chip lit was '+(on?on.getAttribute('data-sec'):'none'));
       }
     }catch(err){ bad.push('threw: '+(err&&err.message||err)); }
     finally{
       try{ md.style.zoom=oz; }catch(_z){}
       try{ if(typeof applyMenuZoom==='function') applyMenuZoom(); }catch(_a){}
       try{ if(host) host.scrollTop=0; }catch(_s){}
       try{ md.classList.remove('on'); if(wasOn) md.classList.add('on'); }catch(_m){}
       try{ __topClear(); }catch(_c){}
     }
     return bad.length?bad.slice(0,8).join('; '):null; }},
  {v:'27.74',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
