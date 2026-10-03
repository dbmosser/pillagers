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

if ($s.Contains("  {v:'18.09',what:")) { throw "check 18.09 is in the fixture already" }

SubRx @'
  {v:'18.08',what:
'@ @'
  {v:'18.09',what:'item icons are painted sharp: a 31 px stash icon is drawn on a canvas at least 93 px across, and the stash grid no longer asks the browser to pixelate its icons',
   run:function(){
     if(typeof itemIconURL!=='function') return 'SKIP: no icon painter here';
     var bad=[], u=itemIconURL('bandage',31), b64=(String(u).split(',')[1]||''), bin='', w=0, d, img, root=document.getElementById('root')||document.body;
     try{ bin=atob(b64); w=((bin.charCodeAt(16)<<24)|(bin.charCodeAt(17)<<16)|(bin.charCodeAt(18)<<8)|bin.charCodeAt(19))>>>0; }catch(e){ bad.push('could not read the icon image'); }
     if(!(w>=93)) bad.push('the 31 px icon is drawn on a '+w+' px canvas');
     d=document.createElement('div'); d.className='invgrid'; img=document.createElement('img'); img.className='ic'; d.appendChild(img); root.appendChild(d);
     try{ if(getComputedStyle(img).imageRendering==='pixelated') bad.push('the stash grid still pixelates its icons'); }finally{ try{ root.removeChild(d); }catch(_r){} }
     return bad.length?bad.join('; '):null; }},
  {v:'18.08',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
