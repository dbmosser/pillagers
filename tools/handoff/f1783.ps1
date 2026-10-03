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

if ($s.Contains("  {v:'17.83',what:")) { throw "check 17.83 is in the fixture already" }

SubRx @'
  {v:'17.82',what:
'@ @'
  {v:'17.83',what:'the title has the Undercroft behind it: with the title up and no floor built yet, one frame builds the floor and draws it under a translucent title',
   run:function(){
     if(typeof titleSceneReady!=='function'||typeof titleOn!=='function') return 'the title sits on a flat gradient';
     if(typeof loop!=='function'||typeof wc==='undefined'||!wc) return 'SKIP: no loop or world canvas in this fixture';
     var bad=[], t=document.getElementById('title'), was=t&&t.classList.contains('on'), st0=state, HB0=HB, d, k, lit=0, bg;
     try{
       if(!t) return 'SKIP: no title in this fixture';
       t.classList.add('on'); state='hub'; HB=null;
       bg=getComputedStyle(t).backgroundColor;
       if(!/rgba\(/.test(bg)||!(parseFloat(bg.split(',')[3])<1)) bad.push('the title background is not translucent ('+bg+')');
       HID.fromWorker=1; try{ loop(performance.now()); loop(performance.now()+16); }finally{ HID.fromWorker=0; }
       if(!HB) bad.push('the floor was not built under the title');
       else{ d=wc.getImageData(0,0,cv.width,cv.height).data; for(k=3;k<d.length;k+=4*211) if(d[k]>0) lit++; if(lit<100) bad.push('nothing was drawn under the title ('+lit+' lit samples)'); }
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{ if(!was&&t) t.classList.remove('on'); state=st0; if(!HB&&HB0) HB=HB0; try{ __topClear(); }catch(_c){} }
     return bad.length?bad.join('; '):null; }},
  {v:'17.82',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
