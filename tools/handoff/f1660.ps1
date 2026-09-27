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

if ($s.Contains("  {v:'16.60',what:")) { throw "check 16.60 is in the fixture already" }

SubRx @'
  {v:'16.59',what:
'@ @'
  {v:'16.60',what:'every run report says which window it came from: player 1 or player 2, and its place in the party',
   run:function(){
     if(typeof buildExport!=='function'||typeof NETP2==='undefined') return 'SKIP: this build has no run report or no player 2 window';
     var k2=NETP2, a, b;
     try{
       NETP2=false; a=String(buildExport());
       NETP2=true; b=String(buildExport());
     } finally { NETP2=k2; }
     if(a.indexOf('Window: player 1')<0) return 'the player 1 report does not say Window: player 1';
     if(b.indexOf('Window: player 2')<0) return 'the player 2 report does not say Window: player 2';
     if(a.indexOf('Party: none')<0) return 'a solo report does not say Party: none';
     return null; }},
  {v:'16.59',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
