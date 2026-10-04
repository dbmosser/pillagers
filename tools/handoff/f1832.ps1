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

if ($s.Contains("  {v:'18.32',what:")) { throw "check 18.32 is in the fixture already" }

SubRx @'
  {v:'18.31',what:
'@ @'
  {v:'18.32',what:'stage E of the styling pass: stash cells, shop cells and the tabs are rounded tiles, and the cells carry a light from the top',
   run:function(){
     var root=document.getElementById('root')||document.body, d=document.createElement('div'), bad=[], c, v, t, s;
     d.innerHTML='<div class="invgrid"><div class="cell c-common">x</div></div><div class="vendgrid"><div class="vcell">y</div></div><div class="invtab">z</div>';
     root.appendChild(d); c=d.querySelector('.cell'); v=d.querySelector('.vcell'); t=d.querySelector('.invtab');
     try{
       s=getComputedStyle(c); if(parseFloat(s.borderTopLeftRadius)<6) bad.push('stash cells are square ('+s.borderTopLeftRadius+')'); if(!/gradient/.test(s.backgroundImage)) bad.push('stash cells are flat');
       s=getComputedStyle(v); if(parseFloat(s.borderTopLeftRadius)<6) bad.push('shop cells are square ('+s.borderTopLeftRadius+')');
       s=getComputedStyle(t); if(parseFloat(s.borderTopLeftRadius)<6) bad.push('the tabs are square ('+s.borderTopLeftRadius+')');
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{ try{ root.removeChild(d); }catch(_r){} }
     return bad.length?bad.join('; '):null; }},
  {v:'18.31',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
