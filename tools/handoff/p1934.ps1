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

# THE BELT HINT READS ON ANY GROUND (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
      ctx.font=beltFS(bw,0.12); ctx.fillStyle='#8a96a1'; ctx.textAlign='center';   // v18.71: grows with the slots under it
      ctx.fillText(sl[sel].name+'   [FIRE] use'+(padOn()?'':'    ['+keyName(keysOf('KeyV'))+'] signal'),W/2,hy-LH(6));   // v13.52: no pad button reaches V; v18.71: the key as set
'@ @'
      ctx.font=beltFS(bw,0.12); ctx.textAlign='center';   // v18.71: grows with the slots under it
      // v19.34, seen on the 4K fog screenshot (2026-10-08): grey words straight on the ground, so on pale ground (fog, sand, a lit
      // floor) they all but vanished. They sit on a soft dark strip now, a little brighter, at the same size and place.
      var _bcT=sl[sel].name+'   [FIRE] use'+(padOn()?'':'    ['+keyName(keysOf('KeyV'))+'] signal'), _bcW=ctx.measureText(_bcT).width, _bcF=parseFloat(((/([\d.]+)px/).exec(String(ctx.font))||[0,11])[1])||11;
      ctx.fillStyle='rgba(6,9,13,.55)'; ctx.fillRect(Math.round(W/2-_bcW/2-_bcF*0.6),Math.round(hy-LH(6)-_bcF*0.95),Math.round(_bcW+_bcF*1.2),Math.round(_bcF*1.25));
      ctx.fillStyle='#b4bfca';
      ctx.fillText(_bcT,W/2,hy-LH(6));   // v13.52: no pad button reaches V; v18.71: the key as set
'@

SubRx @'
var VER='19.33';
'@ @'
var VER='19.34';
'@

$pat = "(?m)^  now:'v19\.33:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v19.34: The hint over the belt is readable on pale ground and in fog. Check 19.34 fails on v19.33',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
