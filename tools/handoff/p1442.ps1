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

SubRx @'
      if(t.classList.contains('on')&&(e.code==='Enter'||e.code==='Space')) go();
'@ @'
      // v14.42, title and saves audit finding 2: ENTER STARTS THE GAME AND NOTHING ELSE. The key's own default action went on
      // to click whatever button still had focus, and after a click on GO FULLSCREEN that is GO FULLSCREEN, now hidden: it
      // toggled fullscreen off as he entered the Undercroft.
      if(t.classList.contains('on')&&(e.code==='Enter'||e.code==='Space')){ e.preventDefault(); go(); }
'@
SubRx @'
var VER='14.41';
'@ @'
var VER='14.42';
'@

$pat = "(?m)^  now:'v14\.41:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v14.42: ENTER ON THE TITLE STARTS THE GAME AND NOTHING ELSE. After a click on GO FULLSCREEN that button kept focus, and Enter both entered the Undercroft and clicked it, dropping fullscreen. Enter and Space on the title now start the game and stop the key there. Check 14.42 presses Enter on the title and reads whether the key was stopped; it fails on v14.41',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
