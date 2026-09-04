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

# ==== THE CORPUS CAUGHT v10.73 AND IT WAS RIGHT TO. v9.17 pinned 16:9 to the
# ==== 820 pixel column on purpose, as the control proving its ultrawide rule
# ==== was really gated. His note is newer than that check and says the opposite:
# ==== the wide monitor is wasted. So the intent has changed and the check has to
# ==== change with it, rather than the build quietly stepping over a control.
# ==== What the control was FOR is kept: prove the cap follows the width instead
# ==== of widening everything everywhere. The gate is the 820 floor now, so a
# ==== narrow screen is what must still be pinned.
SubRx @'
  {v:'9.17',what:'the title screen uses an ultrawide screen instead of leaving two thirds of it empty',
'@ @'
  {v:'9.17',what:'the title screen uses the width it is given, on an ultrawide and on an ordinary widescreen, and a narrow screen still keeps the 820 column',
'@

SubRx @'
     } else {
       // CONTROL 1: 16:9 must be untouched. 1080p, 1440p and 4K are all exactly
       // 1.778 and must keep the layout he already has.
       if(mw!=='820px') bad.push('control: at aspect '+asp.toFixed(2)+', which is not ultrawide, the column cap is '+mw+' rather than 820px');
       if(col.offsetWidth>860) bad.push('control: at aspect '+asp.toFixed(2)+' the column is '+col.offsetWidth+'px, wider than the 820 base');
     }
'@ @'
     } else if(window.innerWidth>=1600){
       // v10.73, HIS NOTE: this used to require 16:9 to stay at 820, which was
       // the control proving the ultrawide rule was gated. He then reported that
       // the title screen wastes a wide monitor, and measured at 1920x1080 it was
       // painting 56 percent of the screen with 427 pixels empty down each side.
       // An ordinary widescreen gets the width now, so the assertion is inverted.
       if(mw==='820px') bad.push('at aspect '+asp.toFixed(2)+' on a '+window.innerWidth+' pixel screen the column is still capped at 820px, so the wide monitor is wasted');
       if(col.offsetWidth<=860) bad.push('at aspect '+asp.toFixed(2)+' on a '+window.innerWidth+' pixel screen the column is only '+col.offsetWidth+'px wide');
     } else if(window.innerWidth<1320){
       // CONTROL 1, in its new home: the floor is what stops this from being a
       // blanket widening, so a screen too narrow to spare the room keeps the
       // column it has always had.
       if(mw!=='820px') bad.push('control: on a '+window.innerWidth+' pixel screen the column cap is '+mw+' rather than the 820px floor');
     }
'@

SubRx @'
     if(!base)  bad.push('the 820px base width is gone, so 16:9 is no longer pinned');
'@ @'
     if(!base)  bad.push('the 820px floor is gone, so a narrow screen is no longer pinned');
'@

SubRx @'
         if(tx.indexOf('@media')===0){ if(/min-aspect-ratio/.test(tx)) gated=true; }
         else if(/max-width:\s*820px/.test(tx)) base=true;
'@ @'
         if(tx.indexOf('@media')===0){ if(/min-aspect-ratio/.test(tx)) gated=true; }
         // v10.73: the 820 is a FLOOR inside a max() now rather than the whole
         // cap, so this looks for the number wherever it sits in the rule.
         else if(/max-width:[^;]*820px/.test(tx)) base=true;
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
