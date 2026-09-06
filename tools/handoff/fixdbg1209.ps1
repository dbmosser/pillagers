$ErrorActionPreference = 'Stop'
trap { Write-Output "FAILED: $_"; exit 1 }
# Diagnostic only, on the DRY fixture builder: check 12.09's control arm
# names the closure state it saw, so the failure on the dry copy can be read.
$enc = New-Object Text.UTF8Encoding $false
$path = 'C:\claudecode\dark raiders\tools\handoff\dry\mk.ps1'
$s = [IO.File]::ReadAllText($path)
$old = "       if(!(pb&&pb.classList.contains('on'))) bad.push('control: ESC with the backpack closed did not raise the pause box');"
$new = "       if(!(pb&&pb.classList.contains('on'))) bad.push('control: ESC with the backpack closed did not raise the pause box (G='+(!!G)+' over='+((G&&G.over)||'-')+' state='+state+' bag='+hubBagOpen+' pauseOpen='+pauseOpen+' titleUp='+document.getElementById('title').classList.contains('on')+' modal='+(document.querySelector('.modal.on')?document.querySelector('.modal.on').id:'-')+' hubOn='+document.getElementById('hub').classList.contains('on')+' active='+(document.activeElement&&document.activeElement.id)+' keysN='+Object.keys(keys).length+')');"
if ($s.IndexOf($new) -ge 0) { Write-Output 'already instrumented'; exit 0 }
$c = ([regex]::Matches($s, [regex]::Escape($old))).Count
if ($c -ne 1) { throw ('anchor matched ' + $c + ' times') }
$s = $s.Replace($old, $new)
[IO.File]::WriteAllText($path, $s, $enc)
Write-Output 'instrumented'
