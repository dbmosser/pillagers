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

if ($s.Contains("  {v:'16.49',what:")) { throw "check 16.49 is in the fixture already" }

SubRx @'
  {v:'16.48',what:
'@ @'
  {v:'16.49',what:'a controller tap with the map cursor moved places the marker and shuts the map, so the map never stays stuck open over a dead gun',
   run:function(){
     if(typeof pollPad!=='function'||typeof netWpFromMap!=='function'||!window.__deploy||!window.__endRaid) return 'SKIP: this build has no controller map path';
     var NGA=navigator.getGamepads, oS=say, oB=blip, bad=[], dn=false, placed=0, oW=netWpFromMap;
     function pad(){ var b=[],q; for(q=0;q<17;q++) b.push({pressed:(q===12&&dn),value:(q===12&&dn)?1:0,touched:(q===12&&dn)}); return [{connected:true,id:'check pad',index:0,mapping:'standard',timestamp:Date.now(),buttons:b,axes:[0,0,0,0]}]; }
     try{
       __runPrep(); __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       say=function(){}; blip=function(){};
       netWpFromMap=function(){ placed++; return oW.apply(null,arguments); };
       navigator.getGamepads=pad;
       dn=false; pollPad();
       G.mapOpen=true; G.mapCur={x:G.player.x+50,y:G.player.y+50};
       dn=false; pollPad(); dn=true; pollPad(); dn=false; pollPad();
       if(!placed) bad.push('the D-UP tap with the map cursor moved placed no marker (open '+G.mapOpen+')');
       else if(G.mapOpen) bad.push('a D-UP tap with the map cursor moved placed the marker and left the map open');
     } finally { navigator.getGamepads=NGA; say=oS; blip=oB; netWpFromMap=oW; try{ G.mapOpen=false; G.mapCur=null; __endRaid('abandon'); __topClear(); }catch(e){} }
     return bad.length?bad.join('; '):null; }},
  {v:'16.48',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
