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

if ($s.Contains("  {v:'24.25',what:")) { throw "check 24.25 is in the fixture already" }

SubRx @'
  {v:'24.24',what:
'@ @'
  {v:'24.25',what:'his #50 (UI redesign ui5b, from the 4K title shot): the title fits the screen with its padding (a column that only just fits without its padding is zoomed until the whole title, padding and all, needs no scrolling), and the browser ResizeObserver loop notice is not logged as a crash',
   run:function(){
     if(typeof titleFit!=='function') return 'SKIP: no title fit here';
     var bad=[], ti=document.getElementById('title'), col=ti&&ti.querySelector('.titlecol'), was, f=document.createElement('div'), n0, ev;
     if(!ti||!col) return 'SKIP: no title column here';
     was=ti.classList.contains('on');
     try{
       ti.classList.add('on'); ti.style.zoom=1;
       // a column that just fits the screen without its padding: the old fit left it alone and the padding ran off the bottom
       f.style.cssText='height:'+Math.max(0,Math.floor((window.innerHeight||1080)*0.985/menuScale())-5-col.scrollHeight)+'px'; col.appendChild(f);
       titleFit();
       if(ti.scrollHeight>ti.clientHeight+1) bad.push('a tall title still scrolls: '+ti.scrollHeight+' in '+ti.clientHeight);
       if(!Array.isArray(P.crashes)) P.crashes=[];
       n0=JSON.stringify(P.crashes);
       ev=new ErrorEvent('error',{message:'ResizeObserver loop completed with undelivered notifications.'});
       window.dispatchEvent(ev);
       if(JSON.stringify(P.crashes)!==n0) bad.push('the ResizeObserver loop notice was logged as a crash');
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{ try{ col.removeChild(f); }catch(_r){} if(!was) ti.classList.remove('on'); try{ titleFit(); }catch(_t){} try{ __topClear(); }catch(_c){} }
     return bad.length?bad.join('; '):null; }},
  {v:'24.24',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
