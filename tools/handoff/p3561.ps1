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

# RESPECT COMPUTER REDUCED MOTION (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
  return (typeof v==='number'&&v>=0&&v<row.opts.length)?v:row.def;
'@ @'
  if(typeof v==='number'&&v>=0&&v<row.opts.length) return v;
  // v28.xx (cw-cx-osmotion): the computer's reduced motion request supplies only an unset choice; saved picks and tuned dials still win.
  if(k==='shake'||k==='fxInt'){
    try{ if(window.matchMedia&&window.matchMedia('(prefers-reduced-motion: reduce)').matches) return 1; }catch(_rm){}
  }
  return row.def;
'@

SubRx @'
  e.stopT=HITSTOP_T; e.stopImm=HITSTOP_IMM; G.elemAny=1;
'@ @'
  // v28.xx (cw-cx-osmotion): honor the existing effect intensity dial for hit pause too; full keeps the usual 60 ms beat.
  var k=(CFG.fxInt===undefined)?1:Math.max(0,Math.min(1,+CFG.fxInt||0));
  if(!k) return false;
  e.stopT=HITSTOP_T*k; e.stopImm=HITSTOP_IMM; G.elemAny=1;
'@

SubRx @'
var VER='35.60';
'@ @'
var VER='35.61';
'@

$pat = "(?m)^  now:'v35\.60:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v35.61: Computer reduced motion starts unset shake light and intensity half. Saved settings win. Check 35.61 fails on v35.60',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
