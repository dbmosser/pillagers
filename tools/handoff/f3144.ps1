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

if ($s.Contains("  {v:'31.44',what:")) { throw "check 31.44 is in the fixture already" }

SubRx @'
  {v:'31.43',what:
'@ @'
  {v:'31.44',what:'under a quarter health the health bar gets a pulsing red outline (the critic: low health is too weak a state), and the raid HUD calls it',
   run:function(){
     if(typeof drawLowHpRing!=='function') return 'there is no low health outline (no drawLowHpRing)';
     if(String(drawHUD).indexOf('drawLowHpRing(')<0) return 'the raid HUD never draws the low health outline';
     var n=0, rs=ctx.strokeRect, a, b, c;
     try{
       ctx.strokeRect=function(){ n++; };
       a=drawLowHpRing(16,900,300,26,18,100); var na=n;
       b=drawLowHpRing(16,900,300,26,80,100); var nb=n-na;
       c=drawLowHpRing(16,900,300,26,0,100);
     } finally { ctx.strokeRect=rs; }
     if(!a||na<1) return 'hp 18 of 100 draws no outline';
     if(b||nb) return 'hp 80 of 100 still draws the outline';
     if(c) return 'hp 0 draws the outline';
     return null; }},
  {v:'31.43',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
