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

# FASHION SAYS HOW MANY WARDENS A TILE NEEDS (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
  if(k==='warden')   return 'put a Warden down';
'@ @'
  // v22.31, from the whole-game bug hunt of 2026-10-08 (K40): A TILE THAT NEEDS MORE THAN ONE WARDEN SAYS HOW MANY. The Machine,
  // the Hood, the Ghost Mask and the Spider need two or three Warden kills (cosOwned counts them), but every Warden tile said put
  // a Warden down, so after the one kill it asked for the tile stayed locked with nothing to say why. A one-kill tile reads as
  // before; the others say how many and how far he has got.
  if(k==='warden'){ var _wn=(+v)||1, _wk=(typeof P!=='undefined'&&P&&P.kills&&P.kills.warden)||0; return _wn===1?'put a Warden down':('put '+_wn+' Wardens down ('+Math.min(_wn,_wk)+' of '+_wn+')'); }
'@

SubRx @'
var VER='22.30';
'@ @'
var VER='22.31';
'@

$pat = "(?m)^  now:'v22\.30:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v22.31: FASHION tiles that need two or three Warden kills now say how many, and how many you have so far. Check 22.31 fails on v22.30',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
