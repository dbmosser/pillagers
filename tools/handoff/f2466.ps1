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

if ($s.Contains("  {v:'24.66',what:")) { throw "check 24.66 is in the fixture already" }

SubRx @'
  {v:'24.65',what:
'@ @'
  {v:'24.66',what:'his #50 (UI redesign ui5q1j, from the AAA judge of the Fashion shot): the Fashion racks are a grid of tiles at least 128px wide, and a locked tile carries a lock glyph',
   run:function(){
     if(!(window.__station&&window.__hubEnter)) return 'SKIP: this fixture cannot walk the Undercroft';
     var bad=[], t, lk, w, z, row;
     try{
       __topClear(); __hubEnter(); __station('mirror','KeyE');
       t=document.querySelector('#appavatarpicker .costile');
       if(!t||!t.getClientRects().length) return 'SKIP: Fashion drew no rack here';
       z=(((typeof menuScale==='function')&&menuScale())||1);
       w=t.getBoundingClientRect().width/z;
       if(w<128) bad.push('a rack tile is '+Math.round(w)+'px wide');
       row=t.parentNode;
       if(getComputedStyle(row).display!=='grid') bad.push('a rack is a '+getComputedStyle(row).display+' row, not a grid that fills the panel');
       lk=document.querySelector('#appavatarpicker .costile.lock');
       if(lk&&getComputedStyle(lk,'::before').backgroundImage.indexOf('svg')<0) bad.push('a locked tile has no lock glyph');
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{ try{ __topClear(); }catch(_c){} }
     return bad.length?bad.join('; '):null; }},
  {v:'24.65',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
