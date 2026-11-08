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

# EXTRACT CARD: ROOM UNDER THE PIP LINES (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
  for(i=0;i<up.length&&i<4;i++) lines.push('<span style="color:'+WORN_RARS[up[i].r].c+'">'+escHtml(wornName(up[i]))+' pip '+up[i].pip+'</span>');
  if(up.length>4) lines.push('<span style="color:var(--ash)">+'+(up.length-4)+'</span>');
'@ @'
  // v37.xx (cw-m3pipgap): one block with 16px under it; the last pip line sat 9px over the stats divider on the extract card (1080 picture of v37.61)
  var h=[];
  for(i=0;i<up.length&&i<4;i++) h.push('<span style="color:'+WORN_RARS[up[i].r].c+'">'+escHtml(wornName(up[i]))+' pip '+up[i].pip+'</span>');
  if(up.length>4) h.push('<span style="color:var(--ash)">+'+(up.length-4)+'</span>');
  if(h.length) lines.push('<div class="ocpips" style="margin:0 0 16px">'+h.join('<br>')+'</div>');
'@

SubRx @'
var VER='37.62';
'@ @'
var VER='37.63';
'@

$pat = "(?m)^  now:'v37\.62:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v37.63: the pip lines of the worn pieces are one block with 16px under it, so the last line no longer crowds the stats row. Words and colours are unchanged Check 37.63 fails on v37.62',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
