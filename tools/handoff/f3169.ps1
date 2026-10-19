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

if ($s.Contains("  {v:'31.69',what:")) { throw "check 31.69 is in the fixture already" }

SubRx @'
  {v:'31.68',what:
'@ @'
  {v:'31.69',what:'the stash help row, sell note and freebie bar lost their explaining sentences (Q8): no recipes line, no sell note, no go up with issued gear',
   run:function(){
     if(!window.__hubEnter||!window.__station) return 'SKIP: this fixture cannot walk the Undercroft';
     var bad=[], sh, dt, fk, src=[].slice.call(document.scripts).map(function(s){ return s.textContent||''; }).join('\n');
     try{
       __topClear(); __runPrep(); __cleanProfile(); __wnseen(1);
       __hubEnter(); __station('term','KeyE');
       sh=document.getElementById('sellhint'); dt=document.getElementById('stashdetail');
       if(!sh||getComputedStyle(sh).display!=='none') bad.push('the sell note still shows');
       if(!dt||/recipes|clears junk/i.test(dt.textContent)) bad.push('the help row still explains: '+(dt&&dt.textContent));
       fk=document.getElementById('hubfreekit');
       if(typeof renderFreeKit==='function'){ renderFreeKit(); if(!fk||/instead of your own|saved for when/i.test(fk.textContent)) bad.push('the freebie bar still explains: '+(fk&&fk.textContent)); }
     }catch(x){ bad.push('threw: '+(x&&x.message||x)); }
     finally{ try{ var hb=document.getElementById('hub'); if(hb) hb.classList.remove('on'); }catch(_h){} __topClear(); __cleanProfile(); }
     return bad.length?bad.join('; '):null; }},
  {v:'31.68',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
