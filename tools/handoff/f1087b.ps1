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

# ==== v8.73 DROVE SPRINT THE OLD WAY and correctly refused to lie about it.
# ==== It tapped SHIFT through the real handler because v10.07 had made sprint a
# ==== toggle, so with v10.87 reading the KEY the tap turned nothing on and the
# ==== check reported "the probe never sprinted at all, so this check is testing
# ==== nothing" rather than passing on an empty run. That is the check working.
# ==== The rule it guards, that a HELD key must not saw sprint on and off when
# ==== stamina runs out, matters more under a hold than it ever did under a
# ==== toggle, so it is driven the new way: hold the key down, and for the
# ==== release arm let go and press again.
SubRx @'
       // v10.07: sprint is a toggle; press SHIFT through the real handler.
       function pressShift(){
         try{ document.dispatchEvent(new KeyboardEvent('keydown',{code:'ShiftLeft',key:'Shift',bubbles:true,cancelable:true})); }catch(_e1){}
         try{ document.dispatchEvent(new KeyboardEvent('keyup',{code:'ShiftLeft',key:'Shift',bubbles:true,cancelable:true})); }catch(_e2){}
       }
       K['KeyD']=true; g.sprintTog=false; pressShift();
'@ @'
       // v10.87: sprint is HELD. The key stays down for the whole run, which is
       // exactly the case the v8.73 rule exists for.
       function holdShift(){ K['ShiftLeft']=true;
         try{ document.dispatchEvent(new KeyboardEvent('keydown',{code:'ShiftLeft',key:'Shift',bubbles:true,cancelable:true})); }catch(_e1){}
       }
       function dropShift(){ delete K['ShiftLeft'];
         try{ document.dispatchEvent(new KeyboardEvent('keyup',{code:'ShiftLeft',key:'Shift',bubbles:true,cancelable:true})); }catch(_e2){}
       }
       K['KeyD']=true; holdShift();
'@
SubRx @'
         if(release&&f===420&&!__state().sprinting) pressShift();
'@ @'
         // The release arm: let go and press again, which is what a player has
         // to do to sprint after running out under a hold.
         if(release&&f===420&&!__state().sprinting){ dropShift(); holdShift(); }
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
