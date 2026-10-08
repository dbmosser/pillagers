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

if ($s.Contains("  {v:'19.77',what:")) { throw "check 19.77 is in the fixture already" }

SubRx @'
  {v:'19.76',what:
'@ @'
  {v:'19.77',what:'the stash key row is readable: DRAG, RIGHT CLICK and the rest and their words are drawn at 12.5px or more, and the row stays on one line',
   run:function(){
     if(!(window.__hubEnter&&window.__station&&window.__wnseen)) return 'SKIP: this fixture cannot open the stash';
     if(window.__vpAlive&&!__vpAlive()) return 'SKIP: the pane has no layout, so nothing renders';
     var bad=[], kb, items, k, tops={}, i;
     try{
       __topClear(); __runPrep(); __cleanProfile(); __wnseen(1);
       __hubEnter(); __station('term','KeyE');
       kb=document.getElementById('invkeybar'); if(!kb||!kb.getBoundingClientRect().width) return 'SKIP: the stash key row is not showing';
       items=[].slice.call(kb.children); k=kb.querySelector('kbd');
       if(!items.length||!k) return 'SKIP: no keys in the row';
       if(!(parseFloat(getComputedStyle(items[0]).fontSize)>=12.4)) bad.push('the key words are '+getComputedStyle(items[0]).fontSize);
       if(!(parseFloat(getComputedStyle(k).fontSize)>=12.4)) bad.push('the key caps are '+getComputedStyle(k).fontSize);
       for(i=0;i<items.length;i++){ var rr=items[i].getBoundingClientRect(); if(rr.width>0&&rr.height>0) tops[Math.round(rr.top+rr.height/2)]=1; }
       if(Object.keys(tops).length>1) bad.push('the key row wraps onto '+Object.keys(tops).length+' lines');
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{ __topClear(); __cleanProfile(); }
     return bad.length?bad.join('; '):null; }},
  {v:'19.76',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
