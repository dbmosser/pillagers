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

# THE XP LINE KEEPS ITS OWN LINE ON THE EXTRACTED CARD (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
    if((m=/^(<span style="color:var\(--amber\)">\+[\d,]+ XP)(?: (\((\d+)% penalty [^)]*\)))?(  &middot;  [\d,]+(?: of [\d,]+| XP in all))(<\/span>)(.*)$/.exec(ln))){ rest.push(m[1]+(m[3]?'  &middot;  '+m[3]+'% penalty':'')+'<span class="ocsr">'+(m[2]?' '+m[2]:'')+m[4]+'</span>'+m[5]+(m[6]?'<span class="ocsr">'+m[6]+'</span>':'')); continue; }
'@ @'
    if((m=/^(<span style="color:var\(--amber\)">\+[\d,]+ XP)(?: (\((\d+)% penalty [^)]*\)))?(  &middot;  [\d,]+(?: of [\d,]+| XP in all))(<\/span>)(.*)$/.exec(ln))){ rest.push(m[1]+(m[3]?'  &middot;  '+m[3]+'% penalty':'')+'<span class="ocsr">'+(m[2]?' '+m[2]:'')+m[4]+(m[6]||'')+'</span>'+m[5]); continue; }   // v35.73 (cw-xpbreak), his picture 2026-10-28 ("+2,386 xpthe seal on cold storage is broken..."): the hidden part sits inside the xp span, so the line no longer ends on an ocsr span and the .ocsr + br rule no longer eats the break after it
'@

SubRx @'
var VER='35.72';
'@ @'
var VER='35.73';
'@

$pat = "(?m)^  now:'v35\.72:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v35.73: the xp line on the extracted card keeps its own line Check 35.73 fails on v35.72',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
