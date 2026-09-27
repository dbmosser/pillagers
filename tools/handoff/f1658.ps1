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

if ($s.Contains("  {v:'16.58',what:")) { throw "check 16.58 is in the fixture already" }

SubRx @'
  {v:'16.57',what:
'@ @'
  {v:'16.58',what:'on a controller B backs out of the open map, backpack and peddler stall instead of rolling under them, and with nothing open B still rolls',
   run:function(){
     if(typeof pollPad!=='function'||typeof raidKey!=='function'||typeof backOut!=='function'||!window.__deploy||!window.__endRaid) return 'SKIP: this build has no controller raid path';
     var NGA=navigator.getGamepads, oRK=raidKey, bad=[], dn=false, rolls=0;
     function pad(){ var b=[],q; for(q=0;q<17;q++) b.push({pressed:(q===1&&dn),value:(q===1&&dn)?1:0,touched:(q===1&&dn)}); return [{connected:true,id:'check pad',index:0,mapping:'standard',timestamp:Date.now(),buttons:b,axes:[0,0,0,0]}]; }
     function tapB(){ dn=false; pollPad(); dn=true; pollPad(); dn=false; pollPad(); }
     try{
       __runPrep(); __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       navigator.getGamepads=pad;
       raidKey=function(code){ if(code==='Space') rolls++; return oRK.apply(null,arguments); };
       tapB(); rolls=0;
       G.mapOpen=true; tapB();
       if(G.mapOpen) bad.push('B left the map open'); if(rolls) bad.push('B rolled under the open map');
       rolls=0; G.bagOpen=true; tapB();
       if(G.bagOpen) bad.push('B left the backpack open'); if(rolls) bad.push('B rolled under the open backpack');
       G.bagOpen=false; G.trade={stock:[]}; tapB();
       if(G.trade) bad.push('B did not walk away from the stall');
       G.trade=null; rolls=0; tapB();
       if(!rolls) bad.push('control: with nothing open B no longer rolls');
     } finally { navigator.getGamepads=NGA; raidKey=oRK; try{ G.mapOpen=false; G.bagOpen=false; G.trade=null; keys={}; __endRaid('abandon'); __topClear(); }catch(e){} }
     return bad.length?bad.join('; '):null; }},
  {v:'16.57',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
