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

if ($s.Contains("  {v:'32.46',what:")) { throw "check 32.46 is in the fixture already" }

SubRx @'
  {v:'32.45',what:
'@ @'
  {v:'32.46',what:'the pre-raid page is design A, map first (his pick 2026-10-19): an ice blue map at least 800 px wide at 1080p drawn from the real map, one A press ascends with fresh pad focus, LB and RB jump between the conditions, the kit tiles and the pack, no cash control, every old control is still there, and the ascend plate stays on the card with the biggest pack a save can hold',
   run:function(){
     if(!(window.__hubEnter&&window.__P&&window.__applyLoaded)) return 'SKIP: this fixture cannot reach the pre-raid page';
     if(typeof renderSector!=='function'||typeof openModal!=='function') return 'SKIP: no pre-raid page';
     var bad=[], snap=null, q, sm=document.getElementById('sectormodal'), went=0, oAsc=ascendNow, oStart=startRaid, oKF=kitFill, cv, r, px, i, k, rr, dep, lastPan, seq, pans;
     function shut(){ var mo=document.querySelectorAll('.modal.on'); for(var j=0;j<mo.length;j++) mo[j].classList.remove('on'); }
     function pad(btn){ var f=function(n){ return n===btn; }; padMenu(f); }
     function rel(){ padMenu(function(){ return false; }); }
     try{
       snap=JSON.parse(JSON.stringify(__P()));
       __topClear(); __runPrep(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       try{ __pinDPR(1); __forceSize(1920,1080); }catch(_fs){}
       q=__P(); q.freeKit=0; q.kitPick='mine'; q.cond='day'; q.wxPick='any';
       q.stash=['medkit','bandage','bandage','smoke','frag','frag','ammobox','core']; q.kit=[];
       __hubEnter(); shut();
       ascendNow=function(){ went++; return true; }; startRaid=function(){}; kitFill=function(){ return {gun:null,kit:[]}; };
       renderSector(); openModal('sectormodal');
       // ONE: the map is wide, ice blue, and drawn from the real map
       cv=document.querySelector('#sectorlist canvas.secprev');
       if(!cv) return 'the pre-raid page has no map canvas';
       r=cv.getBoundingClientRect(); k=Math.min(r.width,r.height*cv.width/cv.height); i=800*Math.min(innerWidth/1920,innerHeight/1080);
       if(k<i) bad.push('ONE: the map shows '+Math.round(k)+' px wide, under '+Math.round(i)+' (800 at 1080p) ['+innerWidth+'x'+innerHeight+' cell '+Math.round(r.width)+'x'+Math.round(r.height)+' kit '+Math.round(document.getElementById('srkitcol').getBoundingClientRect().height)+' side '+Math.round(document.getElementById('srside').getBoundingClientRect().height)+' scale '+((typeof menuScale==='function')?menuScale():'?')+']');
       try{ px=cv.getContext('2d').getImageData(Math.round(cv.width*0.01)+3,Math.round(cv.height*0.01)+3,1,1).data; }catch(_gi){ px=null; }
       if(!px) bad.push('ONE: the map canvas cannot be read');
       else if(!(px[0]<40&&px[2]>px[0]+20)) bad.push('ONE: the map ground is rgb('+px[0]+','+px[1]+','+px[2]+'), not ice blue');
       if(sm.textContent.indexOf('5 zones')<0||sm.textContent.indexOf('2 keyed rooms')<0||sm.textContent.indexOf('3 exits')<0) bad.push('ONE: the stats line does not read 5 zones, 2 keyed rooms, 3 exits');
       if(/test robot|hectare/i.test(sm.textContent)) bad.push('ONE: the test robot or hectares line is still on the page');
       // TWO: nothing the old page offered is gone, and there is no cash control
       if(!document.getElementById('condday')||!document.getElementById('condnight')||document.querySelectorAll('#sectorwx .wxb').length!==6) bad.push('TWO: surface or weather buttons are missing');
       if(document.querySelectorAll('#sectorkitpick .kitb').length!==4) bad.push('TWO: the four kit tiles are not all there');
       if(!sm.querySelector('[data-pa="all"]')||!sm.querySelector('[data-pa="none"]')||!sm.querySelector('[data-core]')) bad.push('TWO: pack all, clear or the data core slot is missing');
       if(!sm.querySelector('[data-pk="medkit"] [data-pd="1"]')||!sm.querySelector('[data-pk="medkit"] [data-pd="-1"]')) bad.push('TWO: a pack row has no stepper');
       if(!document.getElementById('sectordeploy')||!document.getElementById('closesector')||!document.getElementById('srhints')) bad.push('TWO: the ascend plate, close or the hint strip is missing');
       if(sm.querySelector('[data-pk="cash"],.cash,[data-cash]')||/\bcash\b/i.test(sm.textContent)) bad.push('TWO: the page has a cash control');
       // THREE: LB and RB walk the panels, from a fresh focus on ascend
       PAD.focus=null; padSetFocus(null); PAD.prev=[];
       rel();
       dep=document.getElementById('sectordeploy');
       if(PAD.focus!==dep) bad.push('THREE: pad focus does not open on ascend');
       seq=[]; pans=[];
       pad(5); seq.push(srPan(PAD.focus)); rel(); pad(5); seq.push(srPan(PAD.focus)); rel(); pad(5); seq.push(srPan(PAD.focus)); rel(); pad(5); seq.push(srPan(PAD.focus)); rel(); pad(4); seq.push(srPan(PAD.focus)); rel();
       if(seq.join('')!=='ckpcp') bad.push('THREE: RB RB RB RB LB landed on panels '+seq.join(',')+', not c,k,p,c then back to p');
       // FOUR: one A press from fresh focus ascends
       PAD.focus=null; padSetFocus(null); PAD.prev=[]; went=0;
       rel(); pad(0);
       if(went!==1) bad.push('FOUR: one A press on a fresh pre-raid page ascended '+went+' times');
       // FIVE: the ascend plate stays on the card with the biggest pack a save can hold
       shut(); q.stash=[]; q.kit=[];
       for(k in ITEMS){ if(ITEMS[k]&&ITEMS[k].use) q.stash.push(k); }
       for(i=0;i<3;i++) q.stash.push('bandage');
       q.kitPick='mine'; renderSector(); openModal('sectormodal');
       rr=sm.getBoundingClientRect(); dep=document.getElementById('sectordeploy'); r=dep.getBoundingClientRect();
       if(!(r.bottom<=rr.bottom+0.5&&r.top>=rr.top-0.5)) bad.push('FIVE: with '+q.stash.length+' items the ascend plate sits at '+Math.round(r.top)+' to '+Math.round(r.bottom)+' on a card that ends at '+Math.round(rr.bottom));
       i=document.querySelector('#sectorpack .srplist');
       if(!i||!(i.scrollHeight>i.clientHeight+4)) bad.push('FIVE: the long pack does not scroll inside its own list');
       if(document.getElementById('srkitcol').getBoundingClientRect().bottom>rr.bottom+0.5) bad.push('FIVE: the kit column spills off the card');
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{
       ascendNow=oAsc; startRaid=oStart; kitFill=oKF;
       try{ shut(); }catch(_s){}
       try{ PAD.focus=null; padSetFocus(null); PAD.prev=[]; }catch(_p){}
       try{ if(snap&&window.__applyLoaded) __applyLoaded(snap); }catch(_a){}
       try{ __cleanProfile(); }catch(_e){}
       __topClear();
     }
     return bad.length?bad.join('; '):null; }},
  {v:'32.45',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
