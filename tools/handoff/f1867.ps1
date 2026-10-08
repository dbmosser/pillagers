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

if ($s.Contains("  {v:'18.67',what:")) { throw "check 18.67 is in the fixture already" }

SubRx @'
  {v:'18.66',what:
'@ @'
  {v:'18.67',what:'the title rows are solid: the mode rows and the saves rows have a dark fill, so the Undercroft behind the title does not show through them',
   run:function(){
     var b=document.getElementById('modecoop'), bad=[], a, r;
     if(!b) return 'SKIP: no mode menu here';
     function alpha(el){ var c=getComputedStyle(el).backgroundColor, m=/rgba?\(([^)]*)\)/.exec(c); if(!m) return 0; var p=m[1].split(','); return (p.length>3)?parseFloat(p[3]):1; }
     a=alpha(b); if(!(a>=0.7)) bad.push('2 PLAYER CO-OP is see-through (fill '+a+')');
     try{ if(typeof titleRefresh==='function') titleRefresh(); }catch(_t){}
     r=document.querySelector('#slotlist [data-slot]');
     if(r){ a=alpha(r); if(!(a>=0.6)) bad.push('a save row is see-through (fill '+a+')'); }
     return bad.length?bad.join('; '):null; }},
  {v:'18.66',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
