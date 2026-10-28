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

if ($s.Contains("  {v:'36.04',what:")) { throw "check 36.04 is in the fixture already" }

SubRx @'
  {v:'36.03',what:
'@ @'
  {v:'36.04',what:'pause sp keeps its exact gold through the score-gold root token, with no raw gold in ui-shared, and the full shared-look check 29.33 passes',
   run:function(){
     var st=document.getElementById('ui-shared'), cs=getComputedStyle(document.documentElement), i, r, oldCheck=null;
     if(!st) return 'no shared style block';
     if(/#ffc04a/i.test(st.textContent.replace(/\/\*[\s\S]*?\*\//g,''))) return 'ui-shared still contains raw pause sp gold';
     if(cs.getPropertyValue('--score-gold').trim().toLowerCase()!=='#ffc04a') return 'score-gold is not the original #ffc04a';
     if(cs.getPropertyValue('--seat-one').trim().toLowerCase()!=='#ffb454'||cs.getPropertyValue('--seat-two').trim().toLowerCase()!=='#53d9e8') return 'run-over seat colours changed';
     for(i=0;i<__REGRESS.length;i++) if(__REGRESS[i].v==='29.33'){ oldCheck=__REGRESS[i]; break; }
     if(!oldCheck) return 'shared-look check 29.33 is missing';
     r=oldCheck.run(); if(r) return '29.33: '+r;
     if(!(window.__deploy&&window.__state&&window.__endRaid&&window.__P&&window.__applyLoaded)) return 'cannot stage the pause score panel';
     var g, el, hd, row, rule, snap=null, c0=CAREER_ON, d0=DMUL_ON, n0=CFG.nRaider, pb=false, bad=[];
     try{
       snap=JSON.parse(JSON.stringify(__P()));
       __runPrep(); __topClear(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       CAREER_ON=1; DMUL_ON=1; CFG.nRaider=15;
       __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       g=__state(); if(!g||g.over) return 'cannot stage a live raid';
       g.player.iv=99; togglePauseBox(true); pb=true;
       el=document.getElementById('pausesp');
       if(!el||!el.offsetHeight) return 'pause sp panel is missing or hidden';
       hd=el.querySelector('.psph b'); row=el.querySelector('.psprow:not(.z) b'); rule=el.querySelector('.psprule b');
       if(!hd||getComputedStyle(hd).color!=='rgb(255, 192, 74)') bad.push('headline gold changed');
       if(!row||getComputedStyle(row).color!=='rgb(255, 192, 74)') bad.push('setting factor gold changed');
       if(!rule||getComputedStyle(rule).color!=='rgb(255, 192, 74)') bad.push('end rule gold changed');
       return bad.length?bad.join('; '):null;
     }finally{
       try{ if(pb) togglePauseBox(false); }catch(_p){}
       try{ CAREER_ON=c0; DMUL_ON=d0; CFG.nRaider=n0; }catch(_r){}
       try{ __endRaid('abandon'); }catch(_e){}
       try{ if(snap) __applyLoaded(snap); }catch(_s){}
       __topClear();
     }
   }},
  {v:'36.03',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
