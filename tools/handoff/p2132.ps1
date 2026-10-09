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

# THE SECTOR FACTS START UNDER THE NAME (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
margin:10px 0 0;font-size:17px;line-height:1.5">'+SECTOR_CHAR[i]+'</div>'+
'@ @'
margin:10px 0 0;padding-left:0;font-size:17px;line-height:1.5">'+SECTOR_CHAR[i]+'</div>'+
'@

SubRx @'
       '<div class="hint" style="margin:8px 0 0;font-size:16px;line-height:1.6;color:var(--ash)">'+facts.join('  &middot;  ')+'</div></div></div>';
'@ @'
       // v21.32, from the whole-game bug hunt of 2026-10-08 (W-B2), seen on the 4K lift picture: THE SECTOR LINES START UNDER THE NAME.
       // Both lines under a sector name are hint lines, and a hint line carries a 12 px inner margin, so on every sector card the
       // facts (and the description line, when it has words) started 12 px right of the name above them, as if indented. They start
       // at the left edge of the name now. The words are untouched.
       '<div class="hint" style="margin:8px 0 0;padding-left:0;font-size:16px;line-height:1.6;color:var(--ash)">'+facts.join('  &middot;  ')+'</div></div></div>';
'@

SubRx @'
var VER='21.31';
'@ @'
var VER='21.32';
'@

$pat = "(?m)^  now:'v21\.31:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v21.32: On the lift page the facts under each sector name line up with the name. Check 21.32 fails on v21.31',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
