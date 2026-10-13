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

if ($s.Contains("  {v:'25.88',what:")) { throw "check 25.88 is in the fixture already" }

SubRx @'
  {v:'25.87',what:
'@ @'
  {v:'25.88',what:'his rule: the siege after an extraction call is sized by the haul the same way in a DEMO raid (the loot points) as in a CAREER raid (the backpack)',
   run:function(){
     if(!window.__deploy||!window.__endRaid||typeof arcadeDeploy!=='function'||typeof arcadeLeave!=='function'||typeof ARCADE!=='object'||typeof greedOf!=='function'||typeof ival!=='function') return 'SKIP: no arcade or greed here';
     var bad=[], c0=(typeof CAREER_ON==='number')?CAREER_ON:0, key=null, v, gc, gd0, gd, g, k;
     try{
       __topClear(); __runPrep(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       for(k in ITEMS) if(Object.prototype.hasOwnProperty.call(ITEMS,k)&&!ITEMS[k].use&&ival(k)>=1000&&ival(k)<=0.5*CFG.greedFull){ key=k; break; }
       if(!key) return 'SKIP: no valuable of the right size to stage a haul';
       v=ival(key);
       try{ CAREER_ON=1; }catch(_c){}
       __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       g=__state(); if(!g||g.over) return 'SKIP: no live raid';
       if(!g.career) return 'SKIP: no CAREER raid in this build';
       g.bag.length=0; g.bag.push(key);
       gc=greedOf();
       if(!(gc>0)) return 'SKIP: staging: a CAREER backpack with a valuable gave no greed';
       __endRaid('abandon'); __topClear();
       try{ CAREER_ON=0; }catch(_c2){}
       if(!arcadeDeploy({mapIx:0,seed:4242})) return 'SKIP: no DEMO raid';
       g=__state(); if(!g||!g.arcade) return 'SKIP: the DEMO deploy built no arcade raid';
       g.bag.length=0;
       ARCADE.pot=0; gd0=greedOf();
       ARCADE.pot=v; gd=greedOf();
       if(gd0!==0) bad.push('control: an empty DEMO haul gives greed '+gd0);
       if(gd!==gc) bad.push('a DEMO haul of '+v+' loot points gives greed '+gd+', a CAREER backpack of the same value '+gc);
     }catch(x){ bad.push('threw: '+(x&&x.message||x)); }
     finally{ try{ CAREER_ON=c0; }catch(_r){} try{ if(ARCADE.on) arcadeLeave(); }catch(_a){} try{ ARCADE.pot=0; }catch(_p){} try{ var g2=__state(); if(g2&&!g2.over) __endRaid('abandon'); }catch(_e){} __topClear(); }
     return bad.length?bad.join('; '):null; }},
  {v:'25.87',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
