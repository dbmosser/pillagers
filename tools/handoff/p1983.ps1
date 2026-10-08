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

# A WRAPPED CONTRACT HANGS ITS SECOND LINE (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
      var ck=ctx.font+'|'+inner+'|'+t, best, n, lo, hi, mid, tr, it;
'@ @'
      var ck=ctx.font+'|'+inner+'|'+t, best, n, lo, hi, mid, tr, it, IND=Math.round(LH(8));   // v19.83: IND, the hanging indent of a second line
'@

SubRx @'
          if(ctx.measureText(trial).width<=w){ cur=trial; }
'@ @'
          if(ctx.measureText(trial).width<=(lines.length?w-IND:w)){ cur=trial; }
'@

SubRx @'
      for(var _lq=0;_lq<R2.wrapped.length;_lq++){ ctx.fillText(R2.wrapped[_lq],bx+pad+6,ry); ry+=lh; }
'@ @'
      // v19.83, seen on the 4K raid screenshot (2026-10-08): the second line of a wrapped contract started at the same margin as the
      // next contract and read as one of its own (1x Data Core 0/1). It hangs a little to the right now; wrap() leaves it the room.
      for(var _lq=0;_lq<R2.wrapped.length;_lq++){ ctx.fillText(R2.wrapped[_lq],bx+pad+6+(_lq?Math.round(LH(8)):0),ry); ry+=lh; }
'@

SubRx @'
var VER='19.82';
'@ @'
var VER='19.83';
'@

$pat = "(?m)^  now:'v19\.82:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v19.83: In the CONDITIONS box a contract that runs to two lines is easy to tell from the next one. Check 19.83 fails on v19.82',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
