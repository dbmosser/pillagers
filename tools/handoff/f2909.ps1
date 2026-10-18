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

if ($s.Contains("  {v:'29.09',what:")) { throw "check 29.09 is in the fixture already" }

SubRx @'
  {v:'29.08',what:
'@ @'
  {v:'29.09',what:'cw-shforge: a building that holds the Forge is never a stronghold candidate',
   run:function(){
     if(!(window.__state&&window.__runPrep)) return 'SKIP: no raid here';
     if(typeof arcadeDeploy!=='function'||typeof shCands!=='function') return 'SKIP: no arcade or strongholds in this fixture';
     var g, oF, C0, c, b, C1, i, bad=null, rs=say, own=false;
     try{
       say=function(){}; own=true;
       __topClear(); __runPrep();
       if(!arcadeDeploy({mapIx:0,seed:4242})) return 'SKIP: arcadeDeploy built no arcade raid';
       g=__state(); if(!g||!g.player) return 'SKIP: no live raid';
       keys={}; oF=g.forge;
       C0=shCands([]); if(!C0.length) return 'SKIP: staging: no building could be a stronghold';
       c=C0[0]; b=c.b;
       g.forge={x:b.x+b.w/2,y:b.y+b.h/2,name:'THE FORGE'};
       C1=shCands([]);
       for(i=0;i<C1.length;i++) if(C1[i].bi===c.bi) bad='the building holding the Forge is still a stronghold candidate';
       g.forge=oF;
       C1=shCands([]);
       if(!bad&&C1.length!==C0.length) bad='the candidates changed with the Forge back in its place ('+C0.length+' to '+C1.length+')';
       return bad;
     }catch(x){ return 'threw: '+(x&&x.stack||x); }
     finally{ if(own) say=rs; try{ if(g&&oF!==undefined) g.forge=oF; }catch(_f){} try{ __endRaid('abandon'); }catch(_e){} try{ __topClear(); }catch(_t){} }
   }},
  {v:'29.08',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
