$ErrorActionPreference = 'Stop'
trap { Write-Output "FAILED: $_"; exit 1 }
$p = 'C:\claudecode\dark raiders\dark_raiders.html'
$s = [IO.File]::ReadAllText($p)
$n = 0
function SubRx([string]$old, [string]$new) {
  $pat = ($old -split "`n" | ForEach-Object { [regex]::Escape($_.TrimEnd("`r")) }) -join "\r?\n"
  $c = ([regex]::Matches($script:s, $pat)).Count
  if ($c -ne 1) { throw "regex matched $c times: $($old.Substring(0,[Math]::Min(70,$old.Length)))" }
  $new = $new.Replace("`r`n", "`n")
  $script:s = [regex]::Replace($script:s, $pat, { param($m) $new })
  $script:n++
}

# ESC CLOSES THE STASH FROM THE SEARCH BOX (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
      sq.onkeydown=function(ev){ if((ev.code==='Escape'||ev.code==='Tab')&&sq.value){ sq.value=''; STASH_Q=''; stashFilterApply(); ev.preventDefault(); ev.stopPropagation(); } };
'@ @'
      // v20.69, from the whole-game bug hunt of 2026-10-08 (H31): AN EMPTY SEARCH BOX HANDS ESC AND TAB BACK. The floor keys skip a
      // key typed into a box, so once the words were cleared (or the box was empty to begin with) ESC did nothing for as long as the
      // cursor stayed in it, and TAB only moved the cursor on. With nothing left to clear, the key now leaves the box and backs out
      // of the front window, the stash, as it does everywhere else on the floor. A held key never closes it.
      sq.onkeydown=function(ev){ if((ev.code==='Escape'||ev.code==='Tab')&&sq.value){ sq.value=''; STASH_Q=''; stashFilterApply(); ev.preventDefault(); ev.stopPropagation(); }
        else if((ev.code==='Escape'||ev.code==='Tab')&&!ev.repeat){ ev.preventDefault(); ev.stopPropagation(); try{ sq.blur(); }catch(_sb){} backOut(); } };
'@

SubRx @'
var VER='20.68';
'@ @'
var VER='20.69';
'@

$pat = "(?m)^  now:'v20\.68:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v20.69: ESC or TAB in the stash search box clears the words first, then closes the stash. Check 20.69 fails on v20.68',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
