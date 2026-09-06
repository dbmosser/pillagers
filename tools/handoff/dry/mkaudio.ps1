$ErrorActionPreference = 'Stop'
trap { Write-Output "FAILED: $_"; exit 1 }
$d = 'C:\claudecode\dark raiders\tools\handoff\dry'
$s = [IO.File]::ReadAllText((Join-Path $d 'fixture.html'))
$a = "try{ if(window.AudioContext) window.AudioContext=function(){ throw new Error('fixture is silent'); }; }catch(e){}"
$b = "try{ if(window.webkitAudioContext) window.webkitAudioContext=window.AudioContext; }catch(e){}"
if ($s.IndexOf($a) -lt 0) { throw 'AudioContext block not found' }
$s = $s.Replace($a, '/* audio left ON for the hum instrument */').Replace($b, '')
[IO.File]::WriteAllText((Join-Path $d 'fixaudio.html'), $s, (New-Object Text.UTF8Encoding $false))
Write-Output 'fixaudio.html written'
