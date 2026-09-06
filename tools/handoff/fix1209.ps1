$ErrorActionPreference = 'Stop'
trap { Write-Output "FAILED: $_"; exit 1 }
# Check 12.09 dispatched ESC on window. The pause box has a CAPTURE listener
# on window and the floor handler is a bubble listener on window; for an
# event whose target IS window both fire, and the capture one ran second and
# closed the box the handler had just opened (two togglePauseBox calls, the
# last false). A real key lands on the body: capture at window first (box off,
# nothing), then the bubble handler opens it. The check now dispatches on
# document.body, the real path. Applied to the draft and to the dry copy.
$enc = New-Object Text.UTF8Encoding $false
function Fix([string]$path, [int]$n) {
  $s = [IO.File]::ReadAllText($path)
  $old = "window.dispatchEvent(new KeyboardEvent('keydown',{code:'Escape',key:'Escape',bubbles:true,cancelable:true}));"
  $new = "document.body.dispatchEvent(new KeyboardEvent('keydown',{code:'Escape',key:'Escape',bubbles:true,cancelable:true}));   // on the body, the real path: capture at window first, then the floor handler"
  if ($s.IndexOf($new) -ge 0) { Write-Output ($path + ': already fixed'); return }
  $c = ([regex]::Matches($s, [regex]::Escape($old))).Count
  if ($c -ne $n) { throw ($path + ': anchor matched ' + $c + ' times, wanted ' + $n) }
  $s = $s.Replace($old, $new)
  [IO.File]::WriteAllText($path, $s, $enc)
  Write-Output ($path + ': fixed')
}
Fix 'C:\claudecode\dark raiders\tools\handoff\f1209.ps1' 2
# The dry copy holds the same two lines inside the inserted check (12.09 is the
# only check in the file that presses Escape on the window).
Fix 'C:\claudecode\dark raiders\tools\handoff\dry\mk.ps1' 2
