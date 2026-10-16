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

if ($s.Contains("  {v:'28.72',what:")) { throw "check 28.72 is in the fixture already" }

SubRx @'
  {v:'28.71',what:
'@ @'
  {v:'28.72',what:'his order 2026-10-15 (no shining circle on loot): an unopened container, a cache and a box holding a contract item draw no shining circle in the world pass',
   run:function(){
     if(!(window.__deploy&&window.__state&&window.__runPrep&&window.__endRaid&&window.__resetCfg&&window.__pinDefaults&&window.__cleanProfile)) return 'SKIP: this fixture cannot deploy';
     if(typeof drawContS!=='function'||typeof mkContainer!=='function'||typeof setLoot!=='function'||typeof needGlow!=='function') return 'SKIP: no container draw here';
     var bad=[], g, p, ct, ct2, n=0, oF=wc.fill, oS=wc.stroke, rk=Object.keys(RCOL||{});
     function lit(c){ n=0; wc.fill=function(){ if(wc.globalCompositeOperation==='lighter') n++; return oF.apply(wc,arguments); }; wc.stroke=function(){ if(wc.globalCompositeOperation==='lighter') n++; return oS.apply(wc,arguments); };
       try{ wc.save(); drawContS(c); wc.restore(); } finally { delete wc.fill; delete wc.stroke; if(wc.fill!==oF) wc.fill=oF; if(wc.stroke!==oS) wc.stroke=oS; }
       return n; }
     try{
       __topClear(); __runPrep(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       g=__state(); if(!g||g.over) return 'SKIP: no live raid';
       p=g.player;
       ct=mkContainer(p.x+100,p.y,'crate'); setLoot(ct,['scrap','board']); ct.opened=false;
       if(lit(ct)) bad.push('an unopened crate draws '+n+' shining shapes');
       ct2=mkContainer(p.x-100,p.y,'crate'); setLoot(ct2,['scrap','wire']); ct2.opened=false; ct2.cache=1; ct2.best=rk[0]||'common';
       if(lit(ct2)) bad.push('an unopened cache draws '+n+' shining shapes');
       g.need={board:1}; g.needN=1;
       if(lit(ct)) bad.push('a box holding a needed item draws '+n+' shining shapes');
       g.need={}; g.needN=0;
     }catch(x){ bad.push('threw: '+(x&&x.message||x)); }
     finally{
       try{ delete wc.fill; delete wc.stroke; if(wc.fill!==oF) wc.fill=oF; if(wc.stroke!==oS) wc.stroke=oS; }catch(_w){}
       try{ var g2=__state(); if(g2&&!g2.over) __endRaid('abandon'); }catch(_e){}
       __topClear(); }
     return bad.length?bad.join('; '):null; }},
  {v:'28.71',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
