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

if ($s.Contains("  {v:'16.66',what:")) { throw "check 16.66 is in the fixture already" }

SubRx @'
  {v:'16.65',what:
'@ @'
  {v:'16.66',what:'in a raid, backing out never closes an Undercroft backpack left open out of sight; it closes the map in front of the player',
   run:function(){
     if(typeof backOut!=='function'||typeof hubBagOpen==='undefined'||!window.__deploy||!window.__endRaid) return 'SKIP: this build has no Undercroft backpack to test';
     var bad=[], kHB=hubBagOpen, kSet=hubBagOpenSet, commits=0;
     try{
       __runPrep(); __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       hubBagOpenSet=function(v){ if(!v) commits++; hubBagOpen=!!v; };
       hubBagOpen=true; G.mapOpen=true;
       backOut();
       if(G.mapOpen) bad.push('in a raid backing out shut the unseen Undercroft backpack and left the map open');
       if(commits) bad.push('in a raid backing out closed and saved the unseen Undercroft backpack');
     } finally { hubBagOpenSet=kSet; hubBagOpen=kHB; try{ G.mapOpen=false; __endRaid('abandon'); __topClear(); }catch(e){} }
     return bad.length?bad.join('; '):null; }},
  {v:'16.65',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
