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

if ($s.Contains("  {v:'37.35',what:")) { throw "check 37.35 is in the fixture already" }

SubRx @'
  {v:'37.34',what:
'@ @'
  {v:'37.35',what:'cw-m2birth2: the birth card footer has its key and pad hints; the figure canvas holds the whole body; the pad letter picker works on the name box and its name goes on the default button; with a paid kit the map page tile and the line under the kit row both name that kit and neither says freebie; with no paid kit the tile says freebie again',
   run:function(){
     if(!(window.__runPrep&&window.__resetCfg&&window.__pinDefaults&&window.__cleanProfile&&window.__deploy&&window.__endRaid&&window.__state)) return 'SKIP: this fixture cannot stage';
     if(typeof birthOpen!=='function'||typeof padNameStart!=='function') return 'no birth card in this build';
     if(typeof kitInfoOf!=='function') return 'no one source for the kit words (kitInfoOf)';
     var saved=P, cfg={}, k, oldStore=storeSet, oldSave=saveProfile, bad=[], q, el, st, sum;
     function need(ok,msg){ if(!ok) bad.push(msg); }
     function E(id){ return document.getElementById(id); }
     for(k in CFG) cfg[k]=CFG[k];
     try{
       __runPrep(); __topClear(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       storeSet=function(){}; saveProfile=function(){};
       P.cond='day'; P.terms=[]; P.merc=''; CFG.safeSlots=0; P.pilNote=null; P.credits=2000; P.birthKit=null; P.freeKit=0; P.kitPick='mine'; BIRTH=null;
       __deploy({kit:[],safe:null,mapIx:0,seed:4242}); q=__state(); q.bag=[]; q.carriedIn=0; q.carriedKit=[]; q.issuedBandages=0; q.pedCarry=0; q.pedSold=0; q.strayPaid=0; q.goalRewards=null; q.player.downed=false; q.player.hp=100; q.ents.length=0; q.player.iv=99; q.tel.kills={}; q.tel.deathKiller='warden'; q.tel.lastHitName=null;
       __endRaid('dead');
       showScreen('hub');
       need(E('birthmodal').classList.contains('on'),'the card did not open');
       el=E('birthhints');
       need(el&&el.querySelectorAll('.bk').length===3&&el.querySelectorAll('.bp').length===2,'the footer hints are '+(el?el.innerHTML:'missing'));
       need(E('birthcv').height>=330&&E('birthcv').width>=280,'the figure canvas is '+E('birthcv').width+'x'+E('birthcv').height);
       // the pad letter picker on the name box
       need(padNameStart(E('birthname'))===true&&PADNAME&&PADNAME.input===E('birthname'),'the pad letter picker did not open on the name box');
       if(PADNAME){
         padNamePoll(function(){ return false; });
         need(!!PADNAME,'the pad letter picker shut itself over the birth card');
         if(PADNAME){ PADNAME.l=('vosk'+'                ').slice(0,16).split(''); padNameClose(true); }
       }
       need(birthState().name==='vosk'&&E('birthgo').textContent.indexOf('ascend as vosk')===0,'the picked name did not reach the card: '+JSON.stringify(birthState())+' '+E('birthgo').textContent);
       padSetFocus(null); PAD.focus=null;
       // the kit's words on the map page
       document.querySelector('#birthkits [data-bkit="basic"]').click();
       E('birthgo').click();
       need(E('sectormodal').classList.contains('on'),'the default button did not end on the map page');
       st=document.querySelector('#sectorkitpick .kitb[data-kit="free"]');
       need(st&&st.querySelectorAll('span')[0].textContent==='basic kit'&&st.querySelectorAll('span')[1].textContent.indexOf('3 bandages')>=0,'the kit tile reads '+(st?st.textContent:'nothing'));
       sum=document.querySelector('#sectormodal .srsum');
       need(sum&&sum.textContent.indexOf('basic kit')>=0&&!/freebie/i.test(sum.textContent),'the line under the kit row reads '+(sum?JSON.stringify(sum.textContent):'nothing'));
       // no paid kit: the freebie has its own words back
       P.birthKit=null; syncSectorKitPick();
       need(/freebie/i.test(st.querySelectorAll('span')[0].textContent),'with no paid kit the tile reads '+st.textContent);
     }catch(e2){ bad.push('threw: '+(e2&&e2.message||e2)); }
     finally{
       try{ if(PADNAME) padNameClose(false); }catch(_pn){}
       try{ q=__state(); if(q&&!q.over){ q.player.downed=false; q.tel.shots=0; __endRaid('abandon'); } }catch(_e){}
       try{ E('birthmodal').classList.remove('on'); E('sectormodal').classList.remove('on'); }catch(_m){}
       BIRTH=null;
       P=saved; storeSet=oldStore; saveProfile=oldSave;
       for(k in CFG) if(!(k in cfg)) delete CFG[k]; for(k in cfg) CFG[k]=cfg[k];
       try{ __topClear(); __cleanProfile(); }catch(_c){}
     }
     return bad.length?bad.join('; '):null; }},
  {v:'37.34',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
