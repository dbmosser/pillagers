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

# THE STATUS COLUMN STAYS AT THE LEFT (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
  rows=Math.max(1,Math.floor((yBot-oy+g*hr)/((S+g)*hr)));   // more than fit start a second column to the right
'@ @'
  rows=Math.max(1,Math.floor((yBot-oy+g*hr)/((S+g)*hr)));   // more than fit start a second column to the right
  // v19.11, from the review (2026-10-07): with little room below the board (big text, a short window, the full controls list) rows fell to 1 and every
  // further status started a new column further right, out across the play area and off the screen. The column now shrinks to fit first
  // (down to 0.6), and never uses more than two columns; a status past those is left for the CONDITIONS panel, which lists the drinks too.
  var _sk=1; if(n>rows){ _sk=Math.max(0.6,Math.min(1,(yBot-oy+g*hr)/(n*(S+g)*hr))); rows=Math.max(1,Math.floor((yBot-oy+g*hr)/((S+g)*hr*_sk))); }
'@

SubRx @'
    ctx.translate(ox,oy); ctx.scale(hr,hr);
'@ @'
    ctx.translate(ox,oy); ctx.scale(hr*_sk,hr*_sk);
'@

SubRx @'
      x=Math.floor(s/rows)*(S+LH(110)); y=(s%rows)*(S+g); s++;
'@ @'
      if(s>=rows*2) break;   // v19.11: two columns at most
      x=Math.floor(s/rows)*(S+LH(110)); y=(s%rows)*(S+g); s++;
'@

SubRx @'
var VER='19.10';
'@ @'
var VER='19.11';
'@

$pat = "(?m)^  now:'v19\.10:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v19.11: Status icons always stay in the left strip, however little room there is. Check 19.11 fails on v19.10',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
