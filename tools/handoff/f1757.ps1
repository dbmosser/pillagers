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

if ($s.Contains("  {v:'17.57',what:")) { throw "check 17.57 is in the fixture already" }

SubRx @'
  {v:'17.56',what:
'@ @'
  {v:'17.57',what:'a ping on THE OVERSEER names it, in the host window and in a linked one, and a ping on any other body still names its kind or the pillager',
   run:function(){
     if(typeof netPingName!=='function') return 'a ping on the boss calls it WARDEN';
     if(typeof BOSS_NAME==='undefined'||typeof netPingMake!=='function') return 'SKIP: this build has no boss or no ping';
     var bad=[], n;
     n=netPingName({kind:'warden',boss:1,name:BOSS_NAME}); if(n!==BOSS_NAME) bad.push('the host ping on the boss says '+n);
     n=netPingName({kind:'warden',name:BOSS_NAME}); if(n!==BOSS_NAME) bad.push('the linked ping on the boss says '+n);
     n=netPingName({kind:'warden',name:''}); if(n!=='WARDEN') bad.push('a ping on a plain warden says '+n);
     n=netPingName({kind:'raider',name:'GRIT MALLOW'}); if(n!=='GRIT MALLOW') bad.push('a ping on a pillager says '+n);
     if(String(netPingMake).indexOf('netPingName(')<0) bad.push('the ping does not use the name it should');
     return bad.length?bad.join('; '):null; }},
  {v:'17.56',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
