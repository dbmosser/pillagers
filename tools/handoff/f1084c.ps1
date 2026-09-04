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

# ---- WAITING IS NOT THE SAME AS FAILING, and at 24 frames this check could not
# ---- tell them apart: it reported 3 of 13 and 9 of 59 trapped on a build the
# ---- 90 frame sweep had already measured at 0 of 20. The route search is
# ---- rationed to ONE per frame for the whole map and a body that has just
# ---- searched waits 2.6 to 3.8 seconds before it may search again, so a short
# ---- window catches bodies mid-wait and calls them trapped.
# ---- The stale flags are cleared before every step instead, so the body is
# ---- always eligible and the only thing being measured is whether the router
# ---- can answer. Twelve steps is then more than enough and the whole check
# ---- costs less than the 24 frame version did.
SubRx @'
         var t0=performance.now(), got=false;
         for(var f=0;f<24;f++){ __loop(t0+f*16.7); p.x=tx; p.y=ty; if(cw.path&&cw.path.length) got=true; }
'@ @'
         var t0=performance.now(), got=false;
         for(var f=0;f<12;f++){
           cw.pathT=0; cw.pathGoal=null; cw.pathFail=false;   // always eligible to search
           __loop(t0+f*16.7); p.x=tx; p.y=ty;
           if(cw.path&&cw.path.length) got=true;
         }
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
