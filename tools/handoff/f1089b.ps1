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

# ==== A SILENT PROBE INDICTS THE PROBE. Run against a v10.88 fixture, where X
# ==== still swaps, this check reported only the legend line and said nothing
# ==== about the key. Driven by hand in the same page the key clearly DOES swap,
# ==== so the check's own keypress was not landing and its X assertion was
# ==== passing vacuously: exactly the shape of a check that can never fail.
# ==== The instrument now proves itself first. C is still bound and still a
# ==== toggle, so the same dispatch is fired at C and must move something. If it
# ==== does not, the run says the keypress does not work here rather than
# ==== quietly reporting that X is clean.
SubRx @'
     // 1. THE KEY DOES NOTHING. This is his note.
     try{ window.dispatchEvent(new KeyboardEvent('keydown',{code:'KeyX'})); }catch(e){}
     try{ document.dispatchEvent(new KeyboardEvent('keydown',{code:'KeyX',bubbles:true})); }catch(e2){}
     if(p.wep.id!==held||p.sec.id!==stowed)
       bad.push('pressing X still swapped the guns, '+held+' to '+p.wep.id);
'@ @'
     function press(code){
       try{ window.dispatchEvent(new KeyboardEvent('keydown',{code:code})); }catch(_e1){}
       try{ document.dispatchEvent(new KeyboardEvent('keydown',{code:code,bubbles:true})); }catch(_e2){}
     }
     // 0. THE INSTRUMENT FIRST. C is still bound and still a toggle, so the same
     //    dispatch must move something. Without this, a keypress that never
     //    lands makes every line below pass by doing nothing.
     var crouchWas=!!g.crouchTog;
     press('KeyC');
     if(!!g.crouchTog===crouchWas)
       return 'control: a dispatched keypress does nothing in this fixture, so nothing below could be measured';
     press('KeyC');
     // 1. THE KEY DOES NOTHING. This is his note.
     press('KeyX');
     if(p.wep.id!==held||p.sec.id!==stowed)
       bad.push('pressing X still swapped the guns, '+held+' to '+p.wep.id);
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
