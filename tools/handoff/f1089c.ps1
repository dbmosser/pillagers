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

# ==== AND THE INSTRUMENT CONTROL FOUND THE FAULT ON ITS FIRST RUN, in my own
# ==== check rather than in the game. press() dispatched at BOTH window and
# ==== document, and the game's handler is reached either way, so every call
# ==== fired the key TWICE: a crouch toggled on and straight back off, and a
# ==== weapon swap swapped and swapped back. That is precisely why the X
# ==== assertion reported nothing on a build where X plainly works when driven
# ==== by hand. Measured: window flips crouchTog true, document flips it false
# ==== again. One dispatch, at window, which is where the game listens.
SubRx @'
     function press(code){
       try{ window.dispatchEvent(new KeyboardEvent('keydown',{code:code})); }catch(_e1){}
       try{ document.dispatchEvent(new KeyboardEvent('keydown',{code:code,bubbles:true})); }catch(_e2){}
     }
'@ @'
     // ONE dispatch. Firing at window and at document reaches the same handler
     // twice, which turns every press into a press and an unpress.
     function press(code){
       try{ window.dispatchEvent(new KeyboardEvent('keydown',{code:code})); }catch(_e1){}
     }
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
