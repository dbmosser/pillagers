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

if ($s.Contains("  {v:'25.82',what:")) { throw "check 25.82 is in the fixture already" }

SubRx @'
  {v:'25.81',what:
'@ @'
  {v:'25.82',what:'his question: the extraction countdown after a call is as long in a DEMO raid as in a CAREER raid',
   run:function(){
     if(!window.__deploy||!window.__endRaid||typeof tryExtractTick!=='function'||typeof arcadeDeploy!=='function'||typeof arcadeLeave!=='function') return 'SKIP: no extraction call or arcade here';
     var bad=[], c0=(typeof CAREER_ON==='number')?CAREER_ON:0, xw0, wait={}, g, p, z, i, d, bd, r;
     function callWait(tag){
       g=__state(); if(!g||g.over||!g.player) return 'no raid';
       p=g.player; p.iv=99; p.maxhp=100000; p.hp=100000; p.downed=false;
       z=null; bd=1e9;
       for(i=0;i<g.zones.length;i++){ if(g.zones[i].open===false) continue; d=Math.hypot(g.zones[i].x-p.x,g.zones[i].y-p.y); if(d<bd){ bd=d; z=g.zones[i]; } }
       if(!z) return 'no open extraction ring';
       g.ents.length=0; z.beaconT=null; z.callT=0; z.hold=null; z.pullT=null; p.x=z.x; p.y=z.y;
       for(i=0;i<30&&(z.beaconT===null||z.beaconT===undefined);i++){ g.ents.length=0; tryExtractTick(0.1,true); }
       if(z.beaconT===null||z.beaconT===undefined) return 'the call did not start';
       wait[tag]=z.beaconT; return null;
     }
     try{
       __topClear(); __runPrep(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       xw0=CFG.extractWait;
       try{ CAREER_ON=1; }catch(_c){}
       __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       g=__state(); if(!g||g.over) return 'SKIP: no live raid';
       if(!g.career) return 'SKIP: no CAREER raid in this build';
       r=callWait('career'); if(r) return 'SKIP: staging: the CAREER raid: '+r;
       __endRaid('abandon'); __topClear();
       try{ CAREER_ON=0; }catch(_c2){}
       if(!arcadeDeploy({mapIx:0,seed:4242})) return 'SKIP: no DEMO raid';
       g=__state(); if(!g||!g.arcade) return 'SKIP: the DEMO deploy built no arcade raid';
       r=callWait('demo'); if(r) return 'SKIP: staging: the DEMO raid: '+r;
       arcadeLeave();
       if(wait.career!==xw0) bad.push('control: a CAREER call waits '+wait.career+' s, not the dial '+xw0+' s');
       if(wait.demo!==wait.career) bad.push('a DEMO call waits '+wait.demo+' s, a CAREER call waits '+wait.career+' s');
     }catch(x){ bad.push('threw: '+(x&&x.message||x)); }
     finally{ try{ CAREER_ON=c0; }catch(_r){} try{ if(ARCADE.on) arcadeLeave(); }catch(_a){} try{ var g2=__state(); if(g2&&!g2.over) __endRaid('abandon'); }catch(_e){} __topClear(); }
     return bad.length?bad.join('; '):null; }},
  {v:'25.81',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
