$ErrorActionPreference = 'Stop'
trap { Write-Output "FAILED: $_"; exit 1 }
$p = 'C:\claudecode\dark raiders\tools\mkfixture.ps1'
$s = [IO.File]::ReadAllText($p)
$n = 0
function SubRx([string]$old, [string]$new) {
  $pat = ($old -split "`n" | ForEach-Object { [regex]::Escape($_.TrimEnd("`r")) }) -join "\r?\n"
  $c = ([regex]::Matches($script:s, $pat)).Count
  if ($c -ne 1) { throw "regex matched $c times: $($old.Substring(0,[Math]::Min(70,$old.Length)))" }
  $script:s = [regex]::Replace($script:s, $pat, { param($m) $new })
  $script:n++
}

SubRx @'
  {v:'14.40',what:
'@ @'
  {v:'14.41',what:'erasing a save erases its UNDO copy: DELETE, the typed word and ERASE on the title screen remove save 7 and the restore backup kept beside it (title and saves audit finding 1)',
   run:function(){
     if(typeof titleRefresh!=='function'||!document.getElementById('slotlist')) return 'SKIP: no title save list in this document';
     if(typeof SLOT!=='undefined'&&SLOT==='7') return 'SKIP: the fixture is running in save 7';
     var bad=[], K7='salvagerun:profile:7', B7=K7+':prerestore';
     try{
       localStorage.setItem(K7,JSON.stringify({credits:5,pname:'ZQXSEVEN',runs:0,xp:0}));
       localStorage.setItem(B7,'zqx backup of save seven');
       titleRefresh();
       var del=document.querySelector('#slotlist [data-del="7"]');
       if(!del) return 'SKIP: save 7 was not listed with a DELETE button after the refresh';
       del.click();
       var word=document.getElementById('delword'), go=document.getElementById('delgo');
       if(!word||!go||typeof go.onclick!=='function') return 'SKIP: the erase confirmation did not appear';
       word.value='delete'; go.onclick();
       // CONTROL: the save itself is gone, so ERASE ran.
       if(localStorage.getItem(K7)!==null) return 'SKIP: ERASE did not remove save 7, so the erase path did not run here';
       if(localStorage.getItem(B7)!==null) bad.push('ERASE removed save 7 but left its restore backup, which UNDO writes back over the next character made in that save');
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{ try{ localStorage.removeItem(K7); localStorage.removeItem(B7); titleRefresh(); }catch(_c){} }
     return bad.length?bad.join('; '):null; }},
  {v:'14.40',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
