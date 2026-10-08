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

if ($s.Contains("  {v:'19.96',what:")) { throw "check 19.96 is in the fixture already" }

SubRx @'
  {v:'19.95',what:
'@ @'
  {v:'19.96',what:'the equipped gun slot badge in the stash is a clear pill: it has padding round its number and sits clear of the tile corner',
   run:function(){
     if(!(window.__hubEnter&&window.__station&&window.__wnseen)) return 'SKIP: this fixture cannot open the stash';
     if(window.__vpAlive&&!__vpAlive()) return 'SKIP: the pane has no layout, so nothing renders';
     var bad=[], e0=P.equipped, bd=null, cs, cell, gapR, gapB;
     function find(){ var a=[].slice.call(document.querySelectorAll('.cell .cnt')); for(var i=0;i<a.length;i++){ if(/0d1435/.test(a[i].getAttribute('style')||'')&&a[i].offsetWidth>0) return a[i]; } return null; }
     try{
       __topClear(); __runPrep(); __cleanProfile(); __wnseen(1);
       __hubEnter(); __station('term','KeyE');
       bd=find();
       if(!bd&&P.weapons&&P.weapons.length){ P.equipped=P.weapons[0]; try{ renderHub(); }catch(_r){} bd=find(); }
       if(!bd) return 'SKIP: no equipped gun badge showing';
       cs=getComputedStyle(bd); cell=bd.parentElement;
       gapR=cell.clientWidth-(bd.offsetLeft+bd.offsetWidth); gapB=cell.clientHeight-(bd.offsetTop+bd.offsetHeight);
       if(!(parseFloat(cs.paddingLeft)>=4)) bad.push('the badge has '+cs.paddingLeft+' of padding');
       if(!(gapR>=5&&gapB>=4)) bad.push('the badge sits '+gapR+' px from the right and '+gapB+' px from the bottom of the tile');
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{ P.equipped=e0; try{ renderHub(); }catch(_r2){} __topClear(); __cleanProfile(); }
     return bad.length?bad.join('; '):null; }},
  {v:'19.95',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
