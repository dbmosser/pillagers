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

if ($s.Contains("  {v:'27.20',what:")) { throw "check 27.20 is in the fixture already" }

SubRx @'
  {v:'27.19',what:
'@ @'
  {v:'27.20',what:'kit1, his word that the kit is part of the map select screen: a KIT row of four on the sector page (MY LOADOUT, FREEBIE KIT, RANDOM KIT, BEST KIT) with caps details, one on at a time and kept, ASCEND TO THIS SECTOR applies it and goes straight up with no card, the staging ASCEND opens the sector page, the quick ascent takes the kept kit, and the card a party mate sees keeps working under the new names',
   run:function(){
     if(!(window.__P&&window.__applyLoaded&&window.__hubEnter&&window.__station)) return 'SKIP: this fixture cannot reach the lift';
     if(typeof kitDeploy!=='function'||typeof kitApply!=='function') return 'there is no kit row on the map select screen in this build';
     var bad=[], snap=null, q, sm=document.getElementById('sectormodal'), am=document.getElementById('askmodal'), host, bs, i, labs, dets, on, went=0, fills=[], started=0, oAsc=ascendNow, oFill=kitFill, oStart=startRaid, oRs=null, tx, fired=0, b;
     function shut(){ var mo=document.querySelectorAll('.modal.on'); for(var j=0;j<mo.length;j++) mo[j].classList.remove('on'); }
     function btn(k){ return document.querySelector('#sectorkitpick .kitb[data-kit="'+k+'"]'); }
     try{
       snap=JSON.parse(JSON.stringify(__P()));
       __topClear(); __runPrep(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       q=__P(); delete q.kitPick; q.freeKit=0;
       __hubEnter(); shut();
       ascendNow=function(){ went++; return true; };
       kitFill=function(r){ fills.push(!!r); return {gun:null,kit:[]}; };
       startRaid=function(){ started++; };
       // ONE: the row is on the map select screen, four choices, MY LOADOUT on by default
       __station('lift','KeyE');
       if(!sm.classList.contains('on')) return 'ONE: the lift did not open the map select screen';
       host=document.getElementById('sectorkitpick');
       if(!host) return 'ONE: no KIT row on the map select screen';
       bs=host.querySelectorAll('.kitb');
       if(bs.length!==4) bad.push('ONE: '+bs.length+' kit choices, not 4');
       labs=Array.prototype.map.call(bs,function(e){ return e.firstElementChild.textContent; }).join('|');
       if(labs!=='MY LOADOUT|FREEBIE KIT|RANDOM KIT|BEST KIT') bad.push('ONE: the kit choices read '+labs);
       dets=Array.prototype.map.call(bs,function(e){ return e.querySelector('.kd').textContent; });
       if(dets[2].indexOf('2 GUNS')<0||dets[3].indexOf('3 GUNS')<0) bad.push('ONE: the details read '+dets.join('|'));
       for(i=0;i<dets.length;i++) if(dets[i]!==dets[i].toUpperCase()||!dets[i].length) bad.push('ONE: detail '+i+' is not a caps line ('+dets[i]+')');
       on=host.querySelectorAll('.kitb.on');
       if(on.length!==1||on[0].getAttribute('data-kit')!=='mine') bad.push('ONE: the default is not MY LOADOUT alone');
       if(host.parentElement!==sm) bad.push('ONE: the row is not in the sector panel');
       // TWO: one at a time, and kept
       btn('rand').click();
       on=host.querySelectorAll('.kitb.on');
       if(on.length!==1||on[0].getAttribute('data-kit')!=='rand') bad.push('TWO: RANDOM KIT did not become the only choice on');
       if(q.kitPick!=='rand') bad.push('TWO: the choice was not kept ('+q.kitPick+')');
       tx=document.getElementById('sectorkit').textContent;
       if(tx.indexOf('RANDOM KIT')<0) bad.push('TWO: the line under the row does not name RANDOM KIT ('+tx.slice(0,60)+')');
       renderSector(); on=host.querySelectorAll('.kitb.on');
       if(on.length!==1||on[0].getAttribute('data-kit')!=='rand') bad.push('TWO: the page forgot the kit when it was drawn again');
       q.kitPick='nonsense'; renderSector(); on=host.querySelectorAll('.kitb.on');
       if(on.length!==1||on[0].getAttribute('data-kit')!=='mine') bad.push('TWO: a bad saved kit did not read MY LOADOUT');
       // THREE: ASCEND applies the kit and goes straight up, with no card
       function go(k){ went=0; fills.length=0; q.kitPick=k; renderSector(); openModal('sectormodal'); document.getElementById('sectordeploy').click(); }
       q.freeKit=1; q.kitSaved={kit:[],hot:{}}; go('mine');
       if(went!==1) bad.push('THREE: MY LOADOUT went up '+went+' times');
       if(am.classList.contains('on')) bad.push('THREE: the card came up after the map select');
       if(q.freeKit) bad.push('THREE: MY LOADOUT left the freebie kit on');
       go('free');
       if(went!==1||!q.freeKit) bad.push('THREE: FREEBIE KIT went '+went+' times with freeKit '+q.freeKit);
       go('rand');
       if(went!==1||fills.join()!=='true') bad.push('THREE: RANDOM KIT went '+went+' times and filled '+fills.join());
       if(q.freeKit) bad.push('THREE: RANDOM KIT left the freebie kit on');
       go('best');
       if(went!==1||fills.join()!=='false') bad.push('THREE: BEST KIT went '+went+' times and filled '+fills.join());
       if(am.classList.contains('on')||sm.classList.contains('on')) bad.push('THREE: a window is still up after going');
       // FOUR: the staging screen opens the page and goes nowhere by itself
       shut(); went=0; document.getElementById('stagemodal').classList.add('on');
       document.getElementById('stagedrop').click();
       if(!sm.classList.contains('on')||document.getElementById('stagemodal').classList.contains('on')) bad.push('FOUR: the staging ASCEND did not open the map select screen');
       if(went) bad.push('FOUR: the staging ASCEND went up on its own');
       shut();
       // FIVE: the quick ascent takes the kept kit unless it is MY LOADOUT
       started=0; fills.length=0; q.kitPick='rand'; q.freeKit=0; __hubEnter(); shut();
       __station('lift','KeyR');
       if(started!==1||fills.join()!=='true') bad.push('FIVE: the quick ascent started '+started+' raids and filled '+fills.join()+' with RANDOM KIT kept');
       started=0; fills.length=0; q.kitPick='mine'; q.freeKit=1; q.kitSaved={kit:[],hot:{}}; __hubEnter(); shut();
       __station('lift','KeyR');
       if(started!==1||fills.length||!q.freeKit) bad.push('FIVE: the quick ascent with MY LOADOUT kept moved the kit (started '+started+', fills '+fills.join()+', freeKit '+q.freeKit+')');
       // SIX: the card a party mate sees: the new names, and the answers still go up
       shut(); went=0; fills.length=0; q.freeKit=0;
       askKit(function(){ fired++; },true);
       if(!am.classList.contains('on')) bad.push('SIX: the party card did not open');
       if(document.getElementById('askrand').textContent.trim()!=='RANDOM KIT'||document.getElementById('asktop').textContent.trim()!=='BEST KIT') bad.push('SIX: the party card reads '+document.getElementById('askrand').textContent+' and '+document.getElementById('asktop').textContent);
       if(am.textContent.indexOf('RANDOM FROM STASH')>=0||am.textContent.indexOf('TOP GEAR')>=0) bad.push('SIX: the old names are still on the card');
       document.getElementById('askrand').click();
       if(fired!==1||fills.join()!=='true') bad.push('SIX: RANDOM KIT on the card fired '+fired+' and filled '+fills.join());
       askKit(function(){ fired++; },true); document.getElementById('asktop').click();
       if(fired!==2||fills.join()!=='true,false') bad.push('SIX: BEST KIT on the card fired '+fired+' and filled '+fills.join());
       shut();
     }catch(x2){ bad.push('threw: '+(x2&&x2.message||x2)); }
     finally{
       try{ ascendNow=oAsc; kitFill=oFill; startRaid=oStart; }catch(_a){}
       try{ shut(); }catch(_s){}
       try{ if(snap) __applyLoaded(snap); }catch(_r){}
       try{ __topClear(); __resetCfg(); __cleanProfile(); }catch(_c){}
     }
     return bad.length?bad.slice(0,8).join('; '):null; }},
  {v:'27.19',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
