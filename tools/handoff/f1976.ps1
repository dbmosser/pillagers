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

if ($s.Contains("  {v:'19.76',what:")) { throw "check 19.76 is in the fixture already" }

SubRx @'
  {v:'19.75',what:
'@ @'
  {v:'19.76',what:'the stash filter row is readable: the category tabs, the search box and SORT are drawn at 13px or more, and the tabs stay on one line',
   run:function(){
     if(!(window.__hubEnter&&window.__station&&window.__wnseen)) return 'SKIP: this fixture cannot open the stash';
     if(window.__vpAlive&&!__vpAlive()) return 'SKIP: the pane has no layout, so nothing renders';
     var bad=[], tb, tabs, sq, sb, i, f, tops={};
     try{
       __topClear(); __runPrep(); __cleanProfile(); __wnseen(1);
       __hubEnter(); __station('term','KeyE');
       tb=document.getElementById('stashtabs'); if(!tb||!tb.getBoundingClientRect().width) return 'SKIP: the stash did not open';
       tabs=(tb.firstElementChild&&tb.firstElementChild.querySelectorAll)?[].slice.call(tb.firstElementChild.querySelectorAll('.invtab')):[]; sq=document.getElementById('stashsearch'); sb=document.getElementById('stashsort');
       if(!tabs.length||!sq||!sb) return 'SKIP: no filter row';
       for(i=0;i<tabs.length;i++){ f=parseFloat(getComputedStyle(tabs[i]).fontSize); if(!(f>=12.9)) { bad.push('the '+tabs[i].textContent.trim()+' tab is '+f+'px'); break; } tops[Math.round(tabs[i].getBoundingClientRect().top)]=1; }
       if(!(parseFloat(getComputedStyle(sq).fontSize)>=12.9)) bad.push('the search box is '+getComputedStyle(sq).fontSize);
       if(!(parseFloat(getComputedStyle(sb).fontSize)>=12.9)) bad.push('SORT is '+getComputedStyle(sb).fontSize);
       if(Object.keys(tops).length>1) bad.push('the category tabs wrap onto '+Object.keys(tops).length+' lines');
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{ __topClear(); __cleanProfile(); }
     return bad.length?bad.join('; '):null; }},
  {v:'19.75',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
