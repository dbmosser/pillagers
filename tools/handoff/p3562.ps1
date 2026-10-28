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

# SHOW OS MOTION DEFAULTS AS DEFAULTS (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
function gameOptIx(k){
  var row=null;
  for(var i=0;i<GAMEOPTS.length;i++) if(GAMEOPTS[i].k===k) row=GAMEOPTS[i];
  if(!row) return 0;
  var v=(P.gameOpts&&P.gameOpts[k]);
  if(typeof v==='number'&&v>=0&&v<row.opts.length) return v;
  // v28.xx (cw-cx-osmotion): the computer's reduced motion request supplies only an unset choice; saved picks and tuned dials still win.
  if(k==='shake'||k==='fxInt'){
    try{ if(window.matchMedia&&window.matchMedia('(prefers-reduced-motion: reduce)').matches) return 1; }catch(_rm){}
  }
  return row.def;
}
'@ @'
// v28.xx (cw-cx-osmotionlabel): the row and the loader share the computer-aware default; light/half is not a manual change.
function gameOptDefault(row){
  if(row.k==='shake'||row.k==='fxInt'){
    try{ if(window.matchMedia&&window.matchMedia('(prefers-reduced-motion: reduce)').matches) return 1; }catch(_rm){}
  }
  return row.def;
}
function gameOptIx(k){
  var row=null;
  for(var i=0;i<GAMEOPTS.length;i++) if(GAMEOPTS[i].k===k) row=GAMEOPTS[i];
  if(!row) return 0;
  var v=(P.gameOpts&&P.gameOpts[k]);
  if(typeof v==='number'&&v>=0&&v<row.opts.length) return v;
  return gameOptDefault(row);
}
'@

SubRx @'
    var _dflt=(_lv===_gr.def);
'@ @'
    var _dflt=(_lv===gameOptDefault(_gr));   // v28.xx (cw-cx-osmotionlabel): OS motion defaults use the ordinary value style.
'@

SubRx @'
var VER='35.61';
'@ @'
var VER='35.62';
'@

$pat = "(?m)^  now:'v35\.61:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v35.62: OS reduced motion defaults use ordinary settings value styling. Check 35.62 fails on v35.61',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
