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

if ($s.Contains("  {v:'35.69',what:")) { throw "check 35.69 is in the fixture already" }

SubRx @'
  {v:'35.68',what:
'@ @'
  {v:'35.69',what:'cw-dmulshow, his order of 2026-10-28 that the settings score multiplier is indicated to the player: Settings draws a score row with the multiplier the rows pay (it follows a click, and no row at x1.00), a raid draws the x tag beside the score label (none at x1.00), and the career end card and the demo run over card each show one settings line with it',
   run:function(){
     if(!(window.__deploy&&window.__state&&window.__endRaid&&window.__runPrep&&window.__resetCfg&&window.__pinDefaults&&window.__cleanProfile)) return 'SKIP: this fixture cannot deploy';
     if(typeof diffMul!=='function'||typeof diffMulOf!=='function') return 'SKIP: no settings score multiplier in this build';
     if(typeof openSettings!=='function'||typeof arcadeScoreHud!=='function'||typeof ocLedger!=='function'||typeof arcadeOverSync!=='function') return 'SKIP: no settings page, score card or end cards here';
     var bad=[], g, p, c0=(typeof CAREER_ON==='number')?CAREER_ON:0, d0=DMUL_ON, K=['superhot','nRaider','nSentry','eDmg','siegeVol','fogWar'], sv={}, i, m, el, want, rec=[], CP=CanvasRenderingContext2D.prototype, oF=CP.fillText, aOn=ARCADE.on, aOv=ARCADE.over, aSo=ARCADE.solo, lg, c;
     function spy(){ rec=[]; CP.fillText=function(s){ rec.push(String(s)); return oF.apply(this,arguments); }; }
     function tag(){ for(var q=0;q<rec.length;q++) if(/^x\d\.\d\d$/.test(rec[q])) return rec[q]; return null; }
     for(i=0;i<K.length;i++) sv[K[i]]=CFG[K[i]];
     try{
       __topClear(); __runPrep(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       DMUL_ON=1;
       // ZERO: his addition, fog of war on is a step, and a linked window building the raid takes the host's
       if(Math.abs(diffMulOf({superhot:1,nRaider:5,nSentry:12,eDmg:1,siegeVol:0.6,fogWar:1})-1.05)>0.0051) bad.push('fog of war on pays x'+diffMulOf({superhot:1,nRaider:5,nSentry:12,eDmg:1,siegeVol:0.6,fogWar:1})+', not x1.05');
       if(Math.abs(diffMulOf({superhot:1,nRaider:5,nSentry:12,eDmg:1,siegeVol:0.6,fogWar:0})-1)>0.0051) bad.push('fog of war off pays a step');
       if(typeof NET==='object'&&NET){ var _uh=NET.upHold, _uf=NET.upFw; try{ NET.upHold=true; NET.upFw=1; m=diffMulOf({superhot:1,nRaider:5,nSentry:12,eDmg:1,siegeVol:0.6,fogWar:0}); } finally { NET.upHold=_uh; NET.upFw=_uf; } if(Math.abs(m-1.05)>0.0051) bad.push('a linked window building the raid does not take the host fog of war (x'+m+')'); }
       if(typeof netUpAnnounce==='function'&&!/\bm\.fw=/.test(String(netUpAnnounce))) bad.push('the raid word does not carry the host fog of war');
       CFG.fogWar=0;
       // ONE: Settings, the score row
       CFG.superhot=0; CFG.nRaider=15; CFG.nSentry=28; CFG.eDmg=1.4; CFG.siegeVol=1.4;
       openSettings(); m=document.getElementById('settingsmodal');
       el=document.getElementById('set_dmul'); want='x'+(Math.round(diffMulOf(CFG)*100)/100).toFixed(2);
       if(!el) bad.push('Settings draws no score row with the hardest rows');
       else if(String(el.textContent).trim()!==want) bad.push('the Settings score row reads '+JSON.stringify(el.textContent)+', not '+want);
       if(want!=='x1.54') bad.push('staging: the hardest rows pay '+want);
       CFG.eDmg=1; renderSettings(); el=document.getElementById('set_dmul'); want='x'+(Math.round(diffMulOf(CFG)*100)/100).toFixed(2);
       if(!el||String(el.textContent).trim()!==want) bad.push('the Settings score row did not follow a row change to '+want+' ('+(el?el.textContent:'none')+')');
       CFG.superhot=1; CFG.nRaider=5; CFG.nSentry=12; CFG.siegeVol=0.6; renderSettings();
       if(document.getElementById('set_dmul')) bad.push('Settings draws a score row at x1.00');
       CFG.fogWar=1; renderSettings(); el=document.getElementById('set_dmul');
       if(!el||String(el.textContent).trim()!=='x1.05') bad.push('fog of war on alone reads '+(el?el.textContent:'no score row')+' in Settings, not x1.05');
       CFG.fogWar=0;
       try{ if(m) m.classList.remove('on'); }catch(_m){}
       // TWO: a career raid, the tag beside the score label
       __topClear(); __runPrep(); __resetCfg(); __pinDefaults(0); __cleanProfile(); DMUL_ON=1;
       CAREER_ON=1; CFG.superhot=0; CFG.eDmg=1.4;
       __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       g=__state(); if(!g||g.over||!g.player) return 'SKIP: staging: no raid';
       if(!g.career||!g.cs) return 'SKIP: staging: not a career raid';
       p=g.player; keys={}; g.mapOpen=false; g.bagOpen=false; g.paused=false;
       want='x'+diffMul().toFixed(2);
       spy(); try{ arcadeScoreHud(30,hudRes()); }catch(e1){ bad.push('arcadeScoreHud threw '+e1.message); } CP.fillText=oF;
       if(tag()!==want) bad.push('the score card draws '+JSON.stringify(tag())+' beside the score, not '+want);
       DMUL_ON=0; spy(); try{ arcadeScoreHud(30,hudRes()); }catch(e2){} CP.fillText=oF; DMUL_ON=1;
       if(tag()) bad.push('the score card draws '+tag()+' at x1.00');
       // THREE: the career end card, one settings line
       g.cs.s=1000; g.tel=g.tel||{};
       lg=ocLedger('extract',[],{acc:50,sec:300,hp:80,haul:0}).join('');
       i=lg.split(want).length-1;
       if(i!==1||!/>settings</i.test(lg)) bad.push('the career end card shows '+want+' '+i+' time(s) (a settings row: '+/>settings</i.test(lg)+')');
       DMUL_ON=0; lg=ocLedger('extract',[],{acc:50,sec:300,hp:80,haul:0}).join(''); DMUL_ON=1;
       if(/>settings</i.test(lg)) bad.push('the career end card shows a settings row at x1.00');
       try{ __endRaid('abandon'); }catch(_ea){}
       // FOUR: the demo run over card
       __topClear();
       ARCADE.on=1; ARCADE.solo=1; ARCADE.over={at:Date.now(),why:'extract',team:2000,p1:{s:2000,k:3,x:1,d:0},p2:null,dm:1.22};
       try{ arcadeOverSync(); }catch(e3){ bad.push('arcadeOverSync threw '+e3.message); }
       c=document.querySelector('#attract .arcover');
       if(!c) bad.push('staging: no run over card');
       else { i=String(c.textContent).split('x1.22').length-1; if(i!==1) bad.push('the demo run over card shows x1.22 '+i+' time(s)'); }
       ARCADE.over.dm=1; ARCADE.over.at=Date.now()+1; try{ arcadeOverSync(); }catch(e4){}
       c=document.querySelector('#attract .arcover');
       if(c&&/settings x/i.test(c.textContent)) bad.push('the demo run over card shows a settings line at x1.00');
     }catch(err){ bad.push('threw: '+(err&&err.message||err)); }
     finally{
       CP.fillText=oF; DMUL_ON=d0; CAREER_ON=c0; keys={};
       ARCADE.over=aOv; ARCADE.solo=aSo; ARCADE.on=aOn;
       try{ arcadeOverSync(); }catch(_s){} try{ var _c=document.querySelector('#attract .arcover'); if(_c) _c.style.display='none'; }catch(_c2){}
       try{ var _m=document.getElementById('settingsmodal'); if(_m) _m.classList.remove('on'); }catch(_m2){}
       for(i=0;i<K.length;i++) CFG[K[i]]=sv[K[i]];
       try{ var g2=__state(); if(g2&&!g2.over) __endRaid('abandon'); }catch(_e){}
       __topClear();
     }
     return bad.length?bad.join('; '):null; }},
  {v:'35.68',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
