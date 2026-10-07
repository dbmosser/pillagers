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

if ($s.Contains("  {v:'18.51',what:")) { throw "check 18.51 is in the fixture already" }

SubRx @'
  {v:'18.50',what:
'@ @'
  {v:'18.51',what:'a covered host window keeps the kept raid running: the worker tick is wanted while the host spectates for the party, even back in the Undercroft, and not when there is no party',
   run:function(){
     if(typeof hidWant!=='function') return 'SKIP: no worker tick here';
     var bad=[], keep={on:NET.on,role:NET.role,specG:NET.specG}, oH=netEntsHost;
     try{
       netEntsHost=function(){ return false; };
       NET.on=true; NET.role='host'; NET.specG={over:true};
       if(!hidWant()) bad.push('a spectating host with its window covered stops running the kept raid');
       NET.specG=null; if(hidWant()) bad.push('control: the tick is wanted with no raid to run');
       NET.on=false; NET.specG={over:true}; if(hidWant()) bad.push('control: the tick is wanted with no party');
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{ netEntsHost=oH; NET.on=keep.on; NET.role=keep.role; NET.specG=keep.specG; }
     return bad.length?bad.join('; '):null; }},
  {v:'18.50',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
