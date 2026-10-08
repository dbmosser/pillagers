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

# A BLANKED SECTOR LINE TAKES NO ROOM (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
       '<div class="hint" style="margin:10px 0 0;font-size:17px;line-height:1.5">'+SECTOR_CHAR[i]+'</div>'+
'@ @'
       // v19.26, seen on the 4K lift screenshot (2026-10-08): he blanked both sector lines (his text edits), which left an empty
       // band between the name and the facts. A blank line takes no room now; with Edit the words on it stays, to be clicked back.
       '<div class="hint" style="'+((CFG.textEdit!==1&&!String(TX(SECTOR_CHAR[i])||'').trim())?'display:none;':'')+'margin:10px 0 0;font-size:17px;line-height:1.5">'+SECTOR_CHAR[i]+'</div>'+
'@

SubRx @'
var VER='19.25';
'@ @'
var VER='19.26';
'@

$pat = "(?m)^  now:'v19\.25:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v19.26: The sector cards on the lift page have no empty gap under the name. Check 19.26 fails on v19.25',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
