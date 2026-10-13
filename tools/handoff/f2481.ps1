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

if ($s.Contains("  {v:'24.81',what:")) { throw "check 24.81 is in the fixture already" }

SubRx @'
  {v:'24.80',what:
'@ @'
  {v:'24.81',what:'his #50 (UI redesign ui5q1p, from the AAA judge of the Mainframe shot): in the Mainframe the contract detail card is no taller than what it holds (it does not stretch to the height of a long contract list)',
   run:function(){
     if(!(window.__station&&window.__hubEnter)) return 'SKIP: this fixture cannot walk the Undercroft';
     var bad=[], m, d, sib, dr, sr, z;
     try{
       __topClear(); __hubEnter(); __station('mf','KeyE');
       m=document.getElementById('opmodal');
       d=m&&[].filter.call(m.querySelectorAll('.vend > .vdet'),function(e){ return e.getClientRects().length>0; })[0];
       if(!d) return 'SKIP: no contract card shown';
       sib=[].filter.call(d.parentNode.children,function(e){ return e!==d&&e.getClientRects().length>0; })[0];
       if(!sib) return 'SKIP: no list beside the card';
       dr=d.getBoundingClientRect(); sr=sib.getBoundingClientRect();
       z=(((typeof menuScale==='function')&&menuScale())||1);
       if(sr.height<500*z) return 'SKIP: the contract list is too short to show a stretch';
       if(dr.height>sr.height-100*z) bad.push('the contract card stretches to '+Math.round(dr.height/z)+'px beside a '+Math.round(sr.height/z)+'px list');
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{ try{ __topClear(); }catch(_c){} }
     return bad.length?bad.join('; '):null; }},
  {v:'24.80',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
