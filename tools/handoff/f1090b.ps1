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

# ---- THE SPY SAW NOTHING BECAUSE THE LABEL WAS NEVER DRAWN. A ring that
# ---- projects off screen is culled before it can ask about the corner, and at
# ---- the deploy spawn every ring is off screen: zone 0 lands at x -210 with the
# ---- cull at -90. The operator is stood beside a ring now, which is also the
# ---- situation his screenshot was taken in.
SubRx @'
     var z=g.zones&&g.zones[0];
     if(z){ g.active=z; z.open=true; }
     function frame(){ for(var f=0;f<4;f++) __loop(performance.now()+f*16.7); __frame(0); __hud(); }
     frame();
'@ @'
     var z=g.zones&&g.zones[0];
     if(!z) return 'SKIP: this map has no extraction ring to label';
     g.active=z; z.open=true;
     // BESIDE THE RING, not at the spawn. A ring that projects off screen is
     // culled before it can ask about anything, and every ring is off screen
     // from the drop.
     p.x=z.x-260; p.y=z.y-260;
     function frame(){ for(var f=0;f<4;f++) __loop(performance.now()+f*16.7); __frame(0); __hud(); }
     frame();
     var _zs=(typeof w2s==='function')?w2s(z.x,z.r+18,z.y):null;
     if(!_zs||_zs.x<-90||_zs.x>(window.innerWidth||1920)+90)
       return 'SKIP: the ring would not project on screen here, so no label is drawn to test';
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
