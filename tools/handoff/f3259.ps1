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

if ($s.Contains("  {v:'32.59',what:")) { throw "check 32.59 is in the fixture already" }

SubRx @'
  {v:'32.58',what:
'@ @'
  {v:'32.59',what:'the hostiles plate is as wide as the banner above it with a gap under the banner (critic 37)',
   run:function(){
     if(typeof extRowPlate!=='function') return 'no extRowPlate';
     var s='1 HOSTILE CLOSING IN', r, f=ctx.font;
     ctx.save(); ctx.font=hudFS(TYPE.label);
     try{ r=extRowPlate(s,960,900,1,600); }finally{ ctx.restore(); ctx.font=f; }
     if(!r||Math.round(r.w)<600) return 'the plate ignores the banner width: '+(r&&r.w);
     var src=String(drawHUD);
     if(src.indexOf('_exBelt-LH(62)')<0) return 'the banner did not move up for the gap';
     if(src.indexOf('extRowPlate(_exH,W/2,_exRow,_exR,_exBW)')<0) return 'drawHUD does not pass the banner width';
     return null;
   }},
  {v:'32.58',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
