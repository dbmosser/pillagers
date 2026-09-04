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

# ---- ON AN OLDER BUILD THE HOOK THREW instead of answering, because AMBOFF
# ---- does not exist there, and the check reported "AMBOFF is not defined"
# ---- rather than the fault. A throw is still a failure, so the control fired,
# ---- but a control that cannot say what is wrong is half a control.
SubRx @'
window.__ambOff=function(){ return {calls:AMBOFF,live:!!AMB}; };
'@ @'
window.__ambOff=function(){ try{ return {calls:AMBOFF,live:!!AMB}; }catch(e){ return null; } };
'@
SubRx @'
     var hook=window.__ambOff||function(){ return {calls:0,live:false}; };
'@ @'
     var _rawHook=window.__ambOff;
     var hook=function(){ var r=null; try{ r=_rawHook?_rawHook():null; }catch(e){ r=null; }
       return r||{calls:0,live:false,absent:true}; };
     var canCut=!!(_rawHook&&hook().absent!==true);
'@
SubRx @'
     if(!window.__ambOff) bad.push('control: this build has no way to cut the ambient bed at all');
'@ @'
     if(!canCut) bad.push('control: this build has no way to cut the ambient bed at all, so its five voices hold their last level once a raid ends');
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
