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

if ($s.Contains("  {v:'16.51',what:")) { throw "check 16.51 is in the fixture already" }

SubRx @'
  {v:'16.50',what:
'@ @'
  {v:'16.51',what:'the pause box shuts when a raid ends under it, so the end of raid card is what a controller drives; an ended raid still refuses to open the box',
   run:function(){
     if(typeof togglePauseBox!=='function'||!window.__deploy||!window.__endRaid) return 'SKIP: this build has no pause box to test';
     var pb=document.getElementById('pausebox'), oc=document.getElementById('outcome'), bad=[];
     if(!pb) return 'SKIP: there is no pause box in this document';
     try{
       __runPrep(); __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       togglePauseBox(true);
       if(!pb.classList.contains('on')) return 'SKIP: staging: the pause box did not open in a raid';
       __endRaid('dead');
       if(pb.classList.contains('on')) bad.push('the raid ended with the pause box open and the box stayed over the end of raid card');
       if(oc&&!oc.classList.contains('on')&&getComputedStyle(oc).display==='none') bad.push('control: no end of raid card came up');
       togglePauseBox(true);
       if(pb.classList.contains('on')) bad.push('an ended raid opened the pause box');
     } finally { try{ togglePauseBox(false); }catch(e){} try{ __topClear(); }catch(e){} }
     return bad.length?bad.join('; '):null; }},
  {v:'16.50',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
