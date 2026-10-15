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

if ($s.Contains("  {v:'27.08',what:")) { throw "check 27.08 is in the fixture already" }

SubRx @'
  {v:'27.07',what:
'@ @'
  {v:'27.08',what:'career7, his yes to the haul reveal (36): the extraction card strip starts hidden and comes up one picture at a time, the cheapest first, each with its rarity flash and pick sound under a running HAUL line that ends on the secured figure, and a click on the card (which ESC, ENTER and a pad A press) skips it without leaving the card; a death has no strip and a single picture shows at once',
   run:function(){
     if(!(window.__deploy&&window.__state&&window.__runPrep&&window.__endRaid&&window.__P&&window.__applyLoaded)) return 'SKIP: this fixture cannot deploy';
     if(typeof haulRevealStart!=='function') return 'there is no haul reveal in this build';
     var bad=[], snap=null, g=null, p=null, its, i, vals, seen, prev, sounds=[], oS=sfx, tot, last, hid, btn, oc, first, before, ws, q2;
     function stripItems(){ return document.querySelectorAll('#oc_manifest .haulstrip .haulit'); }
     function hidN(){ return document.querySelectorAll('#oc_manifest .haulstrip .haulit.hid').length; }
     function raid(bag){
       __topClear(); __runPrep(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       g=__state(); if(!g||g.over) return false;
       p=g.player; p.iv=99; p.hp=100; p.downed=false;
       g.bag=bag.slice();
       return true;
     }
     try{
       snap=JSON.parse(JSON.stringify(__P()));
       sfx=function(t){ sounds.push(t); };
       // ONE: an extraction with several things in the bag starts the reveal
       if(!raid(['scrap','board','optic','servo','core','medkit'])) return 'SKIP: no live raid';
       __endRaid('extract');
       its=stripItems();
       if(its.length<5) bad.push('ONE: the strip holds '+its.length+' pictures');
       if(hidN()!==its.length) bad.push('ONE: '+hidN()+' of '+its.length+' pictures are hidden at the start');
       if(!haulRevealing()) bad.push('ONE: no reveal is running');
       if(!document.getElementById('haultot')) bad.push('ONE: no HAUL line under the strip');
       // TWO: one at a time, cheapest first, each with a flash and a sound
       vals=[]; seen={}; sounds.length=0; last=hidN();
       for(i=0;i<80&&haulRevealing();i++){
         haulRevealTick(0.05);
         if(hidN()<last){
           Array.prototype.forEach.call(stripItems(),function(nd,ix){ if(!nd.classList.contains('hid')&&!seen[ix]){ seen[ix]=1; vals.push(+nd.getAttribute('data-v')); if(!nd.classList.contains('pop')) bad.push('TWO: a revealed picture has no flash'); if(!nd.style.getPropertyValue('--hc')) bad.push('TWO: a revealed picture has no flash colour'); } });
           if(last-hidN()>2) bad.push('TWO: '+(last-hidN())+' pictures came up in one step');
           last=hidN();
         }
       }
       if(vals.length!==its.length) bad.push('TWO: '+vals.length+' of '+its.length+' pictures came up');
       for(i=1;i<vals.length;i++) if(vals[i]<vals[i-1]){ bad.push('TWO: the reveal is not cheapest first ('+vals.join(',')+')'); break; }
       if(sounds.length!==its.length) bad.push('TWO: '+sounds.length+' sounds for '+its.length+' pictures');
       tot=(document.getElementById('haultot')||{}).textContent||'';
       if(tot.indexOf('HAUL')!==0||tot.indexOf('$')<0) bad.push('TWO: the HAUL line reads "'+tot+'"');
       oc=document.getElementById('oc_manifest'); ws=(oc.querySelector('.haulstrip')||{getAttribute:function(){return '0';}}).getAttribute('data-sec');
       if(tot.replace(/[^0-9]/g,'')!==String(Math.round(+ws))) bad.push('TWO: the HAUL line ends on "'+tot+'", not the secured '+ws);
       // THREE: the skip fills the strip in and does not leave the card
       if(!raid(['scrap','board','optic','servo','core','medkit'])) return 'SKIP: no second raid';
       __endRaid('extract');
       if(!haulRevealing()) bad.push('THREE: no reveal is running on the second card');
       sounds.length=0; haulRevealTick(0.4);
       if(haulRevealSkip()!==true) bad.push('THREE: the skip reported nothing to skip');
       if(haulRevealing()) bad.push('THREE: the skip did not end the reveal');
       if(hidN()!==0) bad.push('THREE: '+hidN()+' pictures still hidden after the skip');
       if(!document.getElementById('outcome').classList.contains('on')) bad.push('THREE: the skip closed the card');
       tot=(document.getElementById('haultot')||{}).textContent||'';
       if(tot.replace(/[^0-9]/g,'')!==String(Math.round(+((document.querySelector('#oc_manifest .haulstrip')||{getAttribute:function(){return '0';}}).getAttribute('data-sec'))))) bad.push('THREE: the skipped HAUL line reads "'+tot+'"');
       if(haulRevealSkip()!==false) bad.push('THREE: a second skip claimed to skip');
       // FOUR: ESC skips it and does not leave the card
       if(!raid(['scrap','board','optic','servo','core','medkit'])) return 'SKIP: no third raid';
       __endRaid('extract');
       document.body.dispatchEvent(new KeyboardEvent('keydown',{code:'Escape',key:'Escape',bubbles:true}));
       if(haulRevealing()) bad.push('FOUR: ESC did not skip the reveal');
       if(hidN()!==0) bad.push('FOUR: '+hidN()+' pictures still hidden after ESC');
       if(haulRevealing()) bad.push('FOUR: ESC did not skip the reveal');
       // FIVE: a single picture shows at once, and a death has no strip
       if(!raid(['core'])) return 'SKIP: no fourth raid';
       __endRaid('extract');
       if(haulRevealing()) bad.push('FIVE: a single picture started a reveal');
       if(stripItems().length&&hidN()) bad.push('FIVE: a single picture was hidden');
       if(!raid(['scrap','board','optic'])) return 'SKIP: no fifth raid';
       __endRaid('dead');
       if(stripItems().length) bad.push('FIVE: a death card has a haul strip');
       if(haulRevealing()) bad.push('FIVE: a death started a reveal');
       // SIX: the card calls the reveal and the loop ticks it
       ws=[].slice.call(document.scripts).map(function(s){ return s.text||''; }).join('\n');
       if(ws.indexOf('haulRevealStart'+'(); }catch')<0) bad.push('SIX: the extraction card never starts the reveal');
       if(ws.indexOf('haulRevealTick'+'(d); }catch')<0) bad.push('SIX: nothing ticks the reveal');
       if(ws.indexOf('ev.isTrusted'+'&&haulRevealing()')<0) bad.push('SIX: a real click on the card never skips');
       if(ws.indexOf('if(haulRevealSkip'+'()) return; document.getElementById')<0) bad.push('SIX: ESC does not skip first');
       q2=0; ws.split("md.id==='outcome'"+'&&haulRevealSkip()').forEach(function(){ q2++; });
       if(q2-1<2) bad.push('SIX: the controller A and B do not both skip first ('+(q2-1)+')');
     }catch(x2){ bad.push('threw: '+(x2&&x2.message||x2)); }
     finally{
       try{ sfx=oS; }catch(_s){}
       try{ HAUL_REV=null; }catch(_h){}
       try{ var g2=__state(); if(g2&&!g2.over) __endRaid('abandon'); }catch(_e){}
       try{ keys={}; }catch(_k){}
       try{ if(snap) __applyLoaded(snap); }catch(_r){}
       try{ __topClear(); __resetCfg(); __cleanProfile(); }catch(_c){}
     }
     return bad.length?bad.slice(0,8).join('; '):null; }},
  {v:'27.07',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
