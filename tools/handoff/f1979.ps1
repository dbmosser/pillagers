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

if ($s.Contains("  {v:'19.79',what:")) { throw "check 19.79 is in the fixture already" }

SubRx @'
  {v:'19.78',what:
'@ @'
  {v:'19.79',what:'the stash belt key numbers are readable: the number in an empty belt slot is drawn at 14px or more',
   run:function(){
     if(!(window.__hubEnter&&window.__station&&window.__wnseen)) return 'SKIP: this fixture cannot open the stash';
     if(window.__vpAlive&&!__vpAlive()) return 'SKIP: the pane has no layout, so nothing renders';
     var bad=[], cells, i, sp=null, f;
     try{
       __topClear(); __runPrep(); __cleanProfile(); __wnseen(1);
       __hubEnter(); __station('term','KeyE');
       cells=[].slice.call(document.querySelectorAll('[data-plan]'));
       for(i=0;i<cells.length&&!sp;i++){ if(cells[i].getBoundingClientRect().width>0&&!cells[i].querySelector('img,canvas')&&cells[i].querySelector('span')) sp=cells[i].querySelector('span'); }
       if(!sp) return 'SKIP: no empty belt slot showing';
       f=parseFloat(getComputedStyle(sp).fontSize);
       if(!(f>=13.9)) bad.push('the number in an empty belt slot is '+f+'px');
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{ __topClear(); __cleanProfile(); }
     return bad.length?bad.join('; '):null; }},
  {v:'19.78',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
