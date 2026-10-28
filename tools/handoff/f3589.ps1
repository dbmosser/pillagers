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

if ($s.Contains("  {v:'35.89',what:")) { throw "check 35.89 is in the fixture already" }

SubRx @'
  {v:'35.88',what:
'@ @'
  {v:'35.89',what:'his order 2026-10-28 (the pause box shows every modifier that changes sp): the score panel also lists the raid conditions that pay sp (night, hard weather, signed terms, x1.05 each, cw-cx-condition-sp) or one muted conditions none row, and its headline is the settings multiplier times the conditions',
   run:function(){
     if(!(window.__deploy&&window.__state&&window.__runPrep&&window.__endRaid&&window.__resetCfg&&window.__pinDefaults&&window.__cleanProfile&&window.__P&&window.__applyLoaded)) return 'SKIP: this fixture cannot deploy';
     if(typeof pauseSpSync!=='function'||typeof raidConditionRows!=='function'||typeof diffMul!=='function') return 'SKIP: no score panel or condition rows in this build';
     var bad=[], g, c0=(typeof CAREER_ON==='number')?CAREER_ON:0, d0=DMUL_ON, snap=null, pb=false, el, rows, i, rr, hd, want, prod, cond0=P.cond;
     function rowOf(l){ for(var j=0;j<rows.length;j++){ var s=rows[j].querySelector('span'); if(s&&s.textContent===l) return rows[j]; } return null; }
     function fac(r){ var b=r&&r.querySelector('b'); return b?parseFloat(String(b.textContent).replace(/^x/,'')):NaN; }
     function open(cond){
       __topClear(); __runPrep(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       CAREER_ON=1; DMUL_ON=1; P.cond=cond;
       __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       g=__state(); if(!g||g.over) return false;
       g.player.iv=99;
       togglePauseBox(true); pb=true;
       el=document.getElementById('pausesp'); rows=el?el.querySelectorAll('.psprow'):[];
       return !!el;
     }
     try{
       snap=JSON.parse(JSON.stringify(__P()));
       if(!open('night')) return 'SKIP: no live raid or no score panel';
       if(isDay()) return 'SKIP: the raid did not come up at night';
       rr=rowOf('night');
       if(!rr) bad.push('a night raid has no night row on the pause box ('+JSON.stringify((el.innerText||'').slice(0,160))+')');
       else if(Math.abs(fac(rr)-1.05)>0.001) bad.push('the night row reads x'+fac(rr)+', not x1.05');
       want=Math.round(diffMul()*raidConditionMul()*100)/100;
       hd=el.querySelector('.psph b'); if(!hd||hd.textContent!=='x'+want.toFixed(2)) bad.push('the headline reads '+(hd&&hd.textContent)+', not x'+want.toFixed(2)+' (settings x'+diffMul()+' times conditions x'+raidConditionMul().toFixed(4)+')');
       for(prod=1,i=0;i<rows.length;i++){ var x=fac(rows[i]); if(x>=1) prod*=x; }
       if(Math.abs(prod-want)>0.011) bad.push('the rows multiply to '+prod.toFixed(4)+', not the headline '+want);
       togglePauseBox(false); pb=false; __endRaid('abandon');
       if(!open('day')) return bad.concat(['SKIP: no second raid']).join('; ');
       if(!raidConditionRows().length){
         rr=rowOf('conditions');
         if(!rr||!/none/.test(rr.textContent||'')||Math.abs(fac(rr)-1)>0.001) bad.push('a clear day raid has no muted conditions none row');
       }
     }catch(x2){ bad.push('threw: '+(x2&&x2.message||x2)); }
     finally{
       try{ if(pb) togglePauseBox(false); }catch(_p){}
       try{ P.cond=cond0||'day'; CAREER_ON=c0; DMUL_ON=d0; }catch(_r){}
       try{ var g2=__state(); if(g2&&!g2.over) __endRaid('abandon'); }catch(_e){}
       try{ if(snap&&window.__applyLoaded) __applyLoaded(snap); }catch(_s){}
       __topClear(); }
     return bad.length?bad.join('; '):null; }},
  {v:'35.88',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
