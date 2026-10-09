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

# THE SELL NOTE LINES UP (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
        <div id="sellhint" class="hint" style="margin-top:6px;font-size:13px;line-height:1.35"></div>
        <div id="nextunlock" class="hint" style="margin-top:4px;font-size:13px;line-height:1.35"></div>
'@ @'
        <!-- v20.94, from the whole-game bug hunt of 2026-10-08 (V-B3), seen on the 4K stash picture: THE SELL NOTE LINES UP WITH THE SELL
             BUTTON. The note under the button is a hint line, and hint lines carry their own side padding, so its words began a step to
             the right of the button edge and of the help line above. It keeps its size and words and loses the side padding. -->
        <div id="sellhint" class="hint" style="margin-top:6px;font-size:13px;line-height:1.35;padding-left:0;padding-right:0"></div>
        <div id="nextunlock" class="hint" style="margin-top:4px;font-size:13px;line-height:1.35;padding-left:0;padding-right:0"></div>
'@

SubRx @'
var VER='20.93';
'@ @'
var VER='20.94';
'@

$pat = "(?m)^  now:'v20\.93:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v20.94: On the stash screen the line under the sell button starts on the button edge. Check 20.94 fails on v20.93',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
