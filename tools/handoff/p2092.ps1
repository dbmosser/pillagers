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

# THE STASH SEARCH BOX LINES UP (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
      var r3=document.createElement('div'); r3.className='invtabs'; r3.style.cssText='padding:4px 0 0 0;gap:6px;display:flex;align-items:center';
      var sq=document.createElement('input'); sq.id='stashsearch'; sq.type='text'; sq.placeholder='search the stash'; sq.value=STASH_Q;
      sq.style.cssText='flex:1;min-width:0;font-size:13px;padding:4px 8px';
'@ @'
      // v20.92, from the whole-game bug hunt of 2026-10-08 (V-B1), seen on the 4K stash picture: THE SEARCH BOX IS AS TALL AS THE TABS
      // AND FILLS THE ROW. It was a thin box about two thirds the height of the tabs and the SORT button beside it, set lower than
      // both, with an empty stretch of the row after SORT. The box and SORT now sit level with the tabs at their height, and the
      // box takes the room left in the row (on a narrow screen the pair wraps under the tabs and fills that line instead).
      var r3=document.createElement('div'); r3.className='invtabs'; r3.style.cssText='padding:0;gap:8px;display:flex;align-items:stretch;align-self:flex-start;flex:1 1 280px';
      var sq=document.createElement('input'); sq.id='stashsearch'; sq.type='text'; sq.placeholder='search the stash'; sq.value=STASH_Q;
      sq.style.cssText='flex:1;min-width:0;font-size:14px;padding:0 12px;box-sizing:border-box;border-radius:8px';
'@

SubRx @'
var VER='20.91';
'@ @'
var VER='20.92';
'@

$pat = "(?m)^  now:'v20\.91:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v20.92: The stash search box is as tall as the tabs and fills the rest of the row. Check 20.92 fails on v20.91',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
