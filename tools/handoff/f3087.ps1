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

if ($s.Contains("  {v:'30.87',what:")) { throw "check 30.87 is in the fixture already" }

SubRx @'
  {v:'30.86',what:
'@ @'
  {v:'30.87',what:'every HUD bar is a flat fill: drawing health, armour and stamina bars makes no gradient (the critic, 10-19)',
   run:function(){
     if(typeof bar!=='function') return 'SKIP: no bar()';
     var oG=ctx.createLinearGradient, n=0, cols=['#5fae6f','#5aa9e6','#8fb5c8'], i;
     try{
       ctx.createLinearGradient=function(){ n++; return oG.apply(this,arguments); };
       ctx.save();
       for(i=0;i<cols.length;i++) bar(10,10+i*20,280,12,0.6,cols[i]);
       ctx.restore();
     } finally { ctx.createLinearGradient=oG; }
     if(n>0) return 'the bars still build '+n+' gradients, so they are glossy';
     return null;
   }},
  {v:'30.86',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
