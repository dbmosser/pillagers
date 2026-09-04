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

# TRACED with the drop rule: out of the south door by frame 60, a four second
# wall hug south of the building, back north, and on the player at 34 units at
# frame 660, eleven seconds. Ten seconds read 153 and called the door blocked.
# The old build never arrives in thirty, so fifteen seconds keeps the control.
SubRx @'
       var t0=performance.now(), best=1e9;
       for(var f=0;f<600;f++){ cw.state='chase'; cw.alert=3; cw.tx=tx; cw.ty=ty;
         __loop(t0+f*16.7); p.x=tx; p.y=ty; p.hp=100; p.iv=99;
         var dd=D(cw,p); if(dd<best) best=dd; }
       // MEASURED before this build: 241 with the old routing and 273 with
       // v11.12, never closer, at seven seconds and at thirty.
       if(best>60) bad.push('the crawler in building 8 got no closer than '+best.toFixed(0)+' units in ten seconds, so its doorway is still not walkable');
'@ @'
       var t0=performance.now(), best=1e9;
       // Fifteen seconds. Traced: out of the south door by frame 60, a four
       // second wall hug south of the building, back north, and on the player
       // at 34 units at frame 660. Ten seconds read 153 and called the door
       // blocked, which it is not.
       for(var f=0;f<900;f++){ cw.state='chase'; cw.alert=3; cw.tx=tx; cw.ty=ty;
         __loop(t0+f*16.7); p.x=tx; p.y=ty; p.hp=100; p.iv=99;
         var dd=D(cw,p); if(dd<best) best=dd; }
       // MEASURED before this build: 241 with the old routing and 273 with
       // v11.12, never closer, at seven seconds and at thirty.
       if(best>60) bad.push('the crawler in building 8 got no closer than '+best.toFixed(0)+' units in fifteen seconds, so its doorway is still not walkable');
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
