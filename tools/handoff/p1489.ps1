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
  el.addEventListener('keyup',function(ev){ ev.stopPropagation(); });
'@ @'
  // v14.89, words audit finding 4: A KEY HELD WHEN THE EDITOR OPENS IS LET GO. The only keyup the game hears is on window, and
  // this box stops it, so W held in a raid when a word was clicked stayed down after Enter and he kept walking.
  el.addEventListener('keyup',function(ev){ try{ keys[ev.code]=false; }catch(_k){} ev.stopPropagation(); });
'@
SubRx @'
var VER='14.88';
'@ @'
var VER='14.89';
'@

$pat = "(?m)^  now:'v14\.88:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v14.89: A KEY HELD WHEN THE WORDS EDITOR OPENS IS LET GO. The editor box stopped every keyup from reaching the game, so a movement key held while clicking a word stayed down after the edit and he kept walking. The box now releases the key it hears go up. Check 14.89 holds W, opens the editor and lets W go in it; it fails on v14.88',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
