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

if ($s.Contains("  {v:'37.68',what:")) { throw "check 37.68 is in the fixture already" }

SubRx @'
  {v:'37.67',what:
'@ @'
  {v:'37.68',what:'cw-cx-prestige: only level 20, three living prestige slots, heir survives swaps and veteran death, picks kept, old and roster saves reload twice',
   run:function(){
    if(typeof pilPrestige!=='function'||typeof pilRosterTake!=='function') return 'no prestige roster';
    var saved=P,raw=JSON.stringify(P),os=storeSet,osp=saveProfile,ao=ARCADE.on,np=NETP2,st=state,bb=BIRTH,cfg={},k,bad=[],r,q,snap,a,b,i,credit,heir,gen,picks,pc;
    function J(x){return JSON.stringify(x);}
    function need(ok,msg){if(!ok)bad.push(msg);}
    function core(p){return J({c:p.credits,s:p.stash,w:p.weapons,eq:p.equipped,ct:p.contracts,fg:p.forged||{},le:p.lifeEarn,p:p.pil,h:p.hall,g:p.pilGen,gr:p.gear,wn:p.worn,ac:p.acctName});}
    function reload(){snap=JSON.parse(J(P));snap.cfg=JSON.parse(J(CFG));snap.cfgv=18;applyLoadedProfile({value:J(snap)});}
    for(k in CFG)cfg[k]=CFG[k];
    try{
      __runPrep(); __topClear(); __resetCfg(); __pinDefaults(0); __cleanProfile();
      storeSet=function(){};saveProfile=function(){};ARCADE.on=0;NETP2=false;showScreen('hub');
      P.hall=[];P.roster=[];P.pilRest=null;P.pilGen=1;P.pil=pilMake('brakka',1);P.pil.lvl=19;P.pil.raids=4;P.pil.picks=['spd','heal'];P.gear=[];P.worn={};delete P.heirs;
      credit=P.credits;need(pilPrestige()===null&&P.roster.length===0&&P.pil.lvl===19,'level 19 prestiged');
      P.pil.lvl=20;ARCADE.on=1;need(pilPrestige()===null,'demo prestiged');ARCADE.on=0;
      state='raid';need(pilPrestige()===null,'raid prestiged');state='hub';NETP2=true;need(pilPrestige()===null,'linked seat prestiged');NETP2=false;
      k=Object.keys(WORN_KINDS).filter(function(id){return WORN_KINDS[id].slots.indexOf('head')>=0;})[0];
      pc=wornAdd(P,wornMake(k,1,10,711));need(!!pc&&wornWear(P,pc.id),'no worn piece staged');
      picks=J(P.pil.picks);r=pilPrestige();
      need(r&&r.prestige===1&&r.lvl===20&&J(r.picks)===picks&&P.roster[0]===r&&!P.pil&&P.hall.length===0,'prestige changed the level, picks or hall');
      need(pilName(r).indexOf('\u2605')>=0&&P.credits===credit,'star missing or prestige paid cash');
      need(Object.keys(P.worn).length===0&&P.gear.filter(function(g){return g.id===pc.id;}).length===1,'prestige lost or doubled worn gear');
      need(birthNeed()&&P.heirs.length===3,'no new heir choice');
      birthFinish(false);heir=P.pil;gen=heir.gen;need(gen===2&&heir.lvl===1,'new heir missing');
      pilRosterTake(0);need(P.pil===r&&P.pilRest===heir&&P.roster.length===0,'take veteran lost the heir');
      state='raid';need(pilRosterTake(-1)===null&&P.pil===r,'raid swapped pillagers');state='hub';ARCADE.on=1;
      need(pilRosterTake(-1)===null&&P.pil===r,'demo swapped pillagers');ARCADE.on=0;
      q=J(P.roster);need(pilPrestige()===null&&J(P.roster)===q,'veteran prestiged twice');
      pilRosterTake(-1);need(P.pil===heir&&P.pilRest===null&&P.roster[0]===r,'bench lost either life');
      // A saved roster, including the active veteran and resting heir, survives the real loader twice.
      pilRosterTake(0);a=J({r:P.roster,h:P.pilRest,p:P.pil});
      for(i=0;i<2;i++){reload();need(J({r:P.roster,h:P.pilRest,p:P.pil})===a,'roster reload '+i+' moved a life');}
      __deploy({kit:['gun_pistol'],safe:null,mapIx:0,seed:4242});
      q=__state();need(q&&q.player&&!q.over,'no veteran raid');
      if(q&&q.player&&!q.over){
        need(q.ents.length===85&&q.containers.length===165,'seed 4242 map 0 moved: '+q.ents.length+'/'+q.containers.length);
        q.tel.kills={};q.tel.deathKiller='warden';q.tel.lastHitName=null;
        r=pilRaidEnd('dead',0,{v:0,k:[]});
        need(r&&r.prestige===0&&P.roster.length===0&&P.pil&&P.pil.gen===gen&&!P.pilRest,'death retained prestige or lost waiting heir');
      }
      try{__endRaid('extract');}catch(_end){} showScreen('hub');
      // Three total prestige lives, including the active one. A full roster never evicts anyone.
      P.roster=[];P.pilRest=null;
      for(i=0;i<3;i++){q=pilMake('veteran'+i,10+i);q.lvl=20;q.prestige=1;P.roster.push(q);}
      P.pil=pilMake('heir',20);P.pilGen=20;P.pil.lvl=20;a=J(P.roster);
      need(pilPrestige()===null&&J(P.roster)===a&&P.pil.name==='heir','full roster evicted a life');
      pilRosterTake(0);need(pilRosterCount()===3&&P.roster.length===2,'active veteran is not counted');
      pilRosterTake(-1);openOps('hall');need(document.querySelectorAll('#hallprestige [data-proster]').length===3&&document.getElementById('hallprestigego').disabled,'roster controls missing');
      // Old save shape: remove only the new fields, retain stash, guns, contracts, forged guns and lineage through two loads.
      delete P.roster;delete P.pilRest;delete P.mig8p;
      a=core(P);reload();need(core(P)===a&&P.mig8p===1&&P.roster.length===0&&!P.pilRest,'old save reload lost account content');
      a=core(P);reload();need(core(P)===a&&P.roster.length===0,'second old save load moved account content');
      __pinDefaults(1);__deploy({kit:[],safe:null,mapIx:1,seed:4242});q=__state();
      need(q.ents.length===374&&q.containers.length===593,'seed 4242 map 1 moved: '+q.ents.length+'/'+q.containers.length);
    }catch(e){bad.push('threw: '+(e&&e.message||e));}
    finally{
      try{if(state==='raid')__endRaid('extract');}catch(_e){}
      try{__topClear();}catch(_c){}
      P=saved;(function(){var s=JSON.parse(raw),n;for(n in P)delete P[n];for(n in s)P[n]=s[n];})();
      storeSet=os;saveProfile=osp;ARCADE.on=ao;NETP2=np;state=st;BIRTH=bb;for(k in cfg)CFG[k]=cfg[k];
    }
    return bad.length?bad.join('; '):null;
   }},
  {v:'37.67',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
