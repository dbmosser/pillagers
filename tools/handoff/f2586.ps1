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

if ($s.Contains("  {v:'25.86',what:")) { throw "check 25.86 is in the fixture already" }

SubRx @'
  {v:'25.85',what:
'@ @'
  {v:'25.86',what:'his rule: the DEMO raid builds from the same dials as a CAREER raid: the raid clock dial is not zeroed, the first weather change is drawn the same, and the dials come back at leave',
   run:function(){
     if(!window.__deploy||!window.__endRaid||typeof arcadeDeploy!=='function'||typeof arcadeLeave!=='function'||typeof ARCADE!=='object') return 'SKIP: no arcade here';
     var bad=[], c0=(typeof CAREER_ON==='number')?CAREER_ON:0, rs0, wx={}, g, i;
     try{
       __topClear(); __runPrep(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       rs0=CFG.raidSec;
       if(!(rs0>0)) return 'SKIP: the raid clock dial is off here';
       try{ CAREER_ON=1; }catch(_c){}
       __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       g=__state(); if(!g||g.over) return 'SKIP: no live raid';
       if(!g.career) return 'SKIP: no CAREER raid in this build';
       wx.career=g.wxAt;
       __endRaid('abandon'); __topClear();
       try{ CAREER_ON=0; }catch(_c2){}
       if(!arcadeDeploy({mapIx:0,seed:4242})) return 'SKIP: no DEMO raid';
       g=__state(); if(!g||!g.arcade) return 'SKIP: the DEMO deploy built no arcade raid';
       wx.demo=g.wxAt;
       if(CFG.raidSec!==rs0) bad.push('the raid clock dial is '+CFG.raidSec+' in a DEMO raid, '+rs0+' in a CAREER raid');
       if(wx.demo!==wx.career) bad.push('the first weather change is at '+wx.demo+' s in a DEMO raid and '+wx.career+' s in a CAREER raid built from the same seed');
       arcadeLeave();
       if(CFG.raidSec!==rs0) bad.push('the raid clock dial did not come back at leave ('+CFG.raidSec+', was '+rs0+')');
     }catch(x){ bad.push('threw: '+(x&&x.message||x)); }
     finally{ try{ CAREER_ON=c0; }catch(_r){} try{ if(ARCADE.on) arcadeLeave(); }catch(_a){} try{ var g2=__state(); if(g2&&!g2.over) __endRaid('abandon'); }catch(_e){} __topClear(); }
     return bad.length?bad.join('; '):null; }},
  {v:'25.85',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
