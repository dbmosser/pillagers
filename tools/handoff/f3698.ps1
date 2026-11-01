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

if ($s.Contains("  {v:'36.98',what:")) { throw "check 36.98 is in the fixture already" }

SubRx @'
  {v:'36.97',what:
'@ @'
  {v:'36.98',what:'the seal opens in two thirds of the time, and the first frame of cutting it calls one wave of machines on the opener from 700 or more away (his 10-31 order)',
   run:function(){
     if(!(window.__seal&&__seal.here&&__seal.need)) return 'SKIP: no seal here';
     if(!(window.__deploy&&window.__state&&window.__endRaid&&window.__loop&&window.__keysRef)) return 'SKIP: this fixture cannot deploy and loop';
     var bad=[], g, p, R, c0, t0, i, K, rs=say, said=[], n1=0, n2=0, e, heading=0, far=0;
     function wave(){ var a=[], j; for(j=0;j<g.ents.length;j++) if(g.ents[j].sealBorn) a.push(g.ents[j]); return a; }
     try{
       if(__seal.need(0)!==Math.round(34*2/3)||__seal.need(1)!==Math.round(55*2/3)) bad.push('the seal needs '+__seal.need(0)+' and '+__seal.need(1)+' seconds at stages 1 and 2, not two thirds of 34 and 55');
       __topClear(); __runPrep(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       g=__state(); p=g.player; if(!g.seal) return 'SKIP: no seal in this raid';
       say=function(m){ said.push(String(m)); };
       R=__seal.here(); c0=R.cut; t0=R.tier; R.cut=0; R.tier=0;
       p.x=g.seal.x+30; p.y=g.seal.y; p.downed=false;
       K=__keysRef(); for(var k in K) delete K[k]; K['KeyE']=true;
       for(i=0;i<6;i++) __loop(performance.now()+i*16.7);
       n1=wave().length;
       if(!(g.seal.gained>0)) bad.push('the seal made no progress with E held beside it');
       if(n1<3) bad.push('only '+n1+' machines were called on the opener in the first frames of cutting, wanted at least 3');
       wave().forEach(function(m){
         if(Math.hypot(m.tx-g.seal.x,m.ty-g.seal.y)<120&&(m.state==='investigate'||m.state==='chase'||m.state==='alarm'||m.state==='hunt')) heading++;
         if(Math.hypot(m.x-p.x,m.y-p.y)>=690) far++;
       });
       if(n1&&heading<n1) bad.push('only '+heading+' of '+n1+' called machines head for the seal');
       if(n1&&far<n1) bad.push('only '+far+' of '+n1+' called machines start 700 or more from the opener');
       if(!said.some(function(s){ return /SEAL BREACH/i.test(s); })) bad.push('the wave said no SEAL BREACH callout');
       for(var k2 in K) delete K[k2];
       for(i=0;i<3;i++) __loop(performance.now()+(10+i)*16.7);
       K['KeyE']=true;
       for(i=0;i<3;i++) __loop(performance.now()+(20+i)*16.7);
       n2=wave().length;
       if(n2!==n1) bad.push('letting go of E and cutting again called more machines ('+n1+' then '+n2+'), one wave per seal per raid');
     }catch(e2){ bad.push('threw: '+(e2&&e2.message||e2)); }
     finally{ say=rs; try{ var K2=__keysRef(); for(var k3 in K2) delete K2[k3]; }catch(_k){} try{ if(R){ R.cut=c0; R.tier=t0; R.done=0; } }catch(_r){} try{ var g2=__state(); if(g2&&!g2.over){ g2.player.downed=false; if(g2.seal){ g2.seal.gained=0; g2.seal.waved=0; } __endRaid('abandon'); } }catch(_e){} try{ if(R){ R.cut=c0; R.tier=t0; } }catch(_r2){} __topClear(); __cleanProfile(); }
     return bad.length?bad.join('; '):null; }},
  {v:'36.97',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
