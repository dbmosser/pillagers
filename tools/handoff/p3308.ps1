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

# ONE GOLDEN DEATH CALLOUT (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
  try{ say(goldDownName(kind),'obj',{sub:'SEARCH THE HOARD'}); }catch(_gs){}
'@ @'
  // v28.xx (cw-cx-goldonce): one golden death callout; fd skips the duplicate feed copy while keeping search the hoard.
  try{ say(goldDownName(kind),'obj',{sub:'SEARCH THE HOARD',fd:1}); }catch(_gs){}
'@

SubRx @'
      try{ spark(S.dx,S.dy,'#ffc72e',30,320); flash(S.dx,S.dy,260,'#ffc72e',.5); say(goldDownName(S.kind),'obj',{sub:'SEARCH THE HOARD'}); }catch(_gd){}
'@ @'
      // v28.xx (cw-cx-goldonce): the linked window also shows the death callout once, with the same name and subtitle.
      try{ spark(S.dx,S.dy,'#ffc72e',30,320); flash(S.dx,S.dy,260,'#ffc72e',.5); say(goldDownName(S.kind),'obj',{sub:'SEARCH THE HOARD',fd:1}); }catch(_gd){}
'@

SubRx @'
var VER='33.07';
'@ @'
var VER='33.08';
'@

$pat = "(?m)^  now:'v33\.07:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v33.08: Golden kills show one callout with the specific name and search the hoard in both windows. Check 33.08 fails on v33.07',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
