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

# A RAID LINE SHOWS ITS DETAIL (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
function msgRowH(){ var mf=(/([\d.]+)px/).exec(FS(TYPE.label)), px=mf?parseFloat(mf[1]):LH(12); return Math.round(px*1.42); }
'@ @'
function msgRowH(){ var mf=(/([\d.]+)px/).exec(FS(TYPE.label)), px=mf?parseFloat(mf[1]):LH(12); return Math.round(px*1.42); }
// v21.94, the raid text rewrite (fix after the queue): A LINE SHOWS ITS DETAIL. say(m,kind,{sub}) has carried a detail since v21.80
// (G.msgSub, the row's sub) but no row drew it, so a headline that needs a number or a key (BACKPACK FULL and which key drops)
// could not be written without losing it. A row with a detail now reads as one line, the headline, two spaces, a middle dot, two
// spaces, then the detail, as the design's feed row does; it wraps and is measured like any other line. A row with no detail is
// drawn exactly as before.
function msgRowText(r){ return (r&&r.sub)?String(r.m)+'  \u00b7  '+String(r.sub):String(r&&r.m); }
'@

SubRx @'
        n=msgWrap(rows[i].m,mw).length;
'@ @'
        n=msgWrap(msgRowText(rows[i]),mw).length;   // v21.94: with its detail
'@

SubRx @'
          if(G&&G.tel){ ll=(G.tel.longLines=G.tel.longLines||[]); if(ll.indexOf(rows[i].m)<0&&ll.length<20) ll.push(rows[i].m); }
'@ @'
          if(G&&G.tel){ ll=(G.tel.longLines=G.tel.longLines||[]); if(ll.indexOf(msgRowText(rows[i]))<0&&ll.length<20) ll.push(msgRowText(rows[i])); }
'@

SubRx @'
_mln=msgWrap(_mrw.m,_mmx)
'@ @'
_mln=msgWrap(msgRowText(_mrw),_mmx)
'@

SubRx @'
var VER='21.93';
'@ @'
var VER='21.94';
'@

$pat = "(?m)^  now:'v21\.93:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v21.94: A raid message can show a short detail after its headline, like BACKPACK FULL then the key that drops an item. Check 21.94 fails on v21.93',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
