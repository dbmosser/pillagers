$ErrorActionPreference = 'Stop'
trap { Write-Output "FAILED: $_"; exit 1 }
# Diagnostic only, on the DRY fixture builder: count togglePauseBox calls and
# what they were asked, and print them in check 12.09's control message.
$enc = New-Object Text.UTF8Encoding $false
$path = 'C:\claudecode\dark raiders\tools\handoff\dry\mk.ps1'
$s = [IO.File]::ReadAllText($path)
$hookOld = "window.__hub=function(){ return HB; };"
$hookNew = "window.__hub=function(){ return HB; };`nwindow.__tpbCount=0; window.__tpbLast=null; try{ var _tpbReal=togglePauseBox; togglePauseBox=function(on){ window.__tpbCount++; window.__tpbLast=on; try{ return _tpbReal.apply(this,arguments); }catch(_te){ window.__tpbErr=String(_te&&_te.message||_te); throw _te; } }; }catch(_tw){ window.__tpbErr='wrap: '+_tw; }"
if ($s.IndexOf('window.__tpbCount=0') -lt 0) {
  $c = ([regex]::Matches($s, [regex]::Escape($hookOld))).Count
  if ($c -ne 1) { throw ('hook anchor matched ' + $c + ' times') }
  $s = $s.Replace($hookOld, $hookNew)
}
$old = "' keysN='+Object.keys(keys).length+')');"
$new = "' keysN='+Object.keys(keys).length+' tpb='+window.__tpbCount+'/'+window.__tpbLast+' err='+window.__tpbErr+')');"
if ($s.IndexOf($new) -lt 0) {
  $c2 = ([regex]::Matches($s, [regex]::Escape($old))).Count
  if ($c2 -ne 1) { throw ('message anchor matched ' + $c2 + ' times') }
  $s = $s.Replace($old, $new)
}
[IO.File]::WriteAllText($path, $s, $enc)
Write-Output 'instrumented b'
