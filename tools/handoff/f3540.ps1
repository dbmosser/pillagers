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

if ($s.Contains("  {v:'35.40',what:")) { throw "check 35.40 is in the fixture already" }

SubRx @'
  {v:'35.39',what:
'@ @'
  {v:'35.40',what:'NO WHITE BARS: the cream rank pips are gone from the raid belt, hand, wheel, backpack, drag ghost, stash, hotbar, pre-raid belt, kit setup, crate, codex, extracted card and KIA card; the loot rows keep them (his order 10-27)',
   run:function(){
     var bad=[], pips=0, rp0=rarityPips, g=null, p=null, its, html, cv, oc, i;
     function cold(){ _iconURL={}; ICONSPR.m={}; ICONSPR.n=0; pips=0; }
     function none(where){ if(pips>0) bad.push(where+' paints '+pips+' rank pips'); }
     try{
       __topClear(); __runPrep(); __pinDPR(1); __forceSize(1920,1080); __resetCfg(); __pinDefaults(0); __cleanProfile();
       rarityPips=function(){ pips++; return 0; };
       // (1) the raid: belt and the item in hand, the backpack with an item on the mouse, the item wheel
       __deploy({kit:['bandage','medkit','plate','gun_rifle','gun_shotgun'],safe:null,mapIx:0,seed:4242});
       g=__state();
       if(!g||!g.player) bad.push('staging: no raid');
       else {
         p=g.player; g.ents.length=0; p.iv=99;
         p.hand={k:'medkit',t:0.2,len:1,armed:0,used:0,prev:false};
         cold(); __frame(); __frame(); none('the raid belt and the item in hand');
         p.hand=null; g.bagOpen=true; g.drag={key:'plate',bagIx:0}; mouse.x=W/2; mouse.y=H/2;
         cold(); __frame(); __frame(); none('the raid backpack and the item on the mouse');
         g.drag=null; g.bagOpen=false;
         g.bag=['bandage','medkit','stim','plate']; g.pouch.frag=2; g.pouch.smoke=1; p.hand=null; g.wheel=null;
         mouse.x=W/2; mouse.y=H/2; keys['KeyQ']=true; raidKey('KeyQ',false,null);
         if(!g.wheel) bad.push('staging: the item wheel did not open');
         cold(); __frame(); __frame(); none('the item wheel');
         keys['KeyQ']=false; try{ wheelRelease(); }catch(_w){}
         // control: the pickup stack is a loot row and stays exactly as it was
         g.wheel=null; g.pick=[]; pickSay('bandage',{item:'bandage'}); for(i=0;i<g.pick.length;i++) g.pick[i].at=(g.t||0)-1;
         cold(); __frame(); __frame();
         if(pips<1) bad.push('control: the pickup stack no longer paints rank pips (it stays as it was)');
         __endRaid('abandon'); __topClear();
       }
       // (2) the Undercroft: backpack, floor belt, stash, hotbar row, kit setup, pre-raid pack and belt, crate, codex
       __cleanProfile(); __hubEnter();
       P.kit=['gun_rifle','gun_shotgun','medkit','plate']; P.hotAssign={4:'gun_shotgun',5:'medkit'};
       P.stash.push('medkit','medkit','bandage','plate','frag','frag','gun_rifle','gun_smg','core','smoke'); saveProfile();
       hubBagOpenSet(true); cold(); drawHubBag(); drawHubBag(); none('the Undercroft backpack and belt'); hubBagOpenSet(false);
       cold(); __hubFrame(); __hubFrame(); none('the Undercroft floor belt');
       cold(); renderHub(); none('the stash grid, hotbar row and kit setup');
       cold(); html=hotPlanHTML(); none('the stash hotbar row');
       P.kitPick='mine'; renderSector(); openModal('sectormodal');
       cold(); html=hotPlanHTML('sector'); renderSector(); syncSectorKit(); none('the pre-raid belt and pack');
       try{ var sm=document.getElementById('sectormodal'); if(sm) sm.classList.remove('on'); }catch(_s){}
       cold(); try{ renderCrate(); }catch(_c1){} none('the crate lists');
       cold(); try{ renderCodex(); }catch(_c2){} none('the codex');
       // (3) the extracted card and the KIA card
       __deploy({kit:[],safe:null,mapIx:0,seed:4242}); g=__state(); g.bag.push('medkit','plate','bandage','gun_rifle','core');
       cold(); __endRaid('extract'); its=document.querySelectorAll('#outcome .haulit img.ic');
       if(its.length<2) bad.push('staging: the extracted card shows '+its.length+' item pictures');
       none('the extracted card'); __topClear();
       __deploy({kit:[],safe:null,mapIx:0,seed:4242}); g=__state(); g.bag.push('medkit','plate','bandage','gun_rifle','gun_smg','core','frag','smoke');
       cold(); __endRaid('dead'); its=document.querySelectorAll('#outcome img.ic');
       if(its.length<1) bad.push('staging: the KIA card shows no item pictures');
       none('the KIA card'); __topClear();
       // (4) the two draws that need a stall or a welcome list are read from their code
       if(/drawItemIcon\(ctx,S\.k/.test(String(drawTrade))) bad.push('the stall stock icons still paint rank pips');
       if(/else drawItemIcon\(_wx/.test(String(maybeWelcome))) bad.push('the welcome list still paints rank pips');
       // control: the loot name pop (drawItemIcon, wc) and the plain menu painter keep the pips
       cold(); cv=document.createElement('canvas'); cv.width=64; cv.height=64; drawItemIcon(cv.getContext('2d'),'medkit',32,32,40);
       if(pips<1) bad.push('control: drawItemIcon no longer paints rank pips (the loot rows use it)');
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{
       try{ rarityPips=rp0; }catch(_rp){}
       try{ keys['KeyQ']=false; }catch(_k){}
       try{ hubBagOpenSet(false); }catch(_hb){}
       try{ var sm2=document.getElementById('sectormodal'); if(sm2) sm2.classList.remove('on'); }catch(_s2){}
       try{ if(state==='raid'&&G&&!G.over) __endRaid('abandon'); }catch(_e){}
       try{ __topClear(); __cleanProfile(); }catch(_c){}
     }
     return bad.length?bad.join('; '):null; }},
  {v:'35.39',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
