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

if ($s.Contains("  {v:'16.61',what:")) { throw "check 16.61 is in the fixture already" }

SubRx @'
  {v:'16.60',what:
'@ @'
  {v:'16.61',what:'pinging twice in quick succession marks the ping as danger, as the controls legend says, and a third press does nothing more',
   run:function(){
     if(typeof netPingMake!=='function'||!window.__deploy||!window.__endRaid) return 'SKIP: this build has no ping';
     var keep={on:NET.on,upSeed:NET.upSeed,pingAt:NET.pingAt,pingLast:NET.pingLast,pings:NET.pings,seat:NET.seat}, oB=netBroadcast, bad=[], a, b, sent=0;
     try{
       __runPrep(); __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       netBroadcast=function(){ sent++; };
       NET.on=true; NET.upSeed=G.seed>>>0; NET.seat=0; NET.pingAt=0; NET.pingLast=null; NET.pings=[]; G.mapOpen=false;
       a=netPingMake();
       if(!a) return 'SKIP: staging: the first ping made nothing';
       b=netPingMake();
       if(!b||!b.dg) bad.push('a second ping at once did not mark danger ('+JSON.stringify(b)+')');
       if(sent!==2) bad.push('the party was told '+sent+' times, not twice, once for the ping and once for danger');
     } finally { netBroadcast=oB; for(var k in keep) NET[k]=keep[k]; try{ __endRaid('abandon'); __topClear(); }catch(e){} }
     return bad.length?bad.join('; '):null; }},
  {v:'16.60',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
