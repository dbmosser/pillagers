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

if ($s.Contains("  {v:'25.18',what:")) { throw "check 25.18 is in the fixture already" }

SubRx @'
  {v:'25.17',what:
'@ @'
  {v:'25.18',what:'his #50 (UI redesign ui5q2h): on the Mainframe the contract the card shows carries the amber rail, and a click on another row moves it there',
   run:function(){
     if(!(window.__station&&window.__hubEnter)) return 'SKIP: this fixture cannot walk the Undercroft';
     var s0=P._conSel, bad=[], rows;
     try{
       __topClear(); __hubEnter(); __station('mf','KeyE');
       rows=document.querySelectorAll('#contracts .crow[data-con]');
       if(rows.length<2) return 'SKIP: fewer than two contracts on the board';
       rows[1].click();
       rows=document.querySelectorAll('#contracts .crow[data-con]');
       if(!rows[1].classList.contains('sel')) bad.push('the clicked row is not marked picked');
       if(rows[0].classList.contains('sel')) bad.push('the first row still looks picked after a click on the second');
       if((getComputedStyle(rows[1]).boxShadow||'').indexOf('inset')<0) bad.push('the picked row has no rail');
       if((rows[0].style.borderColor||'').indexOf('amber')>=0) bad.push('the first row keeps the amber line after a click on the second');
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{ P._conSel=s0; try{ __topClear(); }catch(_c){} }
     return bad.length?bad.join('; '):null; }},
  {v:'25.17',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
