$ErrorActionPreference = 'Stop'
trap { Write-Output "FAILED: $_"; exit 1 }
$p = 'C:\claudecode\dark raiders\tools\mkfixture.ps1'
$s = [IO.File]::ReadAllText($p)
$n = 0
function SubRx([string]$old, [string]$new) {
  $pat = ($old -split "`n" | ForEach-Object { [regex]::Escape($_.TrimEnd("`r")) }) -join "\r?\n"
  $c = ([regex]::Matches($script:s, $pat)).Count
  if ($c -ne 1) { throw "regex matched $c times: $($old.Substring(0,[Math]::Min(70,$old.Length)))" }
  $script:s = [regex]::Replace($script:s, $pat, { param($m) $new })
  $script:n++
}

# ---- 90 FRAMES PER BUILDING IS 9,400 GAME STEPS and the check timed out before
# ---- it could answer. The route search is rationed to ONE per frame for the
# ---- whole map, and a body with a stale route takes that ration immediately, so
# ---- a route that exists shows up within a handful of frames. 24 is four times
# ---- the margin that needs and a quarter of the cost.
SubRx @'
         var t0=performance.now(), got=false;
         for(var f=0;f<90;f++){ __loop(t0+f*16.7); p.x=tx; p.y=ty; if(cw.path&&cw.path.length) got=true; }
'@ @'
         var t0=performance.now(), got=false;
         for(var f=0;f<24;f++){ __loop(t0+f*16.7); p.x=tx; p.y=ty; if(cw.path&&cw.path.length) got=true; }
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
