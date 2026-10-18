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

# Operator menu: one red, even gaps, a solid backdrop (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
z-index:19999;background:var(--ui-scrim)'
'@ @'
z-index:19999;background:color-mix(in srgb,var(--ui-void) 97%,transparent)'
'@

SubRx @'
red=((i===0&&ARCOP.arm)||ex);
'@ @'
red=((i===0&&ARCOP.arm)||(ex&&on));   // v28.xx (cw-party-op3): the critic on screens 62 63 (2 of 5): Exit demo wore the same red as the armed confirm, so nothing read as the one danger; red now shows on the armed confirm and on Exit demo only while it is the focused row
'@

SubRx @'
margin:'+(ex?'var(--sp-4)':'var(--sp-2)')+' 0 0;
'@ @'
margin:var(--sp-2) 0 0;
'@

SubRx @'
margin-top:var(--sp-3);color:'+(ARCOP.arm?'var(--danger)':'var(--ok)')
'@ @'
margin-top:var(--sp-3);color:'+(ARCOP.arm?'var(--tx-2)':'var(--ok)')
'@

SubRx @'
var VER='29.87';
'@ @'
var VER='29.88';
'@

$pat = "(?m)^  now:'v29\.87:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v29.88: The operator menu is calmer: one red thing, even gaps. Check 29.88 fails on v29.87',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
