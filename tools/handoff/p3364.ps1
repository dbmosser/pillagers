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

# PLAYER 2 LINKS IN A TEST FRAME (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
function netP2Url(mode,pair){

'@ @'
function netP2Url(mode,pair,qOver){
'@

SubRx @'
  if(emb){ keep=String((typeof location!=='undefined'&&location.search)||'').replace(/^\?/,'').split('&').filter(function(s){ return s&&!/^(p2|mode|pair|arc|emb)=/.test(s); }).join('&'); if(keep) keep+='&'; }
'@ @'
  // v33.62 (cw-p2noslot): the embedded copy drops netslot too; a window with ?netslot is never player 2 (NETP2=!NETSLOT&&..., v15.76), so a test frame opened with it never linked. qOver is a test seam for the frame's query.
  if(emb){ keep=String((typeof qOver==='string')?qOver:((typeof location!=='undefined'&&location.search)||'')).replace(/^\?/,'').split('&').filter(function(s){ return s&&!/^(p2|mode|pair|arc|emb|netslot)=/.test(s); }).join('&'); if(keep) keep+='&'; }
'@

SubRx @'
var VER='33.63';
'@ @'
var VER='33.64';
'@

$pat = "(?m)^  now:'v33\.63:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v33.64: A test frame opened with netslot now links its player 2 window; nothing changes for players. Check 33.64 fails on v33.63',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
