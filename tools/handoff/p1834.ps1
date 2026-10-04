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

# THE BELT KEYS ARE ROUNDED TILES (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
      ctx.fillStyle=on?'rgba(38,32,20,.94)':'rgba(6,9,13,.80)';
      ctx.fillRect(bx,hy,bw,bw);
'@ @'
      // v18.34, THE STYLING PASS IN THE RAID (2026-10-04): THE BELT KEYS ARE ROUNDED TILES. A belt key was a flat square with a thin
      // stroke. It is a rounded tile now with a light from the top, a rarity wash inside the same shape and a rounded ring, the
      // shape the stash cells took at v18.32. Every size, hit box and colour rule is unchanged.
      var _br=Math.max(3,bw*0.09);
      function _bpath(){ ctx.beginPath(); if(ctx.roundRect) ctx.roundRect(bx+.5,hy+.5,bw-1,bw-1,_br); else ctx.rect(bx+.5,hy+.5,bw-1,bw-1); }
      ctx.save(); _bpath(); ctx.clip();
      var _bg=ctx.createLinearGradient(0,hy,0,hy+bw); _bg.addColorStop(0,on?'rgba(70,56,28,.96)':'rgba(28,36,64,.86)'); _bg.addColorStop(1,on?'rgba(38,32,20,.94)':'rgba(6,9,13,.86)');
      ctx.fillStyle=_bg; ctx.fillRect(bx,hy,bw,bw);
'@

SubRx @'
      if(_hr&&!empty){ var _hf=rfill(_hr); if(_hf){ ctx.fillStyle=_hf; ctx.fillRect(bx,hy,bw,bw); } }
'@ @'
      if(_hr&&!empty){ var _hf=rfill(_hr); if(_hf){ ctx.fillStyle=_hf; ctx.fillRect(bx,hy,bw,bw); } }
      ctx.fillStyle='rgba(255,255,255,.05)'; ctx.fillRect(bx,hy,bw,Math.max(1,bw*0.04));
      ctx.restore();
'@

SubRx @'
      ctx.lineWidth=(dragOver||on)?2:1;
      ctx.strokeRect(bx+.5,hy+.5,bw-1,bw-1);
'@ @'
      ctx.lineWidth=(dragOver||on)?2:1;
      _bpath(); ctx.stroke();   // v18.34: the rounded ring
'@

SubRx @'
var VER='18.33';
'@ @'
var VER='18.34';
'@

$pat = "(?m)^  now:'v18\.33:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v18.34: The tactical belt keys in a raid are rounded, shaded tiles that match the stash. Check 18.34 fails on v18.33',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
