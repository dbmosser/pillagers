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

if ($s.Contains("  {v:'21.85',what:")) { throw "check 21.85 is in the fixture already" }

SubRx @'
  {v:'21.84',what:
'@ @'
  {v:'21.85',what:'the raid text voice: a throw stopped by cover says GRENADE HIT COVER (warn) for a frag and THROW BLOCKED for the others',
   run:function(){
     if(!(window.__deploy&&window.__state&&window.__endRaid)) return 'SKIP: this fixture cannot deploy';
     if(typeof throwFrom!=='function'||typeof mouseWorld!=='function'||typeof rayHitG!=='function') return 'SKIP: no throw, aim point or wall ray in this build';
     var bad=[], g=null, said=[], realSay=say, realMW=mouseWorld, realRay=rayHitG, n0=0, kinds=['frag','smoke','decoy'], i, want, got;
     try{
       __topClear(); __runPrep(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       g=__state(); if(!g||g.over||!g.player||!g.throws) return 'SKIP: staging: no raid';
       keys={};
       var p=g.player;
       // The aim is 100 to the east and a wall stands 30 off, so every kind is stopped short inside its own warning radius.
       mouseWorld=function(){ return {x:p.x+100,y:p.y}; };
       rayHitG=function(){ return 30; };
       say=function(m,k){ said.push({m:String(m),k:k}); };
       n0=g.throws.length;
       for(i=0;i<kinds.length;i++){
         said.length=0;
         throwFrom(kinds[i],0);
         want=(kinds[i]==='frag')?{m:['GRENADE','HIT','COVER'].join(' '),k:'warn'}:{m:['THROW','BLOCKED'].join(' '),k:'info'};
         got=said.length?said[said.length-1]:null;
         if(!got) bad.push('a '+kinds[i]+' stopped by cover says nothing');
         else if(got.m!==want.m||got.k!==want.k) bad.push('a '+kinds[i]+' stopped by cover says '+JSON.stringify(got.m)+' as '+got.k+', not '+want.m+' as '+want.k);
         else if(got.m.length>34||got.m!==got.m.toUpperCase()||/[.!?]$/.test(got.m)) bad.push('the '+kinds[i]+' line is not a caps headline of 34 or fewer with no end punctuation');
       }
     }catch(err){ bad.push('threw: '+(err&&err.message||err)); }
     finally{
       say=realSay; mouseWorld=realMW; rayHitG=realRay;
       try{ var g2=__state(); if(g2&&g2.throws) g2.throws.length=Math.min(g2.throws.length,n0); if(g2&&!g2.over) __endRaid('abandon'); }catch(_e){}
       __topClear();
     }
     return bad.length?bad.join('; '):null; }},
  {v:'21.84',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
