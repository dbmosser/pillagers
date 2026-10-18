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

# RUN INFO TITLE IS WHITE (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
    ctx.fillStyle=UIC.acc; ctx.fillText('RUN INFO',bx+pad,ry);   // v27.42 (info1): was CONDITIONS
'@ @'
    ctx.fillStyle=UIC.tx_1; ctx.fillText('RUN INFO',bx+pad,ry);   // v27.42 (info1): was CONDITIONS; v28.xx (cw-runinfotitle), the critic (2026-10-19): 'Lime is spent on a label ... Remove all lime.' The title is white
'@

SubRx @'
      if(R2.k){ ctx.fillStyle=R2.c; ctx.fillText(R2.k,bx+pad,ry); ry+=lh; }
'@ @'
      if(R2.k){ ctx.fillStyle=UIC.tx_2; ctx.fillText(R2.k,bx+pad,ry); ry+=lh; }   // v28.xx (cw-runinfotitle): the section headings are grey, the panel title white, no lime
'@

SubRx @'
var VER='30.66';
'@ @'
var VER='30.67';
'@

$pat = "(?m)^  now:'v30\.66:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v30.67: The Run info panel title is white and its section headings are grey. Check 30.67 fails on v30.66',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
