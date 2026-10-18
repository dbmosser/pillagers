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

if ($s.Contains("  {v:'30.80',what:")) { throw "check 30.80 is in the fixture already" }

SubRx @'
  {v:'30.79',what:
'@ @'
  {v:'30.80',what:'a name typed on the title goes into the new save that create a new save makes (his order 2026-10-18)',
   run:function(){
     if(typeof newNameKeep!=='function'||typeof newNameTake!=='function') return 'a new save never reads the typed name (no newNameKeep)';
     var b=document.getElementById('newgame'), src=(b&&b.onclick)?String(b.onclick):'', n0=P.pname, r0=P.runs, bad=[], nm=['Zor','blax'].join(''), other=(String(SLOT)==='7')?'6':'7';
     try{
       if(b&&b.onclick&&src.indexOf('newNameKeep')<0) bad.push('create a new save does not keep the typed name');
       P.runs=0;
       P.pname='Oldname'; newNameKeep(nm,SLOT,1); P.pname='PILLAGER';
       if(newNameTake()!==nm||P.pname!==nm) bad.push('a fresh save did not take the typed name ('+P.pname+')');
       P.pname='PILLAGER'; if(newNameTake()) bad.push('the name was taken twice');
       P.pname='Oldname'; newNameKeep('Oldname',SLOT,0); P.pname='PILLAGER'; if(newNameTake()) bad.push('the open save name was carried over when nothing was typed');
       P.pname='Oldname'; newNameKeep(nm,SLOT,1); P.pname='PILLAGER'; P.runs=3; if(newNameTake()) bad.push('a save with raids was renamed');
       P.runs=0; P.pname='Oldname'; newNameKeep(nm,other,1); P.pname='PILLAGER'; if(newNameTake()) bad.push('another slot took the name');
     } finally {
       P.pname=n0; P.runs=r0;
       try{ localStorage.removeItem(NEWNAME_KEY+':'+slotPtrKey()); }catch(_r){}
       try{ saveProfile(); }catch(_s){}
     }
     return bad.length?bad.join('; '):null;
   }},
  {v:'30.79',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
