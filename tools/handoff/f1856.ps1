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

if ($s.Contains("  {v:'18.56',what:")) { throw "check 18.56 is in the fixture already" }

SubRx @'
  {v:'18.55',what:
'@ @'
  {v:'18.56',what:'ERASE asks again at the click: a save armed for erasing and then opened by the player 2 window is kept, and a save nobody has open still erases',
   run:function(){
     if(typeof titleRefresh!=='function'||!document.getElementById('slotlist')) return 'SKIP: no title save list in this document';
     if(typeof NETP2!=='undefined'&&NETP2) return 'SKIP: this is a player 2 window';
     if(typeof SLOT!=='undefined'&&SLOT==='7') return 'SKIP: the fixture is running in save 7';
     var bad=[], K7='salvagerun:profile:7', kP=p2PtrKey(), kL='salvagerun:p2live', oP=null, oL=null, oSame=NET.same, del, word, go;
     try{ oP=localStorage.getItem(kP); oL=localStorage.getItem(kL); }catch(_o){}
     function arm(){ titleRefresh(); del=document.querySelector('#slotlist [data-del="7"]'); if(!del) return false; del.click(); word=document.getElementById('delword'); go=document.getElementById('delgo'); return !!(word&&go&&typeof go.onclick==='function'); }
     try{
       NET.same=null; localStorage.removeItem(kL); localStorage.setItem(kP,'2');
       localStorage.setItem(K7,JSON.stringify({credits:5,pname:'ZQXSEVEN',runs:0,xp:0}));
       if(!arm()) return 'SKIP: save 7 could not be armed for erasing';
       localStorage.setItem(kP,'7'); localStorage.setItem(kL,String(Date.now()));
       word.value='delete'; go.onclick();
       if(localStorage.getItem(K7)===null) bad.push('ERASE removed a save the player 2 window had opened after it was armed');
       localStorage.removeItem(kL); localStorage.setItem(kP,'2');
       if(!arm()) bad.push('control: save 7 could not be armed again');
       else { word.value='delete'; go.onclick(); if(localStorage.getItem(K7)!==null) bad.push('control: ERASE did not remove a save nobody has open'); }
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{ NET.same=oSame; try{ localStorage.removeItem(K7); localStorage.removeItem(K7+':prerestore'); if(oP===null) localStorage.removeItem(kP); else localStorage.setItem(kP,oP); if(oL===null) localStorage.removeItem(kL); else localStorage.setItem(kL,oL); titleRefresh(); }catch(_c){} }
     return bad.length?bad.join('; '):null; }},
  {v:'18.55',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
