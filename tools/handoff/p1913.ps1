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

# THE FASHION PREVIEWS KEEP ONE LOOK (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
var COSPREV={};
'@ @'
var COSPREV={};
// v19.13, from the review (2026-10-07): the preview caches kept every look ever previewed, about 57 PNG pictures per change of
// skin, hair or anything else, never let go. They now keep only the look being worn: a different look clears both stores first.
var PREVLOOK=null;
function prevCacheGuard(){ var lk=''; try{ lk=cosLookKey(); }catch(_lk){ return; } if(lk!==PREVLOOK){ COSPREV={}; OUTPREV={}; PREVLOOK=lk; } }
'@

SubRx @'
  key=kind+':'+id+'|'+cosLookKey(); hit=COSPREV[key]; if(hit!==undefined) return hit;
'@ @'
  prevCacheGuard();   // v19.13: one look's pictures at a time
  key=kind+':'+id+'|'+cosLookKey(); hit=COSPREV[key]; if(hit!==undefined) return hit;
'@

SubRx @'
  k=COSKEY.outfit;
'@ @'
  k=COSKEY.outfit;
  prevCacheGuard();   // v19.13: one look's pictures at a time
'@

SubRx @'
var VER='19.12';
'@ @'
var VER='19.13';
'@

$pat = "(?m)^  now:'v19\.12:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v19.13: Trying on pieces in FASHION no longer builds up memory. Check 19.13 fails on v19.12',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
