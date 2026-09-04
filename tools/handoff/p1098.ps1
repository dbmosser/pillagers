$ErrorActionPreference = 'Stop'
trap { Write-Output "FAILED: $_"; exit 1 }
$p = 'C:\claudecode\dark raiders\dark_raiders.html'
$s = [IO.File]::ReadAllText($p)
$n = 0
function SubRx([string]$old, [string]$new) {
  $pat = ($old -split "`n" | ForEach-Object { [regex]::Escape($_.TrimEnd("`r")) }) -join "\r?\n"
  $c = ([regex]::Matches($script:s, $pat)).Count
  if ($c -ne 1) { throw "regex matched $c times: $($old.Substring(0,[Math]::Min(70,$old.Length)))" }
  $script:s = [regex]::Replace($script:s, $pat, { param($m) $new })
  $script:n++
}

# ============ HIS RUN REPORT, AND IT IS MY CRASH. FOUR TIMES.
# ============
# ============ "v10.96 error on hub x4: Uncaught ReferenceError: sub is not
# ============ defined at psv.onclick", from his flight recorder of 2026-09-04.
# ============
# ============ I DID THIS AT v10.96. Renaming your pillager on the character
# ============ screen updated the name line under the title, and did it with a
# ============ third hand-written copy of that sentence, reading a variable named
# ============ sub that lived beside it. v10.96 wrapped that sentence in a
# ============ function so the pause box could reuse it, which moved sub inside
# ============ the function, and the rename button was left pointing at a name
# ============ that no longer exists in its scope. The name still saved, because
# ============ saveProfile runs first, and then the handler threw and the line
# ============ under the title never changed. He pressed it four times.
# ============
# ============ THE FIX IS THE ONE v10.96 SHOULD HAVE MADE: the rename button
# ============ calls the same function everything else calls, so there is one
# ============ copy of that sentence instead of three. A crash caused by having
# ============ two copies is not fixed by restoring the second one.
SubRx @'
      P.pname=v||'PILLAGER'; saveProfile(); renderSlots();
      if(sub&&P.runs>0) sub.textContent=P.pname+'  \u00b7  '+P.runs+' raid'+(P.runs===1?'':'s')+' logged  \u00b7  '+'$'+P.credits.toLocaleString()+' banked';
'@ @'
      P.pname=v||'PILLAGER'; saveProfile(); renderSlots();
      // v10.98, HIS CRASH REPORT: this was a third hand-written copy of the name
      // line, reading a variable v10.96 moved into subSync. One copy now.
      subSync();
'@

SubRx @'
var VER='10.97';
'@ @'
var VER='10.98';
'@
SubRx @'
  now:'v10.97: a contract target is not salvage, your note. Three items were wanted by something and called salvage anyway: the servo repairs a worn gun and the board asks for it, the optic the board asks for, and the data core the board asks for AND the mainframe burns for intel. SELL JUNK AND LOOSE SALVAGE was clearing the exact item a live contract wanted. Nothing keeps a list now: one function asks the recipes, the rack costs, the repair parts, the mainframe and the contract board.',
'@ @'
  now:'v10.98: the crash in your run report, and it was mine. Renaming your pillager threw every time you pressed SAVE, four times in your log, because v10.96 moved the name line into a function and left the rename button reading a variable that had gone with it. The name saved; the line under the title did not change and the handler died. It calls the one function now.',
'@
SubRx @'
  'THIS IS AN ALPHA. Things will break. When something does, the game writes it into your run report and tells you so; that report is how it gets fixed.',
'@ @'
  'THIS IS AN ALPHA. Things will break. When something does, the game writes it into your run report and tells you so; that report is how it gets fixed.',
  'RENAMING YOUR PILLAGER NO LONGER THROWS. It saved the name and then crashed before updating the line under the title, four times in the last run report, because the button carried its own copy of that sentence. It calls the one that everything else uses.',
'@
SubRx @'
var WHATSNEW_VER='10.97';
'@ @'
var WHATSNEW_VER='10.98';
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
