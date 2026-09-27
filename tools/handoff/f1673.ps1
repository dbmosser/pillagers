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

if ($s.Contains("  {v:'16.73',what:")) { throw "check 16.73 is in the fixture already" }

SubRx @'
  {v:'16.72',what:
'@ @'
  {v:'16.73',what:'kid mode offers 1/20 after 1/10, and a 1/20 kid takes a twentieth of a hit',
   run:function(){
     if(typeof KID_OPTS==='undefined'||typeof netKidMul!=='function'||typeof damagePlayer!=='function'||!window.__deploy||!window.__endRaid) return 'SKIP: this build has no kid mode';
     var bad=[], has=KID_OPTS.some(function(o){ return o&&Math.abs(o[0]-0.05)<1e-9&&o[1]==='1/20'; });
     if(!has) bad.push('kid mode has no 1/20 option ('+KID_OPTS.map(function(o){ return o[1]; }).join(' ')+')');
     var i20=-1, i10=-1; KID_OPTS.forEach(function(o,i){ if(o[1]==='1/20') i20=i; if(o[1]==='1/10') i10=i; });
     if(has&&i20!==i10+1) bad.push('1/20 does not follow 1/10 in the row');
     var oKM=netKidMul, oG=null, kR=NET.role, kOn=NET.on, p=null, hp0;
     try{
       __runPrep(); __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       p=G.player; oG=voxGrunt; voxGrunt=function(){}; p.iv=0; p.armor=0; p.plates=0; hp0=p.hp;
       NET.on=true; NET.role='join'; netKidMul=function(){ return 0.05; };
       damagePlayer(20,'sentry','SENTRY',p.x+5,p.y);
       if(!(hp0-p.hp>0.5&&hp0-p.hp<2)) bad.push('a 20 point hit at 1/20 took '+(hp0-p.hp).toFixed(2)+' health, not about 1');
     } finally { netKidMul=oKM; NET.role=kR; NET.on=kOn; try{ if(oG) voxGrunt=oG; __endRaid('abandon'); __topClear(); }catch(e){} }
     return bad.length?bad.join('; '):null; }},
  {v:'16.72',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
