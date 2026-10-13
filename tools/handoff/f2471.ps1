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

if ($s.Contains("  {v:'24.71',what:")) { throw "check 24.71 is in the fixture already" }

SubRx @'
  {v:'24.70',what:
'@ @'
  {v:'24.71',what:'his #50 (UI redesign ui5q1r, found by the visual lint of the arcade attract HOW TO PLAY page): a key cell of the HOW TO PLAY table is not black (the table inherits the colour of the page, which quirks mode does not do on its own) and is at least 13px',
   run:function(){
     if(typeof arcadeAttEl!=='function'||typeof arcadeAttHow!=='function') return 'SKIP: no attract HOW TO PLAY page here';
     var bad=[], pg=document.createElement('div'), d, td, c, f;
     try{
       arcadeAttEl('arcpage');
       d=(typeof attEl==='function')?attEl():null;
       if(!d) return 'SKIP: no attract element';
       pg.className='arcpage'; d.appendChild(pg);
       arcadeAttHow(pg);
       td=pg.querySelector('td:not(.apk)');
       if(!td) return 'SKIP: the table drew no key cell';
       c=getComputedStyle(td).color; f=parseFloat(getComputedStyle(td).fontSize);
       if(c==='rgb(0, 0, 0)') bad.push('the key cells are black on the black page');
       if(!(f>=13)) bad.push('a key cell is '+f+'px');
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{ try{ if(pg.parentNode) pg.parentNode.removeChild(pg); }catch(_r){} }
     return bad.length?bad.join('; '):null; }},
  {v:'24.70',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
