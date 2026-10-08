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

if ($s.Contains("  {v:'19.26',what:")) { throw "check 19.26 is in the fixture already" }

SubRx @'
  {v:'19.25',what:
'@ @'
  {v:'19.26',what:'a blanked sector line takes no room: with the first sector line blanked the card hides it, and with words in it the card shows them',
   run:function(){
     if(typeof renderSector!=='function'||typeof SECTOR_CHAR==='undefined'||typeof TX!=='function') return 'SKIP: no sector page here';
     var bad=[], P2=P, had=!!P2.txt, t0=had?JSON.parse(JSON.stringify(P2.txt)):null, s=SECTOR_CHAR[0], te=CFG.textEdit, row, d;
     function line(){ renderSector(); row=document.querySelector('.sectorpick[data-map="0"]'); if(!row) return null; var hs=row.querySelectorAll('.hint'); return hs.length?hs[0]:null; }
     try{
       __topClear(); __runPrep(); var _tt=document.getElementById('title'); if(_tt) _tt.classList.remove('on'); __hubEnter(); __station('lift','KeyE');
       CFG.textEdit=0;
       P2.txt=P2.txt||{}; P2.txt[s]=' ';
       d=line(); if(!d) return 'SKIP: no first sector card';
       if(getComputedStyle(d).display!=='none'&&d.getBoundingClientRect().height>2) bad.push('a blanked sector line still takes '+Math.round(d.getBoundingClientRect().height)+' px');
       P2.txt[s]='ZQX SECTOR LINE';
       d=line();
       if(!d||getComputedStyle(d).display==='none') bad.push('control: a sector line with words in it is hidden');
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{ CFG.textEdit=te; if(had) P2.txt=t0; else delete P2.txt; try{ renderSector(); }catch(_r){} __topClear(); }
     return bad.length?bad.join('; '):null; }},
  {v:'19.25',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
