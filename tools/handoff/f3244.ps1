$ErrorActionPreference = 'Stop'
trap { Write-Output "FAILED: $_"; exit 1 }
$p = 'C:\claudecode\dark raiders\tools\mkfixture.ps1'
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

if ($s.Contains("  {v:'32.44',what:")) { throw "check 32.44 is in the fixture already" }

SubRx @'
  {v:'32.43',what:
'@ @'
  {v:'32.44',what:'auto resolution never steps the picture below 75 percent (his 2.44 b)',
   run:function(){
     if(typeof drsTick!=='function'||typeof DRS!=='object') return 'SKIP: no drsTick';
     var sv={scale:DRS.scale,ema:DRS.ema,slowT:DRS.slowT,fastT:DRS.fastT,last:DRS.last,bounce:DRS.bounce,upAt:DRS.upAt,said:DRS.said,moves:DRS.moves,q:DRS.q}, sa=CFG.gfxAuto, lo=1, i, t=100000;
     try{
       CFG.gfxAuto=1; DRS.scale=1; DRS.ema=0; DRS.slowT=0; DRS.fastT=0; DRS.last=0; DRS.q=3; DRS.said=1;
       for(i=0;i<4000;i++){ t+=40; drsTick(40,t); if(DRS.scale<lo) lo=DRS.scale; }
     } finally { for(var k in sv) DRS[k]=sv[k]; CFG.gfxAuto=sa; }
     if(lo>=1-1e-6) return 'the ladder never stepped the scale (check is blind)';
     if(lo<0.75-1e-6) return 'auto resolution fell to '+lo+', under 0.75';
     return null; }},
  {v:'32.43',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
