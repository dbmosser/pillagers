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

if ($s.Contains("  {v:'16.50',what:")) { throw "check 16.50 is in the fixture already" }

SubRx @'
  {v:'16.49',what:
'@ @'
  {v:'16.50',what:'in a raid Settings greys out PICK FILE, UNDO and the tuning console OPEN, which reload the window or open what a controller cannot shut; in the Undercroft they work',
   run:function(){
     if(typeof renderSettings!=='function'||!window.__deploy||!window.__endRaid||!window.__hubEnter) return 'SKIP: this build cannot render Settings here';
     if(typeof RESTORE_BACKUP_KEY!=='string') return 'SKIP: this build keeps no restore backup';
     var kk=RESTORE_BACKUP_KEY, was=null, bad=[];
     function off(id){ var b=document.getElementById(id); return b?(b.disabled?'off':'on'):'none'; }
     try{
       try{ was=localStorage.getItem(kk); localStorage.setItem(kk,JSON.stringify({credits:1})); }catch(e){ return 'SKIP: no storage'; }
       __runPrep(); __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       renderSettings();
       ['set_restore','set_unrestore','set_tune'].forEach(function(id){ if(off(id)!=='off') bad.push('in a raid '+id+' is '+off(id)); });
       __endRaid('abandon'); __topClear(); __hubEnter();
       renderSettings();
       ['set_restore','set_unrestore','set_tune'].forEach(function(id){ if(off(id)!=='on') bad.push('control: in the Undercroft '+id+' is '+off(id)); });
     } finally { try{ if(was===null) localStorage.removeItem(kk); else localStorage.setItem(kk,was); }catch(e){} try{ renderSettings(); }catch(e){} try{ __topClear(); }catch(e){} }
     return bad.length?bad.join('; '):null; }},
  {v:'16.49',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
