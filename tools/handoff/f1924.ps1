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

if ($s.Contains("  {v:'19.24',what:")) { throw "check 19.24 is in the fixture already" }

SubRx @'
  {v:'19.23',what:
'@ @'
  {v:'19.24',what:'the gambler offer shows its item at a size you can see: the picture on the Limited Time Offer card is at least 64 pixels',
   run:function(){
     if(!window.__station||!window.__hubEnter||typeof renderWirtLot!=='function') return 'SKIP: no offer card here';
     var bad=[], el, im, t, b0=P.wirtLotBought, w;
     try{
       __topClear(); __runPrep(); __cleanProfile();
       t=document.getElementById('title'); if(t) t.classList.remove('on');
       __hubEnter(); __station('gamble','KeyE');
       P.wirtLotBought=-1; renderWirtLot();
       el=document.getElementById('wirtlot'); if(!el) return 'SKIP: no offer card';
       im=el.querySelector('img'); if(!im) return 'SKIP: the counter shows no item';
       w=parseFloat(im.style.width)||im.getBoundingClientRect().width;
       if(w<64) bad.push('the offer item is drawn '+w+' pixels wide');
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{ P.wirtLotBought=b0; __topClear(); __cleanProfile(); }
     return bad.length?bad.join('; '):null; }},
  {v:'19.23',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
