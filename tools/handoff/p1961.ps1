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

# THE CO-OP REVIVE BAR GROWS AT 4K (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
    if(_rs){ bar(_rs.x-30,_rs.y-8,60,6,Math.min(1,G.netRevT/NET_REV_T),'#4de3d0');
      ctx.font=FS(TYPE.label); ctx.textAlign='center'; ctx.fillStyle='#4de3d0'; ctx.fillText('REVIVING',_rs.x,_rs.y-14); ctx.textAlign='left'; }
'@ @'
    // v19.61, from the review (2026-10-08): the teammate revive bar grows with the screen like the search and reload bars beside it (v19.57)
    if(_rs){ var _hsV=hudAtIn(_rs.x,_rs.y); try{ bar(_rs.x-30,_rs.y-8,60,6,Math.min(1,G.netRevT/NET_REV_T),'#4de3d0');
      ctx.font=FS(TYPE.label); ctx.textAlign='center'; ctx.fillStyle='#4de3d0'; ctx.fillText('REVIVING',_rs.x,_rs.y-14); ctx.textAlign='left'; } finally { if(_hsV) ctx.restore(); } }
'@

SubRx @'
var VER='19.60';
'@ @'
var VER='19.61';
'@

$pat = "(?m)^  now:'v19\.60:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v19.61: At 4K the co-op revive bar is full size. Check 19.61 fails on v19.60',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
