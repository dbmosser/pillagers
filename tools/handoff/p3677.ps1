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

# THE RING NAME BADGE HUGS ITS LETTER (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
      ctx.save(); ctx.lineWidth=Math.max(1.5,_exFp*0.07); ctx.strokeStyle=ctx.fillStyle; ctx.beginPath(); ctx.arc(_exCx,_exBan-_exFp*0.3,_exFp*0.52,0,6.2832); ctx.stroke(); ctx.restore(); }catch(_exRg){}

'@ @'
      // v36.xx (cw-xcountplate2), the critic's eye on the picture (screen 37): the round badge touched the letters either side on the one-space inbound line. It is an oval that hugs the letter (its width plus 0.1 of the type size each side, a single space is 0.25).
      ctx.save(); ctx.lineWidth=Math.max(1.5,_exFp*0.07); ctx.strokeStyle=ctx.fillStyle; ctx.beginPath(); ctx.ellipse(_exCx,_exBan-_exFp*0.3,hudRawW(TX(_exL))/2+_exFp*0.1,_exFp*0.5,0,0,6.2832); ctx.stroke(); ctx.restore(); }catch(_exRg){}

'@

SubRx @'
var VER='36.76';
'@ @'
var VER='36.77';
'@

$pat = "(?m)^  now:'v36\.76:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v36.77: The ring name badge on the extraction countdown hugs its letter. Check 36.77 fails on v36.76',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
