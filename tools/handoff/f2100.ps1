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

if ($s.Contains("  {v:'21.00',what:")) { throw "check 21.00 is in the fixture already" }

SubRx @'
  {v:'20.99',what:
'@ @'
  {v:'21.00',what:'the two boxes at Wirt are one width: THE GAMBLE and LIMITED TIME OFFER are the same width and start at the same left edge',
   run:function(){
     if(!(window.__hubEnter&&window.__station)||typeof renderWirtLot!=='function') return 'SKIP: no Wirt panel here';
     if(window.__vpAlive&&!__vpAlive()) return 'SKIP: the pane has no layout, so nothing renders';
     var bad=[], t, sg, so, rg, ro, b0=P.wirtLotBought;
     try{
       __topClear(); __runPrep(); __cleanProfile(); if(window.__wnseen) __wnseen(1);
       t=document.getElementById('title'); if(t) t.classList.remove('on');
       __hubEnter(); __station('gamble','KeyE');
       P.wirtLotBought=-1; renderWirtLot();
       sg=document.getElementById('wirtsec_gamble'); so=document.getElementById('wirtsec_offer');
       if(!sg||!so) return 'SKIP: the two boxes are not here';
       rg=sg.getBoundingClientRect(); ro=so.getBoundingClientRect();
       if(!(rg.width>0&&ro.width>0)) return 'SKIP: the Wirt panel has no layout';
       if(Math.abs(rg.width-ro.width)>1) bad.push('THE GAMBLE is '+rg.width.toFixed(1)+' px wide and LIMITED TIME OFFER '+ro.width.toFixed(1)+' px');
       if(Math.abs(rg.left-ro.left)>1) bad.push('the two boxes start '+Math.abs(rg.left-ro.left).toFixed(1)+' px apart');
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{ P.wirtLotBought=b0; try{ [].slice.call(document.querySelectorAll('.modal.on')).forEach(function(x){ x.classList.remove('on'); }); }catch(_m){} __topClear(); __cleanProfile(); }
     return bad.length?bad.join('; '):null; }},
  {v:'20.99',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
