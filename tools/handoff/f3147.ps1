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

if ($s.Contains("  {v:'31.47',what:")) { throw "check 31.47 is in the fixture already" }

SubRx @'
  {v:'31.46',what:
'@ @'
  {v:'31.47',what:'under a quarter health the red outline on the health bar is thick (3px) and the stamina bar steps back (the critic: stamina out-shouts a nearly dead health bar)',
   run:function(){
     if(typeof drawLowHpRing!=='function') return 'there is no low health outline';
     if(String(drawHUD).indexOf('_lowDim')<0) return 'the stamina bar does not step back at low health';
     var w=0, rs=ctx.strokeRect;
     try{
       ctx.strokeRect=function(){ w=ctx.lineWidth; };
       drawLowHpRing(16,900,300,26,18,100);
     } finally { ctx.strokeRect=rs; }
     if(w<3) return 'the low health outline is only '+w+'px thick';
     return null; }},
  {v:'31.46',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
